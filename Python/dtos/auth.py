from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    nome: str
    username: str
    email: EmailStr
    senha: str


class LoginRequest(BaseModel):
    email: EmailStr
    senha: str


class AuthResponse(BaseModel):
    id: int
    nome: str
    username: str
    email: str
    token: str
