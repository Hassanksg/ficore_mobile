/**
 * Critical JavaScript - Essential functionality for initial page load
 * This script should be inlined in the HTML head for fastest execution
 */

(function() {
    'use strict';
    
    // Theme management - Critical for preventing flash of unstyled content
    function initializeTheme() {
        const savedTheme = localStorage.getItem('theme');
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const shouldUseDark = savedTheme === 'dark' || (!savedTheme && prefersDark);
        
        if (shouldUseDark) {
            document.documentElement.classList.add('dark-mode');
        }
    }
    
    // Language management
    function initializeLanguage() {
        const savedLang = localStorage.getItem('language') || 'en';
        document.documentElement.lang = savedLang;
    }
    
    // Performance monitoring
    function initializePerformanceMonitoring() {
        if ('performance' in window && 'PerformanceObserver' in window) {
            // Monitor Largest Contentful Paint
            const lcpObserver = new PerformanceObserver((list) => {
                const entries = list.getEntries();
                const lastEntry = entries[entries.length - 1];
                console.log('LCP:', lastEntry.startTime);
            });
            
            try {
                lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] });
            } catch (e) {
                // Fallback for browsers that don't support LCP
                console.log('LCP monitoring not supported');
            }
            
            // Monitor First Input Delay
            const fidObserver = new PerformanceObserver((list) => {
                const entries = list.getEntries();
                entries.forEach((entry) => {
                    console.log('FID:', entry.processingStart - entry.startTime);
                });
            });
            
            try {
                fidObserver.observe({ entryTypes: ['first-input'] });
            } catch (e) {
                // Fallback for browsers that don't support FID
                console.log('FID monitoring not supported');
            }
        }
    }
    
    // Service Worker registration
    function registerServiceWorker() {
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', () => {
                navigator.serviceWorker.register('/static/service-worker.js')
                    .then((registration) => {
                        console.log('SW registered: ', registration);
                        
                        // Check for updates
                        registration.addEventListener('updatefound', () => {
                            const newWorker = registration.installing;
                            newWorker.addEventListener('statechange', () => {
                                if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                                    // New content is available, show update notification
                                    showUpdateNotification();
                                }
                            });
                        });
                    })
                    .catch((registrationError) => {
                        console.log('SW registration failed: ', registrationError);
                    });
            });
        }
    }
    
    // Show update notification
    function showUpdateNotification() {
        const notification = document.createElement('div');
        notification.className = 'update-notification';
        notification.innerHTML = `
            <div class="update-content">
                <span>New version available!</span>
                <button onclick="window.location.reload()" class="btn btn-sm btn-primary">Update</button>
                <button onclick="this.parentElement.parentElement.remove()" class="btn btn-sm">Later</button>
            </div>
        `;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 1rem;
            box-shadow: var(--card-shadow);
            z-index: 10000;
            max-width: 300px;
        `;
        document.body.appendChild(notification);
        
        // Auto-hide after 10 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 10000);
    }
    
    // Critical DOM ready functions
    function onDOMReady() {
        // Initialize tooltips if Bootstrap is loaded
        if (window.bootstrap && bootstrap.Tooltip) {
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        }
        
        // Initialize theme toggle
        const themeToggle = document.getElementById('darkModeToggle');
        if (themeToggle) {
            themeToggle.addEventListener('click', toggleTheme);
        }
        
        // Initialize language toggle
        const langToggle = document.getElementById('languageToggle');
        if (langToggle) {
            langToggle.addEventListener('click', toggleLanguage);
        }
        
        // Initialize notification bell
        const notificationBell = document.getElementById('notificationBell');
        if (notificationBell) {
            loadNotificationCount();
        }
        
        // Preload critical resources
        preloadCriticalResources();
    }
    
    // Theme toggle function
    function toggleTheme() {
        const isDark = document.documentElement.classList.toggle('dark-mode');
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
        
        // Update theme toggle icon
        const themeToggle = document.getElementById('darkModeToggle');
        if (themeToggle) {
            const icon = themeToggle.querySelector('i');
            if (icon) {
                icon.className = isDark ? 'bi bi-sun' : 'bi bi-moon-stars';
            }
        }
    }
    
    // Language toggle function
    function toggleLanguage() {
        const currentLang = document.documentElement.lang || 'en';
        const newLang = currentLang === 'en' ? 'ha' : 'en';
        
        // Make AJAX request to change language
        fetch('/set_language/' + newLang, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': document.querySelector('meta[name="csrf-token"]')?.content || ''
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                localStorage.setItem('language', newLang);
                window.location.reload();
            }
        })
        .catch(error => {
            console.error('Language toggle failed:', error);
        });
    }
    
    // Load notification count
    function loadNotificationCount() {
        fetch('/api/notifications/count')
            .then(response => response.json())
            .then(data => {
                const badge = document.getElementById('notificationBadge');
                if (badge && data.count > 0) {
                    badge.textContent = data.count;
                    badge.classList.remove('d-none');
                }
            })
            .catch(error => {
                console.error('Failed to load notification count:', error);
            });
    }
    
    // Preload critical resources
    function preloadCriticalResources() {
        const criticalResources = [
            { href: '/static/css/styles.css', as: 'style' },
            { href: '/static/js/scripts.js', as: 'script' },
            { href: 'https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap', as: 'style' }
        ];
        
        criticalResources.forEach(resource => {
            const link = document.createElement('link');
            link.rel = 'preload';
            link.href = resource.href;
            link.as = resource.as;
            if (resource.as === 'style') {
                link.crossOrigin = 'anonymous';
            }
            document.head.appendChild(link);
        });
    }
    
    // Error handling for critical functions
    function handleCriticalError(error, context) {
        console.error(`Critical error in ${context}:`, error);
        
        // Send error to monitoring service if available
        if (window.errorReporting) {
            window.errorReporting.report(error, context);
        }
    }
    
    // Initialize everything
    try {
        initializeTheme();
        initializeLanguage();
        initializePerformanceMonitoring();
        registerServiceWorker();
        
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', onDOMReady);
        } else {
            onDOMReady();
        }
        
    } catch (error) {
        handleCriticalError(error, 'initialization');
    }
    
    // Expose critical functions globally
    window.ficoreApp = {
        toggleTheme: toggleTheme,
        toggleLanguage: toggleLanguage,
        loadNotificationCount: loadNotificationCount
    };
    
})();