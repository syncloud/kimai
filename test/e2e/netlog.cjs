const fs = require('fs')
const raw = fs.readFileSync(process.argv[2], 'utf8').trim()
let d
try { d = JSON.parse(raw) } catch { d = JSON.parse(raw.replace(/,$/, '') + ']}') }
const names = Object.fromEntries(Object.entries(d.constants.logEventTypes).map(([k, v]) => [v, k]))
const errors = Object.fromEntries(Object.entries(d.constants.netError || {}).map(([k, v]) => [v, k]))
for (const e of d.events) {
  const t = names[e.type] || e.type
  const p = JSON.stringify(e.params || {})
  if (/HOST_RESOLVER|TCP_CONNECT|PROXY|CONNECT_JOB|SOCKET_POOL|URL_REQUEST_START|HTTP_STREAM_JOB_CONTROLLER|DNS/.test(t) && p !== '{}') {
    console.log(t, p.slice(0, 300), e.params && e.params.net_error ? errors[e.params.net_error] || '' : '')
  }
}
