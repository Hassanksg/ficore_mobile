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
        const sidebar = document.getElementById('recentActivitySidebar');
        if (!sidebar) {
            console.warn('Sidebar element (#recentActivitySidebar) not found.');
            return;
        }

        const savedExpanded = localStorage.getItem('sidebarExpanded');
        const savedCollapsed = localStorage.getItem('sidebarCollapsed');

        this.sidebarCollapsed = savedCollapsed === 'true';
        this.sidebarExpanded = savedExpanded === 'true' && !this.sidebarCollapsed;

        const icon = document.getElementById('sidebarToggleIcon');
        const collapseBtn = document.getElementById('collapseBtn');

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
        if (!sidebar) {
            console.warn('Sidebar element (#recentActivitySidebar) not found.');
            return;
        }

        this.sidebarExpanded = !this.sidebarExpanded;

        if (this.sidebarExpanded) {
            sidebar.classList.add('expanded');
            if (icon) icon.className = 'bi bi-chevron-left';
            this.loadRecentActivitySidebar();
            const mobileBtn = document.getElementById('mobileActivityToggle');
            if (mobileBtn) mobileBtn.classList.add('hidden');
        } else {
            sidebar.classList.remove('expanded');
            if (icon) icon.className = 'bi bi-chevron-right';
            const mobileBtn = document.getElementById('mobileActivityToggle');
            if (mobileBtn) mobileBtn.classList.remove('hidden');
        }

        localStorage.setItem('sidebarExpanded', this.sidebarExpanded);
    }

    // Collapse sidebar completely
    collapseSidebar() {
        const sidebar = document.getElementById('recentActivitySidebar');
        const icon = document.getElementById('sidebarToggleIcon');
        const collapseBtn = document.getElementById('collapseBtn');
        if (!sidebar) {
            console.warn('Sidebar element (#recentActivitySidebar) not found.');
            return;
        }

        this.sidebarCollapsed = true;
        this.sidebarExpanded = false;

        sidebar.classList.add('collapsed');
        sidebar.classList.remove('expanded');
        if (icon) icon.className = 'bi bi-chevron-right';
        if (collapseBtn) collapseBtn.style.display = 'none';

        localStorage.setItem('sidebarCollapsed', 'true');
        localStorage.setItem('sidebarExpanded', 'false');

        setTimeout(() => {
            this.showRestoreButton();
        }, 300);
    }

    // Show restore button
    showRestoreButton() {
        if (document.getElementById('restoreButton')) return;

        const restoreBtn = document.createElement('button');
        restoreBtn.id = 'restoreButton';
        restoreBtn.className = 'btn btn-sm btn-primary restore-sidebar-btn';
        restoreBtn.innerHTML = '<i class="bi bi-arrow-left-square"></i>';
        restoreBtn.title = '{{ t("general_restore_sidebar", default="Restore sidebar") | e }}';
        restoreBtn.setAttribute('aria-label', '{{ t("general_restore_sidebar", default="Restore sidebar") | e }}');
        restoreBtn.onclick = () => this.restoreSidebar();
        document.body.appendChild(restoreBtn);
    }

    // Restore sidebar
    restoreSidebar() {
        const sidebar = document.getElementById('recentActivitySidebar');
        const collapseBtn = document.getElementById('collapseBtn');
        const restoreBtn = document.getElementById('restoreButton');
        if (!sidebar) {
            console.warn('Sidebar element (#recentActivitySidebar) not found.');
            return;
        }

        this.sidebarCollapsed = false;

        sidebar.classList.remove('collapsed');
        if (collapseBtn) collapseBtn.style.display = 'block';
        if (restoreBtn) restoreBtn.remove();

        localStorage.setItem('sidebarCollapsed', 'false');
        this.toggleActivitySidebar(); // Auto-open after restore
    }

    // Add mobile toggle button
    addMobileToggleButton() {
        if (!this.isMobile || document.getElementById('mobileActivityToggle')) return;

        const mobileBtn = document.createElement('button');
        mobileBtn.id = 'mobileActivityToggle';
        mobileBtn.className = 'mobile-activity-toggle';
        mobileBtn.innerHTML = '<i class="bi bi-clock-history"></i>';
        mobileBtn.setAttribute('aria-label', '{{ t("general_toggle_activity", default="Toggle activity") | e }}');
        mobileBtn.onclick = () => this.toggleActivitySidebar();
        document.body.appendChild(mobileBtn);
    }

    // Handle responsive layout changes
    handleResponsiveLayout() {
        if (this.isMobile) {
            this.addMobileToggleButton();
        }

        window.addEventListener('resize', () => {
            const wasMobile = this.isMobile;
            this.isMobile = window.innerWidth <= 768;

            if (this.isMobile && !wasMobile) {
                this.addMobileToggleButton();
            } else if (!this.isMobile && wasMobile) {
                const mobileBtn = document.getElementById('mobileActivityToggle');
                if (mobileBtn) mobileBtn.remove();
            }
        });
    }

    // Setup event listeners
    setupEventListeners() {
        const sidebar = document.getElementById('recentActivitySidebar');
        if (!sidebar) return;

        // Auto-expand for new users on desktop
        if (!this.isMobile && !localStorage.getItem('sidebarExpanded') && !localStorage.getItem('sidebarCollapsed')) {
            setTimeout(() => {
                this.toggleActivitySidebar();
            }, 1000);
        }

        // Ensure button event listeners are attached
        const toggleBtn = sidebar.querySelector('.sidebar-toggle');
        const collapseBtn = sidebar.querySelector('.sidebar-collapse');
        if (toggleBtn) toggleBtn.onclick = () => this.toggleActivitySidebar();
        if (collapseBtn) collapseBtn.onclick = () => this.collapseSidebar();

        window.addEventListener('beforeunload', () => {
            localStorage.setItem('sidebarExpanded', this.sidebarExpanded);
            localStorage.setItem('sidebarCollapsed', this.sidebarCollapsed);
        });

        if (this.isMobile) {
            this.setupMobileGestures();
        }
    }

    // Setup mobile swipe gestures
    setupMobileGestures() {
        const sidebar = document.getElementById('recentActivitySidebar');
        if (!sidebar) return;

        let startY = 0;
        let currentY = 0;
        let isDragging = false;

        sidebar.addEventListener('touchstart', (e) => {
            startY = e.touches[0].clientY;
            isDragging = true;
        });

        sidebar.addEventListener('touchmove', (e) => {
            if (!isDragging) return;
            currentY = e.touches[0].clientY;
            const deltaY = currentY - startY;
            if (deltaY > 50 && this.sidebarExpanded) {
                e.preventDefault();
            }
        });

        sidebar.addEventListener('touchend', () => {
            if (!isDragging) return;
            isDragging = false;
            const deltaY = currentY - startY;
            if (deltaY > 100 && this.sidebarExpanded) {
                this.toggleActivitySidebar();
            }
        });
    }

    // Load recent activity data with timeout and caching
    loadRecentActivitySidebar() {
        const activityList = document.getElementById('activityList');
        if (!activityList) {
            console.warn('Activity list element (#activityList) not found.');
            return;
        }

        // Show loading state
        activityList.innerHTML = `
            <div class="activity-item loading">
                <div class="activity-icon">
                    <div class="spinner-border spinner-border-sm text-muted" role="status">
                        <span class="visually-hidden">{{ t("general_loading", default="Loading...") | e }}</span>
                    </div>
                </div>
                <div class="activity-content">
                    <div class="activity-description">{{ t("general_loading_activities", default="Loading activities...") | e }}</div>
                    <div class="activity-time text-muted">{{ t("general_please_wait", default="Please wait") | e }}</div>
                </div>
            </div>
        `;

        // Check cached activities
        const cachedActivities = localStorage.getItem('recentActivities');
        if (cachedActivities) {
            try {
                this.activityData = JSON.parse(cachedActivities);
                this.renderSidebarActivities(this.activityData.slice(0, 5));
            } catch (e) {
                console.warn('Failed to parse cached activities:', e);
            }
        }

        // Make API call with timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000);

        fetch('{{ url_for("business.recent_activity") | e }}', {
            credentials: 'include',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'X-CSRFToken': document.querySelector('meta[name="csrf-token"]')?.content || ''
            },
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            if (!response.ok) throw new Error('Failed to load activity');
            return response.json();
        })
        .then(activities => {
            this.activityData = activities;
            localStorage.setItem('recentActivities', JSON.stringify(activities));
            this.renderSidebarActivities(activities.slice(0, 5));
        })
        .catch(error => {
            clearTimeout(timeoutId);
            console.error('Error loading sidebar activity:', error);
            if (this.activityData.length === 0) {
                activityList.innerHTML = `
                    <div class="activity-item">
                        <div class="activity-icon">
                            <i class="bi bi-info-circle text-muted"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-description">{{ t("general_no_recent_activity", default="No recent activity") | e }}</div>
                            <div class="activity-time">{{ t("general_start_adding", default="Start by adding transactions") | e }}</div>
                        </div>
                    </div>
                `;
            }
        });
    }

    // Render activities in sidebar
    renderSidebarActivities(activities) {
        const activityList = document.getElementById('activityList');
        if (!activityList) return;

        if (activities && activities.length > 0) {
            activityList.innerHTML = activities.map(activity => `
                <div class="activity-item">
                    <div class="activity-icon ${this.getActivityType(activity.type)}">
                        <i class="bi ${this.getActivityIcon(activity.type)} ${this.getActivityIconColor(activity.type)}"></i>
                    </div>
                    <div class="activity-content">
                        <div class="activity-description">${activity.description}</div>
                        <div class="activity-time">${this.formatTimeAgo(activity.timestamp)}</div>
                        ${activity.amount ? `<div class="activity-amount ${this.getAmountColor(activity.type)}">${this.formatCurrency(activity.amount)}</div>` : ''}
                    </div>
                </div>
            `).join('');
        } else {
            activityList.innerHTML = `
                <div class="activity-item">
                    <div class="activity-icon">
                        <i class="bi bi-info-circle text-muted"></i>
                    </div>
                    <div class="activity-content">
                        <div class="activity-description">{{ t("general_no_recent_activity", default="No recent activity") | e }}</div>
                        <div class="activity-time">{{ t("general_start_adding", default="Start by adding transactions") | e }}</div>
                    </div>
                </div>
            `;
        }
    }

    // Helper functions for activity rendering
    getActivityType(type) {
        const typeMap = {
            'debtor_added': 'debtor',
            'creditor_added': 'creditor',
            'money_in': 'receipt',
            'money_out': 'payment',
            'forecast_added': 'forecast',
            'fund_added': 'fund',
            'report_generated': 'report'
        };
        return typeMap[type] || 'default';
    }

    getActivityIcon(type) {
        const iconMap = {
            'debtor_added': 'bi-person-plus',
            'creditor_added': 'bi-person-plus',
            'money_in': 'bi-arrow-down-circle',
            'money_out': 'bi-arrow-up-circle',
            'forecast_added': 'bi-graph-up',
            'fund_added': 'bi-piggy-bank',
            'report_generated': 'bi-file-earmark-bar-graph',
            'feedback_submitted': 'bi-star-fill'
        };
        return iconMap[type] || 'bi-circle';
    }

    getActivityIconColor(type) {
        const colorMap = {
            'debtor_added': 'text-success',
            'creditor_added': 'text-danger',
            'money_in': 'text-success',
            'money_out': 'text-danger',
            'forecast_added': 'text-info',
            'fund_added': 'text-warning',
            'report_generated': 'text-secondary',
            'feedback_submitted': 'text-warning'
        };
        return colorMap[type] || 'text-muted';
    }

    getAmountColor(type) {
        return type === 'money_in' || type === 'debtor_added' ? 'text-success' : 'text-danger';
    }

    formatTimeAgo(timestamp) {
        const now = new Date();
        const time = new Date(timestamp);
        const diffInSeconds = Math.floor((now - time) / 1000);
        if (diffInSeconds < 60) return '{{ t("general_just_now", default="Just now") | e }}';
        if (diffInSeconds < 3600) return Math.floor(diffInSeconds / 60) + '{{ t("general_minutes_ago", default="m ago") | e }}';
        if (diffInSeconds < 86400) return Math.floor(diffInSeconds / 3600) + '{{ t("general_hours_ago", default="h ago") | e }}';
        return Math.floor(diffInSeconds / 86400) + '{{ t("general_days_ago", default="d ago") | e }}';
    }

    formatCurrency(amount) {
        if (!amount && amount !== 0) return '';
        const value = typeof amount === "string" ? parseFloat(amount) : amount;
        if (isNaN(value)) return '₦0';
        return '₦' + value.toLocaleString('en-NG', { maximumFractionDigits: 0 });
    }
}

// Global functions for backward compatibility
let sidebarManager;

function toggleActivitySidebar() {
    if (!sidebarManager) {
        console.warn('SidebarManager not initialized. Initializing now...');
        sidebarManager = new SidebarManager();
    }
    sidebarManager.toggleActivitySidebar();
}

function collapseSidebar() {
    if (!sidebarManager) {
        console.warn('SidebarManager not initialized. Initializing now...');
        sidebarManager = new SidebarManager();
    }
    sidebarManager.collapseSidebar();
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    try {
        sidebarManager = new SidebarManager();
    } catch (error) {
        console.error('Failed to initialize SidebarManager:', error);
    }
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SidebarManager;
}
