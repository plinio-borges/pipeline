"""
Configurações da aplicação — Simulador de Cartões de Crédito

ATENÇÃO: este arquivo contém vulnerabilidades intencionais para fins
didáticos no laboratório de SonarQube. Não utilizar como referência
de boas práticas.
"""
import os

# Modo debug ativo — nunca deve ir para produção
DEBUG = True

# Chave secreta da aplicação Flask, gravada diretamente no código-fonte
#SECRET_KEY = "banco_cartoes_2024_secret"

# Credenciais de banco de dados hardcoded
DB_HOST = os.getenv("DB_HOST","localhost")
DB_USER = os.getenv("DB_USER","admin")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME","cartoes_db")

# Chave de API de parceiro de bandeira de cartão, exposta no código
API_KEY_BANDEIRA = os.getenv("API_KEY_BANDEIRA")

UPLOAD_FOLDER = "/tmp/uploads"
