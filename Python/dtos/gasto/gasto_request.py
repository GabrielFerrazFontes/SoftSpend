from pydantic import BaseModel

class GastoRequest(BaseModel):
    titulo: str
    valor: float