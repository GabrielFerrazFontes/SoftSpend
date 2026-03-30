from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import *
from fastapi.middleware.cors import CORSMiddleware
from controllers.ciclo_controller import router as ciclo_router
from controllers.gasto_controller import router as gasto_router

import models, dtos

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ciclo_router, gasto_router)

Base.metadata.create_all(bind=engine)

@app.post("/usuarios", response_model=dtos.UserResponse)
def criar_usuario(user: dtos.UserCreate, db: Session = Depends(get_db)):
    novo = models.User(nome=user.nome)
    db.add(novo)
    db.commit()
    db.refresh(novo)
    return novo

@app.get("/usuarios", response_model=list[dtos.UserResponse])
def listar_usuarios(db: Session = Depends(get_db)):
    return db.query(models.User).all()

