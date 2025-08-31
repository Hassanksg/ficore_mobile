const CACHE_NAME = 'ficore-cache-v2';
const STATIC_CACHE = 'ficore-static-v2';
const DYNAMIC_CACHE = 'ficore-dynamic-v2';

// Static assets that rarely change
const staticAssets = [
    '/static/css/bootstrap-icons.min.css',
    '/static/css/styles.css',
    '/static/css/newbasefilelooks.css',
    '/static/css/iconslooks.css',
    '/static/css/profile_css.css',
    '/static/css/navigation_enhancements.css',
    '/static/js/scripts.js',
    '/static/js/interactivity.js',
    '/static/js/bootstrap.bundle.min.js',
    '/static/manifest.json',
    '/static/img/favicon.ico',
    '/static/img/apple-touch-icon.png',
    '/static/img/favicon-32x32.png',
    '/static/img/favicon-16x16.png',
    '/static/img/default_profile.png',
    '/static/img/ficore_africa_logo.png',
    '/static/img/ficore_logo.png',
    '/static/img/icons/icon-192x192.png',
    '/static/fonts/bootstrap-icons.woff2',
    '/static/fonts/bootstrap-icons.woff'
];

// Routes that should always fetch from network first
const networkFirstRoutes = [
    '/users/login',
    '/users/logout',
    '/users/signup',
    '/users/forgot_password',
    '/users/reset_password',
    '/users/verify_2fa',
    '/api/notifications/count',
    '/api/notifications',
    '/dashboard',
    '/debtors',
    '/creditors',
    '/payments',
    '/receipts',
    '/reports'
];

// Routes that can be cached for offline access
const cacheableRoutes = [
    '/general/home',
    '/general/about',
    '/general/contact',
    '/general/privacy',
    '/general/terms',
    '/set-language'
];

// Install event - cache static assets
self.addEventListener('install', event => {
    console.log('Service Worker installing...');
    event.waitUntil(
        Promise.all([
            caches.open(STATIC_CACHE).then(cache => {
                console.log('Caching static assets...');
                return cache.addAll(staticAssets);
            }),
            caches.open(DYNAMIC_CACHE).then(cache => {
                console.log('Initializing dynamic cache...');
                return cache.addAll(cacheableRoutes);
            })
        ]).catch(error => {
            console.error('Cache installation failed:', error);
        })
    );
    self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
    console.log('Service Worker activating...');
    const cacheWhitelist = [STATIC_CACHE, DYNAMIC_CACHE];
    
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (!cacheWhitelist.includes(cacheName)) {
                        console.log('Deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        }).then(() => {
            console.log('Service Worker activated');
            return self.clients.claim();
        })
    );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', event => {
    const requestUrl = new URL(event.request.url);
    const pathname = requestUrl.pathname;
    
    // Skip non-GET requests
    if (event.request.method !== 'GET') {
        return;
    }
    
    // Handle static assets - Cache First strategy
    if (pathname.startsWith('/static/')) {
        event.respondWith(
            caches.match(event.request).then(response => {
                if (response) {
                    return response;
                }
                
                return fetch(event.request).then(networkResponse => {
                    // Cache successful responses
                    if (networkResponse.status === 200) {
                        const responseClone = networkResponse.clone();
                        caches.open(STATIC_CACHE).then(cache => {
                            cache.put(event.request, responseClone);
                        });
                    }
                    return networkResponse;
                }).catch(() => {
                    // Return offline fallback for images
                    if (pathname.includes('/img/')) {
                        return caches.match('/static/img/default_profile.png');
                    }
                    return new Response('Offline: Static resource not available', { status: 503 });
                });
            })
        );
        return;
    }
    
    // Handle API routes and dynamic content - Network First strategy
    if (networkFirstRoutes.some(route => pathname.startsWith(route))) {
        event.respondWith(
            fetch(event.request).then(response => {
                // Cache successful responses for offline access
                if (response.status === 200 && cacheableRoutes.some(route => pathname.startsWith(route))) {
                    const responseClone = response.clone();
                    caches.open(DYNAMIC_CACHE).then(cache => {
                        cache.put(event.request, responseClone);
                    });
                }
                return response;
            }).catch(() => {
                // Try to serve from cache
                return caches.match(event.request).then(cachedResponse => {
                    if (cachedResponse) {
                        return cachedResponse;
                    }
                    // Return offline page for navigation requests
                    if (event.request.mode === 'navigate') {
                        return caches.match('/general/home') || 
                               new Response('Offline: Please check your connection', { 
                                   status: 503,
                                   headers: { 'Content-Type': 'text/html' }
                               });
                    }
                    return new Response('Offline: Resource not available', { status: 503 });
                });
            })
        );
        return;
    }
    
    // Handle other requests - Stale While Revalidate strategy
    event.respondWith(
        caches.match(event.request).then(cachedResponse => {
            const fetchPromise = fetch(event.request).then(networkResponse => {
                // Update cache in background
                if (networkResponse.status === 200) {
                    const responseClone = networkResponse.clone();
                    caches.open(DYNAMIC_CACHE).then(cache => {
                        cache.put(event.request, responseClone);
                    });
                }
                return networkResponse;
            }).catch(() => {
                // Network failed, return cached version if available
                return cachedResponse || new Response('Offline: Resource not available', { status: 503 });
            });
            
            // Return cached version immediately if available, otherwise wait for network
            return cachedResponse || fetchPromise;
        })
    );
});

// Handle background sync for offline actions
self.addEventListener('sync', event => {
    if (event.tag === 'background-sync') {
        console.log('Background sync triggered');
        event.waitUntil(
            // Handle any queued offline actions here
            Promise.resolve()
        );
    }
});

// Handle push notifications
self.addEventListener('push', event => {
    if (event.data) {
        const data = event.data.json();
        const options = {
            body: data.body,
            icon: '/static/img/icons/icon-192x192.png',
            badge: '/static/img/favicon-32x32.png',
            vibrate: [100, 50, 100],
            data: {
                dateOfArrival: Date.now(),
                primaryKey: data.primaryKey || 1
            },
            actions: [
                {
                    action: 'explore',
                    title: 'View',
                    icon: '/static/img/favicon-16x16.png'
                },
                {
                    action: 'close',
                    title: 'Close',
                    icon: '/static/img/favicon-16x16.png'
                }
            ]
        };
        
        event.waitUntil(
            self.registration.showNotification(data.title || 'FiCore Notification', options)
        );
    }
});

// Handle notification clicks
self.addEventListener('notificationclick', event => {
    event.notification.close();
    
    if (event.action === 'explore') {
        event.waitUntil(
            clients.openWindow('/dashboard')
        );
    }
});
