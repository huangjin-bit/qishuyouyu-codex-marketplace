---
name: qishuyouyu-pr
description: 我的奇树有鱼标准提交流程和 PR 管理规范。用户提到提交改动、标准提交、创建分支、commit、push、draft PR、开 PR、提交评审、合并前检查或从 master 拉分支时必须使用。要求先理解当前工作区改动，基于最新 master 创建 feature/fix/chore 分支，安全带上当前改动，提交、push 并创建 draft PR。
---

# 我的奇树有鱼标准提交流程

## 触发场景

当用户要求提交当前改动、创建分支、生成 commit、push、开草稿 PR、检查 PR 流程，或提到“奇树有鱼 PR 规范”时，必须遵守本 skill。

## 硬性规则

1. 先检查当前 Git 工作区状态，理解用户做了哪些改动。
2. 不要覆盖、丢弃或重写用户未提交改动。
3. 当前默认主分支是 `master`。
4. 创建分支前必须 fetch 远端最新代码，并基于最新 `origin/master` 创建新分支。
5. 分支名使用英文、短横线，格式必须是 `<type>/<slug>`。
6. `<type>` 只能使用 `feature`、`fix`、`chore` 之一。
7. `<slug>` 必须简短概括本次改动，例如 `feature/add-build-history`、`fix-login-timeout`、`chore-update-pr-skill`。
8. 将当前工作区改动安全带到新分支上；如遇冲突或异常，停止并说明需要用户处理的文件。
9. 根据改动内容生成清晰的 commit message，并提交所有相关改动。
10. 禁止 force push。
11. push 新分支到远端后，创建 draft pull request。
12. PR base 必须是 `master`，PR 必须是 draft。
13. PR 标题要简洁概括改动。
14. PR 描述必须包含 `Summary`。
15. 如果缺少权限、远端配置、GitHub CLI 或必要工具，停止并告诉用户原因与下一步建议。
16. 推送前必须检查禁止推送项：`test/`、`tests/`、README 文件、`AGENTS.md`。
17. TDD 过程产生的测试文件只能用于本地验证，不允许进入远端 PR。
18. README 和 `AGENTS.md` 只有在用户明确要求更新时才能改；不要为了记录偏好而顺手改。

## 推荐命令流程

如果当前项目已经安装本插件，优先使用一键标准提交流程：

```powershell
.\scripts\create-qishuyouyu-draft-pr.ps1 -Type feature -Slug "add-build-history" -CommitMessage "Add build history view" -Title "Add build history view"
```

常见类型：

```text
feature  新功能
fix      bug 修复
chore    规范、脚本、配置、文档维护
```

也可以拆成两步执行。

第一步：从最新 `master` 创建规范分支，并把当前未提交改动带到新分支：

```powershell
.\scripts\start-qishuyouyu-pr-branch.ps1 -Type feature -Slug "add-build-history"
```

第二步：提交完成后，推送并创建草稿 PR：

```powershell
.\scripts\publish-qishuyouyu-draft-pr.ps1 -Title "Add build history view"
```

## 手动执行流程

先确认仓库状态和工具：

```powershell
git status --short
git remote -v
gh auth status
```

基于最新 `master` 创建分支：

```powershell
git fetch origin master
git checkout master
git pull --ff-only origin master
git checkout -b "feature/<slug>"
```

如果当前已经有未提交改动，必须先安全保存，再切到最新 `master`，最后恢复到新分支；不要丢弃改动：

```powershell
git stash push -u -m "qishuyouyu-pr-transfer"
git fetch origin master
git checkout master
git pull --ff-only origin master
git checkout -b "feature/<slug>"
git stash pop --index
```

如 `stash pop` 后出现冲突，停止并说明冲突文件。

提交、push、创建 draft PR：

```powershell
.\scripts\check-qishuyouyu-push.ps1
git add -A
git commit -m "<clear commit message>"
git push -u origin "feature/<slug>"
gh pr create --draft --base master --head "feature/<slug>" --title "<PR title>" --body "## Summary`n- <summary>"
```

## Commit Message 规范

- 使用英文，简洁说明行为和对象。
- 优先使用祈使句或简短动词短语。
- 不要写空泛信息，例如 `update`、`fix`、`changes`。

示例：

```text
Add Kun task item creation skill
Fix login timeout error handling
Update PR submission workflow
```

## PR 描述模板

```markdown
## Summary
- 
```

可以按需要增加测试、风险等信息，但 `Summary` 必须存在。

## 执行细节

- 如果当前工作区没有任何改动，先告诉用户没有可提交内容，不要创建空提交。
- 如果已经在非 `master` 分支且存在未提交改动，仍然要先安全保存改动，再基于最新 `origin/master` 创建新分支。
- 如果当前分支已有提交但不在新分支上，不要自动 cherry-pick；先说明当前分支情况并让用户确认。
- 如果远端没有 `origin` 或没有 `master`，停止并说明。
- 如果 `git pull --ff-only origin master` 失败，停止并汇报冲突或非快进原因，不要自动 merge。
- 如果 `git stash pop --index` 或恢复改动失败，停止并列出冲突文件。
- 推送前运行 `.\scripts\check-qishuyouyu-push.ps1`，默认对比 `origin/master...HEAD`。
- 如果确实需要更新 README 或 `AGENTS.md`，必须先获得用户明确确认，并在脚本中使用 `-AllowReadme` 或 `-AllowAgents`。
- 不要使用允许参数绕过 `test/` 或 `tests/` 限制；这些本地测试文件不应进入远端。

## 给用户的反馈方式

- 执行前说明当前分支、工作区改动概览、准备创建的分支名。
- 执行后说明新分支、commit message、push 结果和 draft PR 链接。
- 出错时使用明确错误消息，例如：`[PR] 无法创建 draft PR：GitHub CLI 未登录`。
- 不要创建 ready-for-review PR，除非用户明确要求并确认偏离规范。
