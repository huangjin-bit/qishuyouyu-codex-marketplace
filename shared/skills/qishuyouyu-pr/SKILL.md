---
name: qishuyouyu-pr
description: 奇树有鱼 PR 管理规范。用户提到 PR、开分支、创建草稿 PR、提交评审、邀请易从 review、合并前检查、从 master 拉分支时必须使用。强制从最新 master 创建功能分支，分支命名为 profile-name/当前 PR 功能，PR 必须是 draft，并邀请易从评审。
---

# 奇树有鱼 PR 管理规范

## 触发场景

当用户要求创建分支、提交 PR、开草稿 PR、邀请评审、检查 PR 流程，或提到“奇树有鱼 PR 规范”时，必须遵守本 skill。

## 硬性规则

1. 只能从 `master` 分支创建新功能分支。
2. 创建分支前必须拉取最新 `origin/master`。
3. 分支命名必须是 `<profile-name>/<当前 PR 功能>`，其中 `profile-name` 来自当前 GitHub Profile 的显示名称，不使用 login/username。
4. PR 的 base 必须是 `master`。
5. PR 必须创建为草稿 PR。
6. PR 必须邀请易从评审。
7. 如果无法确定易从的 GitHub username，不要猜测；先询问用户或读取项目配置。
8. 推送前必须检查禁止推送项：`test/`、`tests/`、README 文件、`AGENTS.md`。
9. TDD 过程产生的测试文件只能用于本地验证，不允许进入远端 PR。
10. README 和 `AGENTS.md` 只有在用户明确要求更新时才能改；不要为了记录偏好而顺手改。

## 推荐命令流程

如果当前项目已经安装本插件，固定流程分两步执行。

第一步：从最新 `master` 创建规范分支：

```powershell
.\scripts\start-qishuyouyu-pr-branch.ps1 -Feature "<feature-slug>"
```

第二步：开发、提交完成后，推送并创建草稿 PR：

```powershell
.\scripts\publish-qishuyouyu-draft-pr.ps1 -Reviewer "<yicong-github-username>" -Title "<PR title>"
```

也可以先配置环境变量：

```powershell
$env:QISHUYOUYU_YICONG_GITHUB = "<yicong-github-username>"
.\scripts\start-qishuyouyu-pr-branch.ps1 -Feature "<feature-slug>"
.\scripts\publish-qishuyouyu-draft-pr.ps1 -Title "<PR title>"
```

先确认仓库和身份：

```powershell
git status --short
gh api user --jq ".name"
```

从最新 `master` 创建分支：

```powershell
git fetch origin master
git checkout master
git pull --ff-only origin master
git checkout -b "<profile-name>/<feature-slug>"
```

推送并创建草稿 PR：

```powershell
.\scripts\check-qishuyouyu-push.ps1
git push -u origin "<profile-name>/<feature-slug>"
gh pr create --draft --base master --head "<profile-name>/<feature-slug>" --reviewer "<yicong-github-username>"
```

## 执行细节

- `<profile-name>` 必须使用 `gh api user --jq ".name"` 获取到的 GitHub Profile 显示名称，便于团队识别是谁开的分支。
- 如果 GitHub Profile 显示名称为空，停止并提示用户先配置 Profile Name；不要 fallback 到 login/username。
- `<feature-slug>` 由当前 PR 功能生成，使用简短、可读、低歧义的名称，例如 `fix-login-timeout`、`add-order-export`。
- 如果 `git status --short` 显示未提交改动，创建分支或切换分支前先说明风险，并让用户确认是否提交、暂存、stash 或继续。
- 如果当前不在 `master`，创建新分支前必须切回 `master` 并同步最新远端。
- 如果 `git pull --ff-only origin master` 失败，停止并汇报冲突或非快进原因，不要自动 merge。
- 如果项目默认分支不是 `master`，仍按公司规范使用 `master`；只有用户明确更新规范时才改。
- 推送前运行 `.\scripts\check-qishuyouyu-push.ps1`，默认对比 `origin/master...HEAD`。
- 推荐使用 `.\scripts\start-qishuyouyu-pr-branch.ps1` 固定建分支流程，使用 `.\scripts\publish-qishuyouyu-draft-pr.ps1` 固定发布草稿 PR 流程。
- 如果确实需要更新 README 或 `AGENTS.md`，必须先获得用户明确确认，并在脚本中使用 `-AllowReadme` 或 `-AllowAgents`。
- 不要使用允许参数绕过 `test/` 或 `tests/` 限制；这些本地测试文件不应进入远端。

## PR 描述模板

```markdown
## 变更内容
- 

## 测试
- [ ] 已运行相关测试
- [ ] 已做必要的手动验证

## 风险点
- 
```

## 给用户的反馈方式

- 直接说明当前分支、目标 base、草稿状态和评审人。
- 出错时使用明确错误消息，例如：`[PR] 无法创建草稿 PR：未配置易从的 GitHub username`。
- 不要创建 ready-for-review PR，除非用户明确要求并确认偏离规范。
