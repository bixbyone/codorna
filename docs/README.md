estratégia
1) listar os requisitos de negocios e testes da rinha
2)  - atenção a regra de limites
3) listar os erros por tipo e quantidade
4) focar em fazer o arroz com feijão bem feito
5) focar em performance
6) - pool de conxões
   - multitenancy
   - mvcc
7) o que bash não conseguir nativamente importar de terceiros como lib
8) - converter api em c em lib importavel por abi bash
auto-scale vertical e horizontal por api, vm local, vm regional baseado no parametro de uso de 80% de cpu/memoria
- fases depois zero ko, zero lambança

      - #!/usr/bin/env bash
      
      # Pastas de resultados
      RESULTS_WORKSPACE="$(pwd)/load-test/user-files/results"
      GATLING_BIN_DIR=$HOME/gatling/bin
      GATLING_WORKSPACE="$(pwd)/load-test/user-files"
      
      # Função para capturar estatísticas do Docker
      get_docker_stats() {
        docker stats --no-stream --format "{{.ID}} {{.Names}} {{.CPUPerc}} {{.MemUsage}} {{.Networks}} {{.BlockIO}}"
      }
      
      # Função para capturar processos por filtro
      get_processes() {
        # Exemplos de filtros (alterar conforme a necessidade)
        local filter="$1"  # Filtro para pesquisa de processos
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
        get_docker_stats > "$RESULTS_WORKSPACE/docker/antes.log"
      
        # Iniciar htop em background (opcional)
        # htop -d 10 > "$RESULTS_WORKSPACE/htop/antes.log" &
        # htop_pid=$!
      
        # 2 requests para ativar as instâncias da API
        curl --fail http://localhost:9999/clientes/1/extrato && echo "" &&
        curl --fail http://localhost:9999/clientes/1/extrato && echo "" &&
      
        # Executar Gatling
        runGatling
      
        # Aguardar término do Gatling
        wait
      
        # Capturar estatísticas do Docker (depois)
        get_docker_stats > "$RESULTS_WORKSPACE/docker/depois.log"
      
        # Capturar processos relacionados ao teste (adaptar o filtro)
        get_processes "teste"
      
        # Capturar processos Java
        get_processes "java"
      
        # Capturar processos Gatling (adaptar o filtro, se necessário)
        get_processes "gatling" 
      
        # Finalizar htop (se iniciado)
        # kill $htop_pid
      }
      
      startTest
      
      #Capturar os processos do docker
      get_processes "docker" > "$RESULTS_WORKSPACE/docker.log"
