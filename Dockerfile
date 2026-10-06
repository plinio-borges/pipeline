# Dockerfile do Simulador de Cartões de Crédito
# Usado no Laboratório de Segurança em Kubernetes (Minikube).
#
# Este Dockerfile segue boas práticas básicas de construção de imagem
# (usuário não-root, imagem slim, dependências fixadas) porque o foco
# deste laboratório é o hardening da CAMADA DE KUBERNETES — RBAC,
# Network Policies, Pod Security e Secrets — não da imagem em si.
# O código da aplicação, propositalmente, continua com as
# vulnerabilidades estudadas nos laboratórios de SonarQube e Semgrep.

FROM python:3.11-slim

WORKDIR /app

# [NOTA DIDÁTICA] Atualização dos pacotes nativos da distribuição (Debian)
# Adicionado para mitigar falhas de nível HIGH/CRITICAL identificadas pelo Trivy no SO (util-linux, ncurses, etc.)
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# [NOTA DIDÁTICA] Atualização das ferramentas base do ecossistema Python
# Necessário para corrigir falhas de nível HIGH ocultas em sub-dependências do setuptools (wheel e jaraco.context)
#RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# [NOTA DIDÁTICA] Correção Cirúrgica das dependências base do Python.
# Forçamos o Pip a instalar estritamente as versões seguras indicadas no relatório SARIF anterior.
RUN pip install --no-cache-dir \
    pip==24.0 \
    setuptools==78.1.1 \
    wheel==0.46.2 \
    urllib3==2.8.0 \
    msgpack==1.2.1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser \
    && chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
