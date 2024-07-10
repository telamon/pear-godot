/**
  Hyperswarm is normally not possible to import in browser.
  but when this code runs inside a pears window then it magically imports.
  */
import Hyperswarm from 'hyperswarm'

/**
  bundle all other logic without browserify and avoid huge node_modules/ downloads
  esbuild --bundle ./core/game-core.js --outfile=../build/core.js --format=esm
 */
// import { boot, onPeerHandler, someAction } from './game-core.js'

const utf8Encoder = new globalThis.TextEncoder()
export const s2b = s => utf8Encoder.encode(s)

console.log('RUN0: JS Loaded')

/* This object is visible from godot */
globalThis.bootloader = {
  joinTopic,
  // boot,
  // someAction
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
  swarm.on('connection', peerCB)  // -- delegate connections to godot
  // swarm.on('connection', onPeerHandler) // -- delegate connections to hyper*-app
  const discovery = swarm.join(h)
  await discovery.flushed()
}

