---
name: qsyy-kun
description: 我的奇树有鱼 Kun 平台扩展能力包。用户提到 Kun、坤平台、创建工作项、新建任务项、Work Item、工作项、任务项、qsyyKunCreateWorkItems、qsyyKunCreateTaskItems、Kun MCP 时使用。用于把请求路由到 Kun MCP 能力，并避免暴露后端接口、鉴权和内部字段。
---

# 我的 Kun 平台扩展能力

`qsyy-kun` 是我个人使用的奇树有鱼 Kun 平台扩展能力包。它只描述 AI Agent 应如何使用当前环境中的 Kun MCP 能力，不实现后端接口，也不暴露内部鉴权细节。

## 能力索引

| 能力 | 文件 | 场景 |
|------|------|------|
| `qsyyKunCreateWorkItems` | `qsyyKunCreateWorkItems.md` | 创建 Kun 工作项 |
| `qsyyKunCreateTaskItems` | `qsyyKunCreateTaskItems.md` | 新建 Kun 任务项 |

## 路由规则

- 用户要创建 Kun 工作项、Work Item、任务、需求或缺陷时，读取 `qsyyKunCreateWorkItems.md`。
- 用户明确说“新建任务项”或“创建任务项”时，读取 `qsyyKunCreateTaskItems.md`。
- 当前能力包不提供查看、查询、修改、删除工作项能力。
- 不要把 Kun Work Item 当成 GitHub issue；只有用户明确要求映射时才关联。

## 安全边界

- 只能调用当前环境中 Kun MCP 提供的语义能力。
- 不要直接调用后端 HTTP API。
- 不要要求用户提供平台 token、内部鉴权头、应用 ID、组件 ID 或后端字段。
- 如果当前环境没有 Kun MCP，明确告诉用户缺少 Kun MCP；不要伪造成功结果，不要退回 HTTP API。
