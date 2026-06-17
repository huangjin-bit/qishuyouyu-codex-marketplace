---
name: qishuyouyu-pr
description: 奇树有鱼 PR 管理规范。用户提到 PR、开分支、创建草稿 PR、提交评审、邀请易从 review、合并前检查、从 master 拉分支时使用。强制从最新 master 创建功能分支，分支命名为 profile-name/当前 PR 功能，PR 必须是 draft，并邀请易从评审。
---

# 奇树有鱼 PR 管理规范

## 硬性规则

1. 只能从 `master` 分支创建新功能分支。
2. 创建分支前必须拉取最新 `origin/master`。
3. 分支命名必须是 `<profile-name>/<feature-slug>`，其中 `profile-name` 来自当前 GitHub Profile 的显示名称，不使用 login/username。
4. PR 的 base 必须是 `master`。
5. PR 必须创建为 draft。
6. PR 必须邀请易从评审。
7. 如果无法确定易从的 GitHub username，不要猜测；先询问用户或读取项目配置。
8. 推送前必须检查禁止推送项：`test/`、`tests/`、README 文件、`AGENTS.md`。
9. TDD 过程产生的测试文件只能用于本地验证，不允许进入远端 PR。

## 固定脚本流程

本 skill 自带 PowerShell 脚本，位于当前 skill 目录的 `scripts/` 下。

第一步：从最新 `master` 创建规范分支：

```powershell
.\.github\skills\qishuyouyu-pr\scripts\start-qishuyouyu-pr-branch.ps1 -Feature "<feature-slug>"
```

第二步：开发、提交完成后，推送并创建草稿 PR：

```powershell
.\.github\skills\qishuyouyu-pr\scripts\publish-qishuyouyu-draft-pr.ps1 -Reviewer "<yicong-github-username>" -Title "<PR title>"
```

也可以先配置环境变量：

```powershell
$env:QISHUYOUYU_YICONG_GITHUB = "<yicong-github-username>"
.\.github\skills\qishuyouyu-pr\scripts\start-qishuyouyu-pr-branch.ps1 -Feature "<feature-slug>"
.\.github\skills\qishuyouyu-pr\scripts\publish-qishuyouyu-draft-pr.ps1 -Title "<PR title>"
```

## 执行细节

- 如果 GitHub Profile 显示名称为空，停止并提示用户先配置 Profile Name。
- 如果工作区不干净，创建分支或发布 PR 前停止，提示用户先提交或 stash。
- 如果 `git pull --ff-only origin master` 失败，停止并汇报原因，不要自动 merge。
- 如果确实需要更新 README 或 `AGENTS.md`，必须先获得用户明确确认，并在发布脚本中使用 `-AllowReadme` 或 `-AllowAgents`。
- 不要使用允许参数绕过 `test/` 或 `tests/` 限制。

## PR 描述模板

```markdown
## 变更内容
- 

## 测试
- [ ] 已运行相关 E2E 或手动验证

## 风险点
- 
```
