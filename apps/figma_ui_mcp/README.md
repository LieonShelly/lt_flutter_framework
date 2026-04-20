# Figma UI MCP

本项目是一个专业的 **Figma 设计稿实时数据桥梁**。它基于 Model Context Protocol (MCP) 标准构建，旨在将 Figma 中的 UI 设计属性（布局、样式、矢量图标等）实时同步给本地 AI 编程助手，实现“所见即所得”的代码自动生成体验。

## 1. 主要功能
- **打破沙箱隔离**：成功打通 Figma 设计稿的隔离环境与本地 AI IDE 的双向通信。
- **实时状态同步**：当用户在 Figma 中点选或改变选择时，插件会自动提取当前选中节点的最优 UI 数据（包括长宽、透明度、Auto Layout/Flex 属性、颜色、边框、圆角、阴影、以及文本内容）。
- **矢量图标自导出**：对于判定为图标（Icon）的矢量网络和节点，静默调用 Figma 原生 API，导出完整的 SVG 字符串供 AI 消费。
- **AI 赋能代码生成**：使得本地的大模型助手（如 Antigravity, Cursor, Windsurf）可以通过调用 `get_figma_selection` 这个 MCP 工具，瞬间获得精准的设计参数，从而可以几乎“零误差”地输出 Flutter、React 或 iOS 布局代码，免除了人工量尺寸、取色和拷贝文案的繁琐过程。

## 2. 架构原理与交互流程

由于 Figma 插件环境的底层 JS 沙箱有着极为严苛的安全限制（**无法写入系统文件、无法发送网络请求**），本项目采用了 **“双重桥接（Double Bridge）”** 架构：

![Architecture](https://img.icons8.com/color/48/000000/figma.png) ➔ ![WebSocket](https://img.icons8.com/color/48/000000/network.png) ➔ ![Python](https://img.icons8.com/color/48/000000/python.png) ➔ ![MCP](https://img.icons8.com/color/48/000000/ai.png)

1. **数据采集层：Figma Sandbox (`local_bridge_plugin/code.ts`)**
   - 运行在严格受限的沙箱中，监听 `selectionchange` 事件。
   - 使用异步递归算法提取并过滤图层树状数据。
   - 利用 `figma.ui.postMessage` 机制跨进程把数据投递给自身的 UI iframe。
2. **网络代理层：Figma UI Iframe (`local_bridge_plugin/ui.html`)**
   - 作为浏览器环境运行，具有网络权限。
   - 初始化时与 `ws://localhost:8765` 建立持久 WebSocket 连接。
   - 不作任何数据处理，纯粹作为一个“透明代理”，把沙箱发来的 JSON 实时转推给本地 Python 服务。
3. **数据中枢与输出层：本地服务 (`server/figma_bridge.py`)**
   - **引擎 A (后台长连接)**：启动 WebSocket Server 监听 `8765` 端口，一旦接收到新数据，立马将其序列化并覆盖写入到磁盘的 `latest_selection.json` 文件中。
   - **引擎 B (MCP 服务端)**：通过 `stdio` 劫持命令行标准输入输出，对外暴露 `get_figma_selection` 工具。当 AI 判定需要获取 UI 时调用该工具，脚本同步读取 `latest_selection.json` 并把结果直接喂给 LLM。
   - ***注：利用本地 JSON 文件作为媒介，极其优雅地解耦了 Figma 用户的高频“主动推送（Push）”与大模型的低频“被动拉取（Pull）”。***

## 3. 本地化配置指南

为了让整个链路跑起来，需要依次配置服务端、IDE 客户端与 Figma 插件：

### 步骤一：配置并初始化 Python 服务端
1. 进入 `server` 目录：
   ```bash
   cd server
   ```
2. 创建并启用 Python 虚拟环境（防止污染全局包）：
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. 安装核心依赖：
   ```bash
   pip install -r requirements.txt
   ```

### 步骤二：在 AI IDE 中注册 MCP
打开你所用大模型 IDE（如 Antigravity）的 MCP 配置文件（通常位于 `~/.gemini/antigravity/mcp_config.json` 或 `claude_desktop_config.json`），添加如下 STDIO 服务：

```json
{
  "mcpServers": {
    "FigmaLocalBridge": {
      "command": "你的绝对路径/server/venv/bin/python3",
      "args": [
        "你的绝对路径/server/figma_bridge.py"
      ],
      "env": {
        "FORCE_RELOAD": "1"
      }
    }
  }
}
```
> **注意：** 请务必把 `"你的绝对路径"` 替换为你当前电脑上的完整物理路径。配置完毕后，刷新或重启 AI 工具。

### 步骤三：编译并导入 Figma 插件
1. 进入插件目录并安装 Node 依赖（初次运行）：
   ```bash
   cd ../local_bridge_plugin
   npm install
   ```
2. 将 TypeScript 编译为 JavaScript：
   ```bash
   npm run build
   ```
3. 打开 Figma 桌面端软件，打开任何一个设计稿：
   - 右键点击空白处 ➔ 选择 **Plugins** ➔ **Development** ➔ **Import plugin from manifest...**
   - 在弹出的文件选择器中，定位到 `local_bridge_plugin/manifest.json` 并导入。

### 🚀 使用测试
1. 在 Figma 中运行你刚导入的插件。
2. 随意选中画布里的一个卡片或组件。
3. 在本地 IDE 对 AI 说：**“请读取 Figma 中的选中节点，帮我写一段 Flutter 还原代码。”**
4. 享受魔法吧！
