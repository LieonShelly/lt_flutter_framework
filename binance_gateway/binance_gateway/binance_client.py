import asyncio
import json
import logging
from typing import Optional, AsyncIterator
import httpx
import websockets
from websockets.client import WebSocketClientProtocol

from .models import CandleData, KlineInterval

logger = logging.getLogger(__name__)


class BinanceClient:
    """Binance API client for REST and WebSocket."""

    BASE_REST_URL = "https://api.binance.com"
    BASE_WS_URL = "wss://stream.binance.com:9443/ws"

    def __init__(self, timeout: float = 30.0):
        self._client = httpx.AsyncClient(timeout=httpx.Timeout(timeout))
        self._ws: Optional[WebSocketClientProtocol] = None
        self._ws_task: Optional[asyncio.Task] = None

    async def close(self):
        """Close the client and all connections."""
        if self._ws:
            await self._ws.close()
        await self._client.aclose()

    async def get_klines(
        self,
        symbol: str,
        interval: KlineInterval,
        *,
        start_time: Optional[int] = None,
        end_time: Optional[int] = None,
        limit: int = 500,
    ) -> tuple[list[CandleData], Optional[int]]:
        """
        Fetch historical klines from Binance REST API.

        Returns:
            Tuple of (list of candles, next start time for pagination)
        """
        params = {
            "symbol": symbol.upper(),
            "interval": interval.value,
            "limit": limit,
        }
        if start_time:
            params["startTime"] = start_time
        if end_time:
            params["endTime"] = end_time

        url = f"{self.BASE_REST_URL}/api/v3/klines"
        async with self._client.get(url, params=params) as response:
            response.raise_for_status()
            raw = response.json()

        candles = [self._parse_kline(k) for k in raw]

        # Calculate nextStartTime if we got a full response
        next_start: Optional[int] = None
        if len(candles) == limit:
            next_start = candles[-1].open_time

        return candles, next_start

    async def subscribe_kline_stream(
        self,
        symbol: str,
        interval: KlineInterval,
    ) -> AsyncIterator[CandleData]:
        """
        Subscribe to Binance kline WebSocket stream.

        This yields individual CandleData as they arrive.
        The stream stays open until the connection is closed.
        """
        stream_id = f"{symbol.lower()}@{interval.value}_kline"
        ws_url = f"{self.BASE_WS_URL}/{stream_id}"

        async for ws in websockets.connect(ws_url, ping_interval=None):
            try:
                async for raw in ws:
                    data = json.loads(raw)
                    event = data.get("e")
                    if event == "kline":
                        k = data["k"]
                        yield self._parse_ws_kline(k, symbol.upper(), interval)
                    elif event == "error":
                        logger.error(f"Binance WS error: {data}")
            except websockets.ConnectionClosed:
                logger.warning("WebSocket connection closed, reconnecting...")
                continue
            except Exception as e:
                logger.error(f"Error in kline stream: {e}")
                await asyncio.sleep(1)
                continue

    def _parse_kline(self, raw: list) -> CandleData:
        """Parse a raw kline array from Binance REST API."""
        return CandleData(
            open_time=int(raw[0]),
            close_time=int(raw[6]),
            open=float(raw[1]),
            high=float(raw[2]),
            low=float(raw[3]),
            close=float(raw[4]),
            volume=float(raw[5]),
            quote_volume=float(raw[7]),
            trade_count=int(raw[8]),
            is_final=bool(raw[11]),
        )

    def _parse_ws_kline(
        self,
        k: dict,
        symbol: str,
        interval: KlineInterval,
    ) -> CandleData:
        """Parse a kline from Binance WebSocket stream."""
        return CandleData(
            open_time=int(k["t"]),
            close_time=int(k["T"]),
            open=float(k["o"]),
            high=float(k["h"]),
            low=float(k["l"]),
            close=float(k["c"]),
            volume=float(k["v"]),
            quote_volume=float(k["q"]),
            trade_count=int(k["n"]),
            is_final=bool(k["x"]),
        )
