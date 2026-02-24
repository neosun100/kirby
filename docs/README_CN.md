# Kirby

> 基于 [Kiro CLI](https://kiro.dev/cli/) 的自主 AI Agent 迭代循环系统 — 自动逐条实现 PRD 中的用户故事直到全部完成。

[English](../README.md)

Kirby 每次迭代都会启动一个全新的 AI 实例，从 `prd.json` 中选取下一个未完成的用户故事，实现它，运行质量检查，提交代码，然后继续下一个。跨迭代的记忆通过 git 历史、`progress.txt` 和 `prd.json` 持久化。

同时支持 [Amp](https://ampcode.com) 和 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 作为替代后端。

基于 [Geoffrey Huntley 的 Ralph 模式](https://ghuntley.com/ralph/)，为 Kiro CLI 重新设计，原生集成 Custom Agent、Hooks 和 Steering。

## 工作原理

```
┌─────────────────────────────────────────────────────┐
│                   kirby.sh 循环                       │
│                                                      │
│  迭代 1              迭代 2              ...          │
│  ┌──────────┐        ┌──────────┐                    │
│  │ 全新 AI   │        │ 全新 AI   │                   │
│  │ 实例      │        │ 实例      │                   │
│  │           │        │           │                   │
│  │ 读取 PRD  │        │ 读取 PRD  │                   │
│  │ 选择 US-1 │        │ 选择 US-2 │                   │
│  │ 实现功能  │        │ 实现功能  │                   │
│  │ 运行测试  │        │ 运行测试  │                   │
│  │ 提交代码  │        │ 提交代码  │                   │
│  │ 更新状态  │        │ 更新状态  │                   │
│  └──────────┘        └──────────┘                    │
│       │                    │                          │
│       ▼                    ▼                          │
│  ┌─────────────────────────────────────┐             │
│  │  共享记忆（磁盘文件）                  │             │
│  │  • prd.json     (故事状态)           │             │
│  │  • progress.txt (经验教训)           │             │
│  │  • git history  (代码变更)           │             │
│  │  • AGENTS.md    (发现的模式)         │             │
│  └─────────────────────────────────────┘             │
│                                                      │
│  所有故事 passes:true? ──是──▶ 退出成功               │
└─────────────────────────────────────────────────────┘
```

## 前置要求

- 安装并认证 [Kiro CLI](https://kiro.dev/cli/)
  ```bash
  curl -fsSL https://cli.kiro.dev/install | bash
  ```
- 安装 `jq`（macOS: `brew install jq`，Ubuntu: `apt install jq`）
- 项目需要是一个 git 仓库

可选替代后端：
- [Amp CLI](https://ampcode.com)（`--tool amp`）
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)（`--tool claude`）

## 5 分钟快速上手

```bash
# 1. 克隆 kirby
git clone https://github.com/neosun100/kirby.git

# 2. 复制到你的项目
cd your-project
cp /path/to/kirby/kirby.sh .
cp /path/to/kirby/prompt.md .
cp /path/to/kirby/AGENTS.md .
cp -r /path/to/kirby/.kiro .kiro
chmod +x kirby.sh

# 3. 创建 prd.json（参考示例或使用 skill 生成）
cp /path/to/kirby/prd.json.example prd.json
# 编辑 prd.json，填入你的用户故事...

# 4. 运行
./kirby.sh
```

## 使用方法

```
./kirby.sh [选项] [最大迭代次数]

选项:
  --tool kiro|amp|claude   使用的 AI 工具（默认: kiro）
  --help                   显示帮助信息

参数:
  最大迭代次数              循环最大次数（默认: 10）
```

**示例：**
```bash
./kirby.sh                 # Kiro CLI，10 次迭代
./kirby.sh 20              # Kiro CLI，20 次迭代
./kirby.sh --tool amp 5    # Amp，5 次迭代
./kirby.sh --tool claude   # Claude Code，10 次迭代
```

## 完整工作流

### 第一步：编写 PRD

可以手动编写 `prd.json`，也可以使用 Kiro skill：

```
> 加载 prd skill，为我的 React 应用创建一个暗色模式切换功能的 PRD
```

Skill 会提出澄清问题，然后保存结构化 PRD 到 `tasks/prd-dark-mode.md`。

### 第二步：转换为 prd.json

```
> 加载 kirby skill，将 tasks/prd-dark-mode.md 转换为 prd.json
```

或者手动编写，格式如下：

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

### 第三步：运行 Kirby

```bash
./kirby.sh
```

观察 Kirby 自主实现每个故事，每次迭代一个。

### 第四步：审查并推送

```bash
# 查看 Kirby 做了什么
git log --oneline
cat prd.json | jq '.userStories[] | {id, title, passes}'
cat progress.txt

# 满意后推送
git push origin kirby/dark-mode
```

## 实战案例

### 案例 1：添加 REST API 端点

```json
{
  "project": "ExpressAPI",
  "branchName": "kirby/user-search",
  "description": "添加用户搜索端点",
  "userStories": [
    {
      "id": "US-001",
      "title": "在用户仓库中添加搜索查询",
      "description": "在 UserRepository 中添加 findByName 方法。",
      "acceptanceCriteria": [
        "UserRepository 有 findByName(query: string) 方法",
        "返回名称包含查询字符串的用户（不区分大小写）",
        "类型检查通过",
        "测试通过"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "添加 GET /api/users/search 端点",
      "description": "通过 REST API 暴露用户搜索功能。",
      "acceptanceCriteria": [
        "GET /api/users/search?q=john 返回匹配的用户",
        "缺少 q 参数时返回 400",
        "无匹配时返回空数组",
        "类型检查通过",
        "测试通过"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### 案例 2：数据库迁移 + UI

```json
{
  "project": "TaskApp",
  "branchName": "kirby/task-tags",
  "description": "为任务添加标签系统",
  "userStories": [
    {
      "id": "US-001",
      "title": "创建标签表和关联表",
      "description": "任务与标签的多对多关系数据库 schema。",
      "acceptanceCriteria": [
        "tags 表包含 id, name, color 列",
        "task_tags 关联表包含 task_id, tag_id",
        "迁移成功运行",
        "类型检查通过"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "添加标签 CRUD 服务端操作",
      "description": "创建、读取、删除标签的后端逻辑。",
      "acceptanceCriteria": [
        "createTag(name, color) 操作正常工作",
        "getTags() 返回所有标签",
        "deleteTag(id) 删除标签及关联记录",
        "类型检查通过"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-003",
      "title": "在任务卡片上显示标签",
      "description": "在每个任务卡片上以彩色徽章显示已分配的标签。",
      "acceptanceCriteria": [
        "标签以彩色徽章显示在任务卡片上",
        "最多显示 3 个标签，超出显示 +N",
        "类型检查通过"
      ],
      "priority": 3,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## 使用技巧

### 编写好的用户故事

| ✅ 正确做法 | ❌ 错误做法 |
|------------|-----------|
| "添加 `status` 列，默认值 'pending'" | "改善数据库" |
| "点击删除按钮时显示确认对话框" | "删除功能要有好的用户体验" |
| 每个故事一个聚焦的变更 | 一个故事包含多个不相关的变更 |
| 每个故事都包含"类型检查通过" | 忘记质量检查 |
| 按依赖顺序排列（schema → 后端 → UI） | UI 排在后端之前 |

### 正确拆分故事

**经验法则：** 如果不能用 2-3 句话描述这个变更，就需要拆分。

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

创建 `.kiro/steering/` 文件，给 Kirby 提供项目特定的知识：

```markdown
<!-- .kiro/steering/tech-stack.md -->
# 技术栈
- 框架：Next.js 14 App Router
- 数据库：PostgreSQL + Drizzle ORM
- 样式：Tailwind CSS
- 测试：Vitest + React Testing Library
- 始终使用 server actions，不用 API routes
```

### 故障恢复

如果 Kirby 在某个故事上卡住了：

```bash
# 查看发生了什么
cat progress.txt | tail -30

# 方法 1：手动修复并标记完成
# 编辑 prd.json，将卡住的故事设为 passes: true

# 方法 2：在故事的 notes 字段添加提示
jq '.userStories[0].notes = "使用 src/components/ui 中已有的 Button 组件"' prd.json > tmp && mv tmp prd.json

# 方法 3：将故事拆分为更小的部分

# 然后重新运行
./kirby.sh
```

### 提高迭代效率

1. **先写好 AGENTS.md** — 在首次运行前添加项目的关键模式
2. **使用 steering 文件** — 告诉 Kirby 你的技术栈和约定
3. **保持故事原子化** — 一个变更、一个测试、一个提交
4. **每个功能完成后审查** — 检查 progress.txt 中的经验，将好的提升到 AGENTS.md

## Kiro 集成原理

### Custom Agent（`.kiro/agents/kirby.json`）

Kirby 的 agent 配置提供：
- **预信任工具**：`read`、`write`、`shell` 无需确认即可使用
- **资源加载**：自动加载 `AGENTS.md` 和 `.kiro/steering/` 文件
- **agentSpawn Hook**：启动时自动注入 git 状态、PRD 进度和最近的经验教训

### 与 Ralph 的对比

| 特性 | Ralph | Kirby |
|------|-------|-------|
| AI 工具 | Amp 或 Claude Code | Kiro CLI（+ Amp、Claude） |
| Prompt 传递 | 管道到 stdin | 位置参数 + agent 配置 |
| 工具权限 | `--dangerously-skip-permissions` | `--trust-all-tools`（可细粒度控制） |
| 上下文注入 | 手动（AI 自己读文件） | agentSpawn hook（自动） |
| 项目知识 | 仅 CLAUDE.md / prompt.md | Steering 文件 + AGENTS.md + Hooks |
| MCP 支持 | 有限 | 原生支持 |

## 关键文件

| 文件 | 用途 |
|------|------|
| `kirby.sh` | 主循环脚本 |
| `prompt.md` | 每次迭代的 AI 指令 |
| `.kiro/agents/kirby.json` | Kiro 自定义 agent 配置 |
| `prd.json` | 用户故事及完成状态 |
| `prd.json.example` | PRD 格式示例 |
| `progress.txt` | 只追加的经验日志 |
| `AGENTS.md` | 项目模式（Kiro 自动加载） |
| `skills/prd/SKILL.md` | PRD 生成 skill |
| `skills/kirby/SKILL.md` | PRD 转 JSON skill |

## 调试

```bash
# 查看故事状态
cat prd.json | jq '.userStories[] | {id, title, passes}'

# 查看经验教训
cat progress.txt

# 查看 git 历史
git log --oneline -10

# 增加迭代次数重新运行
./kirby.sh 20
```

## 自动归档

当 prd.json 中的 `branchName` 发生变化时，Kirby 会自动归档上一次运行的文件到 `archive/YYYY-MM-DD-feature-name/`。

## 参考链接

- [Geoffrey Huntley 的 Ralph 文章](https://ghuntley.com/ralph/)
- [Kiro CLI 文档](https://kiro.dev/docs/cli/)
- [Kiro Custom Agents](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)
- [Kiro Steering](https://kiro.dev/docs/cli/steering/)
- [Kiro Hooks](https://kiro.dev/docs/cli/hooks/)
