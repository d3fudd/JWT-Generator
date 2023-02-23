#!/usr/bin/env bash
# 
# usage:   ./jwt-generator.sh [password] [payload]
# example: ./jwt-generator.sh P@ssw0rd '{"sub": "1234567890","name": "John Doe","iat": "1516239022"}'
#

GREEN='\033[32;1m'
BLUE='\033[34;1m'
END='\033[m'

if [ $# -ne 2 ]; then
	echo " "
	echo -e "${GREEN} ┌───────────────────────────────────────┐"
    echo -e " │ ┏┓╻ ╻╺┳╸   ┏━╸┏━╸┏┓╻┏━╸┏━┓┏━┓╺┳╸┏━┓┏━┓│"
    echo -e " │  ┃┃╻┃ ┃    ┃╺┓┣╸ ┃┗┫┣╸ ┣┳┛┣━┫ ┃ ┃ ┃┣┳┛│"
    echo -e " │┗━┛┗┻┛ ╹    ┗━┛┗━╸╹ ╹┗━╸╹┗╸╹ ╹ ╹ ┗━┛╹┗╸│"
    echo -e " └───────────────────────────────────────┘${END}"
	echo " "
	echo -e "${BLUE} Usage: ${END}"
	echo " $0 [password] [payload]"
	echo -e "${BLUE} Example: ${END}"
	echo " $0 P@ssw0rd '{\"sub\": \"1234567890\",\"name\": \"John Doe\",\"iat\": \"1516239022\"}'"
	exit 1
fi

main(){
  set -eo pipefail

  JWT_SECRET=$1
  PAYLOAD=$2

  ${JWT_SECRET_BASE64_ENCODED:-false} && \
    JWT_SECRET=$(printf %s "$JWT_SECRET" | base64 --decode)

  header='{
    "alg": "HS256",
  	"typ": "JWT"
  }'

  header_base64=$(printf %s "$header" | base64_urlencode)
  payload_base64=$(printf %s "$PAYLOAD" | base64_urlencode)
  signed_content="${header_base64}.${payload_base64}"
  signature=$(printf %s "$signed_content" | openssl dgst -binary -sha256 -hmac "$JWT_SECRET" | base64_urlencode)

  log "\\n"
  printf '%s' "${signed_content}.${signature}"
}

base64_urlencode() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }
readonly __entry=$(basename "$0")
log(){ echo -e "$__entry: $*" >&2; }
die(){ log "$*"; exit 1; }
main "$@"
