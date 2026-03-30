from pydantic import BaseModel
from typing import List
from datetime import datetime
from dtos import GastoRequest

class DiaRequest(BaseModel):
    data: datetime
    saldo: float
    gastos: List[GastoRequest]