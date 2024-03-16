## Rinha de Backend - 2024/Q1: Explicação Passo a Passo (em português)

### 1. Estrutura da Solução

#### 1.1. Requerimentos de Negócio

**1.1.1. Lógica de Negócio:**

* API HTTP com endpoints para transações e extrato.
* Suporte para créditos (`c`) e débitos (`d`).
* Controle de concorrência com limite de saldo por cliente.
* Validação de ID de cliente e limite de transações.

**1.1.2. Teste Unitário:**

* Testes para as funcionalidades da API.
* Cobertura de código adequada.

**1.1.3. Teste Funcional:**

* Testes de ponta a ponta para verificar o fluxo completo.
* Validação de respostas HTTP e dados retornados.

**1.1.4. Teste de Integração:**

* Testes para verificar a comunicação entre os componentes da solução.
* Simulação de diferentes cenários de uso.

**1.1.5. Estrutura de Arquivos:**

* Seguir a estrutura padrão para organização do código e demais arquivos.
* Facilitar a leitura e o entendimento da solução.

**1.1.6. Profiling:**

* Identificar gargalos de performance e otimizar o código.
* Melhorar o desempenho da API.

**1.1.7. Teste de Stress:**

* Simular carga elevada para verificar a escalabilidade da solução.
* Identificar pontos de falha e melhorar a robustez da API.

#### 1.2. Tecnologia

* API em Bash.
* Banco de dados SQLite in-memory.
* Arquitetura multi-tenant.
* MVCC

#### 1.3. Requisitos de Negócio Detalhados

**1.3.1. Endpoints da API:**

* **Transações:**
    * POST /clientes/[id]/transacoes
    * Parâmetros:
        * `valor`: Inteiro positivo em centavos.
        * `tipo`: `c` para crédito ou `d` para débito.
        * `descricao`: String de 1 a 10 caracteres.
    * Resposta:
        * HTTP 200 OK com JSON contendo `limite` e `saldo`.
        * HTTP 422 Unprocessable Entity se a transação deixar o saldo negativo.
        * HTTP 404 Not Found se o ID do cliente não for encontrado.
* **Extrato:**
    * GET /clientes/[id]/extrato
    * Parâmetros:
        * `id`: Inteiro positivo.
    * Resposta:
        * HTTP 200 OK com JSON contendo `saldo`, `limite` e `ultimas_transacoes`.
        * HTTP 404 Not Found se o ID do cliente não for encontrado.

**1.3.2. Regras de Negócio:**

* Saldo nunca pode ser negativo.
* Débito não pode deixar o saldo menor que o limite.
* Limite e saldo inicial dos clientes pré-definidos.

**1.3.3. Estrutura da API:**

* Código em Bash organizado em scripts modulares.
* Fácil de ler, entender e modificar.

**1.3.4. Banco de Dados:**

* SQLite in-memory para simplicidade e velocidade.
* Ideal para testes de performance.

**1.3.5. Arquitetura Multi-Tenant:**

* Cada cliente é isolado em seu próprio banco de dados.
* Evita conflitos de dados e garante escalabilidade.

**1.3.6. Testes:**

* Testes unitários, funcionais e de integração.
* Teste de stress para avaliar a performance.

**1.3.7. Entrega:**

* Pull request no repositório da Rinha de Backend.
* Contém código-fonte, Dockerfile e instruções de instalação.

### 2. Considerações Adicionais

#### 2.1. Monitoramento

* Monitorar CPU, memória e outros recursos durante o teste.
* Identificar gargalos e otimizar a solução.

#### 2.2. Segurança

* Implementar medidas de segurança básicas na API.
* Evitar ataques e proteger dados dos clientes.

#### 2.3. Documentação

* Documentar a API e os testes realizados.
* Facilitar o uso e a compreensão da solução.

### 3. Recursos Adicionais

* Repositório da Rinha de Backend 2023/Q3: [https://github.com/zanfranceschi/rinha-de-backend-2023-q3](https://github.com/zanfranceschi/rinha-de-backend-2023-q3)
* [Documentação do


# --------------#versão 2-----------#

## Desvendando a Rinha de Backend 2024/Q1: Guia Completo e Passo a Passo

**Prepare-se para o desafio:**

A Rinha de Backend 2024/Q1 está de volta! Nesta edição, o foco é em controle de concorrência com transações de créditos e débitos, inspirado pelos especialistas Lucas C. e Kmyokoyama.

**Objetivo da Rinha:**

Desenvolver uma API HTTP robusta e performante para gerenciar transações financeiras, com foco em:

- **Controle de concorrência:** garantir a consistência do saldo mesmo com alto volume de transações simultâneas.
- **Desempenho:** lidar com carga de trabalho intensa e responder às requisições de forma rápida e eficiente.

**Requisitos da API:**

**1. Transações:**

* **Endpoint:** `POST /clientes/[id]/transacoes`
* **Dados da Transação:**
    - `valor`: valor em centavos (ex: R$ 10 = 1000 centavos)
    - `tipo`: "c" para crédito ou "d" para débito
    - `descricao`: string de 1 a 10 caracteres
* **Respostas:**
    - **Sucesso:** HTTP 200 OK com `limite` e `saldo` atualizados
    - **Saldo Insuficiente:** HTTP 422 com corpo customizável
    - **Cliente Inexistente:** HTTP 404
    - **Outros Erros:** HTTP 4XX ou 5XX com corpo informativo

**2. Extrato:**

* **Endpoint:** `GET /clientes/[id]/extrato`
* **Resposta:**
    - **Saldo:**
        - `total`: saldo atual
        - `data_extrato`: data/hora da consulta
        - `limite`: limite do cliente
    - **Últimas Transações:**
        - Lista de até 10 transações (ordenada por data/hora decrescente)
        - Detalhes da transação: `valor`, `tipo`, `descricao`, `realizada_em`

**3. Cadastro Inicial de Clientes:**

Cinco clientes pré-cadastrados para teste:

| ID | Limite | Saldo Inicial |
|---|---|---|
| 1 | 100.000 | 0 |
| 2 | 80.000 | 0 |
| 3 | 1.000.000 | 0 |
| 4 | 10.000.000 | 0 |
| 5 | 500.000 | 0 |

**Observações:**

- Não cadastre o cliente com ID 6, pois ele é usado para testar o retorno de HTTP 404.
- Utilize apenas os IDs pré-definidos para evitar erros.

**Sua Missão:**

1. Desenvolva a API em Java, Python, Go, C#, JavaScript ou qualquer linguagem de sua preferência.
2. Implemente os endpoints e funcionalidades descritas.
3. Utilize um banco de dados relacional ou não relacional (exceto Redis).
4. Crie um arquivo `docker-compose.yml` com todos os serviços da sua API.
5. Limite o consumo de CPU e memória dos seus serviços (soma total <= 1.5 CPU e 550MB).
6. Siga a arquitetura mínima:
    - Load balancer (Nginx ou outro)
    - 2 instâncias do servidor web
    - Banco de dados
7. Prepare um README.md com:
    - Seu nome, tecnologias usadas e link para o código-fonte da API.
    - Contatos para caso vença a Rinha.
8. Envie sua submissão como pull request para este repositório até 10/03/2024 às 23:59:59.

**Dicas para o Sucesso:**

- Utilize ferramentas como Gatling para testar a performance da sua API sob carga.
- Monitore o consumo de CPU e memória durante os testes.
- Otimize seu código para garantir eficiência e escalabilidade.
- Revise a documentação e os exemplos fornecidos.

**Recursos Úteis:**

- **Repositório da Rinha:** [https://github.com/zanfranceschi/rinha-de-backend-2024-q1](https://github.com/zanfranceschi/rinha-de-backend-2024-q1)
- **Exemplo de submissão:** [URL inválido removido]
- **Especificações do Ambiente de Testes:** [https://github.com](https://github.com)

#------------versão 3--------------------#


## Rinha de Backend - 2024/Q1 - Explicação Detalhada em Português

**Introdução**

A Rinha de Backend é um desafio que visa compartilhar conhecimento e fomentar a prática de desenvolvimento de APIs robustas e escaláveis. Esta é a segunda edição, com foco em controle de concorrência em transações de crédito e débito.

**Requisitos da API**

A API a ser desenvolvida deve ter os seguintes endpoints:

**Transações**

* **POST /clientes/[id]/transacoes**
    * Parâmetros:
        * `valor`: valor da transação em centavos (inteiro positivo)
        * `tipo`: "c" para crédito ou "d" para débito
        * `descricao`: string com 1 a 10 caracteres
    * Respostas:
        * HTTP 200 OK:
            * `limite`: limite cadastrado do cliente
            * `saldo`: novo saldo após a transação
        * HTTP 422 Unprocessable Entity:
            * Se a transação de débito deixar o saldo negativo
        * HTTP 404 Not Found:
            * Se o ID do cliente não for encontrado

**Extrato**

* **GET /clientes/[id]/extrato**
    * Parâmetros:
        * `id`: ID do cliente
    * Respostas:
        * HTTP 200 OK:
            * `saldo`:
                * `total`: saldo total atual do cliente
                * `data_extrato`: data/hora da consulta do extrato
                * `limite`: limite cadastrado do cliente
            * `ultimas_transacoes`: lista das 10 últimas transações ordenadas por data/hora decrescente, contendo:
                * `valor`: valor da transação
                * `tipo`: "c" para crédito ou "d" para débito
                * `descricao`: descrição da transação
                * `realizada_em`: data/hora da transação
        * HTTP 404 Not Found:
            * Se o ID do cliente não for encontrado

**Requisitos Adicionais**

* Cadastro inicial de 5 clientes com IDs, limites e saldos iniciais específicos (conforme tabela na documentação).
* A API deve ser conteinerizada usando Docker Compose.
* A arquitetura mínima da API deve ter um load balancer, 2 instâncias de servidores web e um banco de dados relacional ou não relacional (exceto bancos de dados em memória como Redis).
* As restrições de CPU e memória para todos os serviços da API somadas não podem ultrapassar 1.5 unidades de CPU e 550MB de memória.
* A API deve ser publicada em um repositório público (ex: GitHub) e o link para o código fonte deve ser incluído na submissão.
* A data limite para submissão é 10 de Março de 2024 às 23:59:59.

**Processo de Entrega**

Para participar, faça um pull request neste repositório incluindo um subdiretório em `participantes` com os seguintes arquivos:

* `docker-compose.yml`: arquivo com a declaração dos serviços da API.
* `README.md`: incluindo seu nome, tecnologias utilizadas, link para o repositório do código fonte e forma de contato.
* Outros arquivos necessários para que seus contêineres subam corretamente (ex: `nginx.conf`, `banco.sql`).

**Exemplo de Submissão**

Consulte a pasta `participantes/exemplo` para um exemplo completo de submissão.

**Teste de Performance**

A ferramenta Gatling será utilizada para realizar o teste de performance. A simulação está disponível em `load-test`.

**Ambiente de Testes**

O ambiente de testes é Linux x64. Se seu ambiente de desenvolvimento for diferente, faça o build do docker para a plataforma Linux x64.

**Execução do Teste**

Siga as instruções na documentação para executar o teste localmente.

**Critérios de Vitória**

Os critérios para vencer a Rinha de Backend serão revelados posteriormente.

**Acompanhamento dos Testes**

O status parcial das execuções dos testes pode ser acompanhado no arquivo `STATUS-TESTES.md`.

**Recursos Adicionais**

* Especificações do Ambiente de Testes: ./SPECTESTENV.md
* Exemplo de Arquivos: ./exemplo
* Simulação Gatling: ./load-test/user-files/simulations/rinhabackend/RinhaBackendCrebitosSimulation.scala

**Observações Importantes**

* A API deve estar disponível na porta 9999.
* O script de pré-teste verific
