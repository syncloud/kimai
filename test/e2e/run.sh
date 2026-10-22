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
npx playwright test --project=${PLAYWRIGHT_PROJECT} "$SPEC"
