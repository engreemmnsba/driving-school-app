// Keeps the web app's own files on the device so it opens without internet.
// Strategy: answer from the saved copy at once (fast start, works offline) and refresh the copy
// in the background; a new release is picked up on the next open.
// Never touches Firebase traffic (Auth, Firestore, Functions) — the app syncs that itself.
const CACHE = 'ds-app-v2';
const SHELL = ['./', 'index.html', 'flutter_bootstrap.js', 'main.dart.js', 'manifest.json', 'icons/Icon-192.png'];
// Saved too, so the first screen has its text, icons and logo without waiting for the network.
// A missing name here is skipped (it never blocks the install).
const ASSETS = [
  'assets/FontManifest.json', 'assets/AssetManifest.bin.json', 'assets/AssetManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/assets/fonts/IBMPlexSansArabic-Regular.ttf', 'assets/assets/fonts/IBMPlexSansArabic-Medium.ttf',
  'assets/assets/fonts/IBMPlexSansArabic-SemiBold.ttf', 'assets/assets/fonts/IBMPlexSansArabic-Bold.ttf',
  'assets/assets/images/logo.png', 'sqlite3.wasm', 'drift_worker.js',
];
// Flutter engine + Firebase JS SDK come from Google's CDN with versioned URLs: safe to keep.
// fonts.gstatic.com = the fallback fonts Flutter fetches for any character the app font lacks;
// without them saved, text can stay blank on a slow or missing connection.
const CDN = ['https://www.gstatic.com/flutter-canvaskit/', 'https://www.gstatic.com/firebasejs/', 'https://fonts.gstatic.com/'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE)
    .then((c) => c.addAll(SHELL).then(() => Promise.allSettled(ASSETS.map((a) => c.add(a)))))
    .then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      // Old copies: ours from an earlier version, and Flutter's own worker (replaced by this one).
      .then((keys) => Promise.all(keys
        .filter((k) => (k.startsWith('ds-app-') && k !== CACHE) || k.startsWith('flutter-'))
        .map((k) => caches.delete(k))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  const sameOrigin = url.origin === self.location.origin;
  if (sameOrigin && (url.pathname.startsWith('/download/') || url.pathname.startsWith('/__/'))) return;

  if (CDN.some((p) => req.url.startsWith(p))) {
    // Versioned files: saved copy first, network only the first time.
    e.respondWith(caches.open(CACHE).then(async (c) => {
      const hit = await c.match(req);
      if (hit) return hit;
      const res = await fetch(req);
      if (res.ok || res.type === 'opaque') c.put(req, res.clone());
      return res;
    }));
    return;
  }
  if (!sameOrigin) return;

  // Pages (any app route) → the saved index.html.
  const key = req.mode === 'navigate' ? 'index.html' : req;
  e.respondWith(caches.open(CACHE).then(async (c) => {
    const hit = await c.match(key);
    const fresh = fetch(req).then((res) => {
      if (res.ok) c.put(key, res.clone());
      return res;
    }).catch(() => undefined);
    if (hit) {
      e.waitUntil(fresh);
      return hit;
    }
    const res = await fresh;
    return res ?? new Response('offline', { status: 503 });
  }));
});
