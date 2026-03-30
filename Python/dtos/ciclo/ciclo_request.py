from pydantic import BaseModel
from typing import List

from dtos import DiaRequest

class CicloRequest(BaseModel):
    valor_total: float
    periodo: str
    diaria: float
    id_usuario: int
    dias: List[DiaRequest]