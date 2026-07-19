/**
 * MCP routes — check status of MCP servers defined in the active config.
 */
const fs = require('fs');
const path = require('path');
const { execFile } = require('child_process');
const toml = require('@iarna/toml');

/**
 * MCP server definitions (from mcp/*.json).
 */
const MCP_DEFINITIONS = {
  filesystem: {
    name: 'Filesystem',
    description: 'View, read, search and write files in the local filesystem',
    package: '@modelcontextprotocol/server-filesystem',
  },
  git: {
    name: 'Git',
    description: 'Perform git actions (diff, log, status, commit, branch, blame)',
    package: '@cyanheads/git-mcp-server',
  },
  github: {
    name: 'GitHub',
    description: 'Manage issues, review PRs, and search GitHub repositories',
    package: '@modelcontextprotocol/server-github',
  },
  docker: {
    name: 'Docker',
    description: 'Control Docker containers, view logs, inspect images, manage networks',
    package: '@hypnosis/docker-mcp-server',
  },
  playwright: {
    name: 'Playwright',
    description: 'Open web browsers, navigate pages, click buttons, input text, capture screenshots',
    package: '@playwright/mcp',
  },
  context7: {
    name: 'Context7',
    description: 'Fetch the latest framework documentation (ASP.NET, Flutter, Unity)',
    package: '@upstash/context7-mcp',
  },
};

/**
 * Check if an npm package is installed globally (non-blocking).
 * Only checks global installs — avoids expensive npm pack --dry-run calls.
 */
function checkNpmPackageAsync(pkg) {
  return new Promise((resolve) => {
    execFile('npm', ['list', '-g', '--depth=0', pkg], { timeout: 8000 }, (err, stdout) => {
      if (!err && stdout && stdout.includes(pkg)) {
        return resolve({ cached: true, method: 'global' });
      }
      // Not global — just report as not cached; the package will auto-install on first use via npx
      resolve({ cached: false, available: true, method: 'npx-on-demand' });
    });
  });
}

module.exports = function (app, ctx) {
  const { WORKSPACE_ROOT, CODEX_HOME } = ctx;
  const configPath = path.join(CODEX_HOME, 'config.toml');

  // GET /api/mcp/status — check all MCP servers (non-blocking)
  app.get('/api/mcp/status', async (req, res) => {
    try {
      // Read MCP servers from active config
      let configuredServers = {};
      try {
        if (fs.existsSync(configPath)) {
          const raw = fs.readFileSync(configPath, 'utf8');
          const data = toml.parse(raw);
          configuredServers = data.mcp_servers || {};
        }
      } catch { /* use empty */ }

      // Check all packages in parallel
      const checks = await Promise.all(
        Object.entries(MCP_DEFINITIONS).map(async ([key, def]) => {
          const configured = configuredServers[key];
          const pkgCheck = await checkNpmPackageAsync(def.package);
          return {
            key,
            name: def.name,
            description: def.description,
            package: def.package,
            configured: !!configured,
            config: configured ? {
              command: configured.command,
              args: configured.args,
            } : null,
            ...pkgCheck,
          };
        })
      );

      res.json({ servers: checks });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // POST /api/mcp/retry/:name — attempt to install/cache a specific MCP package
  app.post('/api/mcp/retry/:name', (req, res) => {
    const def = MCP_DEFINITIONS[req.params.name];
    if (!def) return res.status(404).json({ error: 'Unknown MCP server' });

    execFile('npx', ['-y', def.package, '--help'], { timeout: 60000 }, (err) => {
      if (err) {
        return res.status(500).json({ error: `Failed to cache ${def.package}: ${err.message}` });
      }
      res.json({ success: true, key: req.params.name, package: def.package, message: 'Cached successfully' });
    });
  });
};
