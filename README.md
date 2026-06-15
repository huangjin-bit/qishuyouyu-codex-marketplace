# 奇树有鱼 Codex Plugin

这是奇树有鱼公司的 Codex 插件，用于沉淀团队开发规范和 PR 工作流。

## 已包含的 skill

- `qishuyouyu-pr`：PR 管理规范，强制从最新 `master` 创建分支，创建草稿 PR，并邀请易从评审。
- `qishuyouyu-dev-standards`：通用开发规范，覆盖 TDD、错误处理、日志、注释、模块拆分和前端验证偏好。

## PR 快速使用

先配置易从的 GitHub username：

```powershell
$env:QISHUYOUYU_YICONG_GITHUB = "<yicong-github-username>"
```

创建分支并开草稿 PR：

```powershell
.\scripts\create-qishuyouyu-draft-pr.ps1 -Feature "add-order-export" -Title "Add order export"
```

也可以直接传入评审人：

```powershell
.\scripts\create-qishuyouyu-draft-pr.ps1 -Feature "fix-login-timeout" -Reviewer "<yicong-github-username>"
```

## PR 规则

```mermaid
flowchart LR
  A["检查工作区干净"] --> B["fetch origin master"]
  B --> C["checkout master"]
  C --> D["pull --ff-only origin master"]
  D --> E["创建 <profile-name>/<PR功能> 分支"]
  E --> F["push 分支"]
  F --> G["gh pr create --draft"]
  G --> H["邀请易从 review"]
```

关键约束：

- 只能从 `master` 创建功能分支。
- 分支名格式是 `<profile-name>/<PR功能>`，`profile-name` 来自当前 GitHub Profile 显示名称，不使用 login/username。
- PR base 必须是 `master`。
- PR 必须是 draft。
- 必须邀请易从评审。
