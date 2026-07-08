---
name: qishuyouyu-kun-work-item
description: Kun 工作项开放能力设计规范。用户提到 Kun 工作项、Work Item、查看工作项、创建工作项、修改工作项、personal agent、个人 agent token、auth MCP、用户 token、token 过期、主动获取 token、注册登录统一管理时使用。
---

# Kun 工作项开放能力

## 当前目标

当前正在开放 Kun 平台的部分能力，主要是让 personal agent 能够基于当前用户身份：

- 查看工作项
- 创建工作项
- 修改工作项

这些能力面向 Kun 平台的 Work Item 管理，不是 GitHub issue 的直接替代；只有明确做映射时，才把两者关联起来。

## 参与组件

```text
personal agent
  |- 向 auth MCP 获取个人 agent token
  |- 携带个人 token 调用 Kun

auth MCP
  |- 统一处理注册/登录/身份管理
  |- 根据当前用户生成或返回个人 agent token
  |- 处理 token 生命周期和过期刷新策略

Kun
  |- 校验个人 token
  |- 按当前用户权限查看/创建/修改 Work Item
```

## Token 流程

```text
personal agent -> auth MCP: 获取当前用户的个人 agent token
auth MCP -> personal agent: 返回个人 agent token
personal agent -> Kun: 携带个人 token 查看/创建/修改工作项
Kun -> personal agent: 返回工作项结果
```

## 核心约束

- token 获取是主动触发的：personal agent 需要主动向 auth MCP 获取当前用户对应的个人 agent token。
- personal agent 调用 Kun 时携带的是“当前用户个人 token”，不是平台级共享 token。
- Kun 必须按当前用户身份和权限执行工作项查看、创建、修改。
- auth MCP 负责统一注册、登录、身份管理和 token 生命周期，不要在 Kun 工作项逻辑里重复实现登录体系。
- token 过期时，personal agent 应通过 auth MCP 主动刷新或重新获取 token，再重试 Kun 调用。
- 不要把 token 写入日志、README、AGENTS.md、PR 描述或其他持久化文档。
- 日志只记录 token 获取/刷新/校验的状态和上下文，不记录 token 原文。

## 接口设计建议

调用 Kun 工作项接口时，业务参数和身份凭证要分离：

```text
Authorization: Bearer <personal-agent-token>
Body: work item query/create/update payload
```

推荐的能力边界：

- `AuthMcpClient`：负责获取、刷新个人 agent token。
- `KunWorkItemClient`：负责调用 Kun 工作项查看、创建、修改接口。
- `WorkItemService`：负责编排业务流程和错误处理。

## 错误处理

- auth MCP 不可用：停止 Kun 调用，提示无法获取个人 agent token。
- token 过期：刷新 token 后重试一次；仍失败则返回明确错误。
- Kun 返回无权限：不要自动提权，提示当前用户无权操作该工作项。
- Kun 工作项不存在：明确区分“不存在”和“无权限”。
- 创建/修改失败：保留 Kun 返回的错误码、请求上下文和堆栈，但不要记录 token 原文。

## 需要澄清的问题

如果开始实现接口，先确认：

- auth MCP 获取 token 的具体工具名、接口路径或 MCP tool schema。
- Kun 工作项查看、创建、修改的接口路径和字段 schema。
- token 过期返回码或错误格式。
- personal agent 是否需要缓存 token，以及缓存时长。
- 工作项权限模型：谁能看、谁能创建、谁能修改。
