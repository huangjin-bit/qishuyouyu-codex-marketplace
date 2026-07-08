---
name: qishuyouyu-dev-standards
description: 奇树有鱼通用开发规范。用户要求实现功能、修复 bug、写测试、调试、代码评审、整理项目结构、前端验证或解释复杂概念时使用。偏好 TDD、显式错误处理、带上下文日志、模块化低耦合设计和直接中文沟通。
---

# 奇树有鱼通用开发规范

## 沟通规范

- 使用中文，表达直接，优先给具体例子，再补充原理。
- 复杂概念用简短图示解释，例如 Mermaid 或目录树。
- 修改代码时，优先提供“修改前 / 修改后”的关键片段或说明。
- 结尾总结关键点。

## 编码规范

- 偏好 Java、Python、Vue/uni-app、C++ 的常见工程实践。
- 优先参考项目原本代码结构：先找同类功能、同层目录、同命名方式，再决定新增文件位置和实现风格。
- 不要为了套用个人习惯或通用模板而重排项目目录；除非用户明确要求重构，否则保持现有结构稳定。
- 错误处理要显式，优先使用 `try-catch` 和有意义的错误消息。
- 避免泛化错误；日志中包含上下文、函数名和关键变量。
- 注释解释“为什么”，不要解释一眼能看懂的“是什么”。
- 使用依赖注入提升可测试性。
- 按 Controllers、Services、Repositories、Models、Utils 等职责拆分，保持模块化和低耦合。

## 参考原有结构的实现流程

做代码改动前，按下面顺序确认落点：

```text
1. 找同类功能在哪里
2. 看同类文件如何命名、分层、注入依赖
3. 沿用已有 controller/service/repository/client/adapter 边界
4. 只在没有现成边界时，才新增最小必要模块
5. 修改后检查是否引入了跨层调用或重复逻辑
```

具体要求：

- Java 后端优先沿用现有 package、Controller、Service、Repository、DTO、VO、Enum 的命名方式。
- Vue/uni-app 优先沿用现有页面目录、组件拆分、状态管理、API 封装和样式组织方式。
- Python 脚本优先沿用现有入口、配置读取、日志格式和异常处理方式。
- C++ 代码优先沿用现有头文件/源文件拆分、命名空间、错误码和构建配置。
- 新增公共工具前，先搜索是否已有相同职责的 util/helper/client/adapter。
- 如果必须偏离原结构，先说明原因和影响范围，再动手。

## 测试规范

- 偏好 TDD：先写失败测试，再写刚好够用的实现，然后验证。
- 测试关注行为，不绑定实现细节。
- 奇树有鱼远端 PR 采用 E2E 测试作为主要验证方式。
- TDD 产生的单元测试、临时测试、`test/` 或 `tests/` 下的文件只能作为本地验证材料，不允许推送到远端。
- 修复 bug 时可以先写本地复现测试帮助定位，但完成实现后必须移除或保留在本地未提交状态。

## 协作文档和记忆边界

- 不要为了“方便记忆”随手改 README、`AGENTS.md`、远程 agent 指令或其他团队入口文档。
- README 只有在用户明确要求更新 README 时才能修改。
- `AGENTS.md` 只有在用户明确要求更新 agent 指令时才能修改。
- 用户偏好应优先沉淀到本插件的 skill 中，或作为本地工作说明；不要污染业务仓库的远程协作文档。

## 日志和调试规范

- 日志带清晰前缀，例如 `[DEBUG]`、`[ERROR]`、`[PR]`。
- 日志包含时间戳。
- 有异常堆栈时优先保留堆栈。
- 日志示例：

```java
log.error("[ERROR] [{}] createOrder failed, userId={}, skuId={}", LocalDateTime.now(), userId, skuId, ex);
```

## 前端验证规范

- 使用 Playwright CLI 做截图或验证时，优先使用本机浏览器，不默认下载 Playwright bundled Chromium。
- Windows 上优先尝试 Microsoft Edge：

```powershell
npx playwright screenshot --channel msedge <url> screenshot.png --wait-for-selector ".layout-container"
```

- 如果缺少 bundled Chromium，先切换 `--channel msedge` 或其他本机浏览器通道。
- 只有用户明确同意时才执行 `npx playwright install`。
- 截图前等待真实页面容器，例如 `.layout-container`、`.ai-recommend`、`.search-index`。

## 推荐项目结构

仅在新项目或现有项目没有明确结构时，才参考这个结构；已有项目以原结构为准。

```text
project/
  src/
    api/
    services/
    models/
    utils/
  tests/
  docs/
  docker/
```

## 工作方式

- 开始前先阅读项目现有结构和风格。
- 优先沿用项目已有框架、命名和工具链。
- 改动保持聚焦，避免顺手重构无关代码。
- 完成后说明改了什么、验证了什么、还有哪些风险或待确认项。
