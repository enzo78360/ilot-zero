// Îlot Zéro — version de bureau (Windows / macOS).
// Le jeu est servi par un protocole interne « app:// » pour que les modèles GLB,
// le décodeur Draco (WebAssembly) et le stockage local fonctionnent comme sur le web.
const { app, BrowserWindow, protocol, Menu, shell } = require('electron');
const path = require('path');
const fs = require('fs');

const MIME = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.json': 'application/json', '.svg': 'image/svg+xml',
  '.png': 'image/png', '.glb': 'model/gltf-binary', '.wasm': 'application/wasm', '.css': 'text/css; charset=utf-8' };

// le nom accentué de l'app se retrouve dans le User-Agent, or les en-têtes HTTP doivent rester en ASCII
app.userAgentFallback = app.userAgentFallback.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^\x20-\x7e]/g, '');

protocol.registerSchemesAsPrivileged([
  { scheme: 'app', privileges: { standard: true, secure: true, supportFetchAPI: true, corsEnabled: true, stream: true } },
]);

const ROOT = path.join(__dirname, '..');

function createWindow() {
  const win = new BrowserWindow({
    width: 1600, height: 900, minWidth: 960, minHeight: 540,
    backgroundColor: '#0b1a20', title: 'Îlot Zéro', autoHideMenuBar: true,
    webPreferences: { contextIsolation: true, nodeIntegration: false, sandbox: true, backgroundThrottling: false },
  });
  // les liens externes (README, PeerJS…) s'ouvrent dans le navigateur
  win.webContents.setWindowOpenHandler(({ url }) => { if (/^https?:/.test(url)) shell.openExternal(url); return { action: 'deny' }; });
  win.webContents.on('before-input-event', (e, input) => {
    if (input.type === 'keyDown' && input.key === 'F11') { win.setFullScreen(!win.isFullScreen()); e.preventDefault(); }
  });
  win.loadURL('app://jeu/index.html');
  // test automatique : ILOT_SMOKE=1 charge le jeu, vérifie les modèles puis quitte
  if (process.env.ILOT_SMOKE) win.webContents.on('console-message', (e) => { if (e.level === 'error' || e.level === 'warning') console.log('CONSOLE', e.level, e.message); });
  if (process.env.ILOT_SMOKE) win.webContents.once('did-finish-load', () => setTimeout(async () => {
    const r = await win.webContents.executeJavaScript("Promise.all(['models/armes.glb','vendor/draco/draco_decoder.wasm']).then(()=>Promise.all(['models/armes.glb','vendor/draco/draco_decoder.wasm'].map(u=>fetch(u).then(r=>u+':'+r.status+':'+r.headers.get('content-type'))))).then(st=>JSON.stringify({three: typeof THREE, peer: typeof Peer, menu: !document.getElementById('menu').hidden, st, res: performance.getEntriesByType('resource').filter(e=>/glb|wasm/.test(e.name)).length}))").catch(e => 'ERR ' + e);
    console.log('SMOKE', r); app.exit(0);
  }, 8000));
}

app.whenReady().then(() => {
  protocol.handle('app', async (req) => {
    let rel;
    try { rel = decodeURIComponent(new URL(req.url).pathname).replace(/^\/+/, '') || 'index.html'; }
    catch (err) { return new Response('Requête invalide', { status: 400 }); }
    const file = path.normalize(path.join(ROOT, rel));
    if (!file.startsWith(ROOT + path.sep)) return new Response('Interdit', { status: 403 });
    try {
      const body = await fs.promises.readFile(file);
      return new Response(body, { headers: { 'content-type': MIME[path.extname(file).toLowerCase()] || 'application/octet-stream' } });
    } catch (err) { return new Response('Introuvable', { status: 404 }); }
  });
  if (process.platform !== 'darwin') Menu.setApplicationMenu(null);
  createWindow();
  app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow(); });
});
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
