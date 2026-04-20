# Figma 插件开发
## 需求背景
- 如果在持续的独立开发或重度依赖 AI 生成代码的流中，REST API 的频控始终是个阻碍，可以考虑脱离 REST API 体系。
- Figma 的 Plugin API 运行在本地客户端内存中，拥有直接读取完整设计树的权限，完全不受 REST API 的限流约束。你可以编写一个极简的 Figma 本地插件，通过 WebSocket 协议，在后台静默地将当前选中的节点数据直接推送给你的 IDE，从而彻底绕过官方的 REST 频控墙，构建更顺畅的自动化开发体验。
- 我们要构建的架构本质上是一个 本地数据桥接通道，主要分为三层：
    - 数据采集层 (Figma Plugin)：运行在 Figma 客户端内，直接读取内存中的设计树（Node Tree），不需要通过网络请求 Figma 官方服务器。
    - 传输层 (WebSocket)：建立一个本地的 WebSocket 连接，将解析好的 UI 结构数据实时推送出来。
    - 服务层 (本地 MCP Server)：一个运行在本地的轻量级 Node.js/Python 服务，接收 WebSocket 数据，并将其转化为你的 AI IDE（如 Cursor / Kiro）可以理解的 MCP 协议格式。

- 在这个架构下，只要你在 Figma 里选中了某个图层，你的 AI 助手就能瞬间无延迟地拿到完整的组件节点结构，再也没有 HTTP 429 报错。

## 实施方案

### 第一步：搭建本地中转站 (WebSocket + MCP Server)
    - 你需要一个常驻本地的轻量级服务端。它的主要职责有两个：
        - 监听特定的端口（例如 ws://localhost:8080），等待 Figma 插件连接并接收设计稿数据。
        - 实现 MCP (Model Context Protocol) 接口，让你的 AI IDE 能够通过标准协议查询这些数据。你可以把接收到的 Figma 数据缓存在内存中，当 AI 触发 get_figma_selection 之类的 Tool 时，直接返回内存里的数据。

### 第二步：编写 Figma Plugin (核心突破口)
    - Figma 插件的运行环境分为两部分，这是实施过程中的一个关键技术细节：
        - Sandbox (code.ts)：拥有访问 Figma 文档树的全部权限（figma.currentPage.selection 等），但没有网络访问权限。
        - UI Iframe (ui.html)：这是一个隐藏的浏览器环境，拥有网络访问权限（fetch, WebSocket），但无法直接读取 Figma 文档。
        - 因此，插件的内部数据流向必须是：code.ts (读取选中节点) -> figma.ui.postMessage -> ui.html (接收消息) -> new WebSocket() 发送给本地 Server。

### 第三步：定义数据清洗与序列化协议
    - Figma 的原始节点数据（AST）非常庞大，包含大量 AI 不需要的信息（比如复杂的内部约束状态、无意义的包裹层等）。如果你直接把完整的原始 JSON 喂给大模型，不仅消耗 Token，还容易导致 AI 幻觉或抓不住重点。
    - 你需要在插件端（或者本地 Server 端）做一层过滤，只提取构建 UI 所需的核心属性：
    - 节点类型 (Frame, Text, Component 等)
    - 层级结构 (Children)
    - 布局信息 (Auto Layout 属性：Flex 对应的 direction, padding, spacing)
    - 样式数据 (颜色、字体、圆角、阴影)
    - 文本内容

