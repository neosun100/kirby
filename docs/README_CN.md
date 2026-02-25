<div align="center">

<img src="../kirby-logo.png" alt="Kirby Logo" width="180" />

# Kirby

**基于 Kiro CLI 的自主 AI Agent 迭代循环系统**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/neosun100/kirby?style=social)](https://github.com/neosun100/kirby/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/neosun100/kirby?style=social)](https://github.com/neosun100/kirby/network/members)
[![GitHub issues](https://img.shields.io/github/issues/neosun100/kirby)](https://github.com/neosun100/kirby/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/neosun100/kirby)](https://github.com/neosun100/kirby/commits/main)

[![Kiro CLI](https://img.shields.io/badge/Kiro_CLI-支持-blue?logo=amazonaws&logoColor=white)](https://kiro.dev/cli/)
[![Amp](https://img.shields.io/badge/Amp-支持-green)](https://ampcode.com)
[![Claude Code](https://img.shields.io/badge/Claude_Code-支持-orange)](https://docs.anthropic.com/en/docs/claude-code)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![PRs Welcome](https://img.shields.io/badge/PRs-欢迎-brightgreen.svg)](../CONTRIBUTING.md)

*每次迭代一个全新 AI 实例，逐条实现 PRD 用户故事直到全部完成。*

[快速上手](#-快速上手) · [使用方法](#-使用方法) · [实战案例](#-实战案例) · [使用技巧](#-使用技巧) · [English](../README.md)

</div>

---

## 📖 什么是 Kirby？

Kirby 每次迭代启动一个全新的 AI 实例，从 `prd.json` 中选取下一个未完成的用户故事，实现它，运行质量检查，提交代码，然后继续。跨迭代的记忆通过 git 历史、`progress.txt` 和 `prd.json` 持久化。

基于 [Geoffrey Huntley 的 Ralph 模式](https://ghuntley.com/ralph/)，为 [Kiro CLI](https://kiro.dev/cli/) 重新设计，原生集成 Custom Agent、Hooks 和 Steering。

### 架构图

```
┌──────────────────────────────────────────────────────────┐
│                      kirby.sh 循环                        │
│                                                           │
│  迭代 1               迭代 2               迭代 N         │
│  ┌────────────┐       ┌────────────┐       ┌────────────┐│
│  │ 全新 AI     │       │ 全新 AI     │       │ 全新 AI     ││
│  │             │       │             │       │             ││
│  │ 1. 读取 PRD │       │ 1. 读取 PRD │       │ 1. 读取 PRD ││
│  │ 2. 选择故事 │       │ 2. 选择故事 │       │ 2. 选择故事 ││
│  │ 3. 实现功能 │       │ 3. 实现功能 │       │ 3. 实现功能 ││
│  │ 4. 运行测试 │       │ 4. 运行测试 │       │ 4. 运行测试 ││
│  │ 5. 提交代码 │       │ 5. 提交代码 │       │ 5. 全部完成 ││
│  │ 6. 更新状态 │       │ 6. 更新状态 │       │ 6. COMPLETE ││
│  └────────────┘       └────────────┘       └────────────┘│
│        │                     │                     │      │
│        ▼                     ▼                     ▼      │
│  ┌──────────────────────────────────────────────────────┐│
│  │           共享记忆（持久化文件）                        ││
│  │  📋 prd.json      → 故事状态 (TODO/DONE)             ││
│  │  📝 progress.txt  → 经验教训与上下文                   ││
│  │  📦 git history   → 代码变更历史                       ││
│  │  🧠 AGENTS.md     → 发现的模式                        ││
│  └──────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────┘
```

### Kirby vs Ralph 对比

| 特性 | Ralph | Kirby |
|------|-------|-------|
| AI 工具 | Amp 或 Claude Code | **Kiro CLI**（+ Amp、Claude） |
| Prompt 传递 | 管道到 stdin | 位置参数 + agent 配置 |
| 工具权限 | `--dangerously-skip-permissions` | `--trust-all-tools`（可细粒度控制） |
| 上下文注入 | 手动（AI 自己读文件） | **agentSpawn hook**（自动） |
| 项目知识 | 仅 CLAUDE.md / prompt.md | **Steering 文件** + AGENTS.md + Hooks |
| MCP 支持 | 有限 | **原生支持** |

## 🧠 自驱模式（Autopilot / 圣人模式）

让 Kirby 自己搜索、研究、规划、开发——从一个模糊的想法到完整的项目。

```bash
# 给一个方向——Kirby 搜索全网、设计架构、生成 PRD、然后自动开发
./kirby.sh --autopilot "用 Next.js 14 构建一个实时聊天应用"

# 纯圣人模式——Kirby 自己扫描项目，自己决定一切
./kirby.sh --autopilot
```

### 自驱模式流程

1. **研究** — 搜索全网最佳实践、参考项目、技术栈推荐（保存到 `tasks/research.md`）
2. **架构** — 基于研究设计系统架构（保存到 `tasks/architecture.md`）
3. **PRD** — 编写完整的产品需求文档（保存到 `tasks/prd-*.md`）
4. **规划** — 将 PRD 转换为 8-20 个原子化用户故事写入 `prd.json`
5. **开发** — 进入 Kirby 正常循环，逐个实现每个故事

### 实测结果

测试项目："用 Next.js 14 构建番茄钟应用"

| 阶段 | 耗时 | 产出 |
|------|------|------|
| 研究与规划 | ~3 分钟 | research.md、architecture.md、PRD、prd.json（18 个故事）|
| 自动实现 | ~50 分钟 | 42 个源文件、23 次 git 提交 |
| 质量检查 | 全部通过 | TypeScript ✅ ESLint ✅ Build ✅ Jest（14 个测试）✅ |

## 📋 前置要求

| 依赖 | 安装方式 |
|------|---------|
| [Kiro CLI](https://kiro.dev/cli/) | `curl -fsSL https://cli.kiro.dev/install \| bash` |
| [jq](https://jqlang.github.io/jq/) | `brew install jq`（macOS）/ `apt install jq`（Ubuntu） |
| Git | 大多数系统已预装 |

**可选后端：**

| 工具 | 安装 | 参数 |
|------|------|------|
| [Amp](https://ampcode.com) | 见 ampcode.com | `--tool amp` |
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm i -g @anthropic-ai/claude-code` | `--tool claude` |

## 🚀 快速上手

```bash
# 1. 克隆
git clone https://github.com/neosun100/kirby.git

# 2. 复制到你的项目
cd your-project
cp /path/to/kirby/{kirby.sh,prompt.md,AGENTS.md} .
cp -r /path/to/kirby/.kiro .kiro
chmod +x kirby.sh

# 3. 创建 prd.json（编辑示例或使用 skill 生成）
cp /path/to/kirby/prd.json.example prd.json

# 4. 运行！
./kirby.sh
```

## 💻 使用方法

```
./kirby.sh [选项] [最大迭代次数]

选项:
  --tool kiro|amp|claude   AI 工具（默认: kiro）
  --autopilot [direction]  自驱模式: 搜索、研究、规划、开发
  --version                显示版本
  --help                   显示帮助

参数:
  最大迭代次数              循环最大次数（默认: 10）
```

```bash
./kirby.sh                 # Kiro，10 次迭代
./kirby.sh 20              # Kiro，20 次迭代
./kirby.sh --tool amp 5    # Amp，5 次迭代
./kirby.sh --tool claude   # Claude Code，10 次迭代
./kirby.sh --autopilot "用 Next.js 14 构建聊天应用"  # 自驱模式
./kirby.sh --autopilot     # 纯圣人模式
```

## 🔄 完整工作流

### 第一步 — 编写 PRD

在 Kiro 中使用 skill：

```
> 加载 prd skill，为我的 React 应用创建一个暗色模式切换功能的 PRD
```

或手动编写 `prd.json`：

<details>
<summary>📄 prd.json 格式（点击展开）</summary>

```json
{
  "project": "MyApp",
  "branchName": "kirby/dark-mode",
  "description": "添加暗色模式切换",
  "userStories": [
    {
      "id": "US-001",
      "title": "添加主题 Context",
      "description": "作为开发者，我需要一个 React Context 来管理主题状态。",
      "acceptanceCriteria": [
        "ThemeContext 提供 'light' 和 'dark' 两个值",
        "ThemeProvider 在 _app.tsx 中包裹整个应用",
        "类型检查通过"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

</details>

### 第二步 — 转换 PRD（可选）

```
> 加载 kirby skill，将 tasks/prd-dark-mode.md 转换为 prd.json
```

### 第三步 — 运行 Kirby

```bash
./kirby.sh
```

### 第四步 — 审查并推送

```bash
git log --oneline                                          # 查看提交
cat prd.json | jq '.userStories[] | {id, title, passes}'  # 查看状态
git push origin kirby/dark-mode                            # 推送
```

## 📚 实战案例

<details>
<summary><b>案例 1：REST API 端点</b></summary>

```json
{
  "project": "ExpressAPI",
  "branchName": "kirby/user-search",
  "description": "添加用户搜索端点",
  "userStories": [
    {
      "id": "US-001",
      "title": "在用户仓库中添加搜索查询",
      "acceptanceCriteria": [
        "UserRepository 有 findByName(query: string) 方法",
        "返回名称包含查询字符串的用户（不区分大小写）",
        "类型检查通过", "测试通过"
      ],
      "priority": 1, "passes": false, "notes": ""
    },
    {
      "id": "US-002",
      "title": "添加 GET /api/users/search 端点",
      "acceptanceCriteria": [
        "GET /api/users/search?q=john 返回匹配用户",
        "缺少 q 参数时返回 400",
        "无匹配时返回空数组",
        "类型检查通过", "测试通过"
      ],
      "priority": 2, "passes": false, "notes": ""
    }
  ]
}
```

</details>

<details>
<summary><b>案例 2：数据库迁移 + UI</b></summary>

```json
{
  "project": "TaskApp",
  "branchName": "kirby/task-tags",
  "description": "为任务添加标签系统",
  "userStories": [
    {
      "id": "US-001",
      "title": "创建标签表和关联表",
      "acceptanceCriteria": ["tags 表: id, name, color", "task_tags 关联表: task_id, tag_id", "迁移成功", "类型检查通过"],
      "priority": 1, "passes": false, "notes": ""
    },
    {
      "id": "US-002",
      "title": "添加标签 CRUD 服务端操作",
      "acceptanceCriteria": ["createTag 正常工作", "getTags 返回所有标签", "deleteTag 删除标签及关联", "类型检查通过"],
      "priority": 2, "passes": false, "notes": ""
    },
    {
      "id": "US-003",
      "title": "在任务卡片上显示标签",
      "acceptanceCriteria": ["彩色徽章显示", "最多 3 个，超出显示 +N", "类型检查通过"],
      "priority": 3, "passes": false, "notes": ""
    }
  ]
}
```

</details>

<details>
<summary><b>案例 3：Next.js 团队邀请系统</b></summary>

```json
{
  "project": "SaaSApp",
  "branchName": "kirby/invite-system",
  "description": "团队邀请系统",
  "userStories": [
    {"id":"US-001","title":"添加邀请表","acceptanceCriteria":["invitations 表: id, team_id, email, token, status, expires_at","迁移成功","类型检查通过"],"priority":1,"passes":false,"notes":""},
    {"id":"US-002","title":"创建邀请 server action","acceptanceCriteria":["createInvite 创建带唯一 token 的邀请","重复邮箱返回错误","类型检查通过","测试通过"],"priority":2,"passes":false,"notes":""},
    {"id":"US-003","title":"团队设置中添加邀请表单","acceptanceCriteria":["邮箱输入框 + 发送按钮","提交后显示成功/错误提示","类型检查通过"],"priority":3,"passes":false,"notes":""},
    {"id":"US-004","title":"接受邀请页面","acceptanceCriteria":["/invite/[token] 显示团队名和接受按钮","接受后加入团队","过期/无效 token 显示错误","类型检查通过"],"priority":4,"passes":false,"notes":""}
  ]
}
```

</details>

## 💡 使用技巧

### 编写好的用户故事

| ✅ 正确做法 | ❌ 错误做法 |
|------------|-----------|
| "添加 `status` 列，默认值 'pending'" | "改善数据库" |
| "点击删除按钮时显示确认对话框" | "删除功能要有好的用户体验" |
| 每个故事一个聚焦的变更 | 一个故事包含多个不相关的变更 |
| 每个故事都包含"类型检查通过" | 忘记质量检查 |
| 按依赖顺序排列（schema → 后端 → UI） | UI 排在后端之前 |

### 正确拆分故事

> **经验法则：** 如果不能用 2-3 句话描述这个变更，就需要拆分。

```
❌ "构建用户仪表盘"

✅ 拆分为：
   US-001: 添加仪表盘路由和空页面组件
   US-002: 添加统计查询（总用户数、今日活跃、本周新增）
   US-003: 在仪表盘页面添加统计卡片
   US-004: 添加最近活动列表组件
   US-005: 在仪表盘页面添加活动列表
```

### 使用 Steering 文件

```markdown
<!-- .kiro/steering/tech-stack.md -->
# 技术栈
- 框架：Next.js 14 App Router
- 数据库：PostgreSQL + Drizzle ORM
- 样式：Tailwind CSS
- 始终使用 server actions，不用 API routes
```

### 故障恢复

```bash
# 查看发生了什么
cat progress.txt | tail -30

# 方法 1：在 notes 中添加提示
jq '.userStories[0].notes = "使用 src/components/ui 中的 Button"' prd.json > tmp && mv tmp prd.json

# 方法 2：手动标记完成
jq '.userStories[0].passes = true' prd.json > tmp && mv tmp prd.json

# 方法 3：拆分为更小的故事（手动编辑 prd.json）

# 重新运行
./kirby.sh
```

### 提高效率的 4 个要点

1. 📝 **先写好 AGENTS.md** — 首次运行前添加项目关键模式
2. 🧭 **使用 steering 文件** — 告诉 Kirby 你的技术栈和约定
3. ⚛️ **保持故事原子化** — 一个变更、一个测试、一个提交
4. 🔍 **每个功能后审查** — 将 progress.txt 中的好经验提升到 AGENTS.md

## ⚙️ Kiro 集成原理

### Custom Agent（`.kiro/agents/kirby.json`）

- **预信任工具**：`read`、`write`、`shell` 无需确认
- **资源加载**：自动加载 `AGENTS.md` 和 `.kiro/steering/` 文件
- **agentSpawn Hook**：启动时自动注入 git 状态 + PRD 进度 + 最近经验

### Steering 文件

```
.kiro/steering/
├── project.md      # 项目约定
├── tech-stack.md   # 框架/库偏好
└── testing.md      # 测试模式
```

Kiro 每次迭代自动加载这些文件。

### AGENTS.md

Kiro 原生支持 [AGENTS.md 标准](https://agents.md/)。Kirby 更新这些文件中发现的模式，Kiro 在未来迭代中自动读取。

## 📁 项目结构

```
kirby/
├── kirby.sh                    # 主循环脚本
├── prompt.md                   # 每次迭代的 AI 指令
├── AGENTS.md                   # 项目模式（Kiro 自动加载）
├── prd.json.example            # PRD 格式示例
├── .kiro/
│   ├── agents/kirby.json       # Kiro 自定义 agent 配置
│   └── steering/               # Steering 文件目录（Kiro 自动加载）
│       └── example.md          # 示例 steering 文件
├── skills/
│   ├── prd/SKILL.md            # PRD 生成 skill
│   ├── kirby/SKILL.md          # PRD → JSON 转换 skill
│   └── autopilot/SKILL.md      # 自驱研究与规划 skill
├── docs/README_CN.md           # 中文文档
├── CHANGELOG.md                # 变更日志
├── CONTRIBUTING.md             # 贡献指南
└── LICENSE                     # MIT 许可证
```

## 🐛 调试

```bash
cat prd.json | jq '.userStories[] | {id, title, passes}'  # 故事状态
cat progress.txt                                            # 经验教训
git log --oneline -10                                       # git 历史
./kirby.sh 20                                               # 增加迭代次数
```

## 📄 许可证

[MIT](../LICENSE) © 2026 neosun100

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](../CONTRIBUTING.md) 了解详情。

变更日志：[CHANGELOG.md](../CHANGELOG.md)

## 🔗 参考链接

- [Geoffrey Huntley 的 Ralph 文章](https://ghuntley.com/ralph/)
- [Kiro CLI 文档](https://kiro.dev/docs/cli/)
- [Kiro Custom Agents](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)
- [Kiro Steering](https://kiro.dev/docs/cli/steering/)
- [Kiro Hooks](https://kiro.dev/docs/cli/hooks/)

---

<div align="center">

**如果 Kirby 帮你提高了效率，请给个 ⭐！**

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/kirby&type=Date)](https://star-history.com/#neosun100/kirby&Date)

</div>
