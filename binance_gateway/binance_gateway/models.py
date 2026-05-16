from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field


class KlineInterval(str, Enum):
    M1 = "1m"
    M5 = "5m"
    M15 = "15m"
    H1 = "1h"
    H4 = "4h"
    D1 = "1d"
    W1 = "1w"


class CandleData(BaseModel):
    open_time: int = Field(description="Open time in milliseconds")
    close_time: int = Field(description="Close time in milliseconds")
    open: float = Field(description="Open price")
    high: float = Field(description="High price")
    low: float = Field(description="Low price")
    close: float = Field(description="Close price")
    volume: float = Field(description="Volume")
    quote_volume: float = Field(default=0, description="Quote asset volume")
    trade_count: int = Field(default=0, description="Number of trades")
    is_final: bool = Field(default=False, description="Is this a final candle")


class KlineHistoryRequest(BaseModel):
    symbol: str = Field(description="Trading pair, e.g. BTCUSDT")
    interval: KlineInterval = Field(description="Kline interval")
    start_time: Optional[int] = Field(default=None, description="Start time in milliseconds")
    end_time: Optional[int] = Field(default=None, description="End time in milliseconds")
    limit: int = Field(default=500, ge=1, le=1500, description="Number of candles")


class KlineHistoryResponse(BaseModel):
    candles: List[CandleData]
    next_start_time: Optional[int] = Field(
        default=None,
        description="Next start time for pagination"
    )


class KlineWebSocketMessage(BaseModel):
    event_type: str = Field(default="kline")
    symbol: str
    interval: KlineInterval
    candle: CandleData
