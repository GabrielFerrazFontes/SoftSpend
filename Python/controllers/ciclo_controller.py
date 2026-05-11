from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from dtos.ciclo import CicloResponse, CicloRequest
from services import ciclo_service

router = APIRouter()

@router.post("/ciclos", response_model=CicloResponse)
def criar_ciclo(ciclo: CicloRequest, db: Session = Depends(get_db)):
    return ciclo_service.criar_ciclo(db, ciclo)


@router.get("/ciclos/{ciclo_id}", response_model=CicloResponse)
def get_ciclo(ciclo_id: int, db: Session = Depends(get_db)):
    return ciclo_service.get_ciclo(db, ciclo_id)


@router.get("/usuario/ciclos/{user_id}", response_model=list[CicloResponse])
def get_all_ciclos(user_id: int, db: Session = Depends(get_db)):
    return ciclo_service.get_all_ciclos(db, user_id)


@router.get("/usuario/ciclos/resumo/{user_id}", response_model=list[CicloResponse])
def get_ciclos_resumo(user_id: int, db: Session = Depends(get_db)):
    return ciclo_service.get_ciclos_resumo(db, user_id)


@router.get("/ciclos/{ciclo_id}", response_model=CicloResponse)
def get_ciclo(ciclo_id: int, db: Session = Depends(get_db)):
    return ciclo_service.get_ciclo_by_id(db, ciclo_id)


@router.post("/ciclos/lote", response_model=list[CicloResponse])
def criar_varios(ciclos: list[CicloRequest], db: Session = Depends(get_db)):
    return ciclo_service.criar_varios(db, ciclos)