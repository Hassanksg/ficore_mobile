from flask import Blueprint, request, session, jsonify, redirect, url_for, current_app
from flask_login import current_user
from models import update_user, get_mongo_db
from datetime import datetime, timezone
import logging

logger = logging.getLogger('business_finance_app')

language_bp = Blueprint('language_bp', __name__, url_prefix='/language')

@language_bp.route('/set/<lang>')
def set_language(lang):
    """Set the user's language preference."""
    try:
        # Validate language
        if lang not in ['en', 'ha']:
            logger.warning(
                f"Invalid language '{lang}' requested",
                extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id if current_user.is_authenticated else 'anonymous'}
            )
            lang = 'en'  # Default to English
        
        # Set in session for immediate effect
        session['lang'] = lang
        session.modified = True
        
        # If user is authenticated, save to database
        if current_user.is_authenticated:
            try:
                db = get_mongo_db()
                update_data = {
                    'language': lang,
                    'updated_at': datetime.now(timezone.utc)
                }
                update_user(db, current_user.id, update_data)
                logger.info(
                    f"Language preference saved to database for user {current_user.id}: {lang}",
                    extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id}
                )
            except Exception as e:
                logger.error(
                    f"Failed to save language preference to database for user {current_user.id}: {str(e)}",
                    extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id}
                )
                # Continue anyway - session setting still works
        
        logger.info(
            f"Language set to {lang} for session {session.get('sid', 'no-session-id')}",
            extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id if current_user.is_authenticated else 'anonymous'}
        )
        
        # Return to previous page or home
        return redirect(request.referrer or url_for('general_bp.home'))
        
    except Exception as e:
        logger.error(
            f"Error setting language: {str(e)}",
            extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id if current_user.is_authenticated else 'anonymous'}
        )
        return redirect(url_for('general_bp.home'))

@language_bp.route('/api/set', methods=['POST'])
def api_set_language():
    """API endpoint to set language via AJAX."""
    try:
        data = request.get_json()
        lang = data.get('lang', 'en')
        
        # Validate language
        if lang not in ['en', 'ha']:
            return jsonify({'success': False, 'message': 'Invalid language'}), 400
        
        # Set in session
        session['lang'] = lang
        session.modified = True
        
        # If user is authenticated, save to database
        if current_user.is_authenticated:
            try:
                db = get_mongo_db()
                update_data = {
                    'language': lang,
                    'updated_at': datetime.now(timezone.utc)
                }
                update_user(db, current_user.id, update_data)
                logger.info(
                    f"Language preference saved via API for user {current_user.id}: {lang}",
                    extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id}
                )
            except Exception as e:
                logger.error(
                    f"Failed to save language preference via API for user {current_user.id}: {str(e)}",
                    extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id}
                )
                return jsonify({'success': False, 'message': 'Failed to save preference'}), 500
        
        return jsonify({'success': True, 'language': lang})
        
    except Exception as e:
        logger.error(
            f"Error in API set language: {str(e)}",
            extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id if current_user.is_authenticated else 'anonymous'}
        )
        return jsonify({'success': False, 'message': 'Internal error'}), 500