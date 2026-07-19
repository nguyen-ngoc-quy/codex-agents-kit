/**
 * Agents routes — browse and load agent instructions from agents/*.md files.
 */
const fs = require('fs');
const path = require('path');

const AGENT_LIST = [
  { key: 'architect', name: 'Architect', emoji: '🏗️' },
  { key: 'backend', name: 'Backend', emoji: '💻' },
  { key: 'frontend', name: 'Frontend', emoji: '🎨' },
  { key: 'devops', name: 'DevOps', emoji: '🔧' },
  { key: 'reviewer', name: 'Code Reviewer', emoji: '👁️' },
  { key: 'debugger', name: 'Debugger', emoji: '🐛' },
  { key: 'tester', name: 'Tester', emoji: '🧪' },
];

module.exports = function (app, ctx) {
  const { WORKSPACE_ROOT } = ctx;

  // GET /api/agents — list all agents (metadata only)
  app.get('/api/agents', (req, res) => {
    const results = AGENT_LIST.map(a => {
      const agentPath = path.join(WORKSPACE_ROOT, 'agents', `${a.key}.md`);
      const exists = fs.existsSync(agentPath);
      let metadata = {};
      if (exists) {
        const raw = fs.readFileSync(agentPath, 'utf8');
        const versionMatch = raw.match(/>\s*Version:\s*([^|]+)/);
        const descMatch = raw.match(/#\s.*?\n\n(.+?)\n/);
        if (versionMatch) metadata.version = versionMatch[1].trim();
        if (descMatch) metadata.description = descMatch[1].trim();
      }
      return { ...a, exists, ...metadata };
    });
    res.json(results);
  });

  // GET /api/agents/:name — get full agent content
  app.get('/api/agents/:name', (req, res) => {
    const agent = AGENT_LIST.find(a => a.key === req.params.name);
    if (!agent) return res.status(404).json({ error: 'Agent not found' });

    const agentPath = path.join(WORKSPACE_ROOT, 'agents', `${agent.key}.md`);
    if (!fs.existsSync(agentPath)) {
      return res.status(404).json({ error: 'Agent file not found' });
    }

    const content = fs.readFileSync(agentPath, 'utf8');
    res.json({ ...agent, content });
  });

  // POST /api/agents/:name/load — run codex agent <name> in terminal (returns command)
  app.post('/api/agents/:name/load', (req, res) => {
    const agent = AGENT_LIST.find(a => a.key === req.params.name);
    if (!agent) return res.status(404).json({ error: 'Agent not found' });

    const isWin = process.platform === 'win32';
    const script = path.join(WORKSPACE_ROOT, 'scripts', isWin ? 'load-agent.ps1' : 'load-agent.sh');
    if (!fs.existsSync(script)) return res.status(500).json({ error: 'load-agent script not found' });

    const cmd = isWin
      ? `powershell -NoProfile -File "${script}" "${agent.key}"`
      : `bash "${script}" "${agent.key}"`;

    res.json({ command: cmd, agent: agent.key, name: agent.name });
  });
};
