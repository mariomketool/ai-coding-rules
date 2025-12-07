# Python 3.12 AI Code Generation Guidelines

## Version Requirements

- Target Python version: **3.12+**
- Use modern Python 3.12 features including:
  - PEP 695: Type Parameter Syntax (generic classes with `class MyClass[T]:`)
  - PEP 692: TypedDict with `**kwargs`
  - PEP 698: `@override` decorator
  - Enhanced error messages and performance improvements

## Type Annotations

### General Typing Rules

- **ALWAYS** use type hints for all function signatures, class attributes, and variables where type is not immediately obvious
- Use `from typing import` for complex types
- Prefer built-in generics over typing module equivalents (Python 3.9+ style)
  - Use `list[str]` instead of `List[str]`
  - Use `dict[str, int]` instead of `Dict[str, int]`
  - Use `tuple[int, ...]` instead of `Tuple[int, ...]`
  - Use `set[int]` instead of `Set[int]`

### Type Annotation Examples

```python
# Function signatures
def process_data(items: list[str], limit: int = 10) -> dict[str, int]:
    """Process items and return frequency count."""
    return {item: items.count(item) for item in items[:limit]}

# Class attributes
class DataProcessor:
    items: list[str]
    max_size: int
    _cache: dict[str, Any] | None = None

    def __init__(self, items: list[str], max_size: int = 100) -> None:
        self.items = items
        self.max_size = max_size
```

### Advanced Typing

```python
from typing import Protocol, TypeVar, Generic, Callable, Literal, TypedDict
from collections.abc import Iterable, Sequence

# Protocol for structural subtyping
class Drawable(Protocol):
    def draw(self) -> None: ...

# Generic types using PEP 695 syntax (Python 3.12+)
class Container[T]:
    def __init__(self, value: T) -> None:
        self._value = value

    def get(self) -> T:
        return self._value

# TypedDict for structured dictionaries
class UserDict(TypedDict):
    name: str
    age: int
    email: str | None

# Literal types for specific values
def set_mode(mode: Literal["read", "write", "append"]) -> None:
    ...

# Callable types
def apply_operation(func: Callable[[int, int], int], x: int, y: int) -> int:
    return func(x, y)

# Union types (use | operator)
def get_value(key: str) -> str | int | None:
    ...
```

### Type Checking

- Use `mypy` for static type checking
- Configure strict mode in `mypy.ini` or `pyproject.toml`:

```toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

## Object-Oriented Programming Principles

### SOLID Principles

#### 1. Single Responsibility Principle (SRP)

Each class should have one, and only one, reason to change.

```python
# Bad: Multiple responsibilities
class User:
    def __init__(self, name: str, email: str) -> None:
        self.name = name
        self.email = email

    def save_to_database(self) -> None:
        # Database logic here
        pass

    def send_email(self) -> None:
        # Email logic here
        pass

# Good: Separated responsibilities
class User:
    def __init__(self, name: str, email: str) -> None:
        self.name = name
        self.email = email

class UserRepository:
    def save(self, user: User) -> None:
        # Database logic here
        pass

class EmailService:
    def send(self, to: str, subject: str, body: str) -> None:
        # Email logic here
        pass
```

#### 2. Open/Closed Principle (OCP)

Classes should be open for extension but closed for modification.

```python
from abc import ABC, abstractmethod

# Good: Extension through inheritance/composition
class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        pass

class Circle(Shape):
    def __init__(self, radius: float) -> None:
        self.radius = radius

    def area(self) -> float:
        return 3.14159 * self.radius ** 2

class Rectangle(Shape):
    def __init__(self, width: float, height: float) -> None:
        self.width = width
        self.height = height

    def area(self) -> float:
        return self.width * self.height

class AreaCalculator:
    def total_area(self, shapes: list[Shape]) -> float:
        return sum(shape.area() for shape in shapes)
```

#### 3. Liskov Substitution Principle (LSP)

Derived classes must be substitutable for their base classes.

```python
class Bird(ABC):
    @abstractmethod
    def move(self) -> None:
        pass

class FlyingBird(Bird):
    def move(self) -> None:
        self.fly()

    def fly(self) -> None:
        print("Flying...")

class Penguin(Bird):
    def move(self) -> None:
        self.walk()

    def walk(self) -> None:
        print("Walking...")
```

#### 4. Interface Segregation Principle (ISP)

Clients should not be forced to depend on interfaces they don't use.

```python
from typing import Protocol

# Bad: Fat interface
class Worker(Protocol):
    def work(self) -> None: ...
    def eat(self) -> None: ...
    def sleep(self) -> None: ...

# Good: Segregated interfaces
class Workable(Protocol):
    def work(self) -> None: ...

class Eatable(Protocol):
    def eat(self) -> None: ...

class Sleepable(Protocol):
    def sleep(self) -> None: ...

class Human:
    def work(self) -> None:
        print("Working...")

    def eat(self) -> None:
        print("Eating...")

    def sleep(self) -> None:
        print("Sleeping...")

class Robot:
    def work(self) -> None:
        print("Working...")
```

#### 5. Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions.

```python
from abc import ABC, abstractmethod

# Bad: High-level module depends on low-level module
class MySQLDatabase:
    def save(self, data: str) -> None:
        print(f"Saving to MySQL: {data}")

class UserService:
    def __init__(self) -> None:
        self.db = MySQLDatabase()  # Concrete dependency

    def create_user(self, name: str) -> None:
        self.db.save(name)

# Good: Both depend on abstraction
class Database(ABC):
    @abstractmethod
    def save(self, data: str) -> None:
        pass

class MySQLDatabase(Database):
    def save(self, data: str) -> None:
        print(f"Saving to MySQL: {data}")

class PostgreSQLDatabase(Database):
    def save(self, data: str) -> None:
        print(f"Saving to PostgreSQL: {data}")

class UserService:
    def __init__(self, db: Database) -> None:
        self.db = db  # Abstract dependency

    def create_user(self, name: str) -> None:
        self.db.save(name)
```

### DRY (Don't Repeat Yourself)

Avoid code duplication. Extract common functionality into reusable functions or classes.

```python
# Bad: Repeated logic
def calculate_discount_for_regular(price: float) -> float:
    tax = price * 0.1
    discount = price * 0.05
    return price + tax - discount

def calculate_discount_for_premium(price: float) -> float:
    tax = price * 0.1
    discount = price * 0.15
    return price + tax - discount

# Good: DRY principle
def calculate_final_price(price: float, discount_rate: float, tax_rate: float = 0.1) -> float:
    tax = price * tax_rate
    discount = price * discount_rate
    return price + tax - discount

def calculate_discount_for_regular(price: float) -> float:
    return calculate_final_price(price, discount_rate=0.05)

def calculate_discount_for_premium(price: float) -> float:
    return calculate_final_price(price, discount_rate=0.15)
```

### KISS (Keep It Simple, Stupid)

Write simple, readable code. Avoid unnecessary complexity.

```python
# Bad: Overly complex
def is_valid(x: int) -> bool:
    return True if x > 0 and x < 100 and x % 2 == 0 else False if x <= 0 or x >= 100 else True if x % 2 != 0 else False

# Good: Simple and clear
def is_valid(x: int) -> bool:
    return 0 < x < 100 and x % 2 == 0
```

## Class Design Best Practices

### Use Dataclasses for Data Containers

```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass(frozen=True, slots=True)  # frozen for immutability, slots for memory efficiency
class User:
    id: int
    name: str
    email: str
    created_at: datetime = field(default_factory=datetime.now)
    tags: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        if not self.email:
            raise ValueError("Email cannot be empty")
```

### Property Decorators for Encapsulation

```python
class Temperature:
    def __init__(self, celsius: float) -> None:
        self._celsius = celsius

    @property
    def celsius(self) -> float:
        return self._celsius

    @celsius.setter
    def celsius(self, value: float) -> None:
        if value < -273.15:
            raise ValueError("Temperature below absolute zero")
        self._celsius = value

    @property
    def fahrenheit(self) -> float:
        return self._celsius * 9/5 + 32

    @fahrenheit.setter
    def fahrenheit(self, value: float) -> None:
        self.celsius = (value - 32) * 5/9
```

### Context Managers

Always use context managers for resource management.

```python
from typing import Self
from pathlib import Path

class FileHandler:
    def __init__(self, filename: Path) -> None:
        self.filename = filename
        self.file = None

    def __enter__(self) -> Self:
        self.file = open(self.filename, 'r')
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        if self.file:
            self.file.close()

    def read(self) -> str:
        if self.file:
            return self.file.read()
        raise RuntimeError("File not opened")

# Usage
with FileHandler(Path("data.txt")) as handler:
    content = handler.read()
```

### Abstract Base Classes

```python
from abc import ABC, abstractmethod
from typing import override

class PaymentProcessor(ABC):
    @abstractmethod
    def process_payment(self, amount: float) -> bool:
        """Process a payment. Returns True if successful."""
        pass

    @abstractmethod
    def refund(self, transaction_id: str) -> bool:
        """Refund a payment. Returns True if successful."""
        pass

class StripeProcessor(PaymentProcessor):
    @override
    def process_payment(self, amount: float) -> bool:
        # Stripe-specific implementation
        return True

    @override
    def refund(self, transaction_id: str) -> bool:
        # Stripe-specific implementation
        return True
```

## Error Handling

### Exception Hierarchy

```python
class ApplicationError(Exception):
    """Base exception for application errors."""
    pass

class ValidationError(ApplicationError):
    """Raised when validation fails."""
    pass

class DatabaseError(ApplicationError):
    """Raised when database operations fail."""
    pass

# Usage
def validate_email(email: str) -> None:
    if "@" not in email:
        raise ValidationError(f"Invalid email format: {email}")
```

### Exception Handling Best Practices

```python
from typing import Any

# Be specific with exceptions
try:
    value = int("not a number")
except ValueError as e:
    print(f"Conversion failed: {e}")
except Exception as e:  # Catch-all should be last
    print(f"Unexpected error: {e}")
    raise  # Re-raise if you can't handle it

# Use finally for cleanup
def process_file(filename: Path) -> None:
    file = None
    try:
        file = open(filename, 'r')
        process_data(file.read())
    except FileNotFoundError:
        print(f"File not found: {filename}")
    finally:
        if file:
            file.close()

# Or better, use context managers
def process_file_better(filename: Path) -> None:
    try:
        with open(filename, 'r') as file:
            process_data(file.read())
    except FileNotFoundError:
        print(f"File not found: {filename}")
```

## Code Organization

### Module Structure

```
project/
├── __init__.py
├── models/
│   ├── __init__.py
│   ├── user.py
│   └── product.py
├── services/
│   ├── __init__.py
│   ├── user_service.py
│   └── email_service.py
├── repositories/
│   ├── __init__.py
│   └── user_repository.py
├── utils/
│   ├── __init__.py
│   └── validators.py
└── config.py
```

### Imports

```python
# Standard library imports first
import os
import sys
from pathlib import Path
from typing import Any, Protocol

# Third-party imports second
import requests
from pydantic import BaseModel

# Local imports last
from .models import User
from .services import UserService
```

## Documentation

### Docstrings (Google Style)

```python
def process_items(
    items: list[str],
    limit: int = 10,
    filter_func: Callable[[str], bool] | None = None
) -> dict[str, int]:
    """Process a list of items and return their frequency count.

    This function takes a list of items, optionally filters them,
    and returns a dictionary with item frequencies up to the specified limit.

    Args:
        items: List of string items to process.
        limit: Maximum number of items to process. Defaults to 10.
        filter_func: Optional function to filter items before processing.

    Returns:
        Dictionary mapping items to their frequency counts.

    Raises:
        ValueError: If limit is negative.

    Example:
        >>> process_items(['a', 'b', 'a', 'c'], limit=3)
        {'a': 2, 'b': 1, 'c': 1}
    """
    if limit < 0:
        raise ValueError("Limit must be non-negative")

    filtered_items = items if filter_func is None else [i for i in items if filter_func(i)]
    return {item: filtered_items.count(item) for item in filtered_items[:limit]}
```

## Testing

### Use Type-Safe Testing

```python
import pytest
from typing import Any

class TestUserService:
    @pytest.fixture
    def user_service(self) -> UserService:
        return UserService(database=MockDatabase())

    def test_create_user(self, user_service: UserService) -> None:
        user = user_service.create_user(name="John", email="john@example.com")
        assert user.name == "John"
        assert user.email == "john@example.com"

    def test_invalid_email_raises_error(self, user_service: UserService) -> None:
        with pytest.raises(ValidationError, match="Invalid email"):
            user_service.create_user(name="John", email="invalid")
```

## Performance Considerations

### Use Generators for Large Datasets

```python
from collections.abc import Iterator

def read_large_file(filename: Path) -> Iterator[str]:
    """Read file line by line without loading entire file into memory."""
    with open(filename, 'r') as file:
        for line in file:
            yield line.strip()

# Usage
for line in read_large_file(Path("large_file.txt")):
    process(line)
```

### Use Slots for Memory Efficiency

```python
class Point:
    __slots__ = ('x', 'y')  # Reduces memory overhead

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y
```

## Modern Python 3.12 Features

### Type Parameter Syntax (PEP 695)

```python
# Old way (still valid)
from typing import TypeVar

T = TypeVar('T')

class OldContainer:
    def __init__(self, value: T) -> None:
        self.value = value

# New way (Python 3.12+)
class Container[T]:
    def __init__(self, value: T) -> None:
        self.value = value

def first[T](items: list[T]) -> T | None:
    return items[0] if items else None
```

### @override Decorator (PEP 698)

```python
from typing import override

class Base:
    def method(self) -> None:
        pass

class Derived(Base):
    @override  # Ensures this actually overrides a parent method
    def method(self) -> None:
        super().method()
```

## Configuration and Environment

### Use Pydantic for Settings

```python
from pydantic import Field
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "My Application"
    database_url: str = Field(..., env="DATABASE_URL")
    api_key: str = Field(..., env="API_KEY")
    debug: bool = False
    max_connections: int = 10

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
    }

settings = Settings()
```

## Summary Checklist

- ✅ Use Python 3.12+ features
- ✅ Add type hints to all functions, methods, and class attributes
- ✅ Follow SOLID principles in class design
- ✅ Apply DRY and KISS principles
- ✅ Use dataclasses for data containers
- ✅ Implement proper error handling with custom exceptions
- ✅ Use context managers for resource management
- ✅ Write comprehensive docstrings
- ✅ Use abstract base classes for defining interfaces
- ✅ Configure mypy for strict type checking
- ✅ Prefer composition over inheritance
- ✅ Keep classes focused on single responsibility
- ✅ Use `@override` decorator when overriding methods
- ✅ Use modern type syntax (`list[str]`, `dict[str, int]`, `type | None`)
