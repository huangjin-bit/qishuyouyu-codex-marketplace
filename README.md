# 奇树有鱼 AI 开发规范与能力包中心

这是奇树有鱼研发部门统一使用的 AI 开发规范与能力包仓库。

它不是单一工具的配置仓库，而是公司级 AI 开发上下文分发中心，当前支持：

- Codex marketplace / plugin
- GitHub Copilot repository instructions / skills

暂不服务 Kun agent；Kun agent 的能力包和运行规范单独维护。

## 当前能力包

- `qishuyouyu-business-context`：公司业务上下文，覆盖 drama 应用、Kun 平台定位和组件关系。
- `qishuyouyu-dev-standards`：通用开发规范，强调参考原项目结构、显式错误处理、日志和测试边界。
- `qishuyouyu-pr`：PR 管理规范，覆盖 master 分支策略、profile-name 分支命名、draft PR 和评审邀请。
- `qsyy-kun`：Kun 平台扩展能力包，当前包含 `qsyyKunCreateWorkItems`，通过 Kun MCP 创建工作项。

## 仓库结构

```text
qishuyouyu-codex-marketplace/
  .agents/
    plugins/
      marketplace.json              # Codex marketplace 入口
  plugins/
    qishuyouyu-plugin/              # Codex plugin
      .codex-plugin/
      skills/
      scripts/
  shared/
    skills/                         # Codex 和 Copilot 的统一 skill 来源
  .github/
    copilot-instructions.md         # GitHub Copilot 仓库级长期指令
    skills/                         # GitHub Copilot skills
  docs/
    install-codex.md
    install-copilot.md
    maintenance.md
  tools/
    validate-copilot-support.ps1
  VERSION
  CHANGELOG.md
```

## 安装

Codex 安装方式见 [docs/install-codex.md](docs/install-codex.md)。

GitHub Copilot 安装方式见 [docs/install-copilot.md](docs/install-copilot.md)。

## 维护规则

- 新增公司规范时，优先更新 `shared/skills/<skill-name>/`。
- 使用 `tools/sync-shared-skills.ps1` 生成 Codex skill 和对应 Copilot skill。
- Codex 生成结果位于 `plugins/qishuyouyu-plugin/skills/<skill-name>/`。
- Copilot 生成结果位于 `.github/skills/<skill-name>/`。
- Codex marketplace 条目统一写到 `.agents/plugins/marketplace.json`。
- 不把真实 token、内部密钥、私有接口凭据写入本仓库。
- 公司规范优先写入对应 skill，不随意改业务仓库的 README 或 AGENTS.md。
- 维护流程见 [docs/maintenance.md](docs/maintenance.md)。

## 验证

```powershell
.\tools\sync-shared-skills.ps1
.\tools\validate-copilot-support.ps1
```

推送前还应确认：

```powershell
git status --short
```
