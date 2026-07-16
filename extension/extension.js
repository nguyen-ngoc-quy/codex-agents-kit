// Codex CLI Ultimate — VS Code Extension
// Run Codex CLI commands from the Command Palette and context menus.

const vscode = require('vscode');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Find the workspace root where Codex CLI Ultimate is installed.
 * Walks up from the workspace folder looking for bin/codex.ps1 or bin/codex.
 */
function findCodexRoot() {
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) return null;

    const root = workspaceFolders[0].uri.fsPath;
    // Check if we're in the codex-cli-ultimate repo
    if (require('fs').existsSync(path.join(root, 'bin', 'codex.ps1'))) {
        return root;
    }
    // Search parent directories for the bin/codex.ps1 marker
    let dir = root;
    while (dir !== path.parse(dir).root) {
        if (require('fs').existsSync(path.join(dir, 'bin', 'codex.ps1'))) {
            return dir;
        }
        dir = path.dirname(dir);
    }
    // Fallback to user home .codex directory
    const homeDir = process.env.USERPROFILE || process.env.HOME;
    if (homeDir && require('fs').existsSync(path.join(homeDir, '.codex', 'config.toml'))) {
        return homeDir;
    }
    return null;
}

/**
 * Run a Codex script in the terminal.
 */
function runInTerminal(command, name) {
    const terminal = vscode.window.createTerminal({ name: `Codex: ${name}` });
    terminal.show();
    terminal.sendText(command);
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
            'Codex CLI Ultimate not found. Open a folder inside the codex-cli-ultimate project.'
        );
        return;
    }

    const isWindows = process.platform === 'win32';
    const scriptExt = isWindows ? '.ps1' : '.sh';
    const shellCmd = isWindows ? 'powershell' : 'bash';

    // ── Register Commands ──────────────────────────────────────

    const doctorCmd = vscode.commands.registerCommand('codex-cli-ultimate.doctor', () => {
        const script = path.join(codexRoot, 'scripts', `doctor${scriptExt}`);
        runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}"`, 'doctor');
    });

    const profileCmd = vscode.commands.registerCommand('codex-cli-ultimate.profile', async () => {
        const profiles = ['free', 'premium', 'local', 'ollama', 'openrouter'];
        const selected = await vscode.window.showQuickPick(profiles, {
            placeHolder: 'Select a Codex profile to switch to'
        });
        if (selected) {
            const script = path.join(codexRoot, 'scripts', `switch-profile${scriptExt}`);
            runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}" ${selected}`, `profile: ${selected}`);
        }
    });

    const benchmarkCmd = vscode.commands.registerCommand('codex-cli-ultimate.benchmark', () => {
        const script = path.join(codexRoot, 'scripts', `benchmark${scriptExt}`);
        runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}"`, 'benchmark');
    });

    const initCmd = vscode.commands.registerCommand('codex-cli-ultimate.init', async () => {
        const name = await promptForInput('Project name');
        if (name) {
            const templates = ['basic', 'aspnet', 'flutter'];
            const template = await vscode.window.showQuickPick(templates, {
                placeHolder: 'Select a template (optional)'
            });
            const script = path.join(codexRoot, 'scripts', `init-project${scriptExt}`);
            const args = template ? `${name} ${template}` : name;
            runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}" ${args}`, `init: ${name}`);
        }
    });

    const agentCmd = vscode.commands.registerCommand('codex-cli-ultimate.agent', async () => {
        const agents = ['architect', 'backend', 'frontend', 'devops', 'reviewer', 'debugger', 'tester'];
        const selected = await vscode.window.showQuickPick(agents, {
            placeHolder: 'Select an agent to load'
        });
        if (selected) {
            const script = path.join(codexRoot, 'scripts', `load-agent${scriptExt}`);
            runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}" ${selected}`, `agent: ${selected}`);
        }
    });

    const updateCmd = vscode.commands.registerCommand('codex-cli-ultimate.update', () => {
        const script = path.join(codexRoot, 'scripts', `update${scriptExt}`);
        runInTerminal(`cd "${codexRoot}" && ${shellCmd} "${script}"`, 'update');
    });

    context.subscriptions.push(doctorCmd, profileCmd, benchmarkCmd, initCmd, agentCmd, updateCmd);
}

function deactivate() {}

module.exports = { activate, deactivate };
