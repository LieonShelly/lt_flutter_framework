import asyncio
import json
import logging
from typing import Optional

import websockets
from websockets.client import WebSocketClientProtocol
from websockets.server import WebSocketServerProtocol, serve

from .binance_client import BinanceClient
from .models import KlineInterval, CandleData, KlineWebSocketMessage

logger = logging.getLogger(__name__)


class KlineHandler:
    """Handles kline requests by proxying Binance API."""

    def __init__(self):
        self._binance = BinanceClient()

    async def close(self):
        await self._binance.close()

    async def fetch_history(
        self,
        symbol: str,
        interval: KlineInterval,
        *,
        start_time: Optional[int] = None,
        end_time: Optional[int] = None,
        limit: int = 500,
    ) -> tuple[list[CandleData], Optional[int]]:
        """
        Fetch historical klines from Binance.

        Returns:
            Tuple of (candles, next_start_time)
        """
        return await self._binance.get_klines(
            symbol,
            interval,
            start_time=start_time,
            end_time=end_time,
            limit=limit,
        )

    async def handle_websocket(
        self,
        websocket: WebSocketClientProtocol,
        symbol: str,
        interval: KlineInterval,
    ):
        """
        Handle WebSocket connection from Flutter client.

        Subscribes to Binance kline stream and forwards messages.
        """
        symbol = symbol.upper()
        try:
            # Subscribe to Binance stream
            async for candle in self._binance.subscribe_kline_stream(symbol, interval):
                msg = KlineWebSocketMessage(
                    event_type="kline",
                    symbol=symbol,
                    interval=interval,
                    candle=candle,
                )
                await websocket.send(msg.model_dump_json())
        except websockets.ConnectionClosed:
            logger.info(f"Client disconnected: {websocket.remote_address}")
        except Exception as e:
            logger.error(f"Error in websocket handler: {e}")
        finally:
            await websocket.close()
