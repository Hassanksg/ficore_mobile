"""
Performance optimization utilities for FiCore Labs application.
Provides caching, asset optimization, and response optimization functions.
"""

import os
import hashlib
import gzip
from datetime import datetime, timedelta
from functools import wraps
from flask import request, make_response, current_app, g
from werkzeug.http import http_date
import mimetypes

class PerformanceOptimizer:
    """Handles various performance optimizations for the Flask application."""
    
    def __init__(self, app=None):
        self.app = app
        if app is not None:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize the performance optimizer with the Flask app."""
        app.config.setdefault('PERFORMANCE_CACHE_TIMEOUT', 3600)  # 1 hour
        app.config.setdefault('PERFORMANCE_STATIC_CACHE_TIMEOUT', 86400 * 30)  # 30 days
        app.config.setdefault('PERFORMANCE_ENABLE_GZIP', True)
        app.config.setdefault('PERFORMANCE_ENABLE_ETAG', True)
        
        # Register after_request handlers
        app.after_request(self.add_cache_headers)
        app.after_request(self.add_security_headers)
        
        # Store reference to app
        self.app = app

    def generate_etag(self, data):
        """Generate ETag for response data."""
        if isinstance(data, str):
            data = data.encode('utf-8')
        return hashlib.md5(data).hexdigest()

    def add_cache_headers(self, response):
        """Add appropriate cache headers to responses."""
        if not current_app.config.get('PERFORMANCE_ENABLE_ETAG', True):
            return response
            
        # Skip for certain routes
        skip_routes = ['/api/', '/admin/', '/users/login', '/users/logout']
        if any(request.path.startswith(route) for route in skip_routes):
            return response
            
        # Add cache headers for static files
        if request.path.startswith('/static/'):
            cache_timeout = current_app.config.get('PERFORMANCE_STATIC_CACHE_TIMEOUT', 86400 * 30)
            response.headers['Cache-Control'] = f'public, max-age={cache_timeout}'
            response.headers['Expires'] = http_date(datetime.utcnow() + timedelta(seconds=cache_timeout))
            
            # Add ETag for static files
            if response.data and current_app.config.get('PERFORMANCE_ENABLE_ETAG', True):
                etag = self.generate_etag(response.data)
                response.headers['ETag'] = f'"{etag}"'
                
                # Check if client has cached version
                if request.headers.get('If-None-Match') == f'"{etag}"':
                    response.status_code = 304
                    response.data = b''
        
        # Add cache headers for dynamic content
        elif request.method == 'GET' and response.status_code == 200:
            cache_timeout = current_app.config.get('PERFORMANCE_CACHE_TIMEOUT', 3600)
            response.headers['Cache-Control'] = f'private, max-age={cache_timeout}'
            
        return response

    def add_security_headers(self, response):
        """Add security headers to responses."""
        # Content Security Policy
        csp = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' 'unsafe-eval' "
            "https://cdn.jsdelivr.net https://cdnjs.cloudflare.com "
            "https://fonts.googleapis.com; "
            "style-src 'self' 'unsafe-inline' "
            "https://cdn.jsdelivr.net https://cdnjs.cloudflare.com "
            "https://fonts.googleapis.com; "
            "font-src 'self' https://fonts.gstatic.com "
            "https://cdn.jsdelivr.net; "
            "img-src 'self' data: https:; "
            "connect-src 'self';"
        )
        response.headers['Content-Security-Policy'] = csp
        
        # Other security headers
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        
        return response

def cache_response(timeout=3600):
    """Decorator to cache response data."""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # Generate cache key
            cache_key = f"{request.path}:{request.query_string.decode()}"
            
            # Try to get from cache (if using Redis or similar)
            # For now, we'll use simple in-memory caching via g
            if hasattr(g, 'cache') and cache_key in g.cache:
                cached_data, cached_time = g.cache[cache_key]
                if datetime.utcnow() - cached_time < timedelta(seconds=timeout):
                    return cached_data
            
            # Execute function and cache result
            result = f(*args, **kwargs)
            
            # Store in cache
            if not hasattr(g, 'cache'):
                g.cache = {}
            g.cache[cache_key] = (result, datetime.utcnow())
            
            return result
        return decorated_function
    return decorator

def minify_css(css_content):
    """Basic CSS minification."""
    import re
    
    # Remove comments
    css_content = re.sub(r'/\*.*?\*/', '', css_content, flags=re.DOTALL)
    
    # Remove extra whitespace
    css_content = re.sub(r'\s+', ' ', css_content)
    css_content = re.sub(r';\s*}', '}', css_content)
    css_content = re.sub(r'{\s*', '{', css_content)
    css_content = re.sub(r'}\s*', '}', css_content)
    css_content = re.sub(r':\s*', ':', css_content)
    css_content = re.sub(r';\s*', ';', css_content)
    
    return css_content.strip()

def minify_js(js_content):
    """Basic JavaScript minification."""
    import re
    
    # Remove single-line comments (but preserve URLs)
    js_content = re.sub(r'(?<!:)//.*$', '', js_content, flags=re.MULTILINE)
    
    # Remove multi-line comments
    js_content = re.sub(r'/\*.*?\*/', '', js_content, flags=re.DOTALL)
    
    # Remove extra whitespace
    js_content = re.sub(r'\s+', ' ', js_content)
    js_content = re.sub(r';\s*', ';', js_content)
    js_content = re.sub(r'{\s*', '{', js_content)
    js_content = re.sub(r'}\s*', '}', js_content)
    
    return js_content.strip()

def optimize_images():
    """Placeholder for image optimization functionality."""
    # This would integrate with PIL/Pillow to optimize images
    # For now, we'll just return a message
    return "Image optimization would be implemented here"

def preload_critical_resources():
    """Generate preload headers for critical resources."""
    critical_resources = [
        {'href': '/static/css/styles.css', 'as': 'style'},
        {'href': '/static/css/bootstrap-icons.min.css', 'as': 'style'},
        {'href': '/static/js/scripts.js', 'as': 'script'},
        {'href': 'https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap', 'as': 'style'},
    ]
    
    preload_headers = []
    for resource in critical_resources:
        header = f"<{resource['href']}>; rel=preload; as={resource['as']}"
        if resource['as'] == 'style':
            header += "; crossorigin=anonymous"
        preload_headers.append(header)
    
    return ', '.join(preload_headers)