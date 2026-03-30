from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from dtos import GastoResponse, GastoRequest
from services import gasto_service

router = APIRouter()

@router.post("/dias/{dia_id}/gastos", response_model=GastoResponse)
def criar_gasto(dia_id: int, gasto: GastoRequest, db: Session = Depends(get_db)):
    
    novo_gasto = gasto_service.criar_gasto(db, dia_id, gasto)

    return novo_gasto