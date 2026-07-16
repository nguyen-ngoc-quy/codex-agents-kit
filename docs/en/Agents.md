# 👥 AI Agents Guide

Guide to using specialized **AI Agents** in your development workflow.

---

## 🤖 Agent List

| Agent | Config File | Primary Role |
| :--- | :--- | :--- |
| **Architect** | [architect.md](../../agents/architect.md) | System design, DB schemas, flow diagrams |
| **Backend** | [backend.md](../../agents/backend.md) | ASP.NET Core API development, EF Core optimization |
| **Frontend** | [frontend.md](../../agents/frontend.md) | Flutter, React, Unity UI development |
| **DevOps** | [devops.md](../../agents/devops.md) | Dockerfile, Compose, CI/CD configuration |
| **Reviewer** | [reviewer.md](../../agents/reviewer.md) | Code review, security scanning, clean code checks |
| **Debugger** | [debugger.md](../../agents/debugger.md) | Error log diagnosis, stack trace analysis, patches |
| **Tester** | [tester.md](../../agents/tester.md) | xUnit, Moq, Flutter tests, performance measurement |

---

## 💡 Usage

### CLI Command (v0.1.4+)
Use `codex agent` to load the system instructions for the desired agent:

```powershell
# Load architect agent instructions
codex agent architect

# List available agents
codex agent
```

The agent instructions are printed to the terminal — copy-paste them into Codex CLI as context.

### Manual Method
Before starting a major task, copy the content of the relevant Agent file from `agents/` and send it as a System Prompt or initial context to Codex CLI to shape its behavior and coding rules.
E.g., include the directive: `Use the Backend Agent configuration from agents/backend.md to implement the following feature:`
