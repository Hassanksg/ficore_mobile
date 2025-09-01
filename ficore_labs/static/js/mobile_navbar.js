// Mobile Navbar Enhancements JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize mobile navbar enhancements
    initMobileNavbar();
    initScrollBehavior();
    initHamburgerMenu();
    initMobileMoreMenu();
});

function initMobileNavbar() {
    const navbar = document.querySelector('.navbar');
    const isAuthenticated = document.body.classList.contains('authenticated') || 
                           document.querySelector('.fintech-top-header .profile-link');
    
    if (navbar) {
        navbar.classList.add(isAuthenticated ? 'authenticated' : 'unauthenticated');
    }
}

function initScrollBehavior() {
    let lastScrollTop = 0;
    let scrollTimeout;
    const navbar = document.querySelector('.navbar');
    const header = document.querySelector('.fintech-top-header');
    
    if (!navbar) return;
    
    function handleScroll() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollDelta = scrollTop - lastScrollTop;
        
        // Clear existing timeout
        if (scrollTimeout) {
            clearTimeout(scrollTimeout);
        }
        
        // Add scrolled class when scrolling down
        if (scrollTop > 50) {
            navbar.classList.add('scrolled');
            if (header) {
                header.classList.add('scrolled');
            }
        } else {
            navbar.classList.remove('scrolled');
            if (header) {
                header.classList.remove('scrolled');
            }
        }
        
        // Hide/show navbar based on scroll direction (only on mobile)
        if (window.innerWidth <= 768) {
            if (scrollDelta > 5 && scrollTop > 100) {
                // Scrolling down - hide navbar
                navbar.classList.add('navbar-hidden');
                navbar.classList.remove('navbar-visible');
            } else if (scrollDelta < -5) {
                // Scrolling up - show navbar
                navbar.classList.remove('navbar-hidden');
                navbar.classList.add('navbar-visible');
            }
        }
        
        lastScrollTop = scrollTop;
        
        // Debounce scroll end
        scrollTimeout = setTimeout(() => {
            navbar.classList.remove('navbar-hidden');
            navbar.classList.add('navbar-visible');
        }, 150);
    }
    
    // Throttled scroll handler
    let ticking = false;
    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(handleScroll);
            ticking = true;
            setTimeout(() => { ticking = false; }, 16); // ~60fps
        }
    }
    
    window.addEventListener('scroll', requestTick, { passive: true });
    
    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768) {
            navbar.classList.remove('navbar-hidden', 'navbar-visible');
        }
    });
}

function initHamburgerMenu() {
    const hamburger = document.querySelector('.navbar-toggler');
    const navbarCollapse = document.querySelector('.navbar-collapse');
    
    if (!hamburger || !navbarCollapse) return;
    
    // Ensure proper touch handling
    hamburger.addEventListener('touchstart', function(e) {
        e.preventDefault();
        this.click();
    }, { passive: false });
    
    // Enhanced click handling
    hamburger.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const isExpanded = this.getAttribute('aria-expanded') === 'true';
        
        // Toggle aria-expanded
        this.setAttribute('aria-expanded', !isExpanded);
        
        // Toggle collapse
        if (navbarCollapse.classList.contains('show')) {
            navbarCollapse.classList.remove('show');
            document.body.style.overflow = '';
        } else {
            navbarCollapse.classList.add('show');
            // Prevent body scroll when menu is open
            document.body.style.overflow = 'hidden';
        }
        
        // Add visual feedback
        this.style.transform = 'scale(0.95)';
        setTimeout(() => {
            this.style.transform = '';
        }, 100);
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', function(e) {
        if (!hamburger.contains(e.target) && !navbarCollapse.contains(e.target)) {
            navbarCollapse.classList.remove('show');
            hamburger.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
        }
    });
    
    // Close menu on escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && navbarCollapse.classList.contains('show')) {
            navbarCollapse.classList.remove('show');
            hamburger.setAttribute('aria-expanded', 'false');
            hamburger.focus();
            document.body.style.overflow = '';
        }
    });
    
    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) {
            navbarCollapse.classList.remove('show');
            hamburger.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
        }
    });
}

function initMobileMoreMenu() {
    // Create mobile "More" menu for unauthenticated users
    const navbar = document.querySelector('.navbar');
    const isAuthenticated = document.querySelector('.fintech-top-header .profile-link');
    
    if (isAuthenticated || !navbar) return;
    
    // Find the navbar nav
    const navbarNav = navbar.querySelector('.navbar-nav');
    if (!navbarNav) return;
    
    // Create more menu structure
    const moreMenuItem = document.createElement('li');
    moreMenuItem.className = 'nav-item dropdown mobile-more-menu';
    moreMenuItem.innerHTML = `
        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
            <i class="bi bi-three-dots me-2"></i>More
        </a>
        <ul class="dropdown-menu mobile-more-dropdown">
            <li><a class="dropdown-item" href="/contact">
                <i class="bi bi-envelope me-2"></i>Contact Us
            </a></li>
            <li><a class="dropdown-item" href="#" onclick="showWaitlistModal()">
                <i class="bi bi-bell me-2"></i>Join Waitlist
            </a></li>
            <li><a class="dropdown-item" href="/about">
                <i class="bi bi-info-circle me-2"></i>About Us
            </a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="#" onclick="toggleLanguage()">
                <i class="bi bi-globe me-2"></i>
                <span id="mobileLanguageText">${document.getElementById('languageText')?.textContent || 'ENGLISH'}</span>
            </a></li>
            <li><a class="dropdown-item" href="#" onclick="toggleDarkMode()">
                <i class="bi bi-moon-stars me-2"></i>Toggle Theme
            </a></li>
        </ul>
    `;
    
    // Add to navbar
    navbarNav.appendChild(moreMenuItem);
    
    // Initialize dropdown functionality
    const dropdownToggle = moreMenuItem.querySelector('.dropdown-toggle');
    const dropdownMenu = moreMenuItem.querySelector('.dropdown-menu');
    
    dropdownToggle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const isOpen = dropdownMenu.classList.contains('show');
        
        // Close all other dropdowns
        document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
            if (menu !== dropdownMenu) {
                menu.classList.remove('show');
            }
        });
        
        // Toggle this dropdown
        if (isOpen) {
            dropdownMenu.classList.remove('show');
            dropdownToggle.setAttribute('aria-expanded', 'false');
        } else {
            dropdownMenu.classList.add('show');
            dropdownToggle.setAttribute('aria-expanded', 'true');
        }
    });
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        if (!moreMenuItem.contains(e.target)) {
            dropdownMenu.classList.remove('show');
            dropdownToggle.setAttribute('aria-expanded', 'false');
        }
    });
}

// Utility functions
function showWaitlistModal() {
    // Create a simple modal for waitlist signup
    const modal = document.createElement('div');
    modal.className = 'modal fade';
    modal.innerHTML = `
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Join Our Waitlist</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Be the first to know when we launch new features!</p>
                    <form id="waitlistForm">
                        <div class="mb-3">
                            <label for="waitlistEmail" class="form-label">Email address</label>
                            <input type="email" class="form-control" id="waitlistEmail" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Join Waitlist</button>
                    </form>
                </div>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    // Initialize and show modal
    const bsModal = new bootstrap.Modal(modal);
    bsModal.show();
    
    // Handle form submission
    const form = modal.querySelector('#waitlistForm');
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        const email = modal.querySelector('#waitlistEmail').value;
        
        // Here you would typically send the email to your backend
        console.log('Waitlist signup:', email);
        
        // Show success message
        modal.querySelector('.modal-body').innerHTML = `
            <div class="text-center">
                <i class="bi bi-check-circle-fill text-success" style="font-size: 3rem;"></i>
                <h5 class="mt-3">Thank you!</h5>
                <p>You've been added to our waitlist. We'll notify you when we have updates!</p>
            </div>
        `;
        
        // Auto-close after 3 seconds
        setTimeout(() => {
            bsModal.hide();
        }, 3000);
    });
    
    // Clean up modal after hiding
    modal.addEventListener('hidden.bs.modal', function() {
        document.body.removeChild(modal);
    });
}

// Update language text in mobile menu when language changes
function updateMobileLanguageText() {
    const mobileLanguageText = document.getElementById('mobileLanguageText');
    const mainLanguageText = document.getElementById('languageText');
    
    if (mobileLanguageText && mainLanguageText) {
        mobileLanguageText.textContent = mainLanguageText.textContent;
    }
}

// Hook into existing language toggle function
const originalToggleLanguage = window.toggleLanguage;
if (originalToggleLanguage) {
    window.toggleLanguage = function() {
        originalToggleLanguage();
        setTimeout(updateMobileLanguageText, 100);
    };
}

// Performance optimization: Use Intersection Observer for scroll detection
if ('IntersectionObserver' in window) {
    const sentinel = document.createElement('div');
    sentinel.style.position = 'absolute';
    sentinel.style.top = '100px';
    sentinel.style.height = '1px';
    sentinel.style.width = '1px';
    sentinel.style.opacity = '0';
    sentinel.style.pointerEvents = 'none';
    document.body.appendChild(sentinel);
    
    const observer = new IntersectionObserver((entries) => {
        const navbar = document.querySelector('.navbar');
        if (navbar) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    navbar.classList.remove('scrolled');
                } else {
                    navbar.classList.add('scrolled');
                }
            });
        }
    }, { threshold: 0 });
    
    observer.observe(sentinel);
}