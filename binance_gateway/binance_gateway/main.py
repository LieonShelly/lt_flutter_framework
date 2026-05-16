import asyncio
import logging
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .kline_handler import KlineHandler
from .models import KlineHistoryRequest, KlineHistoryResponse, KlineInterval

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle."""
    handler = KlineHandler()
    app.state.kline_handler = handler
    yield
    await handler.close()


app = FastAPI(
    title="Binance Gateway",
    description="Unified gateway for Binance API",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/api/v1/kline/history", response_model=KlineHistoryResponse)
async def get_kline_history(request: KlineHistoryRequest):
    """
    Get historical kline data.

    This proxies Binance REST API /api/v3/klines endpoint.
    """
    handler: KlineHandler = app.state.kline_handler

    try:
        candles, next_start = await handler.fetch_history(
            symbol=request.symbol,
            interval=request.interval,
            start_time=request.start_time,
            end_time=request.end_time,
            limit=request.limit,
        )
        return KlineHistoryResponse(
            candles=candles,
            next_start_time=next_start,
        )
    except Exception as e:
        logger.error(f"Failed to fetch kline history: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "ok"}


@app.websocket("/ws/kline/{symbol}/{interval}")
async def websocket_kline(
    websocket: WebSocket,
    symbol: str,
    interval: str,
):
    """
    WebSocket endpoint for real-time kline updates.

    Connects to Binance WebSocket and forwards kline updates.
    """
    try:
        kline_interval = KlineInterval(interval)
    except ValueError:
        await websocket.close(code=4000, reason=f"Invalid interval: {interval}")
        return

    await websocket.accept()

    handler: KlineHandler = app.state.kline_handler

    try:
        await handler.handle_websocket(websocket, symbol, kline_interval)
    except WebSocketDisconnect:
        logger.info(f"Client disconnected: {websocket.client}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.close(code=1011, reason=str(e))


def run():
    """Run the server."""
    uvicorn.run(
        "binance_gateway.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info",
    )


if __name__ == "__main__":
    run()
