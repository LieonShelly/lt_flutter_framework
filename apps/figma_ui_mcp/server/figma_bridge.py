import asyncio
import json
import sys
import threading
import websockets
from mcp.server.fastmcp import FastMCP

import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "latest_selection.json")

def get_fallback_data():
    return {
        "status": "waiting",
        "message": "暂无数据。请在 Figma 中选中图层，触发插件推送..."
    }

# ==========================================
# 模块 1: WebSocket 服务 (接收端)
# ==========================================
async def handle_ws_client(websocket):
    """处理来自 Figma Plugin 的长连接"""
    print("🟢 Figma Plugin 已连接到 WebSocket!", file=sys.stderr)
    
    try:
        async for message in websocket:
            try:
                # 接收并反序列化 Figma 推送的 UI 树数据
                data = json.loads(message)
                # 写入文件，使得不同的 MCP 进程可以共享数据
                with open(DATA_FILE, "w", encoding="utf-8") as f:
                    json.dump(data, f, ensure_ascii=False)
                
                if isinstance(data, list):
                    print(f"📥 收到 Figma 数据更新 | 选中根节点数量: {len(data)}", file=sys.stderr)
                else:
                    print(f"📥 收到 Figma 数据更新 | 节点类型: {data.get('type', 'Unknown') if isinstance(data, dict) else 'Unknown'}", file=sys.stderr)
            except json.JSONDecodeError:
                print("❌ 收到无效的 JSON 数据", file=sys.stderr)
    except websockets.exceptions.ConnectionClosed:
        print("🔴 Figma Plugin 断开连接", file=sys.stderr)

async def start_ws_server():
    """启动 WebSocket 监听"""
    try:
        async with websockets.serve(handle_ws_client, "localhost", 8765):
            print("🚀 WebSocket Server 监听在 ws://localhost:8765", file=sys.stderr)
            await asyncio.Future()  # 保持运行
    except OSError as e:
        print(f"⚠️ WebSocket 启动失败 (可能是被另一个实例占用): {e}", file=sys.stderr)

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
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, "r", encoding="utf-8") as f:
                return f.read()
        except Exception:
            return json.dumps(get_fallback_data(), ensure_ascii=False)
    return json.dumps(get_fallback_data(), ensure_ascii=False)


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