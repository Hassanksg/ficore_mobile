"""
Static file optimization utilities for FiCore Labs.
Handles CSS/JS minification, bundling, and asset versioning.
"""

import os
import hashlib
import json
from pathlib import Path
from flask import current_app

class StaticOptimizer:
    """Handles static file optimization and asset management."""
    
    def __init__(self, app=None):
        self.app = app
        self.asset_manifest = {}
        if app is not None:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize the static optimizer with the Flask app."""
        self.app = app
        self.static_folder = Path(app.static_folder)
        self.manifest_path = self.static_folder / 'manifest.json'
        
        # Load existing manifest
        self.load_manifest()
        
        # Register template functions
        app.jinja_env.globals['asset_url'] = self.asset_url
        app.jinja_env.globals['critical_css'] = self.get_critical_css
    
    def load_manifest(self):
        """Load asset manifest from file."""
        if self.manifest_path.exists():
            try:
                with open(self.manifest_path, 'r') as f:
                    self.asset_manifest = json.load(f)
            except (json.JSONDecodeError, IOError):
                self.asset_manifest = {}
        else:
            self.asset_manifest = {}
    
    def save_manifest(self):
        """Save asset manifest to file."""
        try:
            with open(self.manifest_path, 'w') as f:
                json.dump(self.asset_manifest, f, indent=2)
        except IOError as e:
            print(f"Failed to save manifest: {e}")
    
    def generate_file_hash(self, file_path):
        """Generate hash for file content."""
        try:
            with open(file_path, 'rb') as f:
                content = f.read()
                return hashlib.md5(content).hexdigest()[:8]
        except IOError:
            return None
    
    def asset_url(self, filename):
        """Get versioned URL for asset."""
        # Check if we have a versioned file in manifest
        if filename in self.asset_manifest:
            return f"/static/{self.asset_manifest[filename]}"
        
        # Return original filename if no versioned file exists
        return f"/static/{filename}"
    
    def minify_css_file(self, input_path, output_path=None):
        """Minify a CSS file."""
        if output_path is None:
            name, ext = os.path.splitext(input_path)
            output_path = f"{name}.min{ext}"
        
        try:
            with open(input_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Basic CSS minification
            minified = self._minify_css_content(content)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(minified)
            
            return output_path
        except IOError as e:
            print(f"Failed to minify CSS file {input_path}: {e}")
            return input_path
    
    def minify_js_file(self, input_path, output_path=None):
        """Minify a JavaScript file."""
        if output_path is None:
            name, ext = os.path.splitext(input_path)
            output_path = f"{name}.min{ext}"
        
        try:
            with open(input_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Basic JS minification
            minified = self._minify_js_content(content)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(minified)
            
            return output_path
        except IOError as e:
            print(f"Failed to minify JS file {input_path}: {e}")
            return input_path
    
    def _minify_css_content(self, content):
        """Minify CSS content."""
        import re
        
        # Remove comments
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        
        # Remove extra whitespace
        content = re.sub(r'\s+', ' ', content)
        content = re.sub(r';\s*}', '}', content)
        content = re.sub(r'{\s*', '{', content)
        content = re.sub(r'}\s*', '}', content)
        content = re.sub(r':\s*', ':', content)
        content = re.sub(r';\s*', ';', content)
        content = re.sub(r',\s*', ',', content)
        
        return content.strip()
    
    def _minify_js_content(self, content):
        """Minify JavaScript content."""
        import re
        
        # Remove single-line comments (but preserve URLs)
        content = re.sub(r'(?<!:)//.*$', '', content, flags=re.MULTILINE)
        
        # Remove multi-line comments
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        
        # Remove extra whitespace
        content = re.sub(r'\s+', ' ', content)
        content = re.sub(r';\s*', ';', content)
        content = re.sub(r'{\s*', '{', content)
        content = re.sub(r'}\s*', '}', content)
        content = re.sub(r',\s*', ',', content)
        
        return content.strip()
    
    def bundle_css_files(self, file_list, output_name):
        """Bundle multiple CSS files into one."""
        bundled_content = []
        
        for file_path in file_list:
            full_path = self.static_folder / 'css' / file_path
            if full_path.exists():
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        bundled_content.append(f"/* {file_path} */")
                        bundled_content.append(content)
                except IOError as e:
                    print(f"Failed to read CSS file {file_path}: {e}")
        
        # Combine and minify
        combined = '\n'.join(bundled_content)
        minified = self._minify_css_content(combined)
        
        # Write bundled file
        output_path = self.static_folder / 'css' / output_name
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(minified)
            
            # Update manifest
            file_hash = self.generate_file_hash(output_path)
            if file_hash:
                name, ext = os.path.splitext(output_name)
                versioned_name = f"{name}.{file_hash}{ext}"
                versioned_path = self.static_folder / 'css' / versioned_name
                
                # Copy to versioned file
                with open(versioned_path, 'w', encoding='utf-8') as f:
                    f.write(minified)
                
                self.asset_manifest[f"css/{output_name}"] = f"css/{versioned_name}"
                self.save_manifest()
            
            return output_name
        except IOError as e:
            print(f"Failed to write bundled CSS file: {e}")
            return None
    
    def bundle_js_files(self, file_list, output_name):
        """Bundle multiple JavaScript files into one."""
        bundled_content = []
        
        for file_path in file_list:
            full_path = self.static_folder / 'js' / file_path
            if full_path.exists():
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        bundled_content.append(f"/* {file_path} */")
                        bundled_content.append(content)
                        bundled_content.append(';')  # Ensure statements are separated
                except IOError as e:
                    print(f"Failed to read JS file {file_path}: {e}")
        
        # Combine and minify
        combined = '\n'.join(bundled_content)
        minified = self._minify_js_content(combined)
        
        # Write bundled file
        output_path = self.static_folder / 'js' / output_name
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(minified)
            
            # Update manifest
            file_hash = self.generate_file_hash(output_path)
            if file_hash:
                name, ext = os.path.splitext(output_name)
                versioned_name = f"{name}.{file_hash}{ext}"
                versioned_path = self.static_folder / 'js' / versioned_name
                
                # Copy to versioned file
                with open(versioned_path, 'w', encoding='utf-8') as f:
                    f.write(minified)
                
                self.asset_manifest[f"js/{output_name}"] = f"js/{versioned_name}"
                self.save_manifest()
            
            return output_name
        except IOError as e:
            print(f"Failed to write bundled JS file: {e}")
            return None
    
    def get_critical_css(self):
        """Get critical CSS that should be inlined."""
        critical_css_path = self.static_folder / 'css' / 'critical.css'
        if critical_css_path.exists():
            try:
                with open(critical_css_path, 'r', encoding='utf-8') as f:
                    return f.read()
            except IOError:
                pass
        return ""
    
    def optimize_all_assets(self):
        """Optimize all static assets."""
        print("Starting asset optimization...")
        
        # Bundle and minify CSS files
        css_files = [
            'styles.css',
            'newbasefilelooks.css',
            'iconslooks.css',
            'profile_css.css',
            'navigation_enhancements.css'
        ]
        
        bundled_css = self.bundle_css_files(css_files, 'bundle.min.css')
        if bundled_css:
            print(f"Created CSS bundle: {bundled_css}")
        
        # Bundle and minify JS files
        js_files = [
            'scripts.js',
            'interactivity.js'
        ]
        
        bundled_js = self.bundle_js_files(js_files, 'bundle.min.js')
        if bundled_js:
            print(f"Created JS bundle: {bundled_js}")
        
        print("Asset optimization complete!")
        return {
            'css_bundle': bundled_css,
            'js_bundle': bundled_js,
            'manifest': self.asset_manifest
        }