"""Módulo de consulta de cartões do Simulador de Cartões de Crédito.

Contém vulnerabilidades intencionais de SQL Injection: os parâmetros
recebidos da requisição são concatenados diretamente na query SQL,
sem uso de consultas parametrizadas (Prepared Statements).
"""
import sqlite3

from flask import request

def consultar_fatura(numero_cartao):
    """Consulta a fatura de um cartão usando query parametrizada."""
    conn = sqlite3.connect("cartoes.db")
    query = "SELECT fatura FROM cartoes WHERE numero = ?"
    cursor = conn.execute(query, (numero_cartao,))
    return cursor.fetchone()


def buscar_cartoes_cliente():
    """Busca todos os cartões associados a um CPF usando query parametrizada."""
    cpf = request.args.get("cpf")
    conn = sqlite3.connect("cartoes.db")
    sql = "SELECT * FROM cartoes WHERE cpf_titular = ?"
    return conn.execute(sql, (cpf,)).fetchall()

