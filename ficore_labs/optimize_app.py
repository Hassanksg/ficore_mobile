#!/usr/bin/env python3
"""
FiCore Labs Application Optimization Script

This script performs comprehensive optimization of the FiCore Labs application including:
- Static asset optimization (CSS/JS minification and bundling)
- Database index optimization
- Cache warming
- Performance monitoring setup
- Service worker updates

Usage:
    python optimize_app.py [--production] [--skip-assets] [--skip-db]
"""

import os
import sys
import argparse
import json
from pathlib import Path

# Add the application directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from static_optimizer import StaticOptimizer
from database_optimizer import DatabaseOptimizer
from performance_optimizations import PerformanceOptimizer
from utils import get_mongo_db, logger

def optimize_static_assets(app):
    """Optimize static assets (CSS/JS bundling and minification)."""
    print("🔧 Optimizing static assets...")
    
    try:
        optimizer = StaticOptimizer(app)
        
        # Create optimized bundles
        result = optimizer.optimize_all_assets()
        
        if result['css_bundle']:
            print(f"✅ CSS bundle created: {result['css_bundle']}")
        
        if result['js_bundle']:
            print(f"✅ JS bundle created: {result['js_bundle']}")
        
        print(f"📄 Asset manifest updated with {len(result['manifest'])} entries")
        
        return True
        
    except Exception as e:
        print(f"❌ Static asset optimization failed: {e}")
        return False

def optimize_database(app):
    """Optimize database indexes and queries."""
    print("🗄️  Optimizing database...")
    
    try:
        with app.app_context():
            db = get_mongo_db()
            optimizer = DatabaseOptimizer(app)
            
            # Optimize collection indexes
            optimizer.optimize_collection_indexes(db)
            print("✅ Database indexes optimized")
            
            # Clear any existing query cache
            optimizer.clear_cache()
            print("✅ Query cache cleared")
            
        return True
        
    except Exception as e:
        print(f"❌ Database optimization failed: {e}")
        return False

def update_service_worker():
    """Update service worker cache version."""
    print("🔄 Updating service worker...")
    
    try:
        sw_path = Path('static/service-worker.js')
        if sw_path.exists():
            content = sw_path.read_text()
            
            # Update cache version
            import re
            version_pattern = r"const CACHE_NAME = 'ficore-cache-v(\d+)';"
            match = re.search(version_pattern, content)
            
            if match:
                current_version = int(match.group(1))
                new_version = current_version + 1
                new_content = re.sub(
                    version_pattern,
                    f"const CACHE_NAME = 'ficore-cache-v{new_version}';",
                    content
                )
                
                # Also update static cache version
                static_pattern = r"const STATIC_CACHE = 'ficore-static-v(\d+)';"
                new_content = re.sub(
                    static_pattern,
                    f"const STATIC_CACHE = 'ficore-static-v{new_version}';",
                    new_content
                )
                
                # Update dynamic cache version
                dynamic_pattern = r"const DYNAMIC_CACHE = 'ficore-dynamic-v(\d+)';"
                new_content = re.sub(
                    dynamic_pattern,
                    f"const DYNAMIC_CACHE = 'ficore-dynamic-v{new_version}';",
                    new_content
                )
                
                sw_path.write_text(new_content)
                print(f"✅ Service worker updated to version {new_version}")
            else:
                print("⚠️  Could not find cache version in service worker")
        else:
            print("⚠️  Service worker file not found")
            
        return True
        
    except Exception as e:
        print(f"❌ Service worker update failed: {e}")
        return False

def warm_cache(app):
    """Warm up application caches."""
    print("🔥 Warming up caches...")
    
    try:
        with app.app_context():
            # Warm up critical routes
            critical_routes = [
                '/',
                '/general/home',
                '/users/login',
                '/users/signup'
            ]
            
            with app.test_client() as client:
                for route in critical_routes:
                    try:
                        response = client.get(route)
                        if response.status_code == 200:
                            print(f"✅ Warmed cache for {route}")
                        else:
                            print(f"⚠️  Cache warming for {route} returned {response.status_code}")
                    except Exception as e:
                        print(f"⚠️  Failed to warm cache for {route}: {e}")
        
        return True
        
    except Exception as e:
        print(f"❌ Cache warming failed: {e}")
        return False

def generate_performance_report(app):
    """Generate a performance optimization report."""
    print("📊 Generating performance report...")
    
    try:
        report = {
            'timestamp': str(datetime.utcnow()),
            'optimizations': {
                'static_assets': 'Completed',
                'database_indexes': 'Completed',
                'service_worker': 'Updated',
                'cache_warming': 'Completed'
            },
            'recommendations': [
                'Monitor Core Web Vitals regularly',
                'Consider implementing Redis for session storage in production',
                'Set up CDN for static assets',
                'Enable HTTP/2 on your server',
                'Implement database connection pooling',
                'Consider lazy loading for non-critical images'
            ],
            'next_steps': [
                'Test the application thoroughly after optimization',
                'Monitor performance metrics',
                'Set up automated performance testing',
                'Consider implementing Progressive Web App features'
            ]
        }
        
        report_path = Path('performance_report.json')
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"✅ Performance report saved to {report_path}")
        return True
        
    except Exception as e:
        print(f"❌ Performance report generation failed: {e}")
        return False

def main():
    """Main optimization function."""
    parser = argparse.ArgumentParser(description='Optimize FiCore Labs application')
    parser.add_argument('--production', action='store_true', 
                       help='Run optimizations for production environment')
    parser.add_argument('--skip-assets', action='store_true',
                       help='Skip static asset optimization')
    parser.add_argument('--skip-db', action='store_true',
                       help='Skip database optimization')
    parser.add_argument('--skip-cache', action='store_true',
                       help='Skip cache warming')
    
    args = parser.parse_args()
    
    print("🚀 Starting FiCore Labs optimization...")
    print("=" * 50)
    
    # Set environment
    if args.production:
        os.environ['FLASK_ENV'] = 'production'
        print("🏭 Running in production mode")
    else:
        os.environ['FLASK_ENV'] = 'development'
        print("🔧 Running in development mode")
    
    # Create Flask app
    try:
        app = create_app()
        print("✅ Flask application created successfully")
    except Exception as e:
        print(f"❌ Failed to create Flask application: {e}")
        return 1
    
    success_count = 0
    total_steps = 4
    
    # Optimize static assets
    if not args.skip_assets:
        if optimize_static_assets(app):
            success_count += 1
    else:
        print("⏭️  Skipping static asset optimization")
        total_steps -= 1
    
    # Optimize database
    if not args.skip_db:
        if optimize_database(app):
            success_count += 1
    else:
        print("⏭️  Skipping database optimization")
        total_steps -= 1
    
    # Update service worker
    if update_service_worker():
        success_count += 1
    
    # Warm cache
    if not args.skip_cache:
        if warm_cache(app):
            success_count += 1
    else:
        print("⏭️  Skipping cache warming")
        total_steps -= 1
    
    # Generate performance report
    from datetime import datetime
    generate_performance_report(app)
    
    print("=" * 50)
    print(f"🎉 Optimization complete! {success_count}/{total_steps} steps successful")
    
    if success_count == total_steps:
        print("✅ All optimizations completed successfully!")
        print("\n📋 Next steps:")
        print("1. Test your application thoroughly")
        print("2. Monitor performance metrics")
        print("3. Deploy to production if running in development")
        print("4. Set up monitoring and alerting")
        return 0
    else:
        print("⚠️  Some optimizations failed. Check the logs above.")
        return 1

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)