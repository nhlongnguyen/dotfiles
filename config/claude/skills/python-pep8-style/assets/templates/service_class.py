"""Service layer module for business logic.

This module contains service classes that encapsulate business logic
and coordinate between different layers of the application.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from collections.abc import Sequence

logger = logging.getLogger(__name__)


class Repository(Protocol):
    """Protocol for data repository implementations."""

    def get(self, id: int) -> dict | None: ...
    def save(self, data: dict) -> int: ...
    def delete(self, id: int) -> bool: ...


class NotificationService(Protocol):
    """Protocol for notification service implementations."""

    def send(self, recipient: str, message: str) -> bool: ...


@dataclass
class ServiceConfig:
    """Configuration for the service."""

    max_retries: int = 3
    timeout_seconds: float = 30.0
    enable_notifications: bool = True


class UserServiceError(Exception):
    """Base exception for UserService errors."""

    pass


class UserNotFoundError(UserServiceError):
    """Raised when a user cannot be found."""

    def __init__(self, user_id: int) -> None:
        self.user_id = user_id
        super().__init__(f"User {user_id} not found")


class UserService:
    """Service for user-related business operations.

    Coordinates between repository, notifications, and other services
    to perform user operations.

    Attributes:
        repository: Data access repository.
        notifier: Notification service for sending messages.
        config: Service configuration.

    Example:
        >>> repo = UserRepository(database)
        >>> notifier = EmailNotifier()
        >>> service = UserService(repo, notifier)
        >>> user = service.get_user(123)
    """

    def __init__(
        self,
        repository: Repository,
        notifier: NotificationService | None = None,
        config: ServiceConfig | None = None,
    ) -> None:
        """Initialize the service.

        Args:
            repository: Data access repository.
            notifier: Optional notification service.
            config: Optional service configuration.
        """
        self.repository = repository
        self.notifier = notifier
        self.config = config or ServiceConfig()

    def get_user(self, user_id: int) -> dict:
        """Get user by ID.

        Args:
            user_id: The user's unique identifier.

        Returns:
            User data dictionary.

        Raises:
            UserNotFoundError: If user does not exist.
        """
        logger.debug("Fetching user %d", user_id)
        user = self.repository.get(user_id)
        if user is None:
            raise UserNotFoundError(user_id)
        return user

    def create_user(self, user_data: dict) -> int:
        """Create a new user.

        Args:
            user_data: Dictionary containing user data.

        Returns:
            ID of the created user.

        Raises:
            ValueError: If user data is invalid.
        """
        self._validate_user_data(user_data)
        user_id = self.repository.save(user_data)
        logger.info("Created user %d", user_id)

        if self.config.enable_notifications and self.notifier:
            self._send_welcome_notification(user_data)

        return user_id

    def delete_user(self, user_id: int) -> None:
        """Delete a user.

        Args:
            user_id: The user's unique identifier.

        Raises:
            UserNotFoundError: If user does not exist.
        """
        # Verify user exists
        self.get_user(user_id)

        success = self.repository.delete(user_id)
        if success:
            logger.info("Deleted user %d", user_id)

    def _validate_user_data(self, data: dict) -> None:
        """Validate user data.

        Args:
            data: User data to validate.

        Raises:
            ValueError: If data is invalid.
        """
        if not data.get("name"):
            raise ValueError("Name is required")
        if not data.get("email"):
            raise ValueError("Email is required")
        if "@" not in data["email"]:
            raise ValueError("Invalid email format")

    def _send_welcome_notification(self, user_data: dict) -> None:
        """Send welcome notification to new user.

        Args:
            user_data: New user's data.
        """
        if self.notifier is None:
            return

        try:
            self.notifier.send(
                recipient=user_data["email"],
                message=f"Welcome, {user_data['name']}!",
            )
        except Exception as e:
            # Don't fail user creation if notification fails
            logger.warning("Failed to send welcome notification: %s", e)