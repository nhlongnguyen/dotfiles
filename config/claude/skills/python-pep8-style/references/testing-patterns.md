# Python Testing Patterns

This file contains testing patterns for Python using pytest and following TDD best practices.

## Test-Driven Development (TDD)

### The TDD Cycle

```
1. RED    - Write a failing test
2. GREEN  - Write minimal code to pass
3. REFACTOR - Improve code while keeping tests green
```

### TDD Example Workflow

```python
# Step 1: RED - Write the failing test first
# test_user.py
import pytest
from user import User, InvalidEmailError

def test_user_email_is_normalized():
    user = User(email="Test@Example.COM", name="Test")
    assert user.email == "test@example.com"

def test_user_rejects_invalid_email():
    with pytest.raises(InvalidEmailError):
        User(email="invalid", name="Test")

# Step 2: GREEN - Minimal implementation
# user.py
import re
from dataclasses import dataclass

class InvalidEmailError(ValueError):
    pass

EMAIL_PATTERN = re.compile(r"^[\w\.-]+@[\w\.-]+\.\w+$")

@dataclass
class User:
    email: str
    name: str

    def __post_init__(self):
        if not EMAIL_PATTERN.match(self.email):
            raise InvalidEmailError(f"Invalid email: {self.email}")
        self.email = self.email.lower()

# Step 3: REFACTOR - Improve while green
# (extract validation, add type hints, etc.)
```

## pytest Fundamentals

### Basic Test Structure

```python
import pytest
from myapp.calculator import Calculator

class TestCalculator:
    """Tests for Calculator class."""

    def test_add_positive_numbers(self):
        """Two positive numbers should return their sum."""
        calc = Calculator()
        result = calc.add(2, 3)
        assert result == 5

    def test_add_negative_numbers(self):
        """Adding negative numbers should work correctly."""
        calc = Calculator()
        result = calc.add(-2, -3)
        assert result == -5

    def test_add_zero(self):
        """Adding zero should return the other number."""
        calc = Calculator()
        assert calc.add(5, 0) == 5
        assert calc.add(0, 5) == 5
```

### Test Naming Conventions

```python
# GOOD: Descriptive test names
def test_user_creation_with_valid_email_succeeds():
    pass

def test_user_creation_with_invalid_email_raises_validation_error():
    pass

def test_empty_cart_has_zero_total():
    pass

def test_adding_item_to_cart_increases_item_count():
    pass

# BAD: Vague test names
def test_user():
    pass

def test_cart_1():
    pass

def test_it_works():
    pass
```

## Fixtures

### Basic Fixtures

```python
import pytest
from myapp.models import User, Database

@pytest.fixture
def user():
    """Create a test user."""
    return User(
        id=1,
        name="Test User",
        email="test@example.com"
    )

@pytest.fixture
def admin_user():
    """Create an admin user."""
    return User(
        id=2,
        name="Admin",
        email="admin@example.com",
        is_admin=True
    )

def test_user_is_not_admin(user):
    assert not user.is_admin

def test_admin_has_permissions(admin_user):
    assert admin_user.is_admin
```

### Fixture Scopes

```python
import pytest

# Function scope (default) - created for each test
@pytest.fixture
def fresh_data():
    return {"count": 0}

# Class scope - shared across tests in a class
@pytest.fixture(scope="class")
def database_schema():
    schema = create_schema()
    yield schema
    drop_schema(schema)

# Module scope - shared across tests in a module
@pytest.fixture(scope="module")
def database_connection():
    conn = Database.connect()
    yield conn
    conn.close()

# Session scope - shared across entire test session
@pytest.fixture(scope="session")
def expensive_resource():
    resource = create_expensive_resource()
    yield resource
    cleanup_resource(resource)
```

### Fixture Dependencies

```python
import pytest

@pytest.fixture
def database():
    """Create test database."""
    db = Database(":memory:")
    db.create_tables()
    yield db
    db.close()

@pytest.fixture
def user_repository(database):
    """Create repository with database dependency."""
    return UserRepository(database)

@pytest.fixture
def test_user(user_repository):
    """Create and save a test user."""
    user = User(name="Test", email="test@example.com")
    user_repository.save(user)
    return user

def test_find_user_by_email(user_repository, test_user):
    found = user_repository.find_by_email("test@example.com")
    assert found.id == test_user.id
```

### Parameterized Fixtures

```python
import pytest

@pytest.fixture(params=["sqlite", "postgres", "mysql"])
def database(request):
    """Test with multiple database backends."""
    db_type = request.param
    db = Database.create(db_type)
    yield db
    db.close()

def test_insert_and_retrieve(database):
    # This test runs 3 times, once for each database type
    database.insert({"key": "value"})
    result = database.get("key")
    assert result == "value"
```

## Parameterized Tests

### Basic Parameterization

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    (1, 1),
    (2, 4),
    (3, 9),
    (4, 16),
    (-2, 4),
    (0, 0),
])
def test_square(input, expected):
    assert square(input) == expected

@pytest.mark.parametrize("email,is_valid", [
    ("user@example.com", True),
    ("user@subdomain.example.com", True),
    ("user+tag@example.com", True),
    ("invalid", False),
    ("@example.com", False),
    ("user@", False),
    ("", False),
])
def test_email_validation(email, is_valid):
    result = is_valid_email(email)
    assert result == is_valid
```

### Multiple Parameterize Decorators

```python
import pytest

@pytest.mark.parametrize("x", [0, 1, 2])
@pytest.mark.parametrize("y", [0, 1, 2])
def test_commutative_addition(x, y):
    """Tests all combinations: (0,0), (0,1), (0,2), (1,0), ..."""
    assert add(x, y) == add(y, x)
```

### Named Parameter Sets

```python
import pytest

@pytest.mark.parametrize(
    "user_data,expected_error",
    [
        pytest.param(
            {"name": "", "email": "test@example.com"},
            "Name is required",
            id="missing_name"
        ),
        pytest.param(
            {"name": "Test", "email": ""},
            "Email is required",
            id="missing_email"
        ),
        pytest.param(
            {"name": "Test", "email": "invalid"},
            "Invalid email format",
            id="invalid_email"
        ),
    ]
)
def test_user_validation_errors(user_data, expected_error):
    with pytest.raises(ValidationError, match=expected_error):
        User(**user_data)
```

## Assertions

### Basic Assertions

```python
def test_assertions():
    # Equality
    assert result == expected
    assert result != unexpected

    # Boolean
    assert condition
    assert not condition

    # Membership
    assert item in collection
    assert item not in collection

    # Identity
    assert result is None
    assert result is not None

    # Type checking
    assert isinstance(result, ExpectedType)

    # Approximate equality (for floats)
    assert result == pytest.approx(expected, rel=1e-3)
```

### Exception Testing

```python
import pytest

def test_raises_exception():
    with pytest.raises(ValueError):
        raise_value_error()

def test_raises_with_message():
    with pytest.raises(ValueError, match="invalid input"):
        validate_input("bad")

def test_raises_and_inspect():
    with pytest.raises(CustomError) as exc_info:
        do_something_bad()

    assert exc_info.value.code == 400
    assert "details" in str(exc_info.value)
```

### Warning Testing

```python
import pytest
import warnings

def test_deprecation_warning():
    with pytest.warns(DeprecationWarning):
        deprecated_function()

def test_warning_with_message():
    with pytest.warns(UserWarning, match="will be removed"):
        old_api_call()
```

## Mocking

### Using unittest.mock

```python
from unittest.mock import Mock, MagicMock, patch, call

def test_with_mock():
    # Create a mock
    mock_service = Mock()
    mock_service.get_user.return_value = {"id": 1, "name": "Test"}

    # Use the mock
    result = process_user(mock_service, user_id=1)

    # Verify calls
    mock_service.get_user.assert_called_once_with(1)
    assert result["name"] == "Test"
```

### Patching

```python
from unittest.mock import patch

# Patch as decorator
@patch('myapp.services.external_api.fetch_data')
def test_with_patched_api(mock_fetch):
    mock_fetch.return_value = {"status": "ok"}
    result = process_data()
    assert result["status"] == "ok"

# Patch as context manager
def test_with_context_patch():
    with patch('myapp.services.send_email') as mock_send:
        mock_send.return_value = True
        result = notify_user(user)
        mock_send.assert_called_once()

# Patch object method
def test_patch_method():
    with patch.object(UserService, 'authenticate') as mock_auth:
        mock_auth.return_value = True
        service = UserService()
        assert service.login("user", "pass")
```

### Mock Side Effects

```python
from unittest.mock import Mock, patch

def test_mock_side_effect_exception():
    mock_api = Mock()
    mock_api.call.side_effect = ConnectionError("Network error")

    with pytest.raises(ConnectionError):
        mock_api.call()

def test_mock_side_effect_values():
    mock_counter = Mock()
    mock_counter.get_next.side_effect = [1, 2, 3]

    assert mock_counter.get_next() == 1
    assert mock_counter.get_next() == 2
    assert mock_counter.get_next() == 3

def test_mock_side_effect_function():
    def validate(value):
        if value < 0:
            raise ValueError("Negative")
        return value * 2

    mock = Mock(side_effect=validate)
    assert mock(5) == 10
    with pytest.raises(ValueError):
        mock(-1)
```

### Spec and Autospec

```python
from unittest.mock import Mock, create_autospec

class RealService:
    def get_user(self, user_id: int) -> dict:
        pass

    def save_user(self, user: dict) -> bool:
        pass

# Mock with spec ensures only real methods are called
def test_with_spec():
    mock_service = Mock(spec=RealService)
    mock_service.get_user.return_value = {"id": 1}

    # This works
    mock_service.get_user(1)

    # This raises AttributeError (method doesn't exist)
    # mock_service.nonexistent_method()

# Autospec also checks signatures
def test_with_autospec():
    mock_service = create_autospec(RealService)
    mock_service.get_user(1)  # Works

    # This raises TypeError (wrong signature)
    # mock_service.get_user()
```

## pytest Plugins and Markers

### Built-in Markers

```python
import pytest

@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.version_info < (3, 10), reason="Requires Python 3.10+")
def test_new_syntax():
    pass

@pytest.mark.xfail(reason="Known bug #123")
def test_known_failure():
    assert broken_function() == expected

@pytest.mark.slow
def test_slow_operation():
    # Run with: pytest -m "not slow"
    pass
```

### Custom Markers

```python
# conftest.py
import pytest

def pytest_configure(config):
    config.addinivalue_line("markers", "integration: mark test as integration test")
    config.addinivalue_line("markers", "unit: mark test as unit test")

# test_example.py
@pytest.mark.integration
def test_database_connection():
    pass

@pytest.mark.unit
def test_pure_function():
    pass

# Run: pytest -m integration
# Run: pytest -m "not integration"
```

### Useful Fixtures from conftest.py

```python
# conftest.py
import pytest
from pathlib import Path
import tempfile

@pytest.fixture
def temp_dir():
    """Provide a temporary directory."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)

@pytest.fixture
def capture_logs(caplog):
    """Capture log messages."""
    import logging
    caplog.set_level(logging.DEBUG)
    return caplog

@pytest.fixture(autouse=True)
def reset_global_state():
    """Reset global state before each test."""
    global_cache.clear()
    yield
    global_cache.clear()
```

## Async Testing

### Testing async code with pytest-asyncio

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await async_fetch_data()
    assert result["status"] == "ok"

@pytest.mark.asyncio
async def test_async_with_fixture(async_database):
    result = await async_database.query("SELECT 1")
    assert result == 1

@pytest.fixture
async def async_database():
    db = await Database.connect()
    yield db
    await db.close()
```

## Test Organization

### conftest.py Hierarchy

```
tests/
├── conftest.py              # Shared fixtures for all tests
├── unit/
│   ├── conftest.py          # Unit test specific fixtures
│   ├── test_models.py
│   └── test_utils.py
├── integration/
│   ├── conftest.py          # Integration test fixtures
│   ├── test_api.py
│   └── test_database.py
└── e2e/
    ├── conftest.py          # E2E test fixtures
    └── test_workflows.py
```

### Test Class Organization

```python
class TestUserService:
    """Tests for UserService."""

    class TestCreate:
        """Tests for user creation."""

        def test_creates_user_with_valid_data(self):
            pass

        def test_raises_error_for_duplicate_email(self):
            pass

    class TestAuthenticate:
        """Tests for user authentication."""

        def test_authenticates_with_valid_credentials(self):
            pass

        def test_rejects_invalid_password(self):
            pass
```

## Coverage

### Running with Coverage

```bash
# Run tests with coverage
pytest --cov=myapp --cov-report=html

# Specify coverage threshold
pytest --cov=myapp --cov-fail-under=80

# Exclude patterns
pytest --cov=myapp --cov-report=term-missing
```

### Coverage Configuration

```ini
# pyproject.toml
[tool.coverage.run]
source = ["myapp"]
omit = ["*/tests/*", "*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

## Best Practices Summary

### DO

- Write tests before implementation (TDD)
- Use descriptive test names that explain the scenario
- Keep tests independent and isolated
- Use fixtures for shared setup
- Test edge cases and error conditions
- Use parameterized tests for similar scenarios
- Mock external dependencies

### DON'T

- Test implementation details (test behavior)
- Share state between tests
- Write tests that depend on execution order
- Over-mock (test real behavior when possible)
- Write flaky tests (avoid time-dependent tests)
- Ignore test failures