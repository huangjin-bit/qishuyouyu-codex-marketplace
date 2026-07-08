# Changelog

## 0.3.1 - 2026-07-08

- 在 `qsyy-kun` 下新增 `qsyyKunCreateTaskItems`，支持“新建任务项”的用户表达。
- 更新校验脚本，确保 Codex 和 GitHub Copilot 输出都包含新建任务项能力。

## 0.3.0 - 2026-07-08

- 增加 `shared/skills` 作为 Codex 和 GitHub Copilot skills 的统一来源。
- 增加 `tools/sync-shared-skills.ps1`，用于生成 Codex 和 Copilot 两套 skill 输出。
- 删除旧的 `qishuyouyu-kun-work-item`，替换为 `qsyy-kun` Kun 平台扩展能力包。
- 增加 `qsyyKunCreateWorkItems` 能力说明，通过 Kun MCP 创建工作项，只暴露 `repository`、`title`、`content` 三个参数。
- 更新安装、维护和校验文档，明确发布版本需要更新 `VERSION`、`CHANGELOG.md` 并创建 Git tag。

## 0.2.0 - 2026-07-08

- 明确仓库定位为“奇树有鱼 AI 开发规范与能力包中心”。
- 面向整个研发部门提供 Codex marketplace 和 GitHub Copilot skills。
- 增加 Codex 安装说明。
- 增加 GitHub Copilot 安装说明。
- 增加维护说明、版本文件和变更记录。

## 0.1.0 - 2026-06-17

- 创建 Codex marketplace 仓库。
- 增加 `qishuyouyu-plugin`。
- 支持 GitHub Copilot instructions 和 skills。
- 增加业务上下文、开发规范、PR 规范、Kun Work Item token 流程等能力包。
