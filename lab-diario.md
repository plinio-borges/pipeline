# 🧪 Laboratório Prático de DevSecOps

Este guia documenta o estudo de caso real de hardening,
diagnóstico e correção de falhas ocorridas na esteira
do GitHub Actions do Simulador de Cartões de Crédito.

---

## 📌 Contexto do Laboratório

Embora o foco seja o Hardening no Kubernetes (RBAC,
Network Policies, Pod Security e Secrets), a maturidade
exige que a nossa esteira de CI/CD seja resiliente.

Abaixo mapeamos os erros enfrentados e como resolvemos
cada barreira técnica sem mascarar os riscos.

---

## 🛑 Estação 1: Filtro de Severidade do SCA (Trivy fs)

### 🚨 O Sintoma
A esteira quebrava no passo do Trivy FileSystem com
`exit code 1`, mesmo tentando filtrar para falhar apenas
em vulnerabilidades críticas usando `CRITICAL,HIGH`.

### 🔍 O Diagnóstico de Engenharia
A Action do Trivy possui uma validação estrita de strings.
Ao receber a ordem invertida (`CRITICAL,HIGH`) ou espaços
(`HIGH, CRITICAL`), ela falha silenciosamente ao exportar
a variável global `TRIVY_SEVERITY`.

O scanner executava com o padrão de fábrica absoluto,
derrubando o build por falhas de nível Baixo ou Médio.

### 🛠️ A Solução Didática
Ajustamos a esteira no `.yml` para seguir a ordem
crescente de intensidade e sem espaços após a vírgula:

with:
  severity: 'HIGH,CRITICAL'
  exit-code: '1'

---

## 🛑 Estação 2: Downgrade do Pip (Trivy image)

### 🚨 O Sintoma
Mesmo com o filtro corrigido, o Scan da Imagem falhava
apontando vulnerabilidades `HIGH` nos pacotes do Python
(`setuptools`, `wheel`, `urllib3`, `msgpack`).

### 🔍 O Diagnóstico de Engenharia
1. O Paradoxo do Debian: Falhas no SO base (`debian:slim`)
não possuíam correções estáveis lançadas pelo fabricante.
Travar a esteira paralisaria as entregas de negócios.

2. O Downgrade Silencioso do Pip: O comando posterior
`pip install -r requirements.txt` instalava os pacotes do app.
Se uma biblioteca exigisse uma versão legada, o Pip
rebaixava as ferramentas de segurança automaticamente.

### 🛠️ A Solução Didática
1. Inversão das Camadas: Movemos a correção do Python
para ser a última palavra do ambiente (após o requirements).

2. Força Bruta: Adicionamos a flag `--force-reinstall`.

3. Gestão de Exceções (`.trivyignore`): Ignoramos falhas
de sistema sem correção oficial com `ignore-unfixed: true`,
deixando a mitigação sob responsabilidade do Kubernetes.

# Instalação do app primeiro
RUN pip install --no-cache-dir -r requirements.txt

# Blindagem do runtime por último, forçando reinstalação
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --upgrade --force-reinstall \
    setuptools>=78.1.1 wheel>=0.46.2

---

## 🛑 Estação 3: Tokens Invisíveis no DAST (OWASP ZAP)

### 🚨 O Sintoma
O OWASP ZAP quebrava com `exit code 3` exibindo:
`Unexpected number of tokens on line - there should be at least 3`.

### 🔍 O Diagnóstico de Engenharia
O motor do ZAP exige que o arquivo de regras (`rules.tsv`)
utilize tabulações físicas reais (`\t`) para separar as
colunas (ID, Ação e Nome). O arquivo original usava espaços
comuns, o que quebrou o interpretador sintático do contêiner.

### 🛠️ A Solução Didática
Substituímos os espaços por tabulações puras de sistema.
Reestruturamos o passo do JQ no `.yml` com blocos
condicionais (`if [ -f ...]`), garantindo mensagens
claras no sumário caso o relatório não seja gerado.

if [ -f zap-report/zap-report.json ]; then
  ALTOS=\$(jq '[.site[]?.alerts[]? | select(.riskcode=="3")] | length' ... )
else
  echo "- ❌ Erro: O arquivo JSON nao foi gerado." >> \$GITHUB_STEP_SUMMARY
  exit 1
fi

---

## 🧠 Lições Aprendidas de DevSecOps
1. Segurança em Camadas: Quando restrições de código
impedem a atualização, o risco deve ser aceito de forma
documentada (`.trivyignore`) e mitigado no Kubernetes
(ex: `allowPrivilegeEscalation: false`).

2. Resiliência: Pipelines não devem apenas rodar ferramentas,
mas prever falhas de ambiente e gerar mensagens claras.
