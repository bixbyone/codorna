 melhorias na arquitetura:

# Dockerfile 

- Adicionar libs necessárias como jq, sqlite-tools para auxiliar no processamento JSON e SQL
- Definir volumes para armazenar dados fora do container 

# Dockerfile.sqlite

- Definir volume para database 

# docker-compose.yml

- Separar serviços em containers independentes (API, Banco, Load Balancer)
- Escalar serviços (replicas de API)
- Limitar recursos (CPU/Memória) de cada serviço
- Configurar healthcheck no banco

# src/server.sh 

- Melhorar gestão de processos com supervisor como pm2 ou systemd
- Log de requests/respostas
- Tratamento de erros

# src/api.sh

- Validações de schemas com json schema 
- Tratamento de exceções 
- Logs estruturados
- Métricas básicas de resposta

# src/db.sh

- Configurações avançadas do sqlite (WAL, synchronous)
- Logs de queries
- Proteção de concorrência no acesso
- Pool de conexões

# Nginx

- Roteamento inteligente baseado em cabeçalhos 
- Balanceamento de carga 
- Cache de respostas
- WAF / Filtragem

# Testes

- API: testes unitários abrangentes
- Integração: isolar testes por serviço 
- Funcional: fluxos de ponta a ponta
- Performance / Estresse: simular carga alta

De forma geral, a arquitetura pode ser melhorada separando de forma clara cada conjunto de funcionalidade em serviços/containers
distintos e isolados, com gestão de processos, logs e métricas para garantir escalabilidade, desempenho e visibilidade.
