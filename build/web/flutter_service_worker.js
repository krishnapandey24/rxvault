'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "6195376b539573bbe935e1906b1a8bb0",
"assets/AssetManifest.bin.json": "12c5ed6b47041de67d9e2a905fb04067",
"assets/AssetManifest.json": "3276125d74092f2ac33af50cb2353e2d",
"assets/assets/fonts/Poppins-Bold.ttf": "08c20a487911694291bd8c5de41315ad",
"assets/assets/fonts/Poppins-Medium.ttf": "bf59c687bc6d3a70204d3944082c5cc0",
"assets/assets/fonts/Poppins-Regular.ttf": "093ee89be9ede30383f39a899c485a82",
"assets/assets/fonts/RxIcons.ttf": "3249082392390e554189883d4e22fc52",
"assets/assets/html/privacy_policy.html": "e7137a95f183d8104259360e15cab794",
"assets/assets/icons/delete.svg": "ca2c16fb2c02f97c0c7ec4b94f3240ce",
"assets/assets/icons/excel.svg": "b65f9de1dbc9383905c6e053fd677b28",
"assets/assets/icons/healthcare.svg": "f433b899ace3ed12f692063b07cc2367",
"assets/assets/icons/preference.svg": "f1317c57f3f1dcc7eb3cd41e97468358",
"assets/assets/icons/prescription-icon.svg": "0a3478eaa93626abc62c25265c8a0f63",
"assets/assets/icons/services.svg": "7a8782969d32daf1cec1c708fec71f06",
"assets/assets/icons/staff.svg": "1551ed955703b8dc55cfdf063c9699f4",
"assets/assets/icons/triangle.svg": "f202f177d9fd41f3446e2039340045c0",
"assets/assets/images/add_docs.png": "3dbc55d841eba30652b82cee7cda3ec7",
"assets/assets/images/add_image.png": "93df2d0c0dd7bb0332ececa67e5438fe",
"assets/assets/images/as15.png": "dca4283f1c50ef278f05964f6dd15327",
"assets/assets/images/as16.png": "cb5c254d086b8869d12543ec122c5cf6",
"assets/assets/images/asset_26.png": "f7edf02bf9a570f2ab77c08aca4d3382",
"assets/assets/images/asset_27.png": "8b83ee92fdb540a35c336b0dd0631853",
"assets/assets/images/asset_28.png": "f4202df73684e8358f979d84b0924cf7",
"assets/assets/images/asset_29.png": "915e8f41b7813921c3e526c3afe0a293",
"assets/assets/images/asset_30.png": "da020ae7cfddf9f778b15b0a15f203d3",
"assets/assets/images/asset_31.png": "271e91edbada0295a64ca4f0533e3d8b",
"assets/assets/images/camera.png": "f8d482f11faef86e2cdb18b0449af9ce",
"assets/assets/images/doctor.png": "c9d96766cbd9c00833acd932c5f001bb",
"assets/assets/images/ic_female.png": "0cd70e2bc2c24b183dfcb0e2b347b761",
"assets/assets/images/ic_male.png": "39ec18d67b47c5280d80e40e240ba5e6",
"assets/assets/images/logo.png": "2fda74e714f017ea9ad569ee5004bb39",
"assets/assets/images/results.png": "6bc9e67ad9f1156c75b62531668d88fb",
"assets/assets/images/spacedesk_driver_Win_10_64_v2122.msi": "65f5f179e3da0dbfbd6b35cda7af3e0a",
"assets/assets/lottie/loading.json": "e0b88aa1a75b4996451ce3872bcbcf6c",
"assets/FontManifest.json": "d51c043d2c421c91d694e5372c1477a4",
"assets/fonts/MaterialIcons-Regular.otf": "9fab7afb4871b3c5204d26b1921ea43c",
"assets/NOTICES": "915794d02f408c51e1c26b791cc7462a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "25e8ef2d0b74beb3972e862288f3870b",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/flutter_image_compress_web/assets/pica.min.js": "6208ed6419908c4b04382adc8a3053a2",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "99e19a1febfec8d01e3843137c2907c5",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "c3cbaca7c13b1753377cbfc0221747b6",
"icons/Icon-192.png": "c7a31c37934d2f400cca0a5a1f380313",
"icons/Icon-512.png": "5a5247c8e89f08ae8c40b4318cdf5bc9",
"icons/Icon-maskable-192.png": "c7a31c37934d2f400cca0a5a1f380313",
"icons/Icon-maskable-512.png": "5a5247c8e89f08ae8c40b4318cdf5bc9",
"ic_launcher.png": "daeeee08bc379bee0da83bb29de67d36",
"index.html": "43cd5c63eced043cb41931f280992213",
"/": "43cd5c63eced043cb41931f280992213",
"main.dart.js": "81dca2e3d9eb010e9d475b9b76c10a96",
"manifest.json": "5917771cb6c12a88378c17a65e0e4d05",
"rxicon.svg": "e07be5c71436b59f5f1ad2dc532cfb2d",
"version.json": "d1e472118ad8c8636ea72f431d27003c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
