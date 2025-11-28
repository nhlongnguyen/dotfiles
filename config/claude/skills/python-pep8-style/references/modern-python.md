# Modern Python Patterns

This file contains patterns for modern Python features including type hints, dataclasses, async/await, and Python 3.10+ features.

## Type Hints

### Basic Type Hints

```python
# Variable annotations
name: str = "Alice"
age: int = 30
price: float = 19.99
is_active: bool = True

# Function type hints
def greet(name: str) -> str:
    return f"Hello, {name}!"

def add(a: int, b: int) -> int:
    return a + b

def process(data: bytes) -> None:
    # Function returns None
    print(data.decode())
```

### Collection Types

```python
# Python 3.9+ - use built-in types directly
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

def get_coordinates() -> tuple[float, float]:
    return (1.0, 2.0)

def get_user_ids() -> set[int]:
    return {1, 2, 3}

# For Python 3.8 and earlier
from typing import List, Dict, Tuple, Set

def process_items(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}
```

### Optional and Union Types

```python
# Python 3.10+ - use | for unions
def find_user(user_id: int) -> User | None:
    return database.get(user_id)

def process(value: str | int | float) -> str:
    return str(value)

# For Python 3.9 and earlier
from typing import Optional, Union

def find_user(user_id: int) -> Optional[User]:
    return database.get(user_id)

def process(value: Union[str, int, float]) -> str:
    return str(value)
```

### Callable Types

```python
from collections.abc import Callable

# Function that takes a callback
def apply_operation(
    value: int,
    operation: Callable[[int], int]
) -> int:
    return operation(value)

# Function that returns a function
def create_multiplier(factor: int) -> Callable[[int], int]:
    def multiplier(x: int) -> int:
        return x * factor
    return multiplier

# Callable with keyword arguments
from typing import ParamSpec, TypeVar

P = ParamSpec("P")
R = TypeVar("R")

def logged(func: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper
```

### Generic Types

```python
from typing import TypeVar, Generic
from collections.abc import Sequence

T = TypeVar("T")
K = TypeVar("K")
V = TypeVar("V")

# Generic function
def first(items: Sequence[T]) -> T | None:
    return items[0] if items else None

# Generic class
class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Using bounded TypeVar
from typing import TypeVar

Comparable = TypeVar("Comparable", bound="SupportsLessThan")

def min_value(a: Comparable, b: Comparable) -> Comparable:
    return a if a < b else b
```

### Protocol (Structural Subtyping)

```python
from typing import Protocol, runtime_checkable

class Serializable(Protocol):
    """Protocol for objects that can be serialized."""

    def to_dict(self) -> dict[str, Any]: ...

class Drawable(Protocol):
    """Protocol for drawable objects."""

    def draw(self, canvas: Canvas) -> None: ...

# Classes don't need to explicitly inherit
class User:
    def to_dict(self) -> dict[str, Any]:
        return {"id": self.id, "name": self.name}

# User is implicitly Serializable
def save(obj: Serializable) -> None:
    data = obj.to_dict()
    database.save(data)

save(User())  # Works!

# Runtime checkable protocol
@runtime_checkable
class HasLength(Protocol):
    def __len__(self) -> int: ...

if isinstance(obj, HasLength):
    print(len(obj))
```

### TypedDict

```python
from typing import TypedDict, Required, NotRequired

class UserDict(TypedDict):
    id: int
    name: str
    email: str
    age: NotRequired[int]  # Optional key

# All keys required by default
class ConfigDict(TypedDict, total=True):
    host: str
    port: int

# All keys optional
class OptionsDict(TypedDict, total=False):
    timeout: int
    retries: int

def process_user(user: UserDict) -> None:
    print(user["name"])  # Type-safe access
```

### Literal Types

```python
from typing import Literal

def set_status(status: Literal["pending", "active", "completed"]) -> None:
    pass

set_status("active")  # OK
set_status("invalid")  # Type error

# Literal in return types
def get_direction(angle: float) -> Literal["N", "S", "E", "W"]:
    if 45 <= angle < 135:
        return "E"
    elif 135 <= angle < 225:
        return "S"
    elif 225 <= angle < 315:
        return "W"
    return "N"
```

### Type Aliases

```python
from typing import TypeAlias

# Simple alias
UserId: TypeAlias = int
UserDict: TypeAlias = dict[str, Any]

# Complex alias
JsonValue: TypeAlias = (
    str | int | float | bool | None |
    list["JsonValue"] | dict[str, "JsonValue"]
)

# Python 3.12+ type alias syntax
type Vector = list[float]
type Matrix = list[Vector]
type UserId = int
```

## Dataclasses

### Basic Dataclass

```python
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float

# Automatic __init__, __repr__, __eq__
p1 = Point(1.0, 2.0)
p2 = Point(1.0, 2.0)
print(p1)  # Point(x=1.0, y=2.0)
print(p1 == p2)  # True
```

### Default Values and Factories

```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass
class User:
    name: str
    email: str
    # Simple default
    is_active: bool = True
    # Factory for mutable defaults
    tags: list[str] = field(default_factory=list)
    # Factory for computed defaults
    created_at: datetime = field(default_factory=datetime.now)
    # Excluded from __init__
    _cache: dict = field(default_factory=dict, init=False, repr=False)

user = User(name="Alice", email="alice@example.com")
```

### Post-Init Processing

```python
from dataclasses import dataclass, field

@dataclass
class User:
    email: str
    name: str
    normalized_email: str = field(init=False)

    def __post_init__(self) -> None:
        self.normalized_email = self.email.lower().strip()
        self._validate()

    def _validate(self) -> None:
        if "@" not in self.email:
            raise ValueError(f"Invalid email: {self.email}")
```

### Immutable Dataclasses

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Point:
    x: float
    y: float

p = Point(1.0, 2.0)
# p.x = 3.0  # Raises FrozenInstanceError

# Can be used in sets and as dict keys
points = {Point(0, 0), Point(1, 1)}
distances = {Point(0, 0): 0.0, Point(1, 1): 1.414}
```

### Dataclass Inheritance

```python
from dataclasses import dataclass

@dataclass
class Animal:
    name: str
    age: int

@dataclass
class Dog(Animal):
    breed: str
    is_trained: bool = False

dog = Dog(name="Rex", age=3, breed="German Shepherd")
```

### Dataclass with Slots

```python
from dataclasses import dataclass

# Python 3.10+
@dataclass(slots=True)
class Point:
    x: float
    y: float

# More memory efficient, faster attribute access
# Cannot add new attributes dynamically
```

### KW-Only Fields

```python
from dataclasses import dataclass, field

# Python 3.10+
@dataclass
class User:
    id: int
    name: str
    # All fields after kw_only=True require keyword
    email: str = field(kw_only=True)
    is_admin: bool = field(kw_only=True, default=False)

# Must use keywords for email and is_admin
user = User(1, "Alice", email="alice@example.com")
```

## Named Tuples

### typing.NamedTuple

```python
from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float

    def distance_from_origin(self) -> float:
        return (self.x ** 2 + self.y ** 2) ** 0.5

p = Point(3, 4)
print(p.x)  # 3
print(p[0])  # 3 (tuple-like access)
print(p.distance_from_origin())  # 5.0

# Immutable
# p.x = 5  # AttributeError
```

### NamedTuple with Defaults

```python
from typing import NamedTuple

class Connection(NamedTuple):
    host: str
    port: int = 8080
    timeout: float = 30.0

conn = Connection("localhost")
print(conn)  # Connection(host='localhost', port=8080, timeout=30.0)
```

## Enum

### Basic Enum

```python
from enum import Enum, auto

class Status(Enum):
    PENDING = "pending"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

# Usage
status = Status.ACTIVE
print(status.value)  # "active"
print(status.name)   # "ACTIVE"

# Comparison
if status == Status.ACTIVE:
    process()

# Iteration
for s in Status:
    print(s)
```

### IntEnum and StrEnum

```python
from enum import IntEnum, StrEnum

# IntEnum - can be compared with integers
class Priority(IntEnum):
    LOW = 1
    MEDIUM = 2
    HIGH = 3

print(Priority.HIGH > 2)  # True

# StrEnum (Python 3.11+)
class Color(StrEnum):
    RED = "red"
    GREEN = "green"
    BLUE = "blue"

print(f"Color: {Color.RED}")  # "Color: red"
```

### Enum with Methods

```python
from enum import Enum

class OrderStatus(Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

    @property
    def is_final(self) -> bool:
        return self in (OrderStatus.DELIVERED, OrderStatus.CANCELLED)

    def can_transition_to(self, new_status: "OrderStatus") -> bool:
        valid_transitions = {
            OrderStatus.PENDING: {OrderStatus.PROCESSING, OrderStatus.CANCELLED},
            OrderStatus.PROCESSING: {OrderStatus.SHIPPED, OrderStatus.CANCELLED},
            OrderStatus.SHIPPED: {OrderStatus.DELIVERED},
        }
        return new_status in valid_transitions.get(self, set())
```

## Async/Await

### Basic Async Functions

```python
import asyncio

async def fetch_data(url: str) -> dict:
    """Fetch data from URL asynchronously."""
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()

async def main():
    data = await fetch_data("https://api.example.com/data")
    print(data)

# Run async code
asyncio.run(main())
```

### Concurrent Execution

```python
import asyncio

async def fetch_user(user_id: int) -> dict:
    await asyncio.sleep(0.1)  # Simulate network call
    return {"id": user_id, "name": f"User {user_id}"}

async def fetch_all_users(user_ids: list[int]) -> list[dict]:
    # Run all fetches concurrently
    tasks = [fetch_user(uid) for uid in user_ids]
    return await asyncio.gather(*tasks)

async def main():
    users = await fetch_all_users([1, 2, 3, 4, 5])
    print(users)
```

### Async Context Managers

```python
from contextlib import asynccontextmanager

class AsyncDatabase:
    async def connect(self):
        await asyncio.sleep(0.1)
        print("Connected")

    async def close(self):
        await asyncio.sleep(0.1)
        print("Closed")

    async def __aenter__(self):
        await self.connect()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()

# Usage
async def main():
    async with AsyncDatabase() as db:
        # Use database
        pass

# Alternative with decorator
@asynccontextmanager
async def database_connection():
    db = AsyncDatabase()
    await db.connect()
    try:
        yield db
    finally:
        await db.close()
```

### Async Iterators

```python
class AsyncRange:
    def __init__(self, start: int, end: int):
        self.start = start
        self.end = end

    def __aiter__(self):
        self.current = self.start
        return self

    async def __anext__(self) -> int:
        if self.current >= self.end:
            raise StopAsyncIteration
        await asyncio.sleep(0.1)  # Simulate async work
        value = self.current
        self.current += 1
        return value

async def main():
    async for i in AsyncRange(0, 5):
        print(i)
```

### Async Generators

```python
async def async_range(start: int, end: int):
    """Async generator function."""
    for i in range(start, end):
        await asyncio.sleep(0.1)
        yield i

async def fetch_pages(urls: list[str]):
    """Yield fetched pages one at a time."""
    async with aiohttp.ClientSession() as session:
        for url in urls:
            async with session.get(url) as response:
                yield await response.text()

async def main():
    async for page in fetch_pages(urls):
        process(page)
```

## Pattern Matching (Python 3.10+)

### Basic Match

```python
def describe_value(value):
    match value:
        case 0:
            return "zero"
        case 1:
            return "one"
        case _:
            return "other"
```

### Pattern Matching with Types

```python
def process_response(response):
    match response:
        case {"status": "ok", "data": data}:
            return process_data(data)
        case {"status": "error", "message": msg}:
            raise APIError(msg)
        case _:
            raise ValueError("Unknown response format")
```

### Pattern Matching with Classes

```python
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float

@dataclass
class Circle:
    center: Point
    radius: float

@dataclass
class Rectangle:
    top_left: Point
    bottom_right: Point

def calculate_area(shape) -> float:
    match shape:
        case Circle(center=_, radius=r):
            return 3.14159 * r ** 2
        case Rectangle(top_left=Point(x1, y1), bottom_right=Point(x2, y2)):
            return abs(x2 - x1) * abs(y2 - y1)
        case _:
            raise ValueError(f"Unknown shape: {shape}")
```

### Guards in Pattern Matching

```python
def categorize_number(n: int) -> str:
    match n:
        case x if x < 0:
            return "negative"
        case 0:
            return "zero"
        case x if x % 2 == 0:
            return "positive even"
        case _:
            return "positive odd"
```

## Context Managers

### Custom Context Manager Class

```python
class ManagedFile:
    def __init__(self, filename: str, mode: str = "r"):
        self.filename = filename
        self.mode = mode
        self.file = None

    def __enter__(self):
        self.file = open(self.filename, self.mode)
        return self.file

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.file:
            self.file.close()
        # Return True to suppress exception
        return False
```

### Context Manager Decorator

```python
from contextlib import contextmanager

@contextmanager
def temporary_directory():
    import tempfile
    import shutil

    dirpath = tempfile.mkdtemp()
    try:
        yield dirpath
    finally:
        shutil.rmtree(dirpath)

# Usage
with temporary_directory() as tmpdir:
    # Work with temporary directory
    pass
# Directory is automatically cleaned up
```

### Context Manager Utilities

```python
from contextlib import suppress, redirect_stdout, ExitStack
import io

# Suppress specific exceptions
with suppress(FileNotFoundError):
    os.remove("maybe_missing.txt")

# Redirect stdout
f = io.StringIO()
with redirect_stdout(f):
    print("This goes to string")
output = f.getvalue()

# Dynamic context managers
with ExitStack() as stack:
    files = [stack.enter_context(open(f)) for f in filenames]
    # All files are closed when exiting
```

## Decorators

### Function Decorator with Typing

```python
from functools import wraps
from typing import TypeVar, Callable, ParamSpec

P = ParamSpec("P")
R = TypeVar("R")

def logged(func: Callable[P, R]) -> Callable[P, R]:
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Returned: {result}")
        return result
    return wrapper

@logged
def add(a: int, b: int) -> int:
    return a + b
```

### Decorator with Arguments

```python
from functools import wraps
from typing import TypeVar, Callable, ParamSpec

P = ParamSpec("P")
R = TypeVar("R")

def retry(max_attempts: int = 3, delay: float = 1.0):
    def decorator(func: Callable[P, R]) -> Callable[P, R]:
        @wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
            last_exception = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    time.sleep(delay)
            raise last_exception
        return wrapper
    return decorator

@retry(max_attempts=5, delay=0.5)
def fetch_data(url: str) -> dict:
    return requests.get(url).json()
```

### Class Decorator

```python
from dataclasses import dataclass
from functools import wraps

def singleton(cls):
    """Make a class a singleton."""
    instances = {}

    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]

    return get_instance

@singleton
class Configuration:
    def __init__(self):
        self.settings = {}
```