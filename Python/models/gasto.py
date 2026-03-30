from sqlalchemy import *
from database import Base
from sqlalchemy.orm import relationship

class Gasto(Base):
    __tablename__ = "gastos_dia"

    id = Column(Integer, primary_key=True)
    dia_id = Column(Integer, ForeignKey("dias.id"))
    titulo = Column(String(100))
    valor = Column(Float)

    dia = relationship("Dia", back_populates="gastos")