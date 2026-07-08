# qsyyKunCreateWorkItems

## 目标

通过当前环境的 Kun MCP 创建一个 Kun 工作项。Agent 面向用户只收集三个参数：

| 参数 | 含义 | 示例 |
|------|------|------|
| `repository` | 短仓库名 | `drama-react` |
| `title` | 工作项标题 | `修复登录页超时提示` |
| `content` | 工作项内容 | `登录接口超时后需要给出明确错误提示，并保留重试入口。` |

## 执行流程

1. 确认用户意图是创建 Kun 工作项。
2. 如果缺少 `repository`、`title` 或 `content`，只补问缺失字段。
3. 调用当前环境中 Kun MCP 提供的“创建工作项”语义能力。
4. 调用成功后，向用户反馈工作项已创建，并包含 MCP 返回的可公开识别信息。
5. 调用失败时，保留错误消息和上下文，不猜测内部原因。

## Repository 规则

- `repository` 使用短仓库名，例如 `drama-react`、`drama-backend`、`drama-processor`。
- 不要求用户填写 GitHub URL、`owner/repo`、Kun 应用 ID 或组件 ID。
- 仓库名到 Kun 应用/组件的映射由 Kun MCP 内部处理。

## MCP 缺失

如果当前环境没有 Kun MCP，直接告诉用户：

```text
当前环境缺少 Kun MCP，无法创建 Kun 工作项。
```

不要伪造创建成功，不要让用户提供 token，不要改用 HTTP API。

## 禁止暴露的内容

- 后端接口地址
- 应用 ID、组件 ID、阻塞关系 ID、平面 ID
- 内部默认状态、类型字段
- 鉴权 header、token、cookie、session
- MCP 内部如何映射仓库和用户身份

## 示例

用户：

```text
给 drama-react 创建一个工作项：登录失败时错误提示不明确，需要优化。
```

Agent 应整理为：

```text
repository: drama-react
title: 优化登录失败错误提示
content: 登录失败时当前错误提示不明确，需要展示可理解的失败原因，并保留用户重试入口。
```

然后调用 Kun MCP 的“创建工作项”语义能力。
