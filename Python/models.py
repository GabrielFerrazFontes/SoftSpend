from sqlalchemy import *
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100))

class Ciclo(Base):
    __tablename__ = "ciclos"

    id = Column(Integer, primary_key=True, index=True)
    valor_total = Column(Float)
    gasto_total = Column(Float)
    periodo = Column(String(50))
    diaria = Column(Float)
    id_usuario = Column(Integer)

    dias = relationship("Dia", back_populates="ciclo")


class Dia(Base):
    __tablename__ = "dias"

    id = Column(Integer, primary_key=True)
    ciclo_id = Column(Integer, ForeignKey("ciclos.id"))
    data = Column(DateTime(timezone=True))
    saldo = Column(Float)

    ciclo = relationship("Ciclo", back_populates="dias")
    gastos = relationship("Gasto", back_populates="dia")

class Gasto(Base):
    __tablename__ = "gastos_dia"

    id = Column(Integer, primary_key=True)
    dia_id = Column(Integer, ForeignKey("dias.id"))
    titulo = Column(String(100))
    valor = Column(Float)

    dia = relationship("Dia", back_populates="gastos")