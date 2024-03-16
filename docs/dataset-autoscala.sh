#----------codigo original funciona------------------#

#!/usr/bin/env bash

# Use este script para executar testes locais

RESULTS_WORKSPACE="$(pwd)/load-test/user-files/results"
GATLING_BIN_DIR=$HOME/gatling/bin
GATLING_WORKSPACE="$(pwd)/load-test/user-files"

runGatling() {
    sh $GATLING_BIN_DIR/gatling.sh -rm local -s RinhaBackendCrebitosSimulation \
        -rd "Rinha de Backend - 2024/Q1: Crébito" \
        -rf $RESULTS_WORKSPACE \
        -sf "$GATLING_WORKSPACE/simulations"
}

startTest() {
    for i in {1..20}; do
        # 2 requests to wake the 2 api instances up :)
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        runGatling && \
        break || sleep 2;
    done
}

startTest
#---------codigo melhorado mas não funciona - versão amadora --------#

#!/usr/bin/env bash

# Pastas de resultados
RESULTS_WORKSPACE="$(pwd)/load-test/user-files/results"
GATLING_BIN_DIR=<span class="math-inline">HOME/gatling/3\.10\.3/bin
GATLING\_WORKSPACE\="</span>(pwd)/load-test/user-files"

# Função para capturar estatísticas do Docker
get_docker_stats() {
 docker stats --no-stream --format "{{.ID}} {{.Names}} {{.CPUPerc}} {{.MemUsage}} {{.Networks}} {{.BlockIO}}"
}

# Função para capturar processos Java
get_java_processes() {
 # Exemplo de filtro para processos Java
 local filter="java"
 ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/$filter.log"
}

# Função para capturar processos Gatling
get_gatling_processes() {
 # Exemplo de filtro para processos Gatling
 local filter="gatling"
 ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/$filter.log"
}

# Função para executar o Gatling
runGatling() {
 sh $GATLING_BIN_DIR/gatling.sh -rm local -s RinhaBackendCrebitosSimulation \
   -rd "Rinha de Backend - 2024/Q1: Crédito" \
   -rf "$RESULTS_WORKSPACE/gatling" \
   -sf "$GATLING_WORKSPACE/simulations" &> "$RESULTS_WORKSPACE/gatling.log" &
}

startTest() {
 # Criar pastas de resultados (se não existirem)
 mkdir -p "$RESULTS_WORKSPACE/docker" "$RESULTS_WORKSPACE/processes"

 # Capturar estatísticas do Docker (antes)

# ---codigo completo versão pleno/senior gcp ---funcional, testado, versionado, datado, documentado---#

#!/usr/bin/env bash

# =========================================================================
# Script para executar testes de carga com Gatling e coletar dados adicionais
# =========================================================================

# Configurações
RESULTS_WORKSPACE="$(pwd)/load-test/user-files/results"
GATLING_BIN_DIR=$HOME/gatling/3.10.3/bin
GATLING_WORKSPACE="$(pwd)/load-test/user-files"

# Funções
# -------------------------------------------------------------------------

# Capturar estatísticas do Docker
get_docker_stats() {
  docker stats --no-stream --format "{{.ID}} {{.Names}} {{.CPUPerc}} {{.MemUsage}} {{.Networks}} {{.BlockIO}}" > "$RESULTS_WORKSPACE/docker/antes.log"
}

# Capturar processos Java
get_java_processes() {
  # Exemplo de filtro para processos Java
  local filter="java"
  ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/processes/java.log"
}

# Capturar processos Gatling
get_gatling_processes() {
  # Exemplo de filtro para processos Gatling
  local filter="gatling"
  ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/processes/gatling.log"
}

# Executar o Gatling
runGatling() {
  sh $GATLING_BIN_DIR/gatling.sh -rm local -s RinhaBackendCrebitosSimulation \
    -rd "Rinha de Backend - 2024/Q1: Crédito" \
    -rf "$RESULTS_WORKSPACE/gatling" \
    -sf "$GATLING_WORKSPACE/simulations" &> "$RESULTS_WORKSPACE/gatling.log" &
}

# Iniciar teste
startTest() {
  # Criar pastas de resultados (se não existirem)
  mkdir -p "$RESULTS_WORKSPACE/docker" "$RESULTS_WORKSPACE/processes"

  # Capturar estatísticas do Docker (antes)
  get_docker_stats

  # Iniciar htop em background (opcional)
  htop -d 10 > "$RESULTS_WORKSPACE/htop/antes.log" &
  htop_pid=$!

  # 2 requests para ativar as instâncias da API
  curl --fail http://localhost:9999/clientes/1/extrato && echo "" &&
  curl --fail http://localhost:9999/clientes/1/extrato && echo "" &&

  # Executar Gatling
  runGatling

  # Aguardar término do Gatling
  wait

  # Capturar estatísticas do Docker (depois)
  get_docker_stats

  # Capturar processos Java
  get_java_processes

  # Capturar processos Gatling
  get_gatling_processes

  # Finalizar htop (se iniciado)
  kill $htop_pid

  # Gerar relatórios (opcional)
  # ...

}

# Execução
startTest

# Registrar data e hora da execução
echo "Data/Hora: $(date)" >> "$RESULTS_WORKSPACE/log.txt"

# ---fim da versão pleno/senior gcp---

# gpt em ação, parece menos verboso e quando comenta, o faz no codigo

#--"Parece que você está procurando melhorar um script Bash para testes de carga usando Gatling. Vou ajudá-lo a refinar ainda 
#mais o código. Aqui está uma versão melhorada do seu script com algumas melhorias:?"

#----- 1. Correção na definição de variáveis.
#----- 2. Adição de comentários para explicar as funções.
#----- 3. Melhor gerenciamento de erros e logs.
#----- 4. Inclusão de controle de processos Java e Gatling.

#!/usr/bin/env bash

# Pastas de resultados
RESULTS_WORKSPACE="$(pwd)/load-test/user-files/results"
GATLING_BIN_DIR="$HOME/gatling/3.10.3/bin"
GATLING_WORKSPACE="$(pwd)/load-test/user-files"

# Função para capturar estatísticas do Docker
get_docker_stats() {
    docker stats --no-stream --format "{{.ID}} {{.Names}} {{.CPUPerc}} {{.MemUsage}} {{.Networks}} {{.BlockIO}}" > "$RESULTS_WORKSPACE/docker_stats.log"
}

# Função para capturar processos Java
get_java_processes() {
    local filter="java"
    ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/java_processes.log"
}

# Função para capturar processos Gatling
get_gatling_processes() {
    local filter="gatling"
    ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/gatling_processes.log"
}

# Função para executar o Gatling
runGatling() {
    # echo "Iniciando Gatling..."
    sh "$GATLING_BIN_DIR/gatling.sh" -rm local -s RinhaBackendCrebitosSimulation \
        -rd "Rinha de Backend - 2024/Q1: Crédito" \
        -rf "$RESULTS_WORKSPACE/gatling" \
        -sf "$GATLING_WORKSPACE/simulations" &> "$RESULTS_WORKSPACE/gatling.log" &
    # echo "Gatling iniciado."
}

startTest() {
    # Criar pastas de resultados (se não existirem)
    mkdir -p "$RESULTS_WORKSPACE/docker" "$RESULTS_WORKSPACE/processes"

    # Capturar estatísticas do Docker (antes)
    get_docker_stats
    # Capturar processos Java (antes)
    get_java_processes
    # Capturar processos Gatling (antes)
    get_gatling_processes

    for i in {1..20}; do
        # 2 requests para ativar as 2 instâncias da API
        echo "Fazendo requests de aquecimento..."
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        runGatling && \
        break || sleep 2
    done
}


# Iniciar teste
startTest

# Esta versão melhora o seu script, tornando-o mais robusto, legível e fácil de manter. Certifique-se de ajustar as variáveis
# conforme necessário e testar em seu ambiente antes de usar em produção.

#-------------------------#

#!/usr/bin/env bash

# Pastas de resultados
RESULTS_WORKSPACE="$(pwd)/load-test/user-files/results"
GATLING_BIN_DIR="$HOME/gatling/3.10.3/bin"
GATLING_WORKSPACE="$(pwd)/load-test/user-files"

# Função para capturar estatísticas do Docker
get_docker_stats() {
    docker stats --no-stream --format "{{.ID}} {{.Names}} {{.CPUPerc}} {{.MemUsage}} {{.Networks}} {{.BlockIO}}" > "$RESULTS_WORKSPACE/docker_stats.log"
}

# Função para capturar processos Java
get_java_processes() {
    local filter="java"
    ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/java_processes.log"
}

# Função para capturar processos Gatling
get_gatling_processes() {
    local filter="gatling"
    ps -eo pid,user,comm | grep "$filter" > "$RESULTS_WORKSPACE/gatling_processes.log"
}

# Função para executar o Gatling
runGatling() {
    echo "Iniciando Gatling..."
    sh "$GATLING_BIN_DIR/gatling.sh" -rm local -s RinhaBackendCrebitosSimulation \
        -rd "Rinha de Backend - 2024/Q1: Crédito" \
        -rf "$RESULTS_WORKSPACE/gatling" \
        -sf "$GATLING_WORKSPACE/simulations" &> "$RESULTS_WORKSPACE/gatling.log" &
    echo "Gatling iniciado. Aguarde o término do teste..."
}

startTest() {
    # Criar pastas de resultados (se não existirem)
    mkdir -p "$RESULTS_WORKSPACE/docker" "$RESULTS_WORKSPACE/processes"

    # Capturar estatísticas do Docker (antes)
    get_docker_stats
    # Capturar processos Java (antes)
    get_java_processes
    # Capturar processos Gatling (antes)
    get_gatling_processes

    for i in {1..20}; do
        # 2 requests para ativar as 2 instâncias da API
        echo "Fazendo requests de aquecimento..."
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        runGatling && \
        break || sleep 2
    done

    # Aguardar até que o arquivo de log do Gatling seja criado, indicando o término do teste
    while [ ! -f "$RESULTS_WORKSPACE/gatling.log" ]; do
        echo "Aguardando término do teste..."
        sleep 5
    done
    echo "Teste concluído. Verifique os resultados em: $RESULTS_WORKSPACE"
}

# Iniciar teste
startTest

