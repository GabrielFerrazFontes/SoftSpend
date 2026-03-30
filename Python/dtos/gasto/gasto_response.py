from pydantic import BaseModel


class GastoResponse(BaseModel):
    id: int
    titulo: str
    valor: float

    class Config:
        from_attributes = True