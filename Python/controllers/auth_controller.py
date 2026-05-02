from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from database import get_db
from dtos.auth import RegisterRequest, LoginRequest, AuthResponse
from services import auth_service
from repositories import auth_repository

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=AuthResponse)
def register(dados: RegisterRequest, db: Session = Depends(get_db)):
    try:
        usuario = auth_service.registrar(db, dados)
        token = auth_service.criar_token(usuario.id)
        return AuthResponse(
            id=usuario.id,
            nome=usuario.nome,
            username=usuario.username,
            email=usuario.email,
            token=token
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login", response_model=AuthResponse)
def login(dados: LoginRequest, db: Session = Depends(get_db)):
    try:
        usuario, token = auth_service.login(db, dados)
        return AuthResponse(
            id=usuario.id,
            nome=usuario.nome,
            username=usuario.username,
            email=usuario.email,
            token=token
        )
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.get("/me")
def me(authorization: str = Header(None), db: Session = Depends(get_db)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token nao fornecido")
    
    token = authorization.replace("Bearer ", "")
    user_id = auth_service.validar_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Token invalido")
    
    usuario = auth_service.auth_repository.buscar_por_id(db, user_id)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario nao encontrado")
    
    return {
        "id": usuario.id,
        "nome": usuario.nome,
        "email": usuario.email
    }
