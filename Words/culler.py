#!/usr/bin/env python3
"""Simple utility to filter words by length from a text file.

Reads an input file line-by-line, removes any word shorter than the
specified minimum length (default 4), and writes the filtered text to
an output file.

Usage:
    python culler.py input.txt output.txt [--min-length N]

If --min-length is omitted the default of 4 is used.
"""

import argparse
import sys
from typing import Optional


def filter_file(
    input_path: str,
    output_path: str,
    min_length: int = 4,
    max_length: Optional[int] = None,
) -> None:
    """Read ``input_path`` and write to ``output_path`` filtering words
    that don't satisfy the provided length constraints.

    ``min_length`` is inclusive; ``max_length`` is exclusive if provided.
    """
    with open(input_path, "r", encoding="utf-8") as infile, \
         open(output_path, "w", encoding="utf-8") as outfile:
        for line in infile:
            words = line.strip().split()
            kept = []
            for w in words:
                lw = len(w)
                if lw < min_length:
                    continue
                if max_length is not None and lw > max_length:
                    continue
                kept.append(w)
            if kept:
                outfile.write(" ".join(kept) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Remove words shorter than a given length from a text file."
    )
    parser.add_argument("input", help="path to input text file")
    parser.add_argument("output", help="path to write filtered file")
    parser.add_argument(
        "--min-length", "-m", type=int, default=4,
        help="minimum word length to preserve (default 4)"
    )
    parser.add_argument(
        "--max-length", "-M", type=int, default=None,
        help="maximum word length to preserve (words longer than this are removed)"
    )
    args = parser.parse_args()

    try:
        filter_file(
            args.input,
            args.output,
            args.min_length,
            args.max_length,
        )
    except Exception as exc:
        sys.exit(f"error: {exc}")


if __name__ == "__main__":
    main()
