import asyncio
import json
import sys
import threading
import websockets
from mcp.server.fastmcp import FastMCP

# 内存中的全局状态，用于充当数据总线
# Figma 插件将数据写入这里，AI 助手从这里读取
LATEST_FIGMA_DATA = {
    "status": "waiting",
    "message": "暂无数据。请在 Figma 中选中图层，触发插件推送..."
}

# ==========================================
# 模块 1: WebSocket 服务 (接收端)
# ==========================================
async def handle_ws_client(websocket):
    """处理来自 Figma Plugin 的长连接"""
    global LATEST_FIGMA_DATA
    print("🟢 Figma Plugin 已连接到 WebSocket!", file=sys.stderr)
    
    try:
        async for message in websocket:
            try:
                # 接收并反序列化 Figma 推送的 UI 树数据
                data = json.loads(message)
                LATEST_FIGMA_DATA = data
                print(f"📥 收到 Figma 数据更新 | 节点类型: {data.get('type', 'Unknown')}", file=sys.stderr)
            except json.JSONDecodeError:
                print("❌ 收到无效的 JSON 数据", file=sys.stderr)
    except websockets.exceptions.ConnectionClosed:
        print("🔴 Figma Plugin 断开连接", file=sys.stderr)

async def start_ws_server():
    """启动 WebSocket 监听"""
    async with websockets.serve(handle_ws_client, "localhost", 8765):
        print("🚀 WebSocket Server 监听在 ws://localhost:8765", file=sys.stderr)
        await asyncio.Future()  # 保持运行

def run_ws_in_thread():
    """在独立线程中运行 asyncio 事件循环"""
    asyncio.run(start_ws_server())


# ==========================================
# 模块 2: MCP 服务 (输出端)
# ==========================================
# 使用 FastMCP 快速构建服务
mcp = FastMCP("Figma-Local-Bridge")

@mcp.tool()
def get_figma_selection() -> str:
    """
    获取开发者当前在 Figma 中选中的节点数据 (UI 树结构、颜色、布局参数等)。
    当需要分析设计稿、生成 UI 代码 (如 Flutter/iOS) 或获取布局约束时调用此工具。
    """
    return json.dumps(LATEST_FIGMA_DATA, ensure_ascii=False)


# ==========================================
# 入口点：双擎启动
# ==========================================
if __name__ == "__main__":
    # 1. 启动 WebSocket 后台线程
    ws_thread = threading.Thread(target=run_ws_in_thread, daemon=True)
    ws_thread.start()

    print("🛡️ Figma Bridge MCP 启动完毕，等待 IDE 连接...", file=sys.stderr)
    
    # 2. 启动 MCP 服务 (阻塞主线程，通过 stdio 通信)
    mcp.run()