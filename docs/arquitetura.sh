codorna/
├── docker-compose-full-bash.yml
├── docker-compose-standalone.yml
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.sqlite
├── justfile
├── migrations
│   └── 1_setup.sql
├── nginx.conf
└── src
    ├── api.sh
    ├── api-standalone.sh
    ├── db.sh
    ├── lb.sh
    └── server.sh

2 directories, 13 files

#-----------nginx.conf

<<<<<<< HEAD
events {
    worker_connections 8192;
}

http {
    upstream api {
        server 127.0.0.1:8081;
        server 127.0.0.1:8082;
    }

    access_log  off;

    sendfile     on;
    tcp_nopush   on;
    tcp_nodelay  on;

    server {
        listen 9999;

        location / {
            proxy_pass http://api;
        }
    }
}

#------------FROM Docker.sqlite

alpine:latest

RUN apk add --update bash jq socat sqlite

WORKDIR /app/

ARG SOURCE_PATH=src/api.sh

COPY src/server.sh src/
COPY ${SOURCE_PATH} src/service.sh

ENTRYPOINT ["/app/src/server.sh"]

#-------------------docker-compose.yml

version: "3.5"

services:
  api-1: &api
    image: accerqueira/rinha-de-backend-2024-q1-bash-api
    build:
      dockerfile: Dockerfile
      args:
        - SOURCE_PATH=src/api.sh
    depends_on:
      db:
        condition: service_healthy
    environment:
      - PORT=8081
      - WORKERS=8
      - CONNECTIONS=1000
      - PGHOST=127.0.0.1
      - PGUSER=postgres
      - PGPASSWORD=postgres
    network_mode: host
    deploy:
      # replicas: 2
      resources:
        limits:
          cpus: "0.5"
          memory: "145MB"

  api-2:
    <<: *api
    environment:
      - PORT=8082
      - WORKERS=8
      - CONNECTIONS=1000
      - PGHOST=127.0.0.1
      - PGUSER=postgres
      - PGPASSWORD=postgres

  lb:
    image: nginx:latest
    depends_on:
      - api-1
      - api-2
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    network_mode: host
    deploy:
      resources:
        limits:
          cpus: "0.1"
          memory: "10MB"

  db:
    image: postgres:16-alpine
    user: postgres
    environment:
      - POSTGRES_PASSWORD=postgres
    network_mode: host
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 1s
      timeout: "5s"
      retries: 10
    volumes:
      - ./migrations/1_setup.sql:/docker-entrypoint-initdb.d/1_setup.sql
    deploy:
      resources:
        limits:
          cpus: "0.4"
          memory: "250MB"

#---------------------------Dockerfile

FROM alpine:latest

RUN apk add --update bash jq socat postgresql-client

WORKDIR /app/

ARG SOURCE_PATH=src/api.sh

COPY src/server.sh src/
COPY ${SOURCE_PATH} src/service.sh

ENTRYPOINT ["/app/src/server.sh"]

#-----------docker-compose-standalone.yml

version: "3.5"

services:
  api:
    image: accerqueira/rinha-de-backend-2024-q1-bash-api-standalone
    build:
      dockerfile: Dockerfile
      args:
        - SOURCE_PATH=src/api-standalone.sh
    environment:
      - PORT=9999
      - WORKERS=8
      - CONNECTIONS=1000
      - DB_INIT_SCRIPT=
        CREATE TABLE IF NOT EXISTS clientes (
        "id" INTEGER PRIMARY KEY NOT NULL,
        "saldo" INTEGER NOT NULL,
        "limite" INTEGER NOT NULL,
        "ultimas_transacoes" JSON NOT NULL DEFAULT ('[]')
        );
        DELETE FROM clientes;
        INSERT INTO clientes VALUES(1,0,100000,'[]');
        INSERT INTO clientes VALUES(2,0,80000,'[]');
        INSERT INTO clientes VALUES(3,0,1000000,'[]');
        INSERT INTO clientes VALUES(4,0,10000000,'[]');
        INSERT INTO clientes VALUES(5,0,500000,'[]');
    network_mode: host
    pid: host
    deploy:
      # replicas: 2
      resources:
        limits:
          # cpus: "0.5"
          memory: "30MB"
    entrypoint: sh -c 'echo "$${DB_INIT_SCRIPT}" | sqlite3 db.sqlite3 && src/server.sh'

#-------------------------docker-compose-full-bash.yml

version: "3.5"

services:
  api-1: &api
    image: accerqueira/rinha-de-backend-2024-q1-bash-api
    build:
      dockerfile: Dockerfile
      args:
        - SOURCE_PATH=src/api.sh
    depends_on:
      - db
    environment:
      - PORT=8081
      - WORKERS=8
      - CONNECTIONS=1000
      - DB_CONNECTION_URL=127.0.0.1:8083
      # - DB_CONNECTION_URL=db:9999
    network_mode: host
    # deploy:
    #   # replicas: 2
    #   resources:
    #     limits:
    #       # cpus: "0.5"
    #       memory: "100MB"

  api-2:
    <<: *api
    environment:
      - PORT=8082
      - WORKERS=8
      - CONNECTIONS=1000
      - DB_CONNECTION_URL=127.0.0.1:8083

  lb:
    image: accerqueira/rinha-de-backend-2024-q1-bash-lb
    build:
      dockerfile: Dockerfile
      args:
        - SOURCE_PATH=src/lb.sh
    depends_on:
      - api-1
      - api-2
    environment:
      - SERVERS=127.0.0.1:8081|127.0.0.1:8082
      - WORKERS=16
      - CONNECTIONS=10000
      # - SERVERS=api-1:9999|api-2:9999
    network_mode: host
    # ports:
    #   - "9999:9999"
    # deploy:
    #   resources:
    #     limits:
    #       # cpus: "0.25"
    #       memory: "100MB"
    # entrypoint: "socat TCP-LISTEN:9999,reuseaddr,fork,max-children=4 TCP:api:9999"

  db:
    image: accerqueira/rinha-de-backend-2024-q1-bash-db
    build:
      dockerfile: Dockerfile
      args:
        - SOURCE_PATH=src/db.sh
    environment:
      - PORT=8083
      - WORKERS=4
      - CONNECTIONS=100
      - DB_INIT_SCRIPT=
        CREATE TABLE IF NOT EXISTS clientes (
          "id" INTEGER PRIMARY KEY NOT NULL,
          "saldo" INTEGER NOT NULL,
          "limite" INTEGER NOT NULL,
          "ultimas_transacoes" JSON NOT NULL DEFAULT ('[]')
        );
        DELETE FROM clientes;
        INSERT INTO clientes VALUES(1,0,100000,'[]');
        INSERT INTO clientes VALUES(2,0,80000,'[]');
        INSERT INTO clientes VALUES(3,0,1000000,'[]');
        INSERT INTO clientes VALUES(4,0,10000000,'[]');
        INSERT INTO clientes VALUES(5,0,500000,'[]');
    network_mode: host
    # deploy:
    #   resources:
    #     limits:
    #       # cpus: "0.25"
    #       memory: "250MB"
    entrypoint: sh -c 'echo "$${DB_INIT_SCRIPT}" | sqlite3 db.sqlite3 && src/server.sh'

#---------------------#src/server.sh

#!/usr/bin/env bash

__FILE__="$(readlink -f ${BASH_SOURCE[0]})"
__DIR__="${__FILE__%/*}"

SERVICE=${1:-"${APP:-"${__DIR__}/service.sh"}"}
PORT=${2:-${PORT:-9999}}
WORKERS=${WORKERS:-8}
CONNECTIONS=${CONNECTIONS:-$(( 30 * 220 ))}

set -x
socat TCP-LISTEN:${PORT},reuseaddr,fork,max-children=${WORKERS},backlog=${CONNECTIONS} EXEC:"${SERVICE}"
# socat TCP-LISTEN:${PORT},reuseaddr,fork,max-children=4 EXEC:"${SERVICE}"
# ncat -vvvvv --listen --keep-open --source-port ${PORT} --exec "${SERVICE}"

#-----------------#src/server.sh
#src/server.sh
#!/usr/bin/env bash

__FILE__="$(readlink -f ${BASH_SOURCE[0]})"
__DIR__="${__FILE__%/*}"

SERVICE=${1:-"${APP:-"${__DIR__}/service.sh"}"}
PORT=${2:-${PORT:-9999}}
WORKERS=${WORKERS:-8}
CONNECTIONS=${CONNECTIONS:-$(( 30 * 220 ))}

set -x
socat TCP-LISTEN:${PORT},reuseaddr,fork,max-children=${WORKERS},backlog=${CONNECTIONS} EXEC:"${SERVICE}"
# socat TCP-LISTEN:${PORT},reuseaddr,fork,max-children=4 EXEC:"${SERVICE}"
# ncat -vvvvv --listen --keep-open --source-port ${PORT} --exec "${SERVICE}"

#-----------------------------------src/db.sh

#!/usr/bin/env bash

DEBUG=1


DB_PATH="${PWD}/db.sqlite3"


__FILE__="$(readlink -f ${BASH_SOURCE[0]})"
__DIR__="${__FILE__%/*}"


function tap() {
	local PREFIX="${2}"
	[[ -n "$DEBUG" ]] && tee >(sed "s#^#${2}#" >&2) || cat
	# [[ -n "$DEBUG" ]] && tee >(sed "s#^#${2}#" >> "${1}") || cat
}

function sql() {
	sqlite3 \
		-batch \
		-cmd '.output /dev/null' \
		-cmd 'PRAGMA jounal_mode=WAL;' \
		-cmd 'PRAGMA synchronous=NORMAL;' \
		-cmd 'PRAGMA busy_timeout=5000' \
		-cmd '.timeout 5000' \
		-cmd '.output stdout' \
		"${@}" 2> >(grep -v 'database is locked' >&2)
}

function handle_request() {
	local DB_PATH="${1}"
	sql "${DB_PATH}"
	# tap queries.log "> " | sql "${DB_PATH}" | tap queries.log "< "
}

# handle_request "${DB_PATH}"

# lock_file="/tmp/socat-lock-$(( ( RANDOM % 8 )  + 1 ))"
# touch "$lock_file"
#
# exec 4< "$lock_file"
# flock 4
handle_request "${DB_PATH}"
# exec 4<&-

#--------------------------api.sh----------------------------------

#!/usr/bin/env bash

# DEBUG=1


__FILE__="$(readlink -f ${BASH_SOURCE[0]})"
__DIR__="${__FILE__%/*}"


function handle_request() {
	local state_read_prelude=0
	local state_read_headers=1
	local state_read_body=2
	local state_write_response=3

	local current_state=$state_read_prelude

	REQUEST_BODY=""
	while read -e -r line; do
		local line="${line%$'\r'}"
		local line_lc="${line,,}"

		if [[ $current_state -eq $state_read_prelude ]]; then
			REQUEST_PATH="${line% *}"
			REQUEST_METHOD="${REQUEST_PATH% *}"
			REQUEST_PATH="${REQUEST_PATH#* }"
			current_state=$state_read_headers
		elif [[ $current_state -eq $state_read_headers ]]; then
			if [[ "${line_lc}" == "content-length:"* ]]; then
				REQUEST_CONTENT_LENGTH="${line_lc#content-length: }"
			elif [[ "${line_lc}" == "" ]]; then
				if [[ ${REQUEST_CONTENT_LENGTH} -gt 0 ]]; then
					current_state=$state_read_body
				else
					current_state=$state_write_response
					break
				fi
			fi
		fi

		if [[ $current_state -eq $state_read_body ]]; then
			read -N${REQUEST_CONTENT_LENGTH} -t1 line
			REQUEST_BODY+="${line}"
			break
		fi
	done

	if [[ $REQUEST_PATH =~ /([0-9]+)/ ]]; then
			CLIENT_ID="${BASH_REMATCH[1]}"
	fi
	REQUEST_ROUTE="${REQUEST_METHOD} ${REQUEST_PATH//${CLIENT_ID}/:id}"

	# echo "${REQUEST_ROUTE} ${REQUEST_BODY}" >&2
	case ${REQUEST_ROUTE} in
		"GET /clientes/:id/extrato")			handle_GET_extrato $CLIENT_ID ;;
		"POST /clientes/:id/transacoes")	handle_POST_transacoes $CLIENT_ID "${REQUEST_BODY}" ;;
		*)																handle_route_unknown ;;
	esac
}

function http_response() {
	local RESPONSE_STATUS="${1}"
	local RESPONSE_BODY="${2}"

	local _TZ=${TZ}
	local _LC_TIME=${LC_TIME}

	export TZ=GMT
	export LC_TIME=POSIX

	# printf "%s %s %s %s\n" "${REQUEST_PATH}" "${REQUEST_BODY}" "${RESPONSE_STATUS}" "${RESPONSE_BODY}" >&2

	printf "HTTP/1.1 %s\r\n" "${RESPONSE_STATUS}"
	printf "Date: %(%a, %d %b %Y %H:%M:%S GMT)T\r\n"
	printf "Server: bash\r\n"
	printf "Content-Type: application/json\r\n"
	printf "Connection: close\r\n"
	printf "Content-Length: %d\r\n" "${#RESPONSE_BODY}"
	printf "\r\n"
	printf "%s" "${RESPONSE_BODY}"

	TZ=${_TZ}
	LC_TIME=${_LC_TIME}

	exit 0
}

function sql() {
	psql --quiet --tuples-only
	# tee >(sed "s#^#> #" >&2) | psql --quiet --tuples-only | tee >(sed "s#^#< #" >&2)
	# socat - TCP:${DB_CONNECTION_URL},connect-timeout=60
}

function get_bank_statement() {
	local CLIENT_ID=${1}

	echo "SELECT jsonb_build_object(
		'saldo', jsonb_build_object(
			'total', saldo,
			'limite', limite,
			'data_extrato', to_char(now()::timestamp at time zone 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"')
		),
		'ultimas_transacoes', to_jsonb(ultimas_transacoes)
	) FROM clientes WHERE id = ${CLIENT_ID};" | sql "${DB_PATH}"
	# echo "SELECT json_object(
	# 	'saldo', json_object(
	# 		'total', saldo,
	# 		'limite', limite,
	# 		'data_extrato', strftime('%Y-%m-%dT%H:%M:%fZ')
	# 	),
	# 	'ultimas_transacoes', json(ultimas_transacoes)
	# ) FROM clientes WHERE id = ${CLIENT_ID};" | sql "${DB_PATH}"
}

function insert_transaction() {
	local CLIENT_ID=${1}
	local TX="${2//\'/\'\'}"

	echo "UPDATE clientes 
		SET
			saldo=saldo + (
				SELECT
					CASE WHEN x.tipo = 'd' THEN -x.valor ELSE x.valor END as valor
				FROM json_to_record('${TX}') as x(valor int, tipo varchar)
			),
			ultimas_transacoes=(
				jsonb_insert(
					ultimas_transacoes,
					'{0}',
					jsonb_set(
						'${TX}'::jsonb,
						'{realizada_em}',
						to_jsonb(to_char(now()::timestamp at time zone 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'))
					)
				) - 11
			)
		WHERE
			id=${CLIENT_ID} AND
			(saldo + (
				SELECT
					CASE WHEN x.tipo = 'd' THEN -x.valor ELSE x.valor END as valor
				FROM json_to_record('${TX}') as x(valor int, tipo varchar)
			)) >= -limite
		RETURNING json_build_object('saldo', saldo, 'limite', limite);" | sql "${DB_PATH}"

	# echo "UPDATE clientes 
	# 	SET saldo=saldo + (
	# 		SELECT CASE WHEN tipo == 'd' THEN -valor ELSE valor END as valor FROM (
	# 			SELECT json_extract(value, '$.tipo') tipo, json_extract(value, '$.valor') valor FROM json_each('[${TX}]')
	# 		)
	# 	), ultimas_transacoes=(
	# 		SELECT json_remove(json_group_array(json(value)), '"'$[10]'"') txs FROM (
	# 			SELECT id, value FROM (
	# 				SELECT json_insert(json_group_array(json(value)), '"'$[#]'"', json_set('${TX}', '$.realizada_em', strftime('%Y-%m-%dT%H:%M:%fZ'))) txs FROM (
	# 					SELECT txs.value FROM clientes c, json_each(c.ultimas_transacoes) txs WHERE c.id=${CLIENT_ID} ORDER BY key DESC
	# 				)
	# 			) temp, json_each(temp.txs) ORDER BY key DESC
	# 		)
	# 	) WHERE id=${CLIENT_ID} AND (saldo + (
	# 		SELECT CASE WHEN tipo == 'd' THEN -valor ELSE valor END as valor FROM (
	# 			SELECT json_extract(value, '$.tipo') tipo, json_extract(value, '$.valor') valor FROM json_each('[${TX}]')
	# 		)
	# 	)) >= -limite RETURNING json_object('saldo', saldo, 'limite', limite);" | sql "${DB_PATH}"
}

function check_client_exists() {
	local CLIENT_ID="${1}"

	if (( "${CLIENT_ID}" < 1 || "${CLIENT_ID}" > 5 )); then
		http_response 404 '{"error":"cliente nao encontrado"}'
	fi
}

function check_transaction_request() {
	local TX="${1}"

	RESULT=$(echo "${TX}" | jq '
		(.tipo == "d" or .tipo == "c")
			and ((.valor | type) == "number")
			and ((.valor | trunc) == .valor)
			and .valor > 0
			and (1 <= (.descricao | length) and (.descricao | length) <= 10)
	')
	if [[ "${RESULT}" != "true" ]]; then
		http_response 422 '{"error":""}'
	fi
}

function handle_GET_extrato() {
	local CLIENT_ID="${1}"

	check_client_exists "${CLIENT_ID}"

	local BANK_STATEMENT=$(get_bank_statement "${CLIENT_ID}")

	http_response 200 "${BANK_STATEMENT}"
}

function handle_POST_transacoes() {
	local CLIENT_ID="${1}"
	local TX="${2}"

	check_client_exists "${CLIENT_ID}"
	check_transaction_request "${TX}"

	local RESULT=$(insert_transaction "${CLIENT_ID}" "${TX}")

	if [[ "${RESULT}" == "" ]]; then
		http_response 422 '{ "error": "limite insuficiente" }'
	fi

	http_response "200 OK" "${RESULT}"
}

function handle_route_unknown() {
	http_response 404 '{ "error": "funcionalidade nao encontrada" }'
}


handle_request

#-------------------api-standalone.sh

#!/usr/bin/env bash

# DEBUG=1

DB_PATH="./db.sqlite3"


__FILE__="$(readlink -f ${BASH_SOURCE[0]})"
__DIR__="${__FILE__%/*}"


function handle_request() {
	local state_read_prelude=0
	local state_read_headers=1
	local state_read_body=2
	local state_write_response=3

	local current_state=$state_read_prelude

	REQUEST_BODY=""
	while read -e -r line; do
		local line="${line%$'\r'}"
		local line_lc="${line,,}"

		if [[ $current_state -eq $state_read_prelude ]]; then
			REQUEST_PATH="${line% *}"
			REQUEST_METHOD="${REQUEST_PATH% *}"
			REQUEST_PATH="${REQUEST_PATH#* }"
			current_state=$state_read_headers
		elif [[ $current_state -eq $state_read_headers ]]; then
			if [[ "${line_lc}" == "content-length:"* ]]; then
				REQUEST_CONTENT_LENGTH="${line_lc#content-length: }"
			elif [[ "${line_lc}" == "" ]]; then
				if [[ ${REQUEST_CONTENT_LENGTH} -gt 0 ]]; then
					current_state=$state_read_body
				else
					current_state=$state_write_response
					break
				fi
			fi
		fi

		if [[ $current_state -eq $state_read_body ]]; then
			read -N${REQUEST_CONTENT_LENGTH} -t1 line
			REQUEST_BODY+="${line}"
			break
		fi
	done

	if [[ $REQUEST_PATH =~ /([0-9]+)/ ]]; then
			CLIENT_ID="${BASH_REMATCH[1]}"
	fi
	REQUEST_ROUTE="${REQUEST_METHOD} ${REQUEST_PATH//${CLIENT_ID}/:id}"

	case ${REQUEST_ROUTE} in
		"GET /clientes/:id/extrato")			handle_GET_extrato $CLIENT_ID ;;
		"POST /clientes/:id/transacoes")	handle_POST_transacoes $CLIENT_ID "${REQUEST_BODY}" ;;
		*)																handle_route_unknown ;;
	esac
}

function http_response() {
	local RESPONSE_STATUS="${1}"
	local RESPONSE_BODY="${2}"

	local _TZ=${TZ}
	local _LC_TIME=${LC_TIME}

	export TZ=GMT
	export LC_TIME=POSIX

	printf "HTTP/1.1 %s\r\n" "${RESPONSE_STATUS}"
	printf "Date: %(%a, %d %b %Y %H:%M:%S GMT)T\r\n"
	printf "Server: bash\r\n"
	printf "Content-Type: application/json\r\n"
	printf "Connection: close\r\n"
	printf "Content-Length: %d\r\n" "${#RESPONSE_BODY}"
	printf "\r\n"
	printf "%s" "${RESPONSE_BODY}"

	TZ=${_TZ}
	LC_TIME=${_LC_TIME}

	exit 0
}

function sql() {
	sqlite3 \
		-cmd '.output /dev/null' \
		-cmd 'PRAGMA jounal_mode=WAL;' \
		-cmd 'PRAGMA synchronous=NORMAL;' \
		-cmd 'PRAGMA busy_timeout=5000' \
		-cmd '.timeout 5000' \
		-cmd '.output stdout' \
		"${@}" 2> >(grep -v 'database is locked' >&2)
}

function tap() {
	[[ -n "$DEBUG" ]] && tee -a "${1}" || cat
}

function get_bank_statement() {
	local CLIENT_ID=${1}

	echo "SELECT json_object(
		'saldo', json_object(
			'total', saldo,
			'limite', limite,
			'data_extrato', strftime('%Y-%m-%dT%H:%M:%fZ')
		),
		'ultimas_transacoes', json(ultimas_transacoes)
	) FROM clientes WHERE id = ${CLIENT_ID};" | sql "${DB_PATH}"
}

function insert_transaction() {
	local CLIENT_ID=${1}
	local TX="${2//\'/\'\'}"

	echo "UPDATE clientes 
		SET saldo=saldo + (
			SELECT CASE WHEN tipo == 'd' THEN -valor ELSE valor END as valor FROM (
				SELECT json_extract(value, '$.tipo') tipo, json_extract(value, '$.valor') valor FROM json_each('[${TX}]')
			)
		), ultimas_transacoes=(
			SELECT json_remove(json_group_array(json(value)), '"'$[10]'"') txs FROM (
				SELECT id, value FROM (
					SELECT json_insert(json_group_array(json(value)), '"'$[#]'"', json_set('${TX}', '$.realizada_em', strftime('%Y-%m-%dT%H:%M:%fZ'))) txs FROM (
						SELECT txs.value FROM clientes c, json_each(c.ultimas_transacoes) txs WHERE c.id=${CLIENT_ID} ORDER BY key DESC
					)
				) temp, json_each(temp.txs) ORDER BY key DESC
			)
		) WHERE id=${CLIENT_ID} AND (saldo + (
			SELECT CASE WHEN tipo == 'd' THEN -valor ELSE valor END as valor FROM (
				SELECT json_extract(value, '$.tipo') tipo, json_extract(value, '$.valor') valor FROM json_each('[${TX}]')
			)
		)) >= -limite RETURNING json_object('saldo', saldo, 'limite', limite);" | sql "${DB_PATH}"
}

function check_client_exists() {
	local CLIENT_ID="${1}"

	if (( "${CLIENT_ID}" < 1 || "${CLIENT_ID}" > 5 )); then
		http_response 404 '{"error":"cliente nao encontrado"}'
	fi
}

function check_transaction_request() {
	local TX="${1}"

	RESULT=$(echo "${TX}" | jq '
		(.tipo == "d" or .tipo == "c")
			and ((.valor | type) == "number")
			and ((.valor | trunc) == .valor)
			and .valor > 0
			and (1 <= (.descricao | length) and (.descricao | length) <= 10)
	')
	if [[ "${RESULT}" != "true" ]]; then
		http_response 422 '{"error":""}'
	fi
}

function handle_GET_extrato() {
	local CLIENT_ID="${1}"

	check_client_exists "${CLIENT_ID}"

	local BANK_STATEMENT=$(get_bank_statement "${CLIENT_ID}")

	http_response 200 "${BANK_STATEMENT}"
}

function handle_POST_transacoes() {
	local CLIENT_ID="${1}"
	local TX="${2}"

	check_client_exists "${CLIENT_ID}"
	check_transaction_request "${TX}"

	local RESULT=$(insert_transaction "${CLIENT_ID}" "${TX}")

	if [[ "${RESULT}" == "" ]]; then
		http_response 422 '{ "error": "limite insuficiente" }'
	fi

	http_response "200 OK" "${RESULT}"
}

function handle_route_unknown() {
	http_response 404 '{ "error": "funcionalidade nao encontrada" }'
}


# lock_file="/tmp/socat-lock-$(( ( RANDOM % 8 )  + 1 ))"
# touch "$lock_file"
# exec 4< "$lock_file"
# flock 4
handle_request
# exec 4<&-

#src/db.sh
#!/usr/bin/env bash

DEBUG=1


DB_PATH="${PWD}/db.sqlite3"


__FILE__="$(readlink -f ${BASH_SOURCE[0]})"
__DIR__="${__FILE__%/*}"


function tap() {
	local PREFIX="${2}"
	[[ -n "$DEBUG" ]] && tee >(sed "s#^#${2}#" >&2) || cat
	# [[ -n "$DEBUG" ]] && tee >(sed "s#^#${2}#" >> "${1}") || cat
}

function sql() {
	sqlite3 \
		-batch \
		-cmd '.output /dev/null' \
		-cmd 'PRAGMA jounal_mode=WAL;' \
		-cmd 'PRAGMA synchronous=NORMAL;' \
		-cmd 'PRAGMA busy_timeout=5000' \
		-cmd '.timeout 5000' \
		-cmd '.output stdout' \
		"${@}" 2> >(grep -v 'database is locked' >&2)
}

function handle_request() {
	local DB_PATH="${1}"
	sql "${DB_PATH}"
	# tap queries.log "> " | sql "${DB_PATH}" | tap queries.log "< "
}

# handle_request "${DB_PATH}"

# lock_file="/tmp/socat-lock-$(( ( RANDOM % 8 )  + 1 ))"
# touch "$lock_file"
#
# exec 4< "$lock_file"
# flock 4
handle_request "${DB_PATH}"
# exec 4<&-

#------------------(1_setup.sql)
#---------migrations/1_setup.sql
CREATE UNLOGGED TABLE IF NOT EXISTS clientes (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "saldo" INTEGER NOT NULL,
  "limite" INTEGER NOT NULL,
  "ultimas_transacoes" JSONB NOT NULL DEFAULT '[]'::JSONB
);
DELETE FROM clientes;
INSERT INTO clientes VALUES(1,0,100000,'[]');
INSERT INTO clientes VALUES(2,0,80000,'[]');
INSERT INTO clientes VALUES(3,0,1000000,'[]');
INSERT INTO clientes VALUES(4,0,10000000,'[]');
INSERT INTO clientes VALUES(5,0,500000,'[]');

