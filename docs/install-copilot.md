# GitHub Copilot 安装说明

本仓库通过 GitHub Copilot repository instructions 和 skills 分发公司规范。

## 仓库级指令

Copilot 仓库级长期指令位于：

```text
.github/copilot-instructions.md
```

## 安装 skills

安装前建议先预览：

```powershell
gh skill preview huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-business-context
gh skill preview huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-dev-standards
gh skill preview huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-pr
gh skill preview huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-kun-work-item
```

安装：

```powershell
gh skill install huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-business-context
gh skill install huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-dev-standards
gh skill install huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-pr
gh skill install huangjin-bit/qishuyouyu-codex-marketplace qishuyouyu-kun-work-item
```

## 更新

如果 GitHub CLI 支持 skill 更新命令，按当前 CLI 文档更新。

如果是手动 clone 或复制方式使用，进入仓库后运行：

```powershell
git pull --ff-only
```

再重新安装或同步 `.github/skills/` 下的 skill。

## 注意事项

- skills 中的脚本应先预览再安装。
- 不要把真实 token 或内部密钥写进 skill。
- `qishuyouyu-pr` skill 包含 PowerShell 脚本，用于固定 PR 流程和推送前检查。
