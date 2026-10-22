#!/bin/bash -e

DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DIR"

SPEC=$1

export PLAYWRIGHT_DOMAIN=bookworm.com
export PLAYWRIGHT_DEVICE_USER=user
export PLAYWRIGHT_DEVICE_PASSWORD=Password1
export PLAYWRIGHT_PROJECT=desktop
export PLAYWRIGHT_ARTIFACT_DIR=/drone/src/artifact/screenshots

${DIR}/../../apt.sh curl
npm ci --no-audit --no-fund
${DIR}/wait-app.sh kimai.${PLAYWRIGHT_DOMAIN}
getent ahostsv6 kimai.${PLAYWRIGHT_DOMAIN} || true
curl -6 -sk -o /dev/null -w "ipv6: %{http_code} %{remote_ip}\n" https://kimai.${PLAYWRIGHT_DOMAIN} || true
PLAYWRIGHT_NETLOG=/drone/src/artifact/screenshots/netlog.json npx playwright test --project=${PLAYWRIGHT_PROJECT} "$SPEC"
