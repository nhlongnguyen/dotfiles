# Python Coding Principles

## PEP 8 and Core Python Guidelines

These guidelines follow PEP 8 and Python best practices for writing clean, maintainable code.

### Rule 1: Functions should be no longer than 20 lines
- Keep functions focused and readable
- Extract complex logic into smaller functions
- Aim for single responsibility per function

```python
# Good - Under 20 lines, focused responsibility
def process_user(user: dict) -> bool:
    """Process a user if they are valid and active."""
    if not user:
        return False
    if not user.get('valid', False):
        return False
    if not user.get('active', False):
        return False
    
    user['processed'] = True
    send_notification(user)
    return True

# Good - Complex logic extracted to separate functions
def calculate_user_score(user: dict) -> float:
    """Calculate user score based on activity and engagement."""
    activity_score = calculate_activity_score(user)
    engagement_score = calculate_engagement_score(user)
    bonus_score = calculate_bonus_score(user)
    
    return (activity_score * 0.5) + (engagement_score * 0.3) + (bonus_score * 0.2)

# Avoid - Too many lines, multiple responsibilities
def complex_user_processing(user: dict) -> dict:
    """Process user with validation, scoring, and notification."""
    # Validation logic (5 lines)
    if not user or not isinstance(user, dict):
        raise ValueError("Invalid user data")
    if not user.get('email') or '@' not in user['email']:
        raise ValueError("Invalid email")
    
    # Score calculation (10 lines)
    score = 0
    if user.get('posts', 0) > 10:
        score += 50
    if user.get('likes', 0) > 100:
        score += 30
    # ... more scoring logic
    
    # Notification logic (8 lines)
    if score > 80:
        send_email(user['email'], 'High score achieved!')
    elif score > 50:
        send_email(user['email'], 'Good progress!')
    # ... more notification logic
    
    return user  # 25+ lines total - violates rule
```

### Rule 2: Classes should be no longer than 100 lines
- Split large classes into smaller, focused classes
- Use composition over inheritance
- Consider using modules for related functionality

```python
# Good - Under 100 lines, single responsibility
class User:
    """Represents a user with basic operations."""
    
    def __init__(self, name: str, email: str, active: bool = True):
        self.name = name
        self.email = email
        self.active = active
        self.created_at = datetime.now()
    
    def is_active(self) -> bool:
        """Check if user is active."""
        return self.active
    
    def activate(self) -> None:
        """Activate the user."""
        self.active = True
    
    def deactivate(self) -> None:
        """Deactivate the user."""
        self.active = False
    
    def get_display_name(self) -> str:
        """Get user's display name."""
        return self.name.title()
    
    def __str__(self) -> str:
        return f"User({self.name}, {self.email})"

# Good - Separate concerns into different classes
class UserValidator:
    """Validates user data."""
    
    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format."""
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    @staticmethod
    def validate_name(name: str) -> bool:
        """Validate name format."""
        return bool(name and name.strip() and len(name) <= 100)

# Avoid - Too many responsibilities in one class
class MassiveUser:
    """
    This class violates the 100-line rule and has too many responsibilities:
    - User data management
    - Email validation
    - Password hashing
    - Notification sending
    - Database operations
    - API integrations
    - File operations
    - Logging
    - Analytics tracking
    # ... imagine 150+ lines of mixed responsibilities
    """
    pass
```

### Rule 3: Use no more than 4 parameters in function signatures
- Use dataclasses, TypedDict, or objects for multiple related parameters
- Consider using keyword-only arguments for clarity

```python
# Good - 4 parameters max
def create_user(name: str, email: str, role: str, active: bool = True) -> dict:
    """Create a user with basic information."""
    return {
        'name': name,
        'email': email,
        'role': role,
        'active': active,
        'created_at': datetime.now()
    }

# Good - Use dataclass for related parameters
from dataclasses import dataclass
from typing import Optional

@dataclass
class UserData:
    name: str
    email: str
    role: str
    active: bool = True
    department: Optional[str] = None
    manager: Optional[str] = None

def create_user_from_data(user_data: UserData) -> dict:
    """Create user from structured data."""
    return {
        'name': user_data.name,
        'email': user_data.email,
        'role': user_data.role,
        'active': user_data.active,
        'department': user_data.department,
        'manager': user_data.manager,
        'created_at': datetime.now()
    }

# Good - Use TypedDict for structured data
from typing import TypedDict

class UserCreateRequest(TypedDict):
    name: str
    email: str
    role: str
    active: bool
    department: str
    manager: str

def create_user_from_request(request: UserCreateRequest) -> dict:
    """Create user from typed request."""
    return {**request, 'created_at': datetime.now()}

# Avoid - Too many parameters
def create_user(name: str, email: str, role: str, department: str, 
               manager: str, active: bool, created_at: datetime, 
               permissions: list) -> dict:
    """8 parameters make this function difficult to use and understand."""
    pass
```

### Rule Zero: Exception Rule
**"Break these rules only when you have a good reason and document it clearly."**

```python
# Good - Documented exception
class LegacyDataProcessor:
    """
    PYTHON_RULE_EXCEPTION: Legacy system integration requires more than 100 lines
    Approved by: @team_lead
    Reason: Complex mapping logic for 50+ legacy fields cannot be reasonably split
    without breaking the atomic transaction requirements
    """
    
    def process_legacy_data(self, data: dict) -> dict:
        """Process legacy data with complex field mapping."""
        # ... implementation exceeds 100 lines
        pass

# Avoid - Undocumented rule violations
class MassiveProcessor:
    """
    This class has 200+ lines with no explanation why
    No approval or justification for breaking the rules
    """
    pass
```

## Design Principles

### When to Use OOP vs Functional Programming in Python

#### Use Object-Oriented Programming When:

**Modeling Domain Entities**
```python
# Good - OOP for domain models
class User:
    """Represents a user in the system."""
    
    def __init__(self, name: str, email: str, role: str = 'user'):
        self.name = name
        self.email = email
        self.role = role
    
    def is_admin(self) -> bool:
        """Check if user has admin privileges."""
        return self.role == 'admin'
    
    def can_access_resource(self, resource: 'Resource') -> bool:
        """Check if user can access a resource."""
        return self.is_admin() or resource.owner == self

class Resource:
    """Represents a system resource."""
    
    def __init__(self, name: str, owner: User):
        self.name = name
        self.owner = owner

# Usage
user = User("John", "john@example.com", "admin")
resource = Resource("Document", user)
can_access = user.can_access_resource(resource)

# Avoid - Procedural approach for domain logic
def is_admin(user_dict: dict) -> bool:
    """Check if user is admin."""
    return user_dict.get('role') == 'admin'

def can_access_resource(user_dict: dict, resource_dict: dict) -> bool:
    """Check resource access."""
    return is_admin(user_dict) or resource_dict['owner'] == user_dict['name']
```

**Managing State and Behavior Together**
```python
# Good - OOP for stateful objects
class ShoppingCart:
    """Shopping cart with state management."""
    
    def __init__(self):
        self._items: List[dict] = []
    
    def add_item(self, item: dict) -> 'ShoppingCart':
        """Add item to cart."""
        self._items.append(item)
        return self
    
    def total(self) -> float:
        """Calculate total price."""
        return sum(item['price'] for item in self._items)
    
    def is_empty(self) -> bool:
        """Check if cart is empty."""
        return len(self._items) == 0
    
    def item_count(self) -> int:
        """Get number of items."""
        return len(self._items)

# Usage
cart = ShoppingCart()
cart.add_item({'name': 'Book', 'price': 10.99})
cart.add_item({'name': 'Pen', 'price': 2.99})
print(f"Total: ${cart.total():.2f}")  # Total: $13.98

# Avoid - Functional approach for stateful operations
def add_item_to_cart(cart: list, item: dict) -> list:
    """Add item to cart (creates new list each time)."""
    return cart + [item]  # Inefficient for state management

def calculate_total(cart: list) -> float:
    """Calculate cart total."""
    return sum(item['price'] for item in cart)
```

#### Use Functional Programming When:

**Data Transformations and Processing**
```python
# Good - FP for data processing
from typing import List, Dict, Any
from functools import reduce

def calculate_user_stats(users: List[dict]) -> Dict[str, Dict[str, Any]]:
    """Calculate user statistics by role."""
    active_users = [user for user in users if user.get('active', False)]
    
    # Group by role
    role_groups = {}
    for user in active_users:
        role = user.get('role', 'unknown')
        if role not in role_groups:
            role_groups[role] = []
        role_groups[role].append(user)
    
    # Calculate stats for each role
    stats = {}
    for role, role_users in role_groups.items():
        stats[role] = {
            'count': len(role_users),
            'avg_age': sum(u.get('age', 0) for u in role_users) / len(role_users) if role_users else 0
        }
    
    return stats

# Using itertools and functools for more functional approach
from itertools import groupby
from operator import itemgetter

def calculate_user_stats_functional(users: List[dict]) -> Dict[str, Dict[str, Any]]:
    """Calculate user statistics using functional programming."""
    return {
        role: {
            'count': len(role_users),
            'avg_age': sum(u.get('age', 0) for u in role_users) / len(role_users) if role_users else 0
        }
        for role, role_users in groupby(
            sorted([u for u in users if u.get('active', False)], key=itemgetter('role')),
            key=itemgetter('role')
        )
    }

# Usage
users = [
    {'name': 'John', 'age': 30, 'role': 'admin', 'active': True},
    {'name': 'Jane', 'age': 25, 'role': 'user', 'active': True},
    {'name': 'Bob', 'age': 35, 'role': 'user', 'active': False}
]

stats = calculate_user_stats(users)
# {'admin': {'count': 1, 'avg_age': 30.0}, 'user': {'count': 1, 'avg_age': 25.0}}

# Avoid - OOP for simple data transformations
class UserStatsCalculator:
    """Unnecessary class for simple calculation."""
    
    def __init__(self, users: List[dict]):
        self.users = users
    
    def calculate(self) -> Dict[str, Dict[str, Any]]:
        """Calculate statistics."""
        # Unnecessary object creation for simple transformation
        pass
```

**Pure Business Logic**
```python
# Good - FP for calculations
from typing import Optional, Dict

class PricingCalculator:
    """Pricing calculation utilities."""
    
    PROMO_CODES = {
        'SAVE10': 0.10,
        'SAVE20': 0.20,
        'WELCOME25': 0.25
    }
    
    @staticmethod
    def calculate_discount(order_total: float, user_tier: str, 
                          promo_code: Optional[str] = None) -> float:
        """Calculate final price after discounts."""
        base_discount = PricingCalculator._get_tier_discount(user_tier)
        promo_discount = PricingCalculator._get_promo_discount(promo_code)
        total_discount = min(base_discount + promo_discount, 0.5)  # Max 50% discount
        
        return order_total * (1 - total_discount)
    
    @staticmethod
    def _get_tier_discount(tier: str) -> float:
        """Get discount based on user tier."""
        tier_discounts = {
            'premium': 0.15,
            'gold': 0.10,
            'silver': 0.05
        }
        return tier_discounts.get(tier, 0.0)
    
    @staticmethod
    def _get_promo_discount(promo_code: Optional[str]) -> float:
        """Get discount for promo code."""
        if not promo_code:
            return 0.0
        return PricingCalculator.PROMO_CODES.get(promo_code, 0.0)

# Usage
final_price = PricingCalculator.calculate_discount(
    order_total=100.0,
    user_tier='premium',
    promo_code='SAVE10'
)
print(f"Final price: ${final_price:.2f}")  # Final price: $75.00

# Avoid - Stateful object for pure calculations
class StatefulPricingCalculator:
    """Unnecessary state for pure calculation."""
    
    def __init__(self, order_total: float, user_tier: str, promo_code: Optional[str]):
        self.order_total = order_total
        self.user_tier = user_tier
        self.promo_code = promo_code
    
    def calculate(self) -> float:
        """Calculate final price."""
        # Unnecessary state for pure calculation
        pass
```

#### Use Hybrid Approach When:

**Service Objects with Functional Core**
```python
# Good - OOP structure with FP core
from typing import Dict, Any, Union

class OrderProcessor:
    """Process orders with functional core."""
    
    def __init__(self, order: dict):
        self.order = order
    
    def process(self) -> Dict[str, Any]:
        """Process order with functional pipeline."""
        result = self._process_order_pipeline(self.order)
        
        if result['success']:
            self._update_order(result['data'])
            self._notify_success(result['data'])
        else:
            self._handle_error(result['error'])
        
        return result
    
    def _process_order_pipeline(self, order: dict) -> Dict[str, Any]:
        """Functional pipeline for order processing."""
        try:
            # Functional composition
            validated = self._validate_order(order)
            if not validated['success']:
                return validated
            
            calculated = self._calculate_totals(validated['data'])
            if not calculated['success']:
                return calculated
            
            discounted = self._apply_discounts(calculated['data'])
            return discounted
            
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def _validate_order(self, order: dict) -> Dict[str, Any]:
        """Validate order data."""
        if not order.get('items'):
            return {'success': False, 'error': 'No items in order'}
        if not order.get('customer'):
            return {'success': False, 'error': 'No customer information'}
        return {'success': True, 'data': order}
    
    def _calculate_totals(self, order: dict) -> Dict[str, Any]:
        """Calculate order totals."""
        total = sum(item['price'] * item['quantity'] for item in order['items'])
        order['total'] = total
        return {'success': True, 'data': order}
    
    def _apply_discounts(self, order: dict) -> Dict[str, Any]:
        """Apply discounts to order."""
        discount = order.get('discount', 0)
        order['final_total'] = order['total'] * (1 - discount)
        return {'success': True, 'data': order}
    
    def _update_order(self, order: dict) -> None:
        """Update order in system."""
        # Implementation for order update
        pass
    
    def _notify_success(self, order: dict) -> None:
        """Send success notification."""
        # Implementation for notification
        pass
    
    def _handle_error(self, error: str) -> None:
        """Handle processing error."""
        # Implementation for error handling
        pass

# Avoid - Pure OOP without functional benefits
class OrderProcessorOOP:
    """Too much coupling, hard to test individual steps."""
    
    def process(self):
        self._validate_order_state()
        self._calculate_order_totals()
        self._apply_order_discounts()
        # Hard to test individual steps, tightly coupled
    
    def _validate_order_state(self):
        # Modifies self.order directly
        pass
    
    def _calculate_order_totals(self):
        # Depends on previous step's state modification
        pass

# Avoid - Pure FP without OOP benefits
def process_order(order: dict) -> dict:
    """No clear entry point, no state management."""
    # Implementation lacks structure and context
    pass
```

## Class Design Principles

### Single Responsibility Principle
```python
# Good - Single responsibility
class User:
    """Represents a user with basic information."""
    
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
        self.created_at = datetime.now()
    
    def get_full_name(self) -> str:
        """Get user's full name."""
        return self.name.strip()
    
    def is_valid_email(self) -> bool:
        """Check if email is valid format."""
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, self.email))

class UserEmailer:
    """Handles user email operations."""
    
    @staticmethod
    def send_welcome_email(user: User) -> None:
        """Send welcome email to user."""
        print(f"Sending welcome email to {user.email}")
    
    @staticmethod
    def send_notification(user: User, message: str) -> None:
        """Send notification email to user."""
        print(f"Sending notification to {user.email}: {message}")

# Usage
user = User("John Doe", "john@example.com")
UserEmailer.send_welcome_email(user)

# Avoid - Multiple responsibilities
class User:
    """User class with too many responsibilities."""
    
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
        self.created_at = datetime.now()
    
    def get_full_name(self) -> str:
        """Get user's full name."""
        return self.name.strip()
    
    def send_welcome_email(self) -> None:
        """Send welcome email."""
        print(f"Sending welcome email to {self.email}")
    
    def log_activity(self, action: str) -> None:
        """Log user activity."""
        print(f"User {self.name} performed {action}")
    
    def calculate_permissions(self) -> list:
        """Calculate user permissions."""
        # Permission logic mixed with user data
        pass
    
    def backup_to_database(self) -> None:
        """Backup user to database."""
        # Database logic mixed with user data
        pass
```

### Use Composition Over Inheritance
```python
# Good - Composition for shared behavior
from abc import ABC, abstractmethod
from datetime import datetime

class TimestampMixin:
    """Mixin for timestamp functionality."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
    
    def touch(self) -> None:
        """Update timestamp."""
        self.updated_at = datetime.now()

class User(TimestampMixin):
    """User with timestamp functionality."""
    
    def __init__(self, name: str):
        self.name = name
        super().__init__()
    
    def update_name(self, new_name: str) -> None:
        """Update user name."""
        self.name = new_name
        self.touch()

class Post(TimestampMixin):
    """Post with timestamp functionality."""
    
    def __init__(self, title: str, content: str):
        self.title = title
        self.content = content
        super().__init__()
    
    def update_content(self, new_content: str) -> None:
        """Update post content."""
        self.content = new_content
        self.touch()

# Usage
user = User("John")
post = Post("My Post", "Content")
print(f"User created at: {user.created_at}")
print(f"Post created at: {post.created_at}")

# Avoid - Duplicated behavior
class User:
    """User with duplicated timestamp logic."""
    
    def __init__(self, name: str):
        self.name = name
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
    
    def touch(self) -> None:
        """Update timestamp."""
        self.updated_at = datetime.now()

class Post:
    """Post with duplicated timestamp logic."""
    
    def __init__(self, title: str, content: str):
        self.title = title
        self.content = content
        self.created_at = datetime.now()  # Duplicated logic
        self.updated_at = datetime.now()  # Duplicated logic
    
    def touch(self) -> None:
        """Update timestamp."""
        self.updated_at = datetime.now()  # Duplicated logic
```

## Method Design Principles

### Use Type Hints and Clear Parameter Names
```python
# Good - Clear type hints and parameter names
def create_user(name: str, email: str, active: bool = True) -> Dict[str, Any]:
    """Create a user with the given information."""
    return {
        'name': name,
        'email': email,
        'active': active,
        'created_at': datetime.now()
    }

# Good - Use keyword-only arguments for clarity
def send_notification(*, user_id: int, message: str, priority: str = 'normal') -> None:
    """Send notification to user."""
    print(f"Sending {priority} notification to user {user_id}: {message}")

# Usage
user = create_user(name="John", email="john@example.com")
send_notification(user_id=1, message="Welcome!", priority="high")

# Avoid - Unclear parameter types and names
def create_user(n, e, a=True):
    """Create a user."""
    return {'name': n, 'email': e, 'active': a}

# Avoid - Positional arguments for non-obvious parameters
def send_notification(user_id, message, priority='normal'):
    """Send notification."""
    pass

# Usage (unclear what the parameters mean)
send_notification(1, "Welcome!", "high")  # What does "high" refer to?
```

### Use Early Returns and Guard Clauses
```python
# Good - Early returns reduce nesting
def process_user(user: Optional[dict]) -> str:
    """Process user if valid and active."""
    if not user:
        return "User is None"
    
    if not user.get('valid', False):
        return "User is invalid"
    
    if not user.get('active', False):
        return "User is inactive"
    
    # Main processing logic
    user['processed'] = True
    return "User processed successfully"

# Good - Guard clauses for validation
def calculate_discount(price: float, discount_percent: float) -> float:
    """Calculate discounted price."""
    if price < 0:
        raise ValueError("Price cannot be negative")
    
    if not 0 <= discount_percent <= 100:
        raise ValueError("Discount percent must be between 0 and 100")
    
    return price * (1 - discount_percent / 100)

# Avoid - Nested conditions
def process_user(user: Optional[dict]) -> str:
    """Process user with nested conditions."""
    if user:
        if user.get('valid', False):
            if user.get('active', False):
                user['processed'] = True
                return "User processed successfully"
            else:
                return "User is inactive"
        else:
            return "User is invalid"
    else:
        return "User is None"
```

## Python Language Features

### Pythonic Code Patterns

#### Use List Comprehensions and Generator Expressions
```python
# Good - List comprehensions for simple transformations
users = [
    {'name': 'John', 'active': True, 'age': 30},
    {'name': 'Jane', 'active': False, 'age': 25},
    {'name': 'Bob', 'active': True, 'age': 35}
]

# List comprehension
active_users = [user for user in users if user['active']]
user_names = [user['name'].upper() for user in users]

# Generator expression for large datasets
active_user_names = (user['name'] for user in users if user['active'])

# Dictionary comprehension
user_ages = {user['name']: user['age'] for user in users}

# Avoid - Verbose loops for simple transformations
active_users = []
for user in users:
    if user['active']:
        active_users.append(user)

user_names = []
for user in users:
    user_names.append(user['name'].upper())
```

#### Use Itertools for Complex Iterations
```python
from itertools import groupby, chain, combinations
from operator import itemgetter

# Good - Using itertools for complex operations
users = [
    {'name': 'John', 'department': 'Engineering', 'role': 'Senior'},
    {'name': 'Jane', 'department': 'Engineering', 'role': 'Junior'},
    {'name': 'Bob', 'department': 'Sales', 'role': 'Senior'},
    {'name': 'Alice', 'department': 'Sales', 'role': 'Manager'}
]

# Group by department
def group_users_by_department(users):
    """Group users by department."""
    sorted_users = sorted(users, key=itemgetter('department'))
    return {
        dept: list(group)
        for dept, group in groupby(sorted_users, key=itemgetter('department'))
    }

# Chain multiple sequences
def get_all_user_info(users, admins):
    """Get all user information from multiple sources."""
    return list(chain(users, admins))

# Generate combinations
def get_user_pairs(users):
    """Get all possible user pairs."""
    return list(combinations(users, 2))

# Avoid - Manual iteration for complex operations
def group_users_by_department_manual(users):
    """Manually group users by department."""
    groups = {}
    for user in users:
        dept = user['department']
        if dept not in groups:
            groups[dept] = []
        groups[dept].append(user)
    return groups
```

#### Use Context Managers for Resource Management
```python
# Good - Context managers for resource management
from contextlib import contextmanager
from typing import Generator

@contextmanager
def database_connection() -> Generator[object, None, None]:
    """Context manager for database connection."""
    connection = get_database_connection()
    try:
        yield connection
    finally:
        connection.close()

# Usage
def process_users():
    """Process users with proper resource management."""
    with database_connection() as conn:
        users = conn.fetch_users()
        for user in users:
            process_user(user)

# Good - File handling with context managers
def read_user_data(filename: str) -> List[dict]:
    """Read user data from file."""
    with open(filename, 'r') as file:
        return json.load(file)

def write_user_data(filename: str, users: List[dict]) -> None:
    """Write user data to file."""
    with open(filename, 'w') as file:
        json.dump(users, file, indent=2)

# Avoid - Manual resource management
def process_users_manual():
    """Process users without proper resource management."""
    connection = get_database_connection()
    users = connection.fetch_users()
    for user in users:
        process_user(user)
    connection.close()  # Might not be called if exception occurs

def get_database_connection():
    """Mock database connection."""
    return type('Connection', (), {
        'fetch_users': lambda: [{'id': 1, 'name': 'John'}],
        'close': lambda: None
    })()
```

### Error Handling and Exceptions

#### Use Specific Exception Types
```python
# Good - Custom exception classes
class UserError(Exception):
    """Base exception for user-related errors."""
    pass

class UserNotFoundError(UserError):
    """Raised when user cannot be found."""
    
    def __init__(self, user_id: int):
        super().__init__(f"User with ID {user_id} not found")
        self.user_id = user_id

class InvalidUserDataError(UserError):
    """Raised when user data is invalid."""
    
    def __init__(self, message: str = "User data is invalid"):
        super().__init__(message)

def find_user(user_id: int) -> dict:
    """Find user by ID."""
    users = [{'id': 1, 'name': 'John', 'valid': True}]
    
    user = next((u for u in users if u['id'] == user_id), None)
    if not user:
        raise UserNotFoundError(user_id)
    
    if not user.get('valid', False):
        raise InvalidUserDataError(f"User {user_id} data is invalid")
    
    return user

# Usage with specific exception handling
try:
    user = find_user(999)
except UserNotFoundError as e:
    print(f"User not found: {e}")
except InvalidUserDataError as e:
    print(f"Invalid user data: {e}")
except UserError as e:
    print(f"User error: {e}")

# Avoid - Generic exceptions
def find_user_generic(user_id: int) -> dict:
    """Find user with generic exceptions."""
    users = [{'id': 1, 'name': 'John', 'valid': True}]
    
    user = next((u for u in users if u['id'] == user_id), None)
    if not user:
        raise Exception("User not found")  # Too generic
    
    if not user.get('valid', False):
        raise Exception("Invalid user")  # Too generic
    
    return user
```

#### Use Proper Exception Handling Structure
```python
# Good - Proper exception handling structure
def process_user_file(filename: str) -> List[dict]:
    """Process user data from file."""
    try:
        with open(filename, 'r') as file:
            data = json.load(file)
            return validate_user_data(data)
    
    except FileNotFoundError:
        print(f"File not found: {filename}")
        return []
    
    except json.JSONDecodeError as e:
        print(f"Invalid JSON in file {filename}: {e}")
        return []
    
    except InvalidUserDataError as e:
        print(f"Invalid user data in file {filename}: {e}")
        return []
    
    except Exception as e:
        print(f"Unexpected error processing file {filename}: {e}")
        return []

def validate_user_data(data: List[dict]) -> List[dict]:
    """Validate user data."""
    valid_users = []
    for user in data:
        if not isinstance(user, dict):
            raise InvalidUserDataError("User data must be a dictionary")
        if 'name' not in user or 'email' not in user:
            raise InvalidUserDataError("User must have name and email")
        valid_users.append(user)
    return valid_users

# Avoid - Catching all exceptions generically
def process_user_file_generic(filename: str) -> List[dict]:
    """Process user file with generic exception handling."""
    try:
        with open(filename, 'r') as file:
            data = json.load(file)
            return validate_user_data(data)
    except Exception as e:
        print(f"Something went wrong: {e}")
        return []  # Lost information about what went wrong
```

### Data Structures and Collections

#### Use Appropriate Data Structures
```python
from collections import namedtuple, defaultdict, Counter
from typing import Dict, List, Set, Optional

# Good - Use appropriate data structures
User = namedtuple('User', ['name', 'email', 'role'])

def process_user_data(users: List[User]) -> Dict[str, Any]:
    """Process user data with appropriate data structures."""
    # Use defaultdict for grouping
    role_groups = defaultdict(list)
    for user in users:
        role_groups[user.role].append(user)
    
    # Use Counter for counting
    role_counts = Counter(user.role for user in users)
    
    # Use set for unique values
    unique_domains = {user.email.split('@')[1] for user in users}
    
    return {
        'role_groups': dict(role_groups),
        'role_counts': dict(role_counts),
        'unique_domains': unique_domains
    }

# Good - Use dataclasses for structured data
from dataclasses import dataclass, field
from typing import List

@dataclass
class UserProfile:
    """User profile with structured data."""
    name: str
    email: str
    roles: List[str] = field(default_factory=list)
    active: bool = True
    
    def add_role(self, role: str) -> None:
        """Add role to user."""
        if role not in self.roles:
            self.roles.append(role)
    
    def is_admin(self) -> bool:
        """Check if user is admin."""
        return 'admin' in self.roles

# Usage
users = [
    User('John', 'john@example.com', 'admin'),
    User('Jane', 'jane@example.com', 'user'),
    User('Bob', 'bob@company.com', 'user')
]

result = process_user_data(users)
print(result)

# Avoid - Using inappropriate data structures
def process_user_data_inefficient(users: List[dict]) -> Dict[str, Any]:
    """Process user data inefficiently."""
    # Manual grouping instead of defaultdict
    role_groups = {}
    for user in users:
        role = user['role']
        if role not in role_groups:
            role_groups[role] = []
        role_groups[role].append(user)
    
    # Manual counting instead of Counter
    role_counts = {}
    for user in users:
        role = user['role']
        if role not in role_counts:
            role_counts[role] = 0
        role_counts[role] += 1
    
    # Using list instead of set for unique values
    unique_domains = []
    for user in users:
        domain = user['email'].split('@')[1]
        if domain not in unique_domains:
            unique_domains.append(domain)
    
    return {
        'role_groups': role_groups,
        'role_counts': role_counts,
        'unique_domains': unique_domains
    }
```

### String Handling and Formatting

#### Use f-strings for String Formatting
```python
# Good - f-strings for string formatting
def generate_user_report(user: dict) -> str:
    """Generate user report using f-strings."""
    name = user.get('name', 'Unknown')
    email = user.get('email', 'No email')
    status = 'Active' if user.get('active', False) else 'Inactive'
    
    return f"""
User Report
===========
Name: {name}
Email: {email}
Status: {status}
Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

# Good - f-strings with expressions
def format_user_list(users: List[dict]) -> str:
    """Format user list with f-strings."""
    header = f"User List ({len(users)} users)"
    separator = "=" * len(header)
    
    user_lines = [
        f"{i+1:2d}. {user['name']:<20} ({user['email']})"
        for i, user in enumerate(users)
    ]
    
    return f"{header}\n{separator}\n" + "\n".join(user_lines)

# Avoid - Old string formatting methods
def generate_user_report_old(user: dict) -> str:
    """Generate user report using old formatting."""
    name = user.get('name', 'Unknown')
    email = user.get('email', 'No email')
    status = 'Active' if user.get('active', False) else 'Inactive'
    
    # Old % formatting
    return """
User Report
===========
Name: %s
Email: %s
Status: %s
Generated at: %s
""" % (name, email, status, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

# Avoid - String concatenation
def format_user_list_old(users: List[dict]) -> str:
    """Format user list with string concatenation."""
    header = "User List (" + str(len(users)) + " users)"
    separator = "=" * len(header)
    
    result = header + "\n" + separator + "\n"
    for i, user in enumerate(users):
        result += str(i+1) + ". " + user['name'] + " (" + user['email'] + ")\n"
    
    return result
```

## Testing Best Practices

### Write Clear and Descriptive Tests
```python
import unittest
from unittest.mock import patch, MagicMock

class TestUserService(unittest.TestCase):
    """Test cases for UserService."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.user_service = UserService()
        self.sample_user = {
            'name': 'John Doe',
            'email': 'john@example.com',
            'active': True
        }
    
    def test_create_user_with_valid_data_returns_user_dict(self):
        """Test that create_user returns a user dictionary when given valid data."""
        result = self.user_service.create_user(
            name='John Doe',
            email='john@example.com'
        )
        
        self.assertIsInstance(result, dict)
        self.assertEqual(result['name'], 'John Doe')
        self.assertEqual(result['email'], 'john@example.com')
        self.assertTrue(result['active'])
        self.assertIn('created_at', result)
    
    def test_create_user_with_empty_name_raises_value_error(self):
        """Test that create_user raises ValueError when name is empty."""
        with self.assertRaises(ValueError) as context:
            self.user_service.create_user(name='', email='john@example.com')
        
        self.assertIn('Name cannot be empty', str(context.exception))
    
    def test_create_user_with_invalid_email_raises_value_error(self):
        """Test that create_user raises ValueError when email is invalid."""
        with self.assertRaises(ValueError) as context:
            self.user_service.create_user(name='John', email='invalid-email')
        
        self.assertIn('Invalid email format', str(context.exception))
    
    @patch('user_service.send_welcome_email')
    def test_create_user_sends_welcome_email(self, mock_send_email):
        """Test that create_user sends welcome email to new user."""
        user = self.user_service.create_user(
            name='John Doe',
            email='john@example.com'
        )
        
        mock_send_email.assert_called_once_with(user)
    
    def test_activate_user_sets_active_to_true(self):
        """Test that activate_user sets the active field to True."""
        user = {'active': False}
        self.user_service.activate_user(user)
        
        self.assertTrue(user['active'])
    
    def test_is_active_returns_true_for_active_user(self):
        """Test that is_active returns True for active user."""
        active_user = {'active': True}
        result = self.user_service.is_active(active_user)
        
        self.assertTrue(result)
    
    def test_is_active_returns_false_for_inactive_user(self):
        """Test that is_active returns False for inactive user."""
        inactive_user = {'active': False}
        result = self.user_service.is_active(inactive_user)
        
        self.assertFalse(result)

# Avoid - Vague test names and descriptions
class TestUserService(unittest.TestCase):
    """Test user service."""
    
    def test_create_user(self):
        """Test create user."""
        # What exactly are we testing?
        pass
    
    def test_user_stuff(self):
        """Test user stuff."""
        # Too vague
        pass
    
    def test_it_works(self):
        """Test it works."""
        # Doesn't describe what should work
        pass

# Mock UserService for testing
class UserService:
    """Mock user service for testing examples."""
    
    def create_user(self, name: str, email: str) -> dict:
        """Create a user."""
        if not name.strip():
            raise ValueError('Name cannot be empty')
        if '@' not in email:
            raise ValueError('Invalid email format')
        
        user = {
            'name': name,
            'email': email,
            'active': True,
            'created_at': datetime.now()
        }
        send_welcome_email(user)
        return user
    
    def activate_user(self, user: dict) -> None:
        """Activate a user."""
        user['active'] = True
    
    def is_active(self, user: dict) -> bool:
        """Check if user is active."""
        return user.get('active', False)

def send_welcome_email(user: dict) -> None:
    """Send welcome email to user."""
    pass
```

### Test Behavior, Not Implementation
```python
# Good - Test public behavior
class TestUserValidator(unittest.TestCase):
    """Test user validator behavior."""
    
    def test_valid_email_passes_validation(self):
        """Test that valid email passes validation."""
        validator = UserValidator()
        result = validator.validate_email('user@example.com')
        
        self.assertTrue(result)
    
    def test_invalid_email_fails_validation(self):
        """Test that invalid email fails validation."""
        validator = UserValidator()
        result = validator.validate_email('invalid-email')
        
        self.assertFalse(result)
    
    def test_empty_email_fails_validation(self):
        """Test that empty email fails validation."""
        validator = UserValidator()
        result = validator.validate_email('')
        
        self.assertFalse(result)

# Avoid - Testing internal implementation
class TestUserValidator(unittest.TestCase):
    """Test user validator implementation."""
    
    def test_validate_email_calls_regex_match(self):
        """Test internal regex matching."""
        validator = UserValidator()
        
        # This tests implementation details, not behavior
        with patch.object(validator, '_regex_pattern') as mock_pattern:
            validator.validate_email('user@example.com')
            mock_pattern.match.assert_called_once()

# Mock validator for testing
class UserValidator:
    """Mock user validator for testing examples."""
    
    def validate_email(self, email: str) -> bool:
        """Validate email format."""
        if not email:
            return False
        return '@' in email and '.' in email
```

## Performance Considerations

### Use Built-in Functions and Libraries
```python
# Good - Use built-in functions
def calculate_statistics(numbers: List[float]) -> Dict[str, float]:
    """Calculate statistics using built-in functions."""
    if not numbers:
        return {'mean': 0, 'median': 0, 'mode': 0}
    
    mean = sum(numbers) / len(numbers)
    sorted_numbers = sorted(numbers)
    median = sorted_numbers[len(sorted_numbers) // 2]
    
    # Use Counter for mode calculation
    from collections import Counter
    mode = Counter(numbers).most_common(1)[0][0]
    
    return {'mean': mean, 'median': median, 'mode': mode}

# Good - Use list comprehensions for performance
def filter_and_transform_users(users: List[dict]) -> List[str]:
    """Filter and transform user data efficiently."""
    return [
        user['name'].upper()
        for user in users
        if user.get('active', False) and '@' in user.get('email', '')
    ]

# Good - Use generators for memory efficiency
def process_large_dataset(filename: str):
    """Process large dataset with generators."""
    def read_users():
        with open(filename, 'r') as file:
            for line in file:
                yield json.loads(line.strip())
    
    def active_users():
        for user in read_users():
            if user.get('active', False):
                yield user
    
    # Process users one at a time without loading all into memory
    for user in active_users():
        process_user(user)

# Avoid - Inefficient manual implementations
def calculate_statistics_manual(numbers: List[float]) -> Dict[str, float]:
    """Calculate statistics manually (inefficient)."""
    if not numbers:
        return {'mean': 0, 'median': 0, 'mode': 0}
    
    # Manual mean calculation
    total = 0
    for num in numbers:
        total += num
    mean = total / len(numbers)
    
    # Manual median calculation (inefficient sorting)
    for i in range(len(numbers)):
        for j in range(i + 1, len(numbers)):
            if numbers[i] > numbers[j]:
                numbers[i], numbers[j] = numbers[j], numbers[i]
    median = numbers[len(numbers) // 2]
    
    # Manual mode calculation (inefficient)
    mode_count = {}
    for num in numbers:
        if num in mode_count:
            mode_count[num] += 1
        else:
            mode_count[num] = 1
    
    mode = None
    max_count = 0
    for num, count in mode_count.items():
        if count > max_count:
            max_count = count
            mode = num
    
    return {'mean': mean, 'median': median, 'mode': mode}

def process_user(user: dict) -> None:
    """Mock process user function."""
    pass
```

### Use Proper Data Structures for Performance
```python
# Good - Use sets for membership testing
def find_common_users(list1: List[str], list2: List[str]) -> List[str]:
    """Find common users efficiently using sets."""
    set1 = set(list1)
    set2 = set(list2)
    return list(set1 & set2)

# Good - Use dict for O(1) lookups
def build_user_lookup(users: List[dict]) -> Dict[int, dict]:
    """Build user lookup dictionary for fast access."""
    return {user['id']: user for user in users}

def get_user_by_id(user_lookup: Dict[int, dict], user_id: int) -> Optional[dict]:
    """Get user by ID using O(1) lookup."""
    return user_lookup.get(user_id)

# Good - Use deque for efficient queue operations
from collections import deque

class UserQueue:
    """Efficient user queue using deque."""
    
    def __init__(self):
        self._queue = deque()
    
    def enqueue(self, user: dict) -> None:
        """Add user to queue."""
        self._queue.append(user)
    
    def dequeue(self) -> Optional[dict]:
        """Remove and return user from queue."""
        return self._queue.popleft() if self._queue else None
    
    def is_empty(self) -> bool:
        """Check if queue is empty."""
        return len(self._queue) == 0

# Avoid - Inefficient data structure choices
def find_common_users_inefficient(list1: List[str], list2: List[str]) -> List[str]:
    """Find common users inefficiently using lists."""
    common = []
    for user1 in list1:
        for user2 in list2:  # O(n²) complexity
            if user1 == user2 and user1 not in common:
                common.append(user1)
    return common

def get_user_by_id_inefficient(users: List[dict], user_id: int) -> Optional[dict]:
    """Get user by ID using O(n) search."""
    for user in users:  # Linear search every time
        if user['id'] == user_id:
            return user
    return None
```

## Code Organization and Style

### Module Organization
```python
# Good - Clear module structure
# File: user_management/__init__.py
from .user import User
from .user_service import UserService
from .user_validator import UserValidator

__all__ = ['User', 'UserService', 'UserValidator']

# File: user_management/user.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional

@dataclass
class User:
    """User domain model."""
    name: str
    email: str
    active: bool = True
    created_at: datetime = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()

# File: user_management/user_service.py
from typing import List, Dict, Any
from .user import User
from .user_validator import UserValidator

class UserService:
    """Service for user operations."""
    
    def __init__(self):
        self._validator = UserValidator()
    
    def create_user(self, name: str, email: str) -> User:
        """Create a new user."""
        if not self._validator.validate_name(name):
            raise ValueError("Invalid name")
        if not self._validator.validate_email(email):
            raise ValueError("Invalid email")
        
        return User(name=name, email=email)

# File: user_management/user_validator.py
import re
from typing import Union

class UserValidator:
    """Validator for user data."""
    
    EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    
    def validate_email(self, email: str) -> bool:
        """Validate email format."""
        return bool(self.EMAIL_PATTERN.match(email))
    
    def validate_name(self, name: str) -> bool:
        """Validate name format."""
        return bool(name and name.strip() and len(name) <= 100)

# Avoid - Everything in one file
# File: user_stuff.py
class User:
    """User class with everything mixed together."""
    pass

class UserService:
    """Service mixed with other classes."""
    pass

class UserValidator:
    """Validator mixed with other classes."""
    pass
```

### Import Organization
```python
# Good - Organized imports following PEP 8
# Standard library imports
import json
import re
from datetime import datetime
from typing import List, Dict, Any, Optional

# Third-party imports
import requests
from sqlalchemy import create_engine

# Local application imports
from .models import User
from .services import UserService
from .validators import UserValidator

# Avoid - Disorganized imports
from .models import User
import json
from .services import UserService
import re
from typing import List
import requests
from .validators import UserValidator
from datetime import datetime
```

## Tools and Linting

### Essential Tools
```python
# requirements-dev.txt
black==23.3.0              # Code formatting
flake8==6.0.0              # Style guide enforcement
mypy==1.3.0                # Type checking
pylint==2.17.4             # Code analysis
pytest==7.3.1             # Testing framework
pytest-cov==4.1.0         # Coverage reporting
isort==5.12.0              # Import sorting
bandit==1.7.5              # Security linting
```

### Configuration Files
```python
# pyproject.toml
[tool.black]
line-length = 88
target-version = ['py39']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88
known_first_party = ["myapp"]

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "--cov=src --cov-report=html --cov-report=term-missing"

# .flake8
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = .git,__pycache__,build,dist
```

## Python Anti-Patterns to Avoid

### Don't Use Mutable Default Arguments
```python
# Good - Use None as default and create new objects
def add_user_to_list(user: dict, user_list: Optional[List[dict]] = None) -> List[dict]:
    """Add user to list safely."""
    if user_list is None:
        user_list = []
    
    user_list.append(user)
    return user_list

# Avoid - Mutable default arguments
def add_user_to_list_bad(user: dict, user_list: List[dict] = []) -> List[dict]:
    """Add user to list (dangerous with mutable default)."""
    user_list.append(user)  # Same list object reused across calls
    return user_list
```

### Don't Use bare except clauses
```python
# Good - Specific exception handling
def process_data(data: str) -> dict:
    """Process data with proper exception handling."""
    try:
        return json.loads(data)
    except json.JSONDecodeError as e:
        print(f"Invalid JSON: {e}")
        return {}
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {}

# Avoid - Bare except clause
def process_data_bad(data: str) -> dict:
    """Process data with bare except."""
    try:
        return json.loads(data)
    except:  # Catches everything, including KeyboardInterrupt
        return {}
```

### Don't Use Global Variables
```python
# Good - Use classes or dependency injection
class UserService:
    """User service with configurable timeout."""
    
    def __init__(self, timeout: int = 30):
        self.timeout = timeout
    
    def process_user(self, user: dict) -> None:
        """Process user with configured timeout."""
        # Use self.timeout
        pass

# Avoid - Global variables
TIMEOUT = 30  # Global variable

def process_user_global(user: dict) -> None:
    """Process user using global variable."""
    global TIMEOUT  # Hard to test and maintain
    # Use TIMEOUT
```

## Remember

> "Simple is better than complex. Complex is better than complicated." - The Zen of Python

Focus on writing clean, readable Python code that follows PEP 8 and leverages Python's strengths. The goal is code that is Pythonic, maintainable, and follows established best practices.

### Key Takeaways

1. **Follow PEP 8** for code style and formatting
2. **Use type hints** for better code documentation and IDE support
3. **Choose appropriate data structures** for performance and clarity
4. **Handle exceptions specifically** with proper error types
5. **Write descriptive tests** that focus on behavior
6. **Use built-in functions** and libraries for efficiency
7. **Organize code** into logical modules and packages
8. **Use tools** like black, flake8, mypy, and pytest for code quality
9. **Avoid common anti-patterns** like mutable defaults and bare except clauses
10. **Be Pythonic** - write code that feels natural to Python developers