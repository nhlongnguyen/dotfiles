"""Module docstring describing the module's purpose.

This module provides [description of what the module does].

Example:
    >>> from myapp.models import MyClass
    >>> obj = MyClass(name="example")
    >>> obj.process()
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import Sequence

# Module-level constants
DEFAULT_VALUE = 42
MAX_RETRIES = 3


@dataclass
class MyClass:
    """Brief one-line description of the class.

    Longer description explaining the class purpose, behavior,
    and any important implementation details.

    Attributes:
        name: Description of the name attribute.
        value: Description of the value attribute.
        is_active: Whether the instance is active.

    Example:
        >>> obj = MyClass(name="test", value=10)
        >>> obj.process()
        'Processed: test'
    """

    name: str
    value: int = DEFAULT_VALUE
    is_active: bool = True
    _cache: dict[str, Any] = field(default_factory=dict, init=False, repr=False)

    def __post_init__(self) -> None:
        """Validate and normalize after initialization."""
        self._validate()
        self.name = self.name.strip()

    def _validate(self) -> None:
        """Validate instance state."""
        if not self.name:
            raise ValueError("Name cannot be empty")
        if self.value < 0:
            raise ValueError(f"Value must be non-negative, got {self.value}")

    def process(self) -> str:
        """Process the instance and return result.

        Returns:
            Processed string representation.

        Raises:
            RuntimeError: If instance is not active.
        """
        if not self.is_active:
            raise RuntimeError("Cannot process inactive instance")
        return f"Processed: {self.name}"

    def to_dict(self) -> dict[str, Any]:
        """Convert instance to dictionary representation.

        Returns:
            Dictionary containing instance data.
        """
        return {
            "name": self.name,
            "value": self.value,
            "is_active": self.is_active,
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> MyClass:
        """Create instance from dictionary.

        Args:
            data: Dictionary containing instance data.

        Returns:
            New instance created from data.

        Raises:
            KeyError: If required keys are missing.
        """
        return cls(
            name=data["name"],
            value=data.get("value", DEFAULT_VALUE),
            is_active=data.get("is_active", True),
        )