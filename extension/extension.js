// Codex Agents Kit — VS Code Extension
// Run Codex CLI commands from the Command Palette and context menus.

const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

/**
 * Find the workspace root where Codex CLI Ultimate is installed.
 * Walks up from the workspace folder looking for bin/codex.ps1 or bin/codex.
 */
function findCodexRoot() {
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) return null;

    // Check all workspace folders (supports multi-root workspaces)
    for (const folder of workspaceFolders) {
        const root = folder.uri.fsPath;
        if (fs.existsSync(path.join(root, 'bin', 'codex.ps1'))) {
            return root;
        }
        // Search parent directories for the bin/codex.ps1 marker
        let dir = root;
        while (dir !== path.parse(dir).root) {
            if (fs.existsSync(path.join(dir, 'bin', 'codex.ps1'))) {
                return dir;
            }
            dir = path.dirname(dir);
        }
    }
    // Fallback to user home .codex directory
    const homeDir = process.env.USERPROFILE || process.env.HOME;
    if (homeDir && fs.existsSync(path.join(homeDir, '.codex', 'config.toml'))) {
        return path.join(homeDir, '.codex');
    }
    return null;
}

/**
 * Reuse or create a terminal by name to avoid orphan instances.
 * Escapes all arguments to prevent shell injection.
 */
function runInTerminal(command, name) {
    const terminalName = `Codex: ${name}`;
    // Reuse existing terminal with the same name instead of creating new ones
    let terminal = vscode.window.terminals.find(t => t.name === terminalName);
    if (!terminal) {
        terminal = vscode.window.createTerminal({ name: terminalName });
    }
    terminal.show();
    terminal.sendText(command);
}

/**
 * Escape shell arguments to prevent injection.
 * Windows PowerShell uses backtick escaping; POSIX uses single quotes.
 */
function shellEscape(arg, isWindows) {
    if (isWindows) {
        // PowerShell backtick escaping for embedded quotes
        return '"' + String(arg).replace(/[`"$]/g, '`$&') + '"';
    }
    // POSIX: single quotes — break out, insert escaped quote, resume
    const s = String(arg);
    if (s.indexOf("'") === -1) return "'" + s + "'";
    return "'" + s.replace(/'/g, "'\\''") + "'";
}

/**
 * Show a quick pick menu and prompt for input.
 */
async function promptForInput(placeholder) {
    return await vscode.window.showInputBox({ placeHolder: placeholder });
}

/**
 * Activate the extension.
 */
function activate(context) {
    const codexRoot = findCodexRoot();
    if (!codexRoot) {
        vscode.window.showWarningMessage(
            'Codex Agents Kit not found. Open a folder inside the codex-agents-kit project.'
        );
        return;
    }

    const isWindows = process.platform === 'win32';
    const scriptExt = isWindows ? '.ps1' : '.sh';
    const shellCmd = isWindows ? 'powershell' : 'bash';

    // ── Register Commands ──────────────────────────────────────

    const doctorCmd = vscode.commands.registerCommand('codex-agents-kit.doctor', () => {
        const script = path.join(codexRoot, 'scripts', `doctor${scriptExt}`);
        runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}"`, 'doctor');
    });

    const profileCmd = vscode.commands.registerCommand('codex-agents-kit.profile', async () => {
        const profiles = ['free', 'premium', 'local', 'ollama', 'openrouter'];
        const selected = await vscode.window.showQuickPick(profiles, {
            placeHolder: 'Select a Codex profile to switch to'
        });
        if (selected) {
            const script = path.join(codexRoot, 'scripts', `switch-profile${scriptExt}`);
            runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}" ${shellEscape(selected, isWindows)}`, `profile: ${selected}`);
        }
    });

    const benchmarkCmd = vscode.commands.registerCommand('codex-agents-kit.benchmark', () => {
        const script = path.join(codexRoot, 'scripts', `benchmark${scriptExt}`);
        runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}"`, 'benchmark');
    });

    const initCmd = vscode.commands.registerCommand('codex-agents-kit.init', async () => {
        const name = await promptForInput('Project name');
        if (name) {
            const templates = ['basic', 'aspnet', 'flutter'];
            const template = await vscode.window.showQuickPick(templates, {
                placeHolder: 'Select a template (optional)'
            });
            const script = path.join(codexRoot, 'scripts', `init-project${scriptExt}`);
            const args = template
                ? `${shellEscape(name, isWindows)} ${shellEscape(template, isWindows)}`
                : shellEscape(name, isWindows);
            runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}" ${args}`, `init: ${name}`);
        }
    });

    const agentCmd = vscode.commands.registerCommand('codex-agents-kit.agent', async () => {
        const agents = ['architect', 'backend', 'frontend', 'devops', 'reviewer', 'debugger', 'tester'];
        const selected = await vscode.window.showQuickPick(agents, {
            placeHolder: 'Select an agent to load'
        });
        if (selected) {
            const script = path.join(codexRoot, 'scripts', `load-agent${scriptExt}`);
            runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}" ${shellEscape(selected, isWindows)}`, `agent: ${selected}`);
        }
    });

    const updateCmd = vscode.commands.registerCommand('codex-agents-kit.update', () => {
        const script = path.join(codexRoot, 'scripts', `update${scriptExt}`);
        runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}"`, 'update');
    });

    context.subscriptions.push(doctorCmd, profileCmd, benchmarkCmd, initCmd, agentCmd, updateCmd);
}

function deactivate() {}

module.exports = { activate, deactivate };
