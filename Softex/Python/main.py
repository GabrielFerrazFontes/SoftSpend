from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import *
from fastapi.middleware.cors import CORSMiddleware
from routes.ciclo_routes import router as ciclo_router
from routes.gasto_routes import router as gasto_router

import models, schemas

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ciclo_router)
app.include_router(gasto_router)

Base.metadata.create_all(bind=engine)

@app.post("/usuarios", response_model=schemas.UserResponse)
def criar_usuario(user: schemas.UserCreate, db: Session = Depends(get_db)):
    novo = models.User(nome=user.nome)
    db.add(novo)
    db.commit()
    db.refresh(novo)
    return novo

@app.get("/usuarios", response_model=list[schemas.UserResponse])
def listar_usuarios(db: Session = Depends(get_db)):
    return db.query(models.User).all()

