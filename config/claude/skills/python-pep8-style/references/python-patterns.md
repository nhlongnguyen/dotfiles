# Python Patterns and PEP 8 Style Guide

This file contains comprehensive patterns for writing idiomatic Python code following PEP 8 and modern best practices.

## Code Layout

### Indentation

```python
# GOOD: 4 spaces per indentation level
def long_function_name(
        var_one, var_two, var_three,
        var_four):
    print(var_one)

# GOOD: Aligned with opening delimiter
foo = long_function_name(var_one, var_two,
                         var_three, var_four)

# GOOD: Hanging indent with 4-space indent
def long_function_name(
        var_one, var_two, var_three,
        var_four):
    print(var_one)

# GOOD: Hanging indent for continuation
foo = long_function_name(
    var_one, var_two,
    var_three, var_four)

# BAD: Arguments on first line forbidden when not using vertical alignment
foo = long_function_name(var_one, var_two,
    var_three, var_four)

# BAD: Further indentation required as indentation is not distinguishable
def long_function_name(
    var_one, var_two, var_three,
    var_four):
    print(var_one)
```

### Line Length

```python
# GOOD: Line length ≤79 (PEP 8) or ≤88 (Black)
result = some_function(
    argument_one,
    argument_two,
    argument_three,
)

# GOOD: Use implicit continuation in parentheses
with open('/path/to/some/file/you/want/to/read') as file_1, \
     open('/path/to/some/file/being/written', 'w') as file_2:
    file_2.write(file_1.read())

# BETTER: Use context manager (Python 3.10+)
with (
    open('/path/to/some/file/you/want/to/read') as file_1,
    open('/path/to/some/file/being/written', 'w') as file_2,
):
    file_2.write(file_1.read())
```

### Binary Operators

```python
# GOOD: Break BEFORE binary operators (mathematical convention)
income = (gross_wages
          + taxable_interest
          + (dividends - qualified_dividends)
          - ira_deduction
          - student_loan_interest)

# BAD: Break after binary operators
income = (gross_wages +
          taxable_interest +
          (dividends - qualified_dividends) -
          ira_deduction -
          student_loan_interest)
```

### Blank Lines

```python
# GOOD: Two blank lines around top-level definitions
import os


class MyClass:
    """Class docstring."""

    def method_one(self):
        pass

    def method_two(self):
        pass


def standalone_function():
    pass


# GOOD: One blank line between methods
class Example:
    def method_one(self):
        pass

    def method_two(self):
        pass

    def method_three(self):
        pass


# GOOD: Blank lines to separate logical sections
def complex_function():
    # Initialize
    result = []
    counter = 0

    # Process items
    for item in items:
        processed = transform(item)
        result.append(processed)
        counter += 1

    # Return results
    return result, counter
```

## Imports

### Import Organization

```python
# GOOD: Proper import organization
# 1. Standard library imports
import os
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Optional

# 2. Third-party imports (blank line separator)
import requests
from pydantic import BaseModel, Field
from sqlalchemy import Column, Integer, String

# 3. Local application imports (blank line separator)
from myapp.config import settings
from myapp.models import User
from myapp.utils.helpers import format_date

# BAD: Mixed import groups
import os
import requests  # Third-party mixed with stdlib
from myapp.models import User
import sys  # Stdlib after local
```

### Import Styles

```python
# GOOD: Separate lines for different modules
import os
import sys

# GOOD: Multiple imports from same module on one line
from subprocess import PIPE, Popen

# GOOD: Explicit imports
from myapp.models import User, Product, Order

# BAD: Wildcard imports (pollutes namespace)
from myapp.models import *

# GOOD: Absolute imports (preferred)
from myapp.utils import helpers

# ACCEPTABLE: Explicit relative imports
from . import sibling
from .sibling import example
from ..parent import other
```

### Import Aliases

```python
# GOOD: Standard aliases
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# GOOD: Avoiding name conflicts
from myapp.models import User as AppUser
from external_lib import User as ExternalUser

# GOOD: Shortening long module names
from collections.abc import MutableMapping as MM
```

## Naming Conventions

### Module and Package Names

```python
# GOOD: Lowercase with underscores for modules
# my_module.py
# database_utils.py
# http_client.py

# GOOD: Lowercase without underscores for packages
# mypackage/
# utils/
# models/

# BAD: CamelCase or mixed case
# MyModule.py
# DatabaseUtils.py
```

### Class Names

```python
# GOOD: PascalCase for classes
class MyClass:
    pass

class HTTPServer:
    pass

class XMLParser:
    pass

# GOOD: Exception classes end with Error
class ValidationError(Exception):
    pass

class DatabaseConnectionError(Exception):
    pass

# BAD: snake_case or lowercase
class my_class:
    pass
```

### Function and Variable Names

```python
# GOOD: snake_case for functions and variables
def calculate_total_price(items: list[Item]) -> Decimal:
    total_price = Decimal("0")
    for item in items:
        item_price = item.price * item.quantity
        total_price += item_price
    return total_price

# GOOD: Descriptive names
user_count = len(users)
is_valid = validate_input(data)
has_permission = check_permission(user, resource)

# BAD: Single letters (except for loops)
x = len(users)
v = validate_input(data)

# GOOD: Single letters in comprehensions and loops
squares = [x ** 2 for x in range(10)]
for i, item in enumerate(items):
    process(i, item)
```

### Constants

```python
# GOOD: UPPER_SNAKE_CASE for constants
MAX_CONNECTIONS = 100
DEFAULT_TIMEOUT = 30
API_BASE_URL = "https://api.example.com"
VALID_STATUSES = frozenset({"pending", "active", "completed"})

# GOOD: Module-level constants at top
PI = 3.14159
E = 2.71828
```

### Private and Internal Names

```python
# GOOD: Single underscore for internal use
class MyClass:
    def __init__(self):
        self._internal_state = {}  # Internal, not part of public API
        self.public_value = 42     # Public

    def _helper_method(self):
        """Internal helper, not for external use."""
        pass

    def public_method(self):
        """Part of the public API."""
        self._helper_method()

# GOOD: Double underscore for name mangling (rare)
class Parent:
    def __init__(self):
        self.__private = "mangled"  # Becomes _Parent__private

# GOOD: Dunder names for special methods only
class MyClass:
    def __init__(self):
        pass

    def __repr__(self):
        return f"MyClass()"

    def __eq__(self, other):
        return isinstance(other, MyClass)
```

## Whitespace

### Around Operators

```python
# GOOD: Spaces around assignment and comparison
x = 1
y = x + 2
z = (x + y) * 3

if x == 4:
    print(x, y, z)

# GOOD: Spaces around boolean operators
if x and y:
    pass

if not x or y:
    pass

# GOOD: No spaces for keyword arguments
def function(arg1, arg2=None, arg3="default"):
    pass

function(value, arg2=other, arg3="custom")

# GOOD: Spaces around = when combining with type annotations
def function(arg: int = 0) -> int:
    return arg

# GOOD: Lowest priority operators can omit spaces
result = x*2 - 1
hypotenuse = x*x + y*y
c = (a+b) * (a-b)
```

### In Collections

```python
# GOOD: No spaces inside brackets
spam(ham[1], {eggs: 2})
foo = (0,)
my_list = [1, 2, 3]
my_dict = {"key": "value"}

# BAD: Spaces inside brackets
spam( ham[ 1 ], { eggs: 2 } )

# GOOD: No space before comma, space after
x, y = y, x
my_list = [1, 2, 3]

# BAD: Space before comma
x , y = y , x
```

### In Slices

```python
# GOOD: Colons act like binary operators
ham[1:9]
ham[1:9:3]
ham[:9:3]
ham[1::3]
ham[1:9:]

# GOOD: No space around colon when parameter omitted
ham[lower:upper]
ham[lower:upper:step]

# GOOD: Spaces when expressions are used
ham[lower + offset : upper + offset]
ham[: upper_fn(x) : step_fn(x)]
ham[:: step_fn(x)]
ham[lower + offset :]

# BAD: Inconsistent spacing
ham[lower : : step]
ham[ : upper]
```

### Function Calls

```python
# GOOD: No space between function name and parenthesis
spam(1)
dct["key"] = lst[index]

# BAD: Space before parenthesis
spam (1)
dct ["key"] = lst [index]

# GOOD: No trailing whitespace
def function():
    return value  # No spaces after 'value'
```

## Strings

### Quote Style

```python
# GOOD: Pick one style and be consistent
# Single quotes
name = 'John'
message = 'Hello, World!'

# OR double quotes
name = "John"
message = "Hello, World!"

# GOOD: Use opposite quote to avoid escaping
message = "It's a beautiful day"
json_str = '{"key": "value"}'

# GOOD: Always use double quotes for docstrings
def function():
    """This is a docstring."""
    pass

# GOOD: Triple quotes for multi-line strings
long_text = """
This is a long text
that spans multiple lines
and preserves formatting.
"""
```

### String Formatting

```python
# GOOD: f-strings (Python 3.6+) - preferred
name = "Alice"
age = 30
message = f"Hello, {name}! You are {age} years old."

# GOOD: f-strings with expressions
total = f"Total: ${price * quantity:.2f}"
debug = f"{value=}"  # Python 3.8+: prints "value=42"

# GOOD: .format() for complex cases
template = "Hello, {name}! You are {age} years old."
message = template.format(name=name, age=age)

# ACCEPTABLE: % formatting for logging
logger.info("Processing %s items for user %s", count, user_id)

# BAD: String concatenation in loops
result = ""
for item in items:
    result += str(item)  # Creates new string each iteration

# GOOD: Use join for building strings
result = "".join(str(item) for item in items)
```

## Comments

### Block Comments

```python
# GOOD: Block comments for sections
# This section handles user authentication.
# We validate the token, check permissions,
# and set up the session context.
def authenticate_user(token: str) -> User:
    pass

# GOOD: Separate paragraphs with blank comment line
# First paragraph explaining the overall purpose.
#
# Second paragraph with additional details
# that might be helpful.
def complex_function():
    pass
```

### Inline Comments

```python
# GOOD: Inline comments separated by at least two spaces
x = x + 1  # Compensate for border

# BAD: Stating the obvious
x = x + 1  # Increment x

# BAD: Too close to code
x = x + 1 # Increment x

# GOOD: Explaining non-obvious behavior
flags = flags & ~0x04  # Clear bit 2 (disable logging)
```

### TODO Comments

```python
# GOOD: TODO with owner and description
# TODO(username): Refactor this to use the new API
# TODO: Remove this workaround after Python 3.12 migration
# FIXME: This breaks when user has no email

# BAD: TODO without context
# TODO: fix this
```

## Docstrings

### Module Docstrings

```python
"""User authentication and session management.

This module provides utilities for authenticating users,
managing sessions, and handling permissions.

Example:
    >>> from auth import authenticate
    >>> user = authenticate("username", "password")
    >>> user.is_authenticated
    True

Attributes:
    DEFAULT_SESSION_TIMEOUT: Default session timeout in seconds.
    MAX_LOGIN_ATTEMPTS: Maximum login attempts before lockout.
"""
```

### Function Docstrings

```python
def fetch_user_by_id(user_id: int, include_deleted: bool = False) -> User | None:
    """Fetch a user by their unique identifier.

    Retrieves user data from the database. By default, deleted users
    are excluded from results.

    Args:
        user_id: The unique identifier of the user.
        include_deleted: If True, include soft-deleted users.

    Returns:
        The User object if found, None otherwise.

    Raises:
        DatabaseError: If database connection fails.
        ValueError: If user_id is negative.

    Example:
        >>> user = fetch_user_by_id(123)
        >>> user.name
        'John Doe'
    """
    pass
```

### Class Docstrings

```python
class UserRepository:
    """Repository for user data access operations.

    Provides CRUD operations for User entities, with support
    for caching and batch operations.

    Attributes:
        connection: Database connection instance.
        cache: Optional cache backend for read operations.

    Example:
        >>> repo = UserRepository(db_connection)
        >>> user = repo.get(123)
        >>> repo.save(user)
    """

    def __init__(self, connection: Connection, cache: Cache | None = None):
        """Initialize the repository.

        Args:
            connection: Database connection to use.
            cache: Optional cache for read operations.
        """
        self.connection = connection
        self.cache = cache
```

## Functions and Methods

### Function Design

```python
# GOOD: Single responsibility, clear purpose
def calculate_discount(price: Decimal, rate: Decimal) -> Decimal:
    """Calculate discount amount from price and rate."""
    return price * rate

def apply_discount(price: Decimal, discount: Decimal) -> Decimal:
    """Apply discount to price, ensuring non-negative result."""
    return max(price - discount, Decimal("0"))

# BAD: Function doing too much
def process_order(order):
    # Validates order
    # Calculates prices
    # Applies discounts
    # Updates inventory
    # Sends notifications
    # Logs everything
    pass  # 200+ lines
```

### Default Arguments

```python
# GOOD: Immutable defaults
def process_items(items: list[str], prefix: str = "") -> list[str]:
    return [f"{prefix}{item}" for item in items]

# BAD: Mutable default argument
def add_item(item: str, items: list[str] = []) -> list[str]:
    items.append(item)  # Mutates shared default!
    return items

# GOOD: Use None and create inside function
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

### Method Arguments

```python
class MyClass:
    # GOOD: First argument is always 'self' for instance methods
    def instance_method(self, arg1, arg2):
        pass

    # GOOD: First argument is 'cls' for class methods
    @classmethod
    def class_method(cls, arg1):
        pass

    # GOOD: No implicit first argument for static methods
    @staticmethod
    def static_method(arg1, arg2):
        pass
```

## Exception Handling

### Catching Exceptions

```python
# GOOD: Catch specific exceptions
try:
    value = int(user_input)
except ValueError:
    print("Please enter a valid number")

# GOOD: Multiple specific exceptions
try:
    data = fetch_and_process(url)
except (ConnectionError, TimeoutError) as e:
    logger.warning("Network error: %s", e)
    data = get_cached_data()
except ValueError as e:
    logger.error("Invalid data: %s", e)
    raise

# BAD: Bare except (catches everything including SystemExit)
try:
    do_something()
except:
    pass  # Silently swallows all errors

# BAD: Catching too broadly
try:
    do_something()
except Exception:
    pass  # Hides bugs
```

### Exception Chaining

```python
# GOOD: Chain exceptions to preserve context
try:
    data = json.loads(response.text)
except json.JSONDecodeError as e:
    raise DataProcessingError(f"Invalid JSON response") from e

# GOOD: Suppress original exception when appropriate
try:
    value = int(text)
except ValueError:
    raise UserInputError("Please enter a number") from None
```

### Custom Exceptions

```python
# GOOD: Inherit from Exception, not BaseException
class ApplicationError(Exception):
    """Base exception for application errors."""
    pass

class ValidationError(ApplicationError):
    """Raised when validation fails."""

    def __init__(self, field: str, message: str) -> None:
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")

class NotFoundError(ApplicationError):
    """Raised when a resource is not found."""

    def __init__(self, resource_type: str, resource_id: Any) -> None:
        self.resource_type = resource_type
        self.resource_id = resource_id
        super().__init__(f"{resource_type} with id {resource_id} not found")
```

## Comprehensions and Generators

### List Comprehensions

```python
# GOOD: Simple, readable comprehension
squares = [x ** 2 for x in range(10)]
evens = [x for x in numbers if x % 2 == 0]

# GOOD: Transforming data
names = [user.name.upper() for user in users]

# BAD: Complex comprehension (use loop instead)
result = [
    transform(x, y)
    for x in range(10)
    for y in range(10)
    if x != y
    if is_valid(x, y)
]

# BETTER: Use explicit loops for complex logic
result = []
for x in range(10):
    for y in range(10):
        if x != y and is_valid(x, y):
            result.append(transform(x, y))
```

### Dictionary Comprehensions

```python
# GOOD: Creating dictionaries
user_by_id = {user.id: user for user in users}
word_counts = {word: text.count(word) for word in unique_words}

# GOOD: Filtering dictionaries
active_users = {k: v for k, v in users.items() if v.is_active}
```

### Generator Expressions

```python
# GOOD: Use generators for large datasets
total = sum(x ** 2 for x in range(1000000))

# GOOD: Memory-efficient processing
lines = (line.strip() for line in file)
non_empty = (line for line in lines if line)
processed = (process(line) for line in non_empty)

# GOOD: Generator functions for complex logic
def fibonacci(n: int):
    """Generate first n Fibonacci numbers."""
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

for num in fibonacci(10):
    print(num)
```

## Python Idioms

### Truthiness

```python
# GOOD: Use truthiness for empty checks
if items:  # Not empty
    process(items)

if not items:  # Empty
    return default

# GOOD: Use truthiness for None checks (when appropriate)
if value:  # Not None and not empty/zero
    use(value)

# GOOD: Explicit None check when 0/empty is valid
if value is not None:
    use(value)

# BAD: Redundant comparisons
if len(items) > 0:  # Use: if items:
    pass

if value == True:  # Use: if value:
    pass

if value is True:  # Only use for exact boolean check
    pass
```

### Iteration

```python
# GOOD: Direct iteration
for item in items:
    process(item)

# GOOD: enumerate for index + value
for index, item in enumerate(items):
    print(f"{index}: {item}")

# GOOD: zip for parallel iteration
for name, score in zip(names, scores):
    print(f"{name}: {score}")

# GOOD: zip with strict (Python 3.10+)
for name, score in zip(names, scores, strict=True):
    pass  # Raises if lengths differ

# BAD: Using range(len())
for i in range(len(items)):
    print(items[i])

# GOOD: Reversed iteration
for item in reversed(items):
    process(item)
```

### Dictionary Operations

```python
# GOOD: Direct key check
if key in my_dict:
    value = my_dict[key]

# GOOD: Get with default
value = my_dict.get(key, default_value)

# GOOD: setdefault for conditional insert
my_dict.setdefault(key, []).append(item)

# GOOD: dict.items() for key-value iteration
for key, value in my_dict.items():
    process(key, value)

# BAD: Using .keys() when not necessary
for key in my_dict.keys():  # Use: for key in my_dict:
    pass
```

### Unpacking

```python
# GOOD: Tuple unpacking
x, y = point
first, second, *rest = items
first, *middle, last = items
_, value, _ = get_triple()  # Ignore values

# GOOD: Dictionary unpacking
defaults = {"timeout": 30, "retries": 3}
config = {**defaults, **user_config}

# GOOD: Argument unpacking
args = [1, 2, 3]
kwargs = {"key": "value"}
function(*args, **kwargs)
```

## Context Managers

```python
# GOOD: File operations
with open("file.txt") as f:
    data = f.read()

# GOOD: Multiple context managers
with open("input.txt") as infile, open("output.txt", "w") as outfile:
    outfile.write(infile.read())

# GOOD: Database transactions
with database.transaction():
    update_record(data)

# GOOD: Temporary directory
from tempfile import TemporaryDirectory

with TemporaryDirectory() as tmpdir:
    # Work with temporary files
    pass  # Directory auto-cleaned

# GOOD: Suppressing exceptions
from contextlib import suppress

with suppress(FileNotFoundError):
    os.remove("maybe_exists.txt")
```