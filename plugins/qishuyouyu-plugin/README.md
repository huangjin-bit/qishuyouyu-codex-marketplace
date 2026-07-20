# 奇树有鱼 Codex Plugin

这是我个人使用的奇树有鱼 Codex 插件，用于沉淀个人开发规范和 PR 工作流。

## 已包含的 skill

- `qishuyouyu-pr`：标准提交流程，基于最新 `master` 创建 `feature/fix/chore` 分支，提交、push 并创建草稿 PR。
- `qishuyouyu-dev-standards`：我的开发规范，覆盖 TDD、错误处理、日志、注释、模块拆分和前端验证偏好。
- `qishuyouyu-business-context`：我在奇树有鱼项目中的业务上下文，覆盖 drama 应用、Kun 平台定位和组件关系。
- `qsyy-kun`：Kun 平台扩展能力包，当前通过 Kun MCP 创建工作项/任务项。

## PR 快速使用

创建分支、提交并开草稿 PR：

```powershell
.\scripts\create-qishuyouyu-draft-pr.ps1 -Type feature -Slug "add-order-export" -CommitMessage "Add order export" -Title "Add order export"
```

也可以拆成两步：

```powershell
.\scripts\start-qishuyouyu-pr-branch.ps1 -Type fix -Slug "login-timeout"
.\scripts\publish-qishuyouyu-draft-pr.ps1 -Title "Fix login timeout"
```

## PR 规则

```mermaid
flowchart LR
  A["检查当前工作区改动"] --> B["stash 保存当前改动"]
  B --> C["fetch origin master"]
  C --> D["checkout master"]
  D --> E["pull --ff-only origin master"]
  E --> F["创建 feature/fix/chore 分支"]
  F --> G["恢复当前改动"]
  G --> H["commit"]
  H --> I["push 分支"]
  I --> J["gh pr create --draft"]
```

关键约束：

- 默认主分支是 `master`。
- 分支名格式是 `feature/<slug>`、`fix/<slug>` 或 `chore/<slug>`。
- 分支名使用英文、短横线，并能概括本次改动。
- PR base 必须是 `master`。
- PR 必须是 draft。
- PR 描述必须包含 `Summary`。
- 不要覆盖或丢弃用户未提交改动。
- 不要 force push。
