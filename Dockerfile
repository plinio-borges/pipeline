# Dockerfile do Simulador de Cartões de Crédito
# Usado no Laboratório de Segurança em Kubernetes (Minikube).
FROM python:3.11-slim

WORKDIR /app

# [NOTA DIDÁTICA] Atualização dos pacotes nativos da distribuição (Debian)
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser \
    && chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
