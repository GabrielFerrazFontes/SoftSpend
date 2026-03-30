from pydantic import BaseModel, field_validator
from typing import List
from datetime import datetime, date, timezone

class UserCreate(BaseModel):
    nome: str

class GastoCreate(BaseModel):
    titulo: str
    valor: float

class DiaCreate(BaseModel):
    data: datetime
    saldo: float
    gastos: List[GastoCreate]

class CicloCreate(BaseModel):
    valor_total: float
    periodo: str
    diaria: float
    id_usuario: int
    dias: List[DiaCreate]

class UserResponse(BaseModel):
    id: int
    nome: str

    class Config:
        from_attributes = True

class GastoResponse(BaseModel):
    id: int
    titulo: str
    valor: float

    class Config:
        from_attributes = True


class DiaResponse(BaseModel):
    id: int
    data: datetime
    saldo: float
    gastos: List[GastoResponse]

    @field_validator("data", mode="before")
    def ensure_utc(cls, v):
        if isinstance(v, date) and not isinstance(v, datetime):
            return datetime.combine(v, datetime.min.time(), tzinfo=timezone.utc)

        if isinstance(v, datetime):
            if v.tzinfo is None:
                return v.replace(tzinfo=timezone.utc)

        return v

    class Config:
        from_attributes = True


class CicloResponse(BaseModel):
    id: int
    valor_total: float
    gasto_total: float
    periodo: str
    diaria: float
    dias: List[DiaResponse]

    class Config:
        from_attributes = True