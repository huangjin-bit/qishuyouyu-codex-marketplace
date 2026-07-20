# 奇树有鱼 Copilot 指令

本仓库同时分发 Codex marketplace 和 GitHub Copilot skills。Copilot 在处理奇树有鱼相关任务时，应优先遵守这里的长期规则。

## 业务上下文

- 公司主业务是漫剧 `drama` 应用，核心组件包括 `drama-react`、`drama-backend`、`drama-processor`。
- 当前明确的 drama 前端仓库是 `https://github.com/openai36/drama-react.git`。
- Kun 是公司内部 AI DevOps 自动化平台，负责应用、组件、Work Item、Agent 调度、Jenkins、构建发布和日志，不是 GitHub/GitLab 代码托管平台。
- 所有代码统一放在 GitHub 上，统一用 Git 管理；Kun 接入 GitHub 仓库并调度流程。
- 当前开放的 Kun Work Item 能力仅包括创建工作项，由 `qsyy-kun` skill 指导 Agent 调用当前环境中的 Kun MCP。
- 创建 Kun 工作项时只面向用户收集 `repository`、`title`、`content` 三个参数；不要暴露后端接口、鉴权或内部字段。

## 代码工作方式

- 开始改代码前，先参考原项目结构：找同类功能、同层目录、命名方式和已有边界。
- 优先沿用现有 Controller、Service、Repository、DTO、组件、API 封装、配置读取和日志格式。
- 不要为了套用通用模板而重排目录；除非用户明确要求重构，否则保持原结构稳定。
- 新增公共工具前，先搜索是否已有相同职责的 util/helper/client/adapter。
- 如果必须偏离原结构，先说明原因和影响范围。

## 测试和验证

- 奇树有鱼远端 PR 采用 E2E 测试作为主要验证方式。
- TDD 产生的单元测试、临时测试、`test/` 或 `tests/` 下的文件只能本地使用，不能推送远端。
- 修复 bug 时可以先写本地复现测试帮助定位，但完成后不要把这类测试文件提交到远端 PR。

## PR 和协作文档

- PR 分支必须从最新 `master` 创建。
- 分支名格式为 `feature/<slug>`、`fix/<slug>` 或 `chore/<slug>`，使用英文和短横线。
- PR base 必须是 `master`，PR 必须是 draft。
- 推送前必须检查禁止项：`test/`、`tests/`、README 文件、`AGENTS.md`。
- README、`AGENTS.md`、远程 agent 指令只有在用户明确要求时才能修改。

## 仓库维护

- Codex marketplace 入口是 `.agents/plugins/marketplace.json`。
- Codex 插件本体在 `plugins/qishuyouyu-plugin/`。
- Copilot skills 在 `.github/skills/`。
- 同一条公司规范变更时，应先更新 `shared/skills/`，再运行 `tools/sync-shared-skills.ps1` 生成 Codex 和 Copilot 两套 skill。
