# 奇树有鱼 Codex Marketplace

这是奇树有鱼团队的 Codex 插件市场仓库，用于统一分发公司内部 Codex 插件。

## 当前插件

- `qishuyouyu-plugin`：奇树有鱼开发规范和 PR 管理插件。

## 仓库结构

```text
qishuyouyu-plugin/
  .agents/
    plugins/
      marketplace.json
  plugins/
    qishuyouyu-plugin/
      .codex-plugin/
      skills/
      scripts/
```

## 使用方式

团队成员 clone 本仓库后，在 Codex 中通过 marketplace 文件加载：

```text
.agents/plugins/marketplace.json
```

插件本体路径：

```text
plugins/qishuyouyu-plugin
```

## 维护规则

- 新增插件时放到 `plugins/<plugin-name>/`。
- marketplace 条目统一写到 `.agents/plugins/marketplace.json`。
- 插件内的公司规范优先写入对应 skill，不随意改业务仓库的 README 或 AGENTS.md。
- 推送前使用插件内的 PR/push 规范脚本做检查。
