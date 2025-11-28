#!/usr/bin/env python3
"""Command-line interface for the application.

This script provides a CLI for [description of what it does].

Usage:
    python cli_script.py --input data.json --output results.json
    python cli_script.py -v process --file input.txt

Example:
    $ python cli_script.py --help
    $ python cli_script.py process --input data.json
"""
from __future__ import annotations

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class ApplicationError(Exception):
    """Base exception for application errors."""

    pass


class InputError(ApplicationError):
    """Raised when input is invalid."""

    pass


def setup_logging(verbose: bool) -> None:
    """Configure logging based on verbosity setting.

    Args:
        verbose: If True, set logging to DEBUG level.
    """
    level = logging.DEBUG if verbose else logging.INFO
    logging.getLogger().setLevel(level)


def load_json_file(path: Path) -> dict[str, Any]:
    """Load and parse a JSON file.

    Args:
        path: Path to the JSON file.

    Returns:
        Parsed JSON data.

    Raises:
        InputError: If file cannot be read or parsed.
    """
    try:
        with path.open() as f:
            return json.load(f)
    except FileNotFoundError:
        raise InputError(f"File not found: {path}")
    except json.JSONDecodeError as e:
        raise InputError(f"Invalid JSON in {path}: {e}")


def save_json_file(path: Path, data: dict[str, Any]) -> None:
    """Save data to a JSON file.

    Args:
        path: Output file path.
        data: Data to save.
    """
    with path.open("w") as f:
        json.dump(data, f, indent=2)
    logger.info("Saved output to %s", path)


def process_data(data: dict[str, Any]) -> dict[str, Any]:
    """Process the input data.

    Args:
        data: Input data to process.

    Returns:
        Processed data.
    """
    # Implement your processing logic here
    result = {
        "status": "processed",
        "input_keys": list(data.keys()),
        "item_count": len(data),
    }
    return result


def create_parser() -> argparse.ArgumentParser:
    """Create and configure the argument parser.

    Returns:
        Configured ArgumentParser instance.
    """
    parser = argparse.ArgumentParser(
        description="Process data files and generate results.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --input data.json --output results.json
  %(prog)s -v --input data.json
  %(prog)s --dry-run --input data.json
        """,
    )

    # Global options
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose output",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )

    # Input/output options
    parser.add_argument(
        "-i", "--input",
        type=Path,
        required=True,
        help="Input JSON file path",
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        default=None,
        help="Output JSON file path (default: stdout)",
    )

    # Processing options
    parser.add_argument(
        "--format",
        choices=["json", "text", "csv"],
        default="json",
        help="Output format (default: json)",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    """Main entry point for the CLI.

    Args:
        argv: Command-line arguments (defaults to sys.argv[1:]).

    Returns:
        Exit code (0 for success, non-zero for errors).
    """
    parser = create_parser()
    args = parser.parse_args(argv)

    setup_logging(args.verbose)
    logger.debug("Arguments: %s", args)

    try:
        # Load input
        logger.info("Loading input from %s", args.input)
        data = load_json_file(args.input)

        # Process data
        if args.dry_run:
            logger.info("Dry run - would process %d items", len(data))
            return 0

        result = process_data(data)

        # Output results
        if args.output:
            save_json_file(args.output, result)
        else:
            print(json.dumps(result, indent=2))

        return 0

    except InputError as e:
        logger.error("Input error: %s", e)
        return 1
    except ApplicationError as e:
        logger.error("Application error: %s", e)
        return 2
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
        return 130
    except Exception as e:
        logger.exception("Unexpected error: %s", e)
        return 1


if __name__ == "__main__":
    sys.exit(main())