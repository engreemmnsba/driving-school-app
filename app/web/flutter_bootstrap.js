{{flutter_js}}
{{flutter_build_config}}

// No Flutter service worker: offline_sw.js (registered in index.html) keeps the app on the device,
// including the Flutter engine and Firebase SDK that load from Google's CDN.
_flutter.loader.load();
