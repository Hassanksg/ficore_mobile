"""
Additional admin routes for receipt management completion
"""
from flask import Blueprint, request, flash, redirect, url_for, render_template, session
from flask_login import login_required, current_user
from admin_receipt_completion import complete_approve_receipt, complete_reject_receipt
from translations import trans
import utils
import logging

logger = logging.getLogger('business_finance_app')

admin_receipt_bp = Blueprint('admin_receipt', __name__, url_prefix='/admin')

@admin_receipt_bp.route('/receipts/approve/<receipt_id>', methods=['POST'])
@login_required
@utils.requires_role('admin')
@utils.limiter.limit("10 per hour")
def approve_receipt(receipt_id):
    """Approve a payment receipt and activate user subscription."""
    try:
        success, message = complete_approve_receipt(receipt_id, current_user.id)
        
        if success:
            flash(trans('admin_receipt_approved', default='Receipt approved and subscription activated'), 'success')
        else:
            flash(trans('admin_receipt_approval_failed', default=f'Failed to approve receipt: {message}'), 'danger')
        
        return redirect(url_for('admin.manage_receipts'))
        
    except Exception as e:
        logger.error(f"Error in approve_receipt route for receipt {receipt_id}: {str(e)}",
                     extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id})
        flash(trans('admin_database_error', default='An error occurred while processing the request'), 'danger')
        return redirect(url_for('admin.manage_receipts'))

@admin_receipt_bp.route('/receipts/reject/<receipt_id>', methods=['POST'])
@login_required
@utils.requires_role('admin')
@utils.limiter.limit("10 per hour")
def reject_receipt(receipt_id):
    """Reject a payment receipt."""
    try:
        reason = request.form.get('reason', '').strip()
        if not reason:
            flash(trans('admin_rejection_reason_required', default='Rejection reason is required'), 'danger')
            return redirect(url_for('admin.manage_receipts'))
        
        success, message = complete_reject_receipt(receipt_id, current_user.id, reason)
        
        if success:
            flash(trans('admin_receipt_rejected', default='Receipt rejected successfully'), 'success')
        else:
            flash(trans('admin_receipt_rejection_failed', default=f'Failed to reject receipt: {message}'), 'danger')
        
        return redirect(url_for('admin.manage_receipts'))
        
    except Exception as e:
        logger.error(f"Error in reject_receipt route for receipt {receipt_id}: {str(e)}",
                     extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id})
        flash(trans('admin_database_error', default='An error occurred while processing the request'), 'danger')
        return redirect(url_for('admin.manage_receipts'))

@admin_receipt_bp.route('/receipts/view/<receipt_id>')
@login_required
@utils.requires_role('admin')
@utils.limiter.limit("50 per hour")
def view_receipt(receipt_id):
    """View a specific receipt with details."""
    try:
        from bson import ObjectId
        db = utils.get_mongo_db()
        if db is None:
            raise Exception("Failed to connect to MongoDB")
        
        receipt = db.payment_receipts.find_one({'_id': ObjectId(receipt_id)})
        if not receipt:
            flash(trans('admin_receipt_not_found', default='Receipt not found'), 'danger')
            return redirect(url_for('admin.manage_receipts'))
        
        # Get user information
        user = db.users.find_one({'_id': receipt['user_id']})
        receipt['user_email'] = user.get('email', 'Unknown') if user else 'Unknown'
        receipt['user_display_name'] = user.get('display_name', receipt['user_id']) if user else receipt['user_id']
        receipt['_id'] = str(receipt['_id'])
        
        logger.info(f"Admin {current_user.id} viewed receipt {receipt_id}",
                    extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id})
        
        return render_template('admin/receipt_detail.html', receipt=receipt,
                             title=trans('admin_receipt_details', default='Receipt Details'))
        
    except Exception as e:
        logger.error(f"Error viewing receipt {receipt_id}: {str(e)}",
                     extra={'session_id': session.get('sid', 'no-session-id'), 'user_id': current_user.id})
        flash(trans('admin_database_error', default='An error occurred while accessing the database'), 'danger')
        return redirect(url_for('admin.manage_receipts'))