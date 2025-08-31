import time
from functools import wraps
from datetime import datetime, timedelta
from flask import current_app, g
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError, OperationFailure
import logging

logger = logging.getLogger(__name__)

class DatabaseOptimizer:
    """Handles database optimization and connection management."""
    
    def __init__(self, app=None):
        self.app = app
        self.query_cache = {}
        self.cache_ttl = 300  # 5 minutes default TTL
        if app is not None:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize the database optimizer with the Flask app."""
        self.app = app
        
        # Configure connection pooling
        app.config.setdefault('MONGO_MAX_POOL_SIZE', 50)
        app.config.setdefault('MONGO_MIN_POOL_SIZE', 5)
        app.config.setdefault('MONGO_MAX_IDLE_TIME_MS', 30000)
        app.config.setdefault('MONGO_SERVER_SELECTION_TIMEOUT_MS', 5000)
        
        # Register teardown handler
        app.teardown_appcontext(self.close_db_connection)
    
    def get_optimized_connection(self):
        """Get an optimized MongoDB connection with proper pooling."""
        if 'mongo_client' not in g:
            try:
                g.mongo_client = MongoClient(
                    current_app.config['MONGO_URI'],
                    maxPoolSize=current_app.config.get('MONGO_MAX_POOL_SIZE', 50),
                    minPoolSize=current_app.config.get('MONGO_MIN_POOL_SIZE', 5),
                    maxIdleTimeMS=current_app.config.get('MONGO_MAX_IDLE_TIME_MS', 30000),
                    serverSelectionTimeoutMS=current_app.config.get('MONGO_SERVER_SELECTION_TIMEOUT_MS', 5000),
                    connectTimeoutMS=10000,
                    socketTimeoutMS=20000,
                    retryWrites=True,
                    retryReads=True,
                    readPreference='secondaryPreferred'
                )
                # Test connection
                g.mongo_client.admin.command('ping')
                logger.info("Optimized MongoDB connection established")
            except Exception as e:
                logger.error(f"Failed to establish optimized MongoDB connection: {e}")
                raise
        
        return g.mongo_client
    
    def close_db_connection(self, exception):
        """Close database connection on app context teardown."""
        client = g.pop('mongo_client', None)
        if client is not None:
            client.close()
    
    def cached_query(self, cache_key, ttl=None):
        """Decorator for caching database query results."""
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                if ttl is None:
                    cache_ttl = self.cache_ttl
                else:
                    cache_ttl = ttl
                
                # Check cache
                if cache_key in self.query_cache:
                    cached_data, cached_time = self.query_cache[cache_key]
                    if datetime.utcnow() - cached_time < timedelta(seconds=cache_ttl):
                        logger.debug(f"Cache hit for key: {cache_key}")
                        return cached_data
                
                # Execute query and cache result
                result = func(*args, **kwargs)
                self.query_cache[cache_key] = (result, datetime.utcnow())
                logger.debug(f"Cache miss for key: {cache_key}, result cached")
                
                return result
            return wrapper
        return decorator
    
    def clear_cache(self, pattern=None):
        """Clear query cache, optionally by pattern."""
        if pattern is None:
            self.query_cache.clear()
            logger.info("All query cache cleared")
        else:
            keys_to_remove = [key for key in self.query_cache.keys() if pattern in key]
            for key in keys_to_remove:
                del self.query_cache[key]
            logger.info(f"Cache cleared for pattern: {pattern}, {len(keys_to_remove)} entries removed")
    
    def optimize_collection_indexes(self, db):
        """Optimize collection indexes for better query performance."""
        try:
            # Helper function to check if index exists with same specification
            def index_exists(collection, index_spec, index_name):
                existing_indexes = collection.index_information()
                for name, info in existing_indexes.items():
                    if name == index_name:
                        continue  # Skip if name matches exactly
                    if info.get('key') == index_spec:
                        logger.warning(f"Index with specification {index_spec} already exists with name {name}")
                        return True
                return False

            # Users collection optimization
            users_collection = db.users
            
            # Compound indexes for common queries
            email_active_idx = [('email', 1), ('is_active', 1)]
            if not index_exists(users_collection, email_active_idx, 'email_active_idx'):
                users_collection.create_index(email_active_idx, background=True, name='email_active_idx')
            
            role_subscription_idx = [('role', 1), ('is_subscribed', 1), ('trial_end', 1)]
            if not index_exists(users_collection, role_subscription_idx, 'role_subscription_idx'):
                users_collection.create_index(role_subscription_idx, background=True, name='role_subscription_idx')
            
            # Records collection optimization
            records_collection = db.records
            
            # Compound indexes for dashboard queries
            user_type_created_idx = [('user_id', 1), ('type', 1), ('created_at', -1)]
            if not index_exists(records_collection, user_type_created_idx, 'user_type_created_idx'):
                records_collection.create_index(user_type_created_idx, background=True, name='user_type_created_idx')
            
            user_amount_idx = [('user_id', 1), ('amount_owed', -1)]
            if not index_exists(records_collection, user_amount_idx, 'user_amount_idx'):
                records_collection.create_index(user_amount_idx, background=True, name='user_amount_idx', sparse=True)
            
            # Cashflows collection optimization
            cashflows_collection = db.cashflows
            
            user_type_date_idx = [('user_id', 1), ('type', 1), ('created_at', -1)]
            if not index_exists(cashflows_collection, user_type_date_idx, 'user_type_date_idx'):
                cashflows_collection.create_index(user_type_date_idx, background=True, name='user_type_date_idx')
            
            user_amount_desc_idx = [('user_id', 1), ('amount', -1)]
            if not index_exists(cashflows_collection, user_amount_desc_idx, 'user_amount_desc_idx'):
                cashflows_collection.create_index(user_amount_desc_idx, background=True, name='user_amount_desc_idx')
            
            # Notifications collection optimization
            notifications_collection = db.notifications
            
            user_read_timestamp_idx = [('user_id', 1), ('read', 1), ('timestamp', -1)]
            if not index_exists(notifications_collection, user_read_timestamp_idx, 'user_read_timestamp_idx'):
                notifications_collection.create_index(user_read_timestamp_idx, background=True, name='user_read_timestamp_idx')
            
            # Sessions collection TTL index
            sessions_collection = db.sessions
            session_ttl_idx = [('created_at', 1)]
            if not index_exists(sessions_collection, session_ttl_idx, 'session_ttl_idx'):
                sessions_collection.create_index(
                    'created_at',
                    expireAfterSeconds=1800,  # 30 minutes
                    background=True,
                    name='session_ttl_idx'
                )
            
            logger.info("Database indexes optimized successfully")
            
        except OperationFailure as e:
            logger.error(f"Failed to optimize database indexes: {e}")
            raise
        except Exception as e:
            logger.error(f"Unexpected error during index optimization: {e}")
            raise
    
    def get_aggregation_pipeline_for_dashboard(self, user_id):
        """Get optimized aggregation pipeline for dashboard data."""
        return [
            {
                '$match': {
                    'user_id': user_id
                }
            },
            {
                '$facet': {
                    'debtors': [
                        {'$match': {'type': 'debtor'}},
                        {'$group': {
                            '_id': None,
                            'total_amount': {'$sum': '$amount_owed'},
                            'count': {'$sum': 1}
                        }}
                    ],
                    'creditors': [
                        {'$match': {'type': 'creditor'}},
                        {'$group': {
                            '_id': None,
                            'total_amount': {'$sum': '$amount_owed'},
                            'count': {'$sum': 1}
                        }}
                    ],
                    'recent_records': [
                        {'$sort': {'created_at': -1}},
                        {'$limit': 5},
                        {'$project': {
                            'type': 1,
                            'name': 1,
                            'amount_owed': 1,
                            'created_at': 1
                        }}
                    ]
                }
            }
        ]
    
    def get_optimized_user_stats(self, user_id):
        """Get user statistics with optimized queries."""
        cache_key = f"user_stats_{user_id}"
        
        @self.cached_query(cache_key, ttl=300)  # Cache for 5 minutes
        def _get_stats():
            try:
                client = self.get_optimized_connection()
                db = client['bizdb']
                
                # Use aggregation pipeline for efficient data retrieval
                pipeline = self.get_aggregation_pipeline_for_dashboard(user_id)
                result = list(db.records.aggregate(pipeline))
                
                if result:
                    data = result[0]
                    return {
                        'debtors': data.get('debtors', [{}])[0],
                        'creditors': data.get('creditors', [{}])[0],
                        'recent_records': data.get('recent_records', [])
                    }
                
                return {
                    'debtors': {'total_amount': 0, 'count': 0},
                    'creditors': {'total_amount': 0, 'count': 0},
                    'recent_records': []
                }
                
            except Exception as e:
                logger.error(f"Failed to get user stats for {user_id}: {e}")
                return {
                    'debtors': {'total_amount': 0, 'count': 0},
                    'creditors': {'total_amount': 0, 'count': 0},
                    'recent_records': []
                }
        
        return _get_stats()
    
    def bulk_insert_optimized(self, collection, documents, ordered=False):
        """Perform optimized bulk insert operations."""
        try:
            if not documents:
                return
            
            # Split large batches for better performance
            batch_size = 1000
            for i in range(0, len(documents), batch_size):
                batch = documents[i:i + batch_size]
                collection.insert_many(batch, ordered=ordered)
            
            logger.info(f"Bulk inserted {len(documents)} documents")
            
        except Exception as e:
            logger.error(f"Bulk insert failed: {e}")
            raise
    
    def optimize_query_performance(self, collection, query, projection=None):
        """Optimize query performance with proper projections and hints."""
        try:
            # Use projection to limit returned fields
            if projection is None:
                projection = {'_id': 1}  # Default minimal projection
            
            # Add query hints for better index usage
            cursor = collection.find(query, projection)
            
            # Use appropriate read preference for better performance
            cursor = cursor.read_preference('secondaryPreferred')
            
            return cursor
            
        except Exception as e:
            logger.error(f"Query optimization failed: {e}")
            raise
    
    def monitor_slow_queries(self, threshold_ms=1000):
        """Monitor and log slow database queries."""
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                start_time = time.time()
                result = func(*args, **kwargs)
                execution_time = (time.time() - start_time) * 1000
                
                if execution_time > threshold_ms:
                    logger.warning(f"Slow query detected: {func.__name__} took {execution_time:.2f}ms")
                
                return result
            return wrapper
        return decorator

