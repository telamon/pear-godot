import Hyperswarm from 'hyperswarm'
const utf8Encoder = new globalThis.TextEncoder()
export const s2b = s => utf8Encoder.encode(s)

console.log('RUN0: JS Loaded')

/* This object is visible from godot */
globalThis.bootloader = {
  joinTopic
}

async function hash (data) {
  if (typeof data === 'string') data = s2b(data)
  return globalThis.crypto.subtle.digest('SHA-256', data)
}

let swarm = null

/** @param {string} topic
  * @param {function} peerCB */
async function joinTopic (topic = 'global', peerCB) {
  const h = await hash(topic)
  swarm ||= new Hyperswarm()
  swarm.on('connection', peerCB)
  const discovery = swarm.join(h)
  await discovery.flushed()
}

