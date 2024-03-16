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
