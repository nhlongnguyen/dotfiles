# Python Coding Principles

## PEP 8 and Core Python Guidelines

### Rule 1: Functions should be no longer than 20 lines
Keep functions focused and readable. Extract complex logic into smaller functions.

```python
# Good - Under 20 lines, focused responsibility
def process_user(user: dict) -> bool:
    """Process a user if they are valid and active."""
    if not user or not user.get('valid', False) or not user.get('active', False):
        return False
    
    user['processed'] = True
    send_notification(user)
    return True

# Good - Complex logic extracted to separate functions
def calculate_user_score(user: dict) -> float:
    activity_score = calculate_activity_score(user)
    engagement_score = calculate_engagement_score(user)
    bonus_score = calculate_bonus_score(user)
    return (activity_score * 0.5) + (engagement_score * 0.3) + (bonus_score * 0.2)
```

### Rule 2: Classes should be no longer than 100 lines
Split large classes into smaller, focused classes. Use composition over inheritance.

```python
# Good - Under 100 lines, single responsibility
class User:
    def __init__(self, name: str, email: str, active: bool = True):
        self.name = name
        self.email = email
        self.active = active
        self.created_at = datetime.now()
    
    def is_active(self) -> bool:
        return self.active
    
    def activate(self) -> None:
        self.active = True
    
    def __str__(self) -> str:
        return f"User({self.name}, {self.email})"

# Good - Separate concerns into different classes
class UserValidator:
    @staticmethod
    def validate_email(email: str) -> bool:
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
```

### Rule 3: Use no more than 4 parameters in function signatures
Use dataclasses, TypedDict, or objects for multiple related parameters.

```python
# Good - 4 parameters max
def create_user(name: str, email: str, role: str, active: bool = True) -> dict:
    return {
        'name': name, 'email': email, 'role': role, 'active': active,
        'created_at': datetime.now()
    }

# Good - Use dataclass for related parameters
@dataclass
class UserData:
    name: str
    email: str
    role: str
    active: bool = True
    department: Optional[str] = None

def create_user_from_data(user_data: UserData) -> dict:
    return {
        'name': user_data.name, 'email': user_data.email, 'role': user_data.role,
        'active': user_data.active, 'department': user_data.department,
        'created_at': datetime.now()
    }
```

### Rule Zero: Exception Rule
**"Break these rules only when you have a good reason and document it clearly."**

Document exceptions clearly with approval and reasoning.

## Design Principles

### When to Use OOP vs Functional Programming

**Use OOP for:**
- Domain entities with state and behavior
- Stateful objects (e.g., shopping carts)
- Complex object relationships

```python
# Good - OOP for domain models
class User:
    def __init__(self, name: str, email: str, role: str = 'user'):
        self.name = name
        self.email = email
        self.role = role
    
    def is_admin(self) -> bool:
        return self.role == 'admin'
    
    def can_access_resource(self, resource: 'Resource') -> bool:
        return self.is_admin() or resource.owner == self

# Good - OOP for stateful objects
class ShoppingCart:
    def __init__(self):
        self._items: List[dict] = []
    
    def add_item(self, item: dict) -> 'ShoppingCart':
        self._items.append(item)
        return self
    
    def total(self) -> float:
        return sum(item['price'] for item in self._items)
```

**Use FP for:**
- Data transformations and calculations
- Pure business logic
- Stateless operations

```python
# Good - FP for data processing
def calculate_user_stats(users: List[dict]) -> Dict[str, Dict[str, Any]]:
    active_users = [user for user in users if user.get('active', False)]
    
    role_groups = {}
    for user in active_users:
        role = user.get('role', 'unknown')
        role_groups.setdefault(role, []).append(user)
    
    return {
        role: {
            'count': len(role_users),
            'avg_age': sum(u.get('age', 0) for u in role_users) / len(role_users) if role_users else 0
        }
        for role, role_users in role_groups.items()
    }

# Good - FP for calculations
class PricingCalculator:
    PROMO_CODES = {'SAVE10': 0.10, 'SAVE20': 0.20, 'WELCOME25': 0.25}
    
    @staticmethod
    def calculate_discount(order_total: float, user_tier: str, promo_code: Optional[str] = None) -> float:
        base_discount = PricingCalculator._get_tier_discount(user_tier)
        promo_discount = PricingCalculator.PROMO_CODES.get(promo_code, 0.0)
        total_discount = min(base_discount + promo_discount, 0.5)
        return order_total * (1 - total_discount)
```

**Use Hybrid for:**
- Service objects with functional pipeline
- Complex business workflows

```python
# Good - Service object with functional core
class OrderProcessor:
    def __init__(self, order: dict):
        self.order = order
    
    def process(self) -> Dict[str, Any]:
        result = self._process_order_pipeline(self.order)
        
        if result['success']:
            self._update_order(result['data'])
            self._notify_success(result['data'])
        else:
            self._handle_error(result['error'])
        
        return result
    
    def _process_order_pipeline(self, order: dict) -> Dict[str, Any]:
        try:
            return (order
                   |> self._validate_order
                   |> self._calculate_totals
                   |> self._apply_discounts)
        except Exception as e:
            return {'success': False, 'error': str(e)}
```

### Class Design Principles

#### Single Responsibility Principle
```python
# Good - Single responsibility
class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
        self.created_at = datetime.now()
    
    def get_full_name(self) -> str:
        return self.name.strip()
    
    def is_valid_email(self) -> bool:
        import re
        return bool(re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', self.email))

class UserEmailer:
    @staticmethod
    def send_welcome_email(user: User) -> None:
        print(f"Sending welcome email to {user.email}")

# Avoid - Multiple responsibilities (mixing user data with email, logging, permissions)
```

#### Use Composition Over Inheritance
```python
# Good - Composition for shared behavior
class TimestampMixin:
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
    
    def touch(self) -> None:
        self.updated_at = datetime.now()

class User(TimestampMixin):
    def __init__(self, name: str):
        self.name = name
        super().__init__()
    
    def update_name(self, new_name: str) -> None:
        self.name = new_name
        self.touch()

# Avoid - Duplicated behavior across classes
```

### Method Design Principles

#### Use Type Hints and Clear Parameter Names
```python
# Good - Clear type hints and parameter names
def create_user(name: str, email: str, active: bool = True) -> Dict[str, Any]:
    return {
        'name': name, 'email': email, 'active': active,
        'created_at': datetime.now()
    }

# Good - Use keyword-only arguments for clarity
def send_notification(*, user_id: int, message: str, priority: str = 'normal') -> None:
    print(f"Sending {priority} notification to user {user_id}: {message}")

# Avoid - Unclear parameter types and names
```

#### Use Early Returns and Guard Clauses
```python
# Good - Early returns reduce nesting
def process_user(user: Optional[dict]) -> str:
    if not user:
        return "User is None"
    if not user.get('valid', False):
        return "User is invalid"
    if not user.get('active', False):
        return "User is inactive"
    
    user['processed'] = True
    return "User processed successfully"

# Good - Guard clauses for validation
def calculate_discount(price: float, discount_percent: float) -> float:
    if price < 0:
        raise ValueError("Price cannot be negative")
    if not 0 <= discount_percent <= 100:
        raise ValueError("Discount percent must be between 0 and 100")
    
    return price * (1 - discount_percent / 100)

# Avoid - Nested conditions
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

active_users = [user for user in users if user['active']]
user_names = [user['name'].upper() for user in users]
active_user_names = (user['name'] for user in users if user['active'])  # Generator
user_ages = {user['name']: user['age'] for user in users}  # Dict comprehension

# Avoid - Verbose loops for simple transformations
```

#### Use Itertools for Complex Iterations
```python
from itertools import groupby, chain, combinations
from operator import itemgetter

# Good - Using itertools for complex operations
def group_users_by_department(users):
    sorted_users = sorted(users, key=itemgetter('department'))
    return {
        dept: list(group)
        for dept, group in groupby(sorted_users, key=itemgetter('department'))
    }

# Chain multiple sequences
def get_all_user_info(users, admins):
    return list(chain(users, admins))

# Generate combinations
def get_user_pairs(users):
    return list(combinations(users, 2))

# Avoid - Manual iteration for complex operations
```

#### Use Context Managers for Resource Management
```python
# Good - Context managers for resource management
from contextlib import contextmanager

@contextmanager
def database_connection():
    connection = get_database_connection()
    try:
        yield connection
    finally:
        connection.close()

# Usage
def process_users():
    with database_connection() as conn:
        users = conn.fetch_users()
        for user in users:
            process_user(user)

# Good - File handling with context managers
def read_user_data(filename: str) -> List[dict]:
    with open(filename, 'r') as file:
        return json.load(file)

# Avoid - Manual resource management
```

### Error Handling and Exceptions

#### Use Specific Exception Types
```python
# Good - Custom exception classes
class UserError(Exception):
    """Base exception for user-related errors."""
    pass

class UserNotFoundError(UserError):
    def __init__(self, user_id: int):
        super().__init__(f"User with ID {user_id} not found")
        self.user_id = user_id

class InvalidUserDataError(UserError):
    def __init__(self, message: str = "User data is invalid"):
        super().__init__(message)

def find_user(user_id: int) -> dict:
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

# Avoid - Generic exceptions
```

#### Use Proper Exception Handling Structure
```python
# Good - Proper exception handling structure
def process_user_file(filename: str) -> List[dict]:
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
    valid_users = []
    for user in data:
        if not isinstance(user, dict):
            raise InvalidUserDataError("User data must be a dictionary")
        if 'name' not in user or 'email' not in user:
            raise InvalidUserDataError("User must have name and email")
        valid_users.append(user)
    return valid_users

# Avoid - Catching all exceptions generically
```

### Data Structures and Collections

#### Use Appropriate Data Structures
```python
from collections import namedtuple, defaultdict, Counter

# Good - Use appropriate data structures
User = namedtuple('User', ['name', 'email', 'role'])

def process_user_data(users: List[User]) -> Dict[str, Any]:
    role_groups = defaultdict(list)
    for user in users:
        role_groups[user.role].append(user)
    
    role_counts = Counter(user.role for user in users)
    unique_domains = {user.email.split('@')[1] for user in users}
    
    return {
        'role_groups': dict(role_groups),
        'role_counts': dict(role_counts),
        'unique_domains': unique_domains
    }

# Good - Use dataclasses for structured data
@dataclass
class UserProfile:
    name: str
    email: str
    roles: List[str] = field(default_factory=list)
    active: bool = True
    
    def add_role(self, role: str) -> None:
        if role not in self.roles:
            self.roles.append(role)
    
    def is_admin(self) -> bool:
        return 'admin' in self.roles

# Avoid - Using inappropriate data structures (manual grouping, counting)
```

### String Handling and Formatting

#### Use f-strings for String Formatting
```python
# Good - f-strings for string formatting
def generate_user_report(user: dict) -> str:
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
    header = f"User List ({len(users)} users)"
    separator = "=" * len(header)
    
    user_lines = [
        f"{i+1:2d}. {user['name']:<20} ({user['email']})"
        for i, user in enumerate(users)
    ]
    
    return f"{header}\n{separator}\n" + "\n".join(user_lines)

# Avoid - Old string formatting methods (% formatting, string concatenation)
```

## Testing Best Practices

### Write Clear and Descriptive Tests
```python
import unittest
from unittest.mock import patch

class TestUserService(unittest.TestCase):
    def setUp(self):
        self.user_service = UserService()
        self.sample_user = {
            'name': 'John Doe',
            'email': 'john@example.com',
            'active': True
        }
    
    def test_create_user_with_valid_data_returns_user_dict(self):
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
        with self.assertRaises(ValueError) as context:
            self.user_service.create_user(name='', email='john@example.com')
        
        self.assertIn('Name cannot be empty', str(context.exception))
    
    @patch('user_service.send_welcome_email')
    def test_create_user_sends_welcome_email(self, mock_send_email):
        user = self.user_service.create_user(
            name='John Doe',
            email='john@example.com'
        )
        
        mock_send_email.assert_called_once_with(user)
    
    def test_activate_user_sets_active_to_true(self):
        user = {'active': False}
        self.user_service.activate_user(user)
        
        self.assertTrue(user['active'])

# Avoid - Vague test names and descriptions
```

### Test Behavior, Not Implementation
```python
# Good - Test public behavior
class TestUserValidator(unittest.TestCase):
    def test_valid_email_passes_validation(self):
        validator = UserValidator()
        result = validator.validate_email('user@example.com')
        
        self.assertTrue(result)
    
    def test_invalid_email_fails_validation(self):
        validator = UserValidator()
        result = validator.validate_email('invalid-email')
        
        self.assertFalse(result)
    
    def test_empty_email_fails_validation(self):
        validator = UserValidator()
        result = validator.validate_email('')
        
        self.assertFalse(result)

# Avoid - Testing internal implementation
```

## Performance Considerations

### Use Built-in Functions and Libraries
```python
# Good - Use built-in functions
def calculate_statistics(numbers: List[float]) -> Dict[str, float]:
    if not numbers:
        return {'mean': 0, 'median': 0, 'mode': 0}
    
    mean = sum(numbers) / len(numbers)
    sorted_numbers = sorted(numbers)
    median = sorted_numbers[len(sorted_numbers) // 2]
    
    from collections import Counter
    mode = Counter(numbers).most_common(1)[0][0]
    
    return {'mean': mean, 'median': median, 'mode': mode}

# Good - Use list comprehensions for performance
def filter_and_transform_users(users: List[dict]) -> List[str]:
    return [
        user['name'].upper()
        for user in users
        if user.get('active', False) and '@' in user.get('email', '')
    ]

# Good - Use generators for memory efficiency
def process_large_dataset(filename: str):
    def read_users():
        with open(filename, 'r') as file:
            for line in file:
                yield json.loads(line.strip())
    
    def active_users():
        for user in read_users():
            if user.get('active', False):
                yield user
    
    for user in active_users():
        process_user(user)

# Avoid - Inefficient manual implementations
```

### Use Proper Data Structures for Performance
```python
# Good - Use sets for membership testing
def find_common_users(list1: List[str], list2: List[str]) -> List[str]:
    set1 = set(list1)
    set2 = set(list2)
    return list(set1 & set2)

# Good - Use dict for O(1) lookups
def build_user_lookup(users: List[dict]) -> Dict[int, dict]:
    return {user['id']: user for user in users}

def get_user_by_id(user_lookup: Dict[int, dict], user_id: int) -> Optional[dict]:
    return user_lookup.get(user_id)

# Good - Use deque for efficient queue operations
from collections import deque

class UserQueue:
    def __init__(self):
        self._queue = deque()
    
    def enqueue(self, user: dict) -> None:
        self._queue.append(user)
    
    def dequeue(self) -> Optional[dict]:
        return self._queue.popleft() if self._queue else None
    
    def is_empty(self) -> bool:
        return len(self._queue) == 0

# Avoid - Inefficient data structure choices (O(n²) complexity, linear search)
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
@dataclass
class User:
    name: str
    email: str
    active: bool = True
    created_at: datetime = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()

# File: user_management/user_service.py
class UserService:
    def __init__(self):
        self._validator = UserValidator()
    
    def create_user(self, name: str, email: str) -> User:
        if not self._validator.validate_name(name):
            raise ValueError("Invalid name")
        if not self._validator.validate_email(email):
            raise ValueError("Invalid email")
        
        return User(name=name, email=email)

# File: user_management/user_validator.py
class UserValidator:
    EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    
    def validate_email(self, email: str) -> bool:
        return bool(self.EMAIL_PATTERN.match(email))
    
    def validate_name(self, name: str) -> bool:
        return bool(name and name.strip() and len(name) <= 100)

# Avoid - Everything in one file
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

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
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
    if user_list is None:
        user_list = []
    
    user_list.append(user)
    return user_list

# Avoid - Mutable default arguments
def add_user_to_list_bad(user: dict, user_list: List[dict] = []) -> List[dict]:
    user_list.append(user)  # Same list object reused across calls
    return user_list
```

### Don't Use bare except clauses
```python
# Good - Specific exception handling
def process_data(data: str) -> dict:
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
    try:
        return json.loads(data)
    except:  # Catches everything, including KeyboardInterrupt
        return {}
```

### Don't Use Global Variables
```python
# Good - Use classes or dependency injection
class UserService:
    def __init__(self, timeout: int = 30):
        self.timeout = timeout
    
    def process_user(self, user: dict) -> None:
        # Use self.timeout
        pass

# Avoid - Global variables
TIMEOUT = 30  # Global variable

def process_user_global(user: dict) -> None:
    global TIMEOUT  # Hard to test and maintain
    # Use TIMEOUT
```

## Key Takeaways

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

> "Simple is better than complex. Complex is better than complicated." - The Zen of Python

Focus on writing clean, readable Python code that follows PEP 8 and leverages Python's strengths. The goal is code that is Pythonic, maintainable, and follows established best practices.