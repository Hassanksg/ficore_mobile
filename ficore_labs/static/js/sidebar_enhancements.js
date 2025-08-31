/**
 * Enhanced Recent Activity Sidebar Functionality
 * Handles collapse/expand, mobile responsiveness, and localStorage persistence
 */

class SidebarManager {
    constructor() {
        this.sidebarExpanded = false;
        this.sidebarCollapsed = false;
        this.activityData = [];
        this.isMobile = window.innerWidth <= 768;
        
        this.init();
    }
    
    init() {
        this.initializeSidebarState();
        this.setupEventListeners();
        this.handleResponsiveLayout();
    }
    
    // Initialize sidebar state from localStorage
    initializeSidebarState() {
        const savedExpanded = localStorage.getItem('sidebarExpanded');
        const savedCollapsed = localStorage.getItem('sidebarCollapsed');
        
        this.sidebarCollapsed = savedCollapsed === 'true';
        this.sidebarExpanded = savedExpanded === 'true' && !this.sidebarCollapsed;
        
        const sidebar = document.getElementById('recentActivitySidebar');
        const icon = document.getElementById('sidebarToggleIcon');
        const collapseBtn = document.getElementById('collapseBtn');
        
        if (!sidebar) return;
        
        if (this.sidebarCollapsed) {
            sidebar.classList.add('collapsed');
            sidebar.classList.remove('expanded');
            if (collapseBtn) collapseBtn.style.display = 'none';
            this.showRestoreButton();
        } else if (this.sidebarExpanded) {
            sidebar.classList.add('expanded');
            if (icon) icon.className = 'bi bi-chevron-left';
            this.loadRecentActivitySidebar();
        }
    }
    
    // Toggle sidebar visibility
    toggleActivitySidebar() {
        if (this.sidebarCollapsed) return; // Don't toggle if collapsed
        
        const sidebar = document.getElementById('recentActivitySidebar');
        const icon = document.getElementById('sidebarToggleIcon');
        
        if (!sidebar) return;
        
        this.sidebarExpanded = !this.sidebarExpanded;
        
        if (this.sidebarExpanded) {
            sidebar.classList.add('expanded');
            if (icon) icon.className = 'bi bi-chevron-left';
            this.loadRecentActivitySidebar();
        } else {
            sidebar.classList.remove('expanded');
            if (icon) icon.className = 'bi bi-chevron-right';
        }
        
        // Save state to localStorage
        localStorage.setItem('sidebarExpanded', this.sidebarExpanded);
    }
    
    // Collapse sidebar completely
    collapseSidebar() {
        const sidebar = document.getElementById('recentActivitySidebar');
        const icon = document.getElementById('sidebarToggleIcon');
        const collapseBtn = document.getElementById('collapseBtn');
        
        if (!sidebar) return;
        
        this.sidebarCollapsed = true;
        this.sidebarExpanded = false;
        
        sidebar.classList.add('collapsed');
        sidebar.classList.remove('expanded');
        if (icon) icon.className = 'bi bi-chevron-right';
        if (collapseBtn) collapseBtn.style.display = 'none';
        
        // Save state to localStorage
        localStorage.setItem('sidebarCollapsed', 'true');
        localStorage.setItem('sidebarExpanded', 'false');
        
        // Show restore button after animation
        setTimeout(() => {
            this.showRestoreButton();
        }, 300);
    }
    
    // Show restore button
    showRestoreButton() {
        if (document.getElementById('restoreButton')) return; // Already exists
        
        const restoreBtn = document.createElement('button');
        restoreBtn.id = 'restoreButton';
        restoreBtn.className = 'btn btn-sm btn-primary restore-sidebar-btn';
        restoreBtn.innerHTML = '<i class="bi bi-arrow-left-square"></i>';
        restoreBtn.title = 'Restore sidebar';
        restoreBtn.onclick = () => this.restoreSidebar();
        restoreBtn.setAttribute('aria-label', 'Restore sidebar');
        
        document.body.appendChild(restoreBtn);
    }
    
    // Restore sidebar
    restoreSidebar() {
        const sidebar = document.getElementById('recentActivitySidebar');
        const collapseBtn = document.getElementById('collapseBtn');
        const restoreBtn = document.getElementById('restoreButton');
        
        if (!sidebar) return;
        
        this.sidebarCollapsed = false;
        
        sidebar.classList.remove('collapsed');
        if (collapseBtn) collapseBtn.style.display = 'block';
        
        if (restoreBtn) {
            restoreBtn.remove();
        }
        
        // Save state to localStorage
        localStorage.setItem('sidebarCollapsed', 'false');
    }
    
    // Add mobile toggle button
    addMobileToggleButton() {
        if (document.getElementById('mobileActivityToggle')) return; // Already exists
        
        const mobileBtn = document.createElement('button');
        mobileBtn.id = 'mobileActivityToggle';
        mobileBtn.className = 'mobile-activity-toggle';
        mobileBtn.innerHTML = '<i class="bi bi-clock-history"></i>';
        mobileBtn.onclick = () => this.toggleActivitySidebar();
        mobileBtn.setAttribute('aria-label', 'Toggle activity');
        
        document.body.appendChild(mobileBtn);
    }
    
    // Handle responsive layout changes
    handleResponsiveLayout() {
        if (this.isMobile) {
            this.addMobileToggleButton();
        }
        
        // Handle window resize
        window.addEventListener('resize', () => {
            const wasMobile = this.isMobile;
            this.isMobile = window.innerWidth <= 768;
            
            if (this.isMobile && !wasMobile) {
                // Switched to mobile
                this.addMobileToggleButton();
            } else if (!this.isMobile && wasMobile) {
                // Switched to desktop
                const mobileBtn = document.getElementById('mobileActivityToggle');
                if (mobileBtn) {
                    mobileBtn.remove();
                }
            }
        });
    }
    
    // Setup event listeners
    setupEventListeners() {
        // Auto-expand for new users on desktop
        if (!this.isMobile && 
            !localStorage.getItem('sidebarExpanded') && 
            !localStorage.getItem('sidebarCollapsed')) {
            setTimeout(() => {
                this.toggleActivitySidebar();
            }, 1000);
        }
        
        // Remember user preference on page unload
        window.addEventListener('beforeunload', () => {
            localStorage.setItem('sidebarExpanded', this.sidebarExpanded);
            localStorage.setItem('sidebarCollapsed', this.sidebarCollapsed);
        });
        
        // Handle swipe gestures on mobile
        if (this.isMobile) {
            this.setupMobileGestures();
        }
    }
    
    // Setup mobile swipe gestures
    setupMobileGestures() {
        let startY = 0;
        let currentY = 0;
        let isDragging = false;
        
        const sidebar = document.getElementById('recentActivitySidebar');
        if (!sidebar) return;
        
        sidebar.addEventListener('touchstart', (e) => {
            startY = e.touches[0].clientY;
            isDragging = true;
        });
        
        sidebar.addEventListener('touchmove', (e) => {
            if (!isDragging) return;
            currentY = e.touches[0].clientY;
            const deltaY = currentY - startY;
            
            // Only allow downward swipe to close
            if (deltaY > 50 && this.sidebarExpanded) {
                e.preventDefault();
            }
        });
        
        sidebar.addEventListener('touchend', (e) => {
            if (!isDragging) return;
            isDragging = false;
            
            const deltaY = currentY - startY;
            
            // Close sidebar if swiped down significantly
            if (deltaY > 100 && this.sidebarExpanded) {
                this.toggleActivitySidebar();
            }
        });
    }
    
    // Load recent activity data
    loadRecentActivitySidebar() {
        // This function should be implemented based on your backend API
        // For now, we'll use a placeholder
        const activityList = document.getElementById('activityList');
        if (!activityList) return;
        
        // Show loading state
        activityList.innerHTML = `
            <div class="activity-item loading">
                <div class="activity-icon">
                    <div class="spinner-border spinner-border-sm text-muted" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
                <div class="activity-content">
                    <div class="activity-description">Loading activities...</div>
                    <div class="activity-time text-muted">Please wait</div>
                </div>
            </div>
        `;
        
        // Make API call if available
        if (typeof loadRecentActivitySidebar === 'function') {
            loadRecentActivitySidebar();
        }
    }
}

// Global functions for backward compatibility
let sidebarManager;

function toggleActivitySidebar() {
    if (sidebarManager) {
        sidebarManager.toggleActivitySidebar();
    }
}

function collapseSidebar() {
    if (sidebarManager) {
        sidebarManager.collapseSidebar();
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    sidebarManager = new SidebarManager();
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SidebarManager;
}