from datetime import datetime, timezone
from models import get_mongo_db, update_user, get_user
from flask_login import current_user
from flask import session
import logging

logger = logging.getLogger('business_finance_app')

def get_user_settings(user_id):
    """Get user settings from database."""
    try:
        db = get_mongo_db()
        user = get_user(db, user_id)
        if not user:
            return None
        
        # Default settings structure
        default_settings = {
            'language': 'en',
            'theme': 'light',
            'layout': 'default',
            'show_kobo': True,
            'incognito_mode': False,
            'app_sounds': True,
            'fingerprint_password': False,
            'fingerprint_pin': False,
            'hide_sensitive_data': False
        }
        
        # Merge user settings with defaults
        user_settings = default_settings.copy()
        
        # Get language from user record
        if hasattr(user, 'language') and user.language:
            user_settings['language'] = user.language
        
        # Get theme preference (dark_mode field)
        if hasattr(user, 'dark_mode') and user.dark_mode is not None:
            user_settings['theme'] = 'dark' if user.dark_mode else 'light'
        
        # Get other settings from user.settings
        if hasattr(user, 'settings') and user.settings:
            user_settings.update(user.settings)
        
        # Get security settings from user.security_settings
        if hasattr(user, 'security_settings') and user.security_settings:
            user_settings.update(user.security_settings)
        
        return user_settings
        
    except Exception as e:
        logger.error(f"Error getting user settings for {user_id}: {str(e)}")
        return None

def save_user_settings(user_id, settings):
    """Save user settings to database."""
    try:
        db = get_mongo_db()
        
        # Separate settings into different categories
        update_data = {}
        
        # Language setting
        if 'language' in settings:
            update_data['language'] = settings['language']
        
        # Theme setting (stored as dark_mode boolean)
        if 'theme' in settings:
            update_data['dark_mode'] = settings['theme'] == 'dark'
        
        # General settings
        general_settings = {}
        for key in ['show_kobo', 'incognito_mode', 'app_sounds', 'layout']:
            if key in settings:
                general_settings[key] = settings[key]
        
        if general_settings:
            update_data['settings'] = general_settings
        
        # Security settings
        security_settings = {}
        for key in ['fingerprint_password', 'fingerprint_pin', 'hide_sensitive_data']:
            if key in settings:
                security_settings[key] = settings[key]
        
        if security_settings:
            update_data['security_settings'] = security_settings
        
        # Add timestamp
        update_data['updated_at'] = datetime.now(timezone.utc)
        
        # Update user record
        result = update_user(db, user_id, update_data)
        
        if result:
            logger.info(f"User settings saved for {user_id}: {list(settings.keys())}")
            return True
        else:
            logger.warning(f"No changes made to user settings for {user_id}")
            return False
            
    except Exception as e:
        logger.error(f"Error saving user settings for {user_id}: {str(e)}")
        return False

def apply_user_settings_to_session(user_id):
    """Apply user settings to current session."""
    try:
        settings = get_user_settings(user_id)
        if not settings:
            return False
        
        # Apply language setting to session
        if settings.get('language'):
            session['lang'] = settings['language']
        
        # Apply theme setting to session
        if settings.get('theme'):
            session['dark_mode'] = settings['theme'] == 'dark'
        
        # Apply other settings to session for template access
        session['user_settings'] = {
            'show_kobo': settings.get('show_kobo', True),
            'incognito_mode': settings.get('incognito_mode', False),
            'app_sounds': settings.get('app_sounds', True),
            'layout': settings.get('layout', 'default')
        }
        
        session['security_settings'] = {
            'fingerprint_password': settings.get('fingerprint_password', False),
            'fingerprint_pin': settings.get('fingerprint_pin', False),
            'hide_sensitive_data': settings.get('hide_sensitive_data', False)
        }
        
        session.modified = True
        logger.info(f"User settings applied to session for {user_id}")
        return True
        
    except Exception as e:
        logger.error(f"Error applying user settings to session for {user_id}: {str(e)}")
        return False

def get_default_user_settings():
    """Get default user settings."""
    return {
        'language': 'en',
        'theme': 'light',
        'layout': 'default',
        'show_kobo': True,
        'incognito_mode': False,
        'app_sounds': True,
        'fingerprint_password': False,
        'fingerprint_pin': False,
        'hide_sensitive_data': False
    }