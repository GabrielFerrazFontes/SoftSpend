from sqlalchemy.orm import Session
import models
from dtos.ciclo import CicloResponse, CicloRequest
from repositories import ciclo_repository


def montar_ciclo(ciclo: CicloRequest) -> models.Ciclo:
    novo_ciclo = models.Ciclo(
        valor_total=ciclo.valor_total,
        periodo=ciclo.periodo,
        diaria=ciclo.diaria,
        id_usuario=ciclo.id_usuario
    )

    gasto_total = 0

    for dia in ciclo.dias:
        novo_dia = models.Dia(
            data=dia.data,
            saldo=dia.saldo
        )

        for gasto in dia.gastos:
            novo_gasto = models.Gasto(
                titulo=gasto.titulo, 
                valor=gasto.valor
            )
            gasto_total += gasto.valor
            novo_dia.gastos.append(novo_gasto)

        novo_ciclo.dias.append(novo_dia)

    novo_ciclo.gasto_total = gasto_total

    return novo_ciclo


def criar_ciclo(db: Session, ciclo: CicloRequest):
    novo_ciclo = montar_ciclo(ciclo)
    return ciclo_repository.criar_ciclo(db, novo_ciclo)


def criar_varios(db: Session, ciclos: list[CicloRequest]):
    lista_ciclos = []

    for ciclo in ciclos:
        lista_ciclos.append(montar_ciclo(ciclo))

    return ciclo_repository.criar_varios(db, lista_ciclos)


def get_ciclo(db: Session, ciclo_id: int):
    return ciclo_repository.get_ciclo(db, ciclo_id)


def get_all_ciclos(db: Session, user_id: int):
    return ciclo_repository.get_all_ciclos(db, user_id)