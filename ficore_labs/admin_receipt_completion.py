"""
Completion of admin receipt management functionality
"""
from datetime import datetime, timezone, timedelta
from bson import ObjectId
from flask import flash, redirect, url_for
from models import update_user, get_mongo_db
import logging

logger = logging.getLogger('business_finance_app')

def complete_approve_receipt(receipt_id, admin_user_id):
    """Complete the receipt approval process."""
    try:
        db = get_mongo_db()
        if db is None:
            raise Exception("Failed to connect to MongoDB")
        
        receipt = db.payment_receipts.find_one({'_id': ObjectId(receipt_id)})
        if not receipt:
            return False, 'Receipt not found'
        
        # Update receipt status
        db.payment_receipts.update_one(
            {'_id': ObjectId(receipt_id)},
            {'$set': {
                'status': 'approved', 
                'approved_by': admin_user_id, 
                'approved_at': datetime.now(timezone.utc)
            }}
        )
        
        # Activate user subscription
        plan_duration = 30 if receipt['plan_type'] == 'monthly' else 365
        subscription_end = datetime.now(timezone.utc) + timedelta(days=plan_duration)
        
        update_data = {
            'is_subscribed': True,
            'subscription_plan': receipt['plan_type'],
            'subscription_start': datetime.now(timezone.utc),
            'subscription_end': subscription_end,
            'is_trial': False,  # End trial when subscription starts
            'updated_at': datetime.now(timezone.utc)
        }
        
        success = update_user(db, receipt['user_id'], update_data)
        
        if success:
            # Log audit event
            db.audit_logs.insert_one({
                'admin_id': admin_user_id,
                'action': 'approve_receipt',
                'details': {
                    'receipt_id': str(receipt_id),
                    'user_id': receipt['user_id'],
                    'plan_type': receipt['plan_type'],
                    'amount_paid': receipt['amount_paid']
                },
                'timestamp': datetime.now(timezone.utc)
            })
            
            logger.info(f"Receipt {receipt_id} approved by admin {admin_user_id} for user {receipt['user_id']}")
            return True, 'Receipt approved and subscription activated'
        else:
            return False, 'Failed to update user subscription'
            
    except Exception as e:
        logger.error(f"Error approving receipt {receipt_id}: {str(e)}")
        return False, f'Error approving receipt: {str(e)}'

def complete_reject_receipt(receipt_id, admin_user_id, reason):
    """Complete the receipt rejection process."""
    try:
        db = get_mongo_db()
        if db is None:
            raise Exception("Failed to connect to MongoDB")
        
        receipt = db.payment_receipts.find_one({'_id': ObjectId(receipt_id)})
        if not receipt:
            return False, 'Receipt not found'
        
        # Update receipt status
        db.payment_receipts.update_one(
            {'_id': ObjectId(receipt_id)},
            {'$set': {
                'status': 'rejected', 
                'rejected_by': admin_user_id, 
                'rejected_at': datetime.now(timezone.utc),
                'rejection_reason': reason
            }}
        )
        
        # Log audit event
        db.audit_logs.insert_one({
            'admin_id': admin_user_id,
            'action': 'reject_receipt',
            'details': {
                'receipt_id': str(receipt_id),
                'user_id': receipt['user_id'],
                'reason': reason
            },
            'timestamp': datetime.now(timezone.utc)
        })
        
        logger.info(f"Receipt {receipt_id} rejected by admin {admin_user_id} for user {receipt['user_id']}")
        return True, 'Receipt rejected successfully'
        
    except Exception as e:
        logger.error(f"Error rejecting receipt {receipt_id}: {str(e)}")
        return False, f'Error rejecting receipt: {str(e)}'