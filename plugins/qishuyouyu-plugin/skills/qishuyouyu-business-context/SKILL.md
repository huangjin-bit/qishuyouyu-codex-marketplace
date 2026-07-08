---
name: qishuyouyu-business-context
description: 奇树有鱼公司业务上下文和通用语言。用户提到 drama、漫剧、Kun、AI DevOps、应用管理、组件管理、工作项、Agent 调度、Jenkins、构建发布、日志、drama-react、drama-backend、drama-processor 时使用。用于区分 drama 主业务应用和 Kun 内部 AI DevOps 平台。
---

# 奇树有鱼业务上下文

## 核心业务

奇树有鱼公司的主业务是漫剧 `drama` 应用。

```text
drama 应用
  |- drama-react
  |  |- 漫剧平台前端
  |- drama-backend
  |  |- 漫剧平台后端
  |- drama-processor
     |- 辅助微服务，例如 API 签名、外观相关处理等
```

当前明确的前端仓库：

```text
https://github.com/openai36/drama-react.git
```

所有代码统一放在 GitHub 上，统一使用 Git 管理。

## Kun 平台定位

Kun 是公司内部 AI DevOps 自动化平台。

Kun 不是 GitHub、GitLab 这类代码托管平台；代码托管和版本管理仍以 GitHub 为准。

Kun 负责管理：

- 应用和组件
- GitHub 仓库接入
- 工作项 Work Item
- 云端 robot / agent 调度
- 代码修改 Agent 调度
- Jenkins 集成
- 主分支最新代码发布和运行
- 构建/运行日志查看

## Kun 管理范围

Kun 可以管理 Kun 平台自身组件：

```text
Kun 平台
  |- Kun 前端
  |- Kun 后端
  |- Python 处理组件
```

Kun 也可以管理 drama 应用组件：

```text
drama 应用组件
  |- drama-react
  |- drama-backend
  |- drama-processor
```

## 通用语言

| 术语 | 本项目中的含义 | 不是什么 |
|------|----------------|----------|
| `drama` | 公司主业务漫剧应用 | Kun 平台本身 |
| `drama-react` | 漫剧平台前端仓库/组件 | Kun 前端 |
| `drama-backend` | 漫剧平台后端仓库/组件 | Kun 后端 |
| `drama-processor` | drama 辅助微服务集合，例如 API 签名、外观相关处理 | 通用脚本目录 |
| `Kun` | 内部 AI DevOps 自动化平台 | GitHub/GitLab 代码托管平台 |
| `Work Item` | Kun 中管理的工作项 | GitHub issue 的同义词，除非明确映射 |
| `robot / agent` | Kun 调度的云端自动化执行者 | 本地开发者手动执行命令 |
| `组件` | Kun 管理和发布的应用组成单元 | 一定等同于前端 UI component |

## 实现和沟通要求

- 讨论代码托管、分支、PR、仓库权限时，默认对象是 GitHub。
- 讨论应用、组件、工作项、构建发布、日志、Agent 调度时，默认对象是 Kun。
- 讨论 drama 需求时，先确认涉及 `drama-react`、`drama-backend` 还是 `drama-processor`。
- 讨论 Kun 需求时，先确认是 Kun 平台自身组件，还是 Kun 管理的 drama 组件。
- 不要把 Kun 当成代码仓库来源；Kun 接入 GitHub 仓库并调度流程。
- 不确定业务归属时，先用组件关系图确认上下文，再设计代码或流程。
