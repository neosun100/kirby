>微信公众号：**[AI健自习室]**
>关注Crypto与LLM技术、关注`AI-StudyLab`。问题或建议，请公众号留言。

# 🔥 全网首个 Kiro 自主 Agent 循环系统！一条命令让 AI 自动写完整个项目

> 【!info】
> 📌 项目地址：[https://github.com/neosun100/kirby](https://github.com/neosun100/kirby)
> 📌 作者：neosun100 | 协议：MIT 开源
> 📌 支持工具：Kiro CLI / Amp / Claude Code

> 🚀 **核心价值**：Kirby 是市面上**第一个专为 Kiro CLI 打造的自主 AI Agent 迭代循环系统**。你只需要写一份需求文档（PRD），运行一条命令 `./kirby.sh`，AI 就会自动一个接一个地实现所有用户故事——每次迭代都是全新的 AI 实例，直到所有需求全部完成。**从"人驱动 AI"到"AI 自驱动"，这才是 Agentic 编程的终极形态。**

![封面图](kirby-logo.png)

---

## 🤔 先聊一个灵魂问题：你真的在用 AI 编程吗？

2025 年，AI 编程工具已经遍地开花——Cursor、Windsurf、Claude Code、Amp、Kiro……

但你有没有发现一个尴尬的现实？

> 大多数时候，我们只是在**用 AI 写代码片段**，而不是在**让 AI 完成项目**。

你还是那个"人肉调度器"：手动拆任务、手动喂 prompt、手动检查结果、手动提交代码。AI 只是你手里的一把更快的锤子，但**挥锤的还是你**。

**Kirby 要改变的，正是这件事。**

它的核心理念只有一句话：

> **写好需求，按下回车，去喝杯咖啡。回来时，代码已经写完、测试已经通过、提交已经完成。**

---

## 📖 Kirby 是什么？一张图说清楚

Kirby 的工作原理极其优雅——一个 Bash 循环，每次迭代启动一个**全新的 AI 实例**：

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

**关键设计哲学：每次迭代 = 全新上下文。**

为什么？因为 AI 的上下文窗口是有限的。当一个任务太大，AI 会"迷路"。Kirby 的解决方案是：**每次只做一件事，做完就"重生"**。跨迭代的记忆通过 git 历史、`progress.txt` 和 `prd.json` 持久化。

这个模式源自 [Geoffrey Huntley 的 Ralph 模式](https://ghuntley.com/ralph/)，但 Kirby 做了一次**面向 Kiro 的深度重构**。

---

## ⚡ Kirby vs Ralph：为什么选 Kirby？

如果你了解 Ralph，可能会问：已经有 Ralph 了，为什么还需要 Kirby？

答案是：**Kirby 是为 Kiro 原生设计的，而 Ralph 不是。**

| 特性 | Ralph | Kirby |
|------|-------|-------|
| 🤖 AI 工具 | Amp 或 Claude Code | **Kiro CLI**（同时兼容 Amp、Claude） |
| 📨 Prompt 传递 | 管道到 stdin | 位置参数 + Agent 配置 |
| 🔐 工具权限 | `--dangerously-skip-permissions` | `--trust-all-tools`（可细粒度控制） |
| 🧠 上下文注入 | 手动（AI 自己读文件） | **agentSpawn Hook 自动注入** |
| 📚 项目知识 | 仅 CLAUDE.md / prompt.md | **Steering 文件 + AGENTS.md + Hooks** |
| 🔌 MCP 支持 | 有限 | **原生支持** |

> 💡 **划重点**：Kirby 的 `agentSpawn` Hook 是杀手级特性。每次 AI 实例启动时，它会**自动注入** git 状态、PRD 进度和最近的经验教训——AI 不需要"找"上下文，上下文直接"喂"给它。

---

## 🛠️ 3 分钟上手：从零到自动化

### 第一步：安装

```bash
# 安装 Kiro CLI（如果还没有）
curl -fsSL https://cli.kiro.dev/install | bash

# 克隆 Kirby
git clone https://github.com/neosun100/kirby.git

# 复制到你的项目
cd your-project
cp /path/to/kirby/{kirby.sh,prompt.md,AGENTS.md} .
cp -r /path/to/kirby/.kiro .kiro
chmod +x kirby.sh
```

### 第二步：写需求（PRD）

创建一个 `prd.json`，把你的需求拆成用户故事：

```json
{
  "project": "MyApp",
  "branchName": "kirby/dark-mode",
  "description": "添加暗色模式切换",
  "userStories": [
    {
      "id": "US-001",
      "title": "添加主题 Context",
      "acceptanceCriteria": [
        "ThemeContext 提供 'light' 和 'dark' 两个值",
        "ThemeProvider 在 _app.tsx 中包裹整个应用",
        "类型检查通过"
      ],
      "priority": 1,
      "passes": false
    }
  ]
}
```

> 📌 **小贴士**：也可以用 Kirby 内置的 Skill 自动生成 PRD！在 Kiro 中输入：`加载 prd skill，为我的 React 应用创建一个暗色模式切换功能的 PRD`

### 第三步：一条命令，坐等收工

```bash
./kirby.sh
```

就这么简单。Kirby 会：
1. 自动创建功能分支
2. 按优先级选取下一个未完成的故事
3. 实现功能代码
4. 运行质量检查（类型检查、测试等）
5. 通过后自动 `git commit`
6. 更新 `prd.json` 状态
7. 记录经验到 `progress.txt`
8. **循环，直到所有故事完成**

---

## 🏗️ 实战案例：Kirby 能做什么？

### 案例 1：REST API 端点开发

> 2 个用户故事 → Kirby 自动完成仓库层查询 + API 端点暴露 + 错误处理 + 测试

### 案例 2：数据库迁移 + UI 组件

> 3 个用户故事 → 自动完成建表迁移 → CRUD 服务端操作 → 前端标签展示组件，**全程零人工干预**

### 案例 3：Next.js 团队邀请系统

> 4 个用户故事 → 邀请表 → Server Action → 邀请表单 UI → 接受邀请页面，**一个完整的业务功能闭环**

> 🔥 **关键洞察**：Kirby 最擅长的是**中等粒度的功能开发**——不是"帮我写一行代码"，而是"帮我实现这个完整功能"。每个故事应该小到一次迭代能完成，大到有实际业务价值。

---

## 🧠 5 个让 Kirby 效率翻倍的技巧

### 1. 故事要"原子化"

| ✅ 正确 | ❌ 错误 |
|---------|---------|
| "添加 `status` 列，默认值 'pending'" | "改善数据库" |
| "点击删除按钮时显示确认对话框" | "删除功能要有好的用户体验" |
| 每个故事一个聚焦的变更 | 一个故事包含多个不相关的变更 |

> **经验法则**：如果不能用 2-3 句话描述这个变更，就需要拆分。

### 2. 先写好 AGENTS.md

在首次运行前，把项目的关键模式写进 `AGENTS.md`。Kiro 会自动加载它。

### 3. 善用 Steering 文件

```markdown
<!-- .kiro/steering/tech-stack.md -->
# 技术栈
- 框架：Next.js 14 App Router
- 数据库：PostgreSQL + Drizzle ORM
- 样式：Tailwind CSS
- 始终使用 server actions，不用 API routes
```

### 4. 按依赖排序故事

Schema → 后端 → UI，**永远不要把 UI 排在后端之前**。

### 5. 每个功能后审查

把 `progress.txt` 中的好经验提升到 `AGENTS.md`，让后续迭代越来越聪明。

---

## 🔧 Kiro 原生集成：为什么 Kirby 只有在 Kiro 上才能发挥最大威力？

Kirby 不是简单地"调用 Kiro CLI"，而是深度利用了 Kiro 的 3 大原生能力：

### 🎯 Custom Agent（自定义 Agent）

`.kiro/agents/kirby.json` 配置了：
- **预信任工具**：`read`、`write`、`shell` 无需确认
- **资源加载**：自动加载 `AGENTS.md` 和 Steering 文件
- **agentSpawn Hook**：启动时自动注入项目状态

### 🧭 Steering 文件

告诉 AI 你的项目约定、技术栈偏好、测试模式——Kiro 每次迭代自动加载。

### 📋 AGENTS.md 标准

Kiro 原生支持 [AGENTS.md 标准](https://agents.md/)。Kirby 在每次迭代中发现的模式会写入 AGENTS.md，Kiro 在未来迭代中自动读取——**AI 在自我进化**。

---

## ❓ 常见问题

**Q：Kirby 只能用 Kiro 吗？**
A：不是。Kirby 同时支持 `--tool amp` 和 `--tool claude`，但在 Kiro 上体验最佳（因为 Hook、Steering、AGENTS.md 等原生集成）。

**Q：如果某个故事卡住了怎么办？**
A：3 种恢复方式——在 `notes` 中添加提示、手动标记完成、或拆分为更小的故事。详见 README 的故障恢复章节。

**Q：PRD 必须手写吗？**
A：不用！Kirby 内置了 PRD 生成 Skill，在 Kiro 中用自然语言描述需求即可自动生成。

**Q：支持什么编程语言？**
A：任何 Kiro 支持的语言——Python、TypeScript、Java、Go、Rust 等等。

---

## 🌟 为什么说 Kirby 是 Agentic 编程的里程碑？

让我们拉远视角看看 AI 编程的演进：

```
2023: Copilot 时代     → AI 补全代码行
2024: Cursor 时代      → AI 编辑代码块
2025: Agent 时代       → AI 完成单个任务
2026: Kirby 时代  → AI 自主完成整个功能 🚀
```

Kirby 代表的不只是一个工具，而是一种**范式转移**：

- 从"人写代码，AI 辅助" → **"人写需求，AI 执行"**
- 从"单次对话" → **"多轮自主迭代"**
- 从"无状态交互" → **"有记忆的持续进化"**

这才是 Kiro 所倡导的 **Spec-Driven Development（规范驱动开发）** 的终极实践。

---

## 🚀 现在就开始

```bash
git clone https://github.com/neosun100/kirby.git
```

⭐ 如果 Kirby 帮你提高了效率，请给个 Star！

📖 中文文档：[docs/README_CN.md](https://github.com/neosun100/kirby/blob/main/docs/README_CN.md)

🤝 欢迎贡献：[CONTRIBUTING.md](https://github.com/neosun100/kirby/blob/main/CONTRIBUTING.md)

---

## 📚 参考资料

1. [Kirby GitHub 仓库](https://github.com/neosun100/kirby)
2. [Geoffrey Huntley 的 Ralph 文章](https://ghuntley.com/ralph/)
3. [Kiro CLI 官方文档](https://kiro.dev/docs/cli/)
4. [Kiro Custom Agents 配置参考](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)
5. [Kiro Steering 文件文档](https://kiro.dev/docs/cli/steering/)
6. [Kiro Hooks 文档](https://kiro.dev/docs/cli/hooks/)
7. [AGENTS.md 标准](https://agents.md/)

---

💬 **互动时间**：
对本文有任何想法或疑问？欢迎在评论区留言讨论！
如果觉得有帮助，别忘了点个"在看"并分享给需要的朋友～

![扫码_搜索联合传播样式-标准色版](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

👆 扫码关注，获取更多精彩内容
