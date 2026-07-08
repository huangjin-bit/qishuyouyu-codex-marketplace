# 维护说明

本仓库是公司 AI 开发规范与能力包中心，服务整个研发部门。

## 内容同步原则

同一条公司规范需要同时维护：

```text
Source:
  shared/skills/<skill-name>/SKILL.md

Generated Codex:
  plugins/qishuyouyu-plugin/skills/<skill-name>/SKILL.md

Generated GitHub Copilot:
  .github/skills/<skill-name>/SKILL.md
```

长期稳定、所有 Copilot 会话都应知道的内容，也应同步到：

```text
.github/copilot-instructions.md
```

## 新增 skill 流程

1. 在 `shared/skills/` 下新增 skill。
2. 如果涉及脚本，把脚本放在 shared 对应 skill 的 `scripts/` 目录。
3. 运行 `tools/sync-shared-skills.ps1` 生成 Codex 和 Copilot 输出。
4. 更新 `README.md` 的能力包列表。
5. 更新 `CHANGELOG.md`。
6. 运行验证脚本。

## 验证

```powershell
.\tools\sync-shared-skills.ps1
.\tools\validate-marketplace.ps1
.\tools\validate-copilot-support.ps1
```

还需要检查：

```powershell
Get-Content .agents\plugins\marketplace.json | ConvertFrom-Json
Get-Content plugins\qishuyouyu-plugin\.codex-plugin\plugin.json | ConvertFrom-Json
git status --short
```

## 安全边界

- 不提交真实 token、API key、密码、私钥。
- 不在日志示例里写真实凭据。
- Kun MCP 相关内容只写语义能力和公开参数，不写生产 token 或私有凭据。
- public 仓库中避免写入尚未公开的内部接口地址。
- `qsyy-kun` 不暴露后端接口地址、鉴权 header、应用 ID、组件 ID 或内部默认字段。

## 版本规则

当前版本记录在仓库根目录 `VERSION` 文件中。

当前使用简单语义版本：

```text
MAJOR.MINOR.PATCH
```

- `MAJOR`：破坏性变更，例如删除或重命名 skill。
- `MINOR`：新增能力包或重要规范。
- `PATCH`：文档修正、验证脚本修正、措辞调整。

发布版本时同时更新 `VERSION`、`CHANGELOG.md`，并创建 Git tag，例如：

```powershell
git tag v0.3.0
git push origin master --tags
```
