# Codex 安装说明

本仓库通过 Codex marketplace 分发 `qishuyouyu-plugin`。

## 安装 marketplace

```powershell
codex plugin marketplace add huangjin-bit/qishuyouyu-codex-marketplace
```

查看 marketplace：

```powershell
codex plugin marketplace list
```

## 安装插件

```powershell
codex plugin add qishuyouyu-plugin@qishuyouyu-codex-marketplace
```

如果当前 Codex CLI 支持 `--marketplace` 参数，也可以使用：

```powershell
codex plugin add qishuyouyu-plugin --marketplace qishuyouyu-codex-marketplace
```

## 更新

当仓库内容更新后，按 Codex 当前 CLI 支持的方式刷新 marketplace 或重新安装插件。

如果本地是 clone 仓库方式使用，进入仓库后运行：

```powershell
git pull --ff-only
```

## 当前插件内容

- 业务上下文：drama、Kun、组件关系。
- 开发规范：参考原项目结构、显式错误处理、日志、测试边界。
- PR 规范：从 master 建分支、draft PR、邀请评审。
- Kun Work Item：personal agent token / auth MCP / Kun 工作项调用流程。
