# qsyyKunCreateTaskItems

## 目标

通过当前环境的 Kun MCP 新建一个 Kun 任务项。这里的“任务项”是面向用户的说法，落到 Kun 平台时由 MCP 映射到对应工作项能力。

Agent 面向用户只收集三个参数：

| 参数 | 含义 | 示例 |
|------|------|------|
| `repository` | 短仓库名 | `drama-react` |
| `title` | 任务项标题 | `补充登录页异常提示` |
| `content` | 任务项内容 | `登录接口超时或失败时，需要展示明确提示并保留重试入口。` |

## 执行流程

1. 确认用户意图是新建 Kun 任务项。
2. 如果缺少 `repository`、`title` 或 `content`，只补问缺失字段。
3. 调用当前环境中 Kun MCP 提供的“创建工作项/任务项”语义能力。
4. 调用成功后，向用户反馈任务项已新建，并包含 MCP 返回的可公开识别信息。
5. 调用失败时，保留错误消息和上下文，不猜测内部原因。

## Repository 规则

- `repository` 使用短仓库名，例如 `drama-react`、`drama-backend`、`drama-processor`。
- 不要求用户填写 GitHub URL、`owner/repo`、Kun 应用 ID 或组件 ID。
- 仓库名到 Kun 应用/组件的映射由 Kun MCP 内部处理。

## MCP 缺失

如果当前环境没有 Kun MCP，直接告诉用户：

```text
当前环境缺少 Kun MCP，无法新建 Kun 任务项。
```

不要伪造新建成功，不要让用户提供 token，不要改用 HTTP API。

## 禁止暴露的内容

- 后端接口地址
- 应用 ID、组件 ID、阻塞关系 ID、平面 ID
- 内部默认状态、类型字段
- 鉴权 header、token、cookie、session
- MCP 内部如何映射仓库和用户身份

## 示例

用户：

```text
给 drama-react 新建一个任务项：登录失败时错误提示不明确，需要优化。
```

Agent 应整理为：

```text
repository: drama-react
title: 优化登录失败错误提示
content: 登录失败时当前错误提示不明确，需要展示可理解的失败原因，并保留用户重试入口。
```

然后调用 Kun MCP 的“创建工作项/任务项”语义能力。
