#!/bin/bash -e

DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "${DIR}/../.." && pwd)
cd "$DIR"

SPEC=${1:?usage: run.sh <spec>}

export PLAYWRIGHT_DOMAIN=buster.com
export PLAYWRIGHT_APP=kimai
export PLAYWRIGHT_DEVICE_USER=user
export PLAYWRIGHT_DEVICE_PASSWORD=Password1
export PLAYWRIGHT_PROJECT=desktop
export PLAYWRIGHT_ARTIFACT_DIR=${ROOT}/artifact/screenshots
NAME=$(basename "$SPEC" .spec.ts)
export PLAYWRIGHT_OUTPUT_DIR=${ROOT}/artifact/playwright/${NAME}

DEVICE=${PLAYWRIGHT_APP}.${PLAYWRIGHT_DOMAIN}
LOG_DIR=${ROOT}/artifact/e2e-log/${NAME}

collect() {
  mkdir -p ${LOG_DIR}
  SSH="sshpass -p ${PLAYWRIGHT_DEVICE_PASSWORD} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 root@${DEVICE}"
  ${SSH} "tar cf - -C /var/snap/kimai/current log" | tar xf - -C ${LOG_DIR} || true
  ${SSH} "journalctl --no-pager -u snap.kimai.nginx -u snap.kimai.server" > ${LOG_DIR}/kimai-nginx-php-fpm.log 2>&1 || true
  ${SSH} "journalctl --no-pager -t kimai -t php-fpm -t nginx" > ${LOG_DIR}/kimai-syslog.log 2>&1 || true
  ${SSH} "journalctl --no-pager -n 5000" > ${LOG_DIR}/journalctl.log 2>&1 || true
  chmod -R a+r ${ROOT}/artifact || true
}

mkdir -p ${PLAYWRIGHT_ARTIFACT_DIR}
trap collect EXIT

${ROOT}/apt.sh curl sshpass openssh-client
npm ci --no-audit --no-fund --fetch-retries=5
${DIR}/wait-app.sh ${DEVICE}
npx playwright test --project=${PLAYWRIGHT_PROJECT} "$SPEC"
