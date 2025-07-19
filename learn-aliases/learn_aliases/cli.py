#!/usr/bin/env python3
"""
learn-aliases - Interactive quiz to memorize your mac-dev-setup aliases.

Scans your ~/.mac-dev-setup-aliases file and presents an interactive quiz
to help you learn and memorize the aliases.
"""

import os
import random
import re
import readline  # noqa: F401  # history + arrow-key editing on most systems
from typing import List, Dict

# Configuration
ALIAS_FILE = os.path.expanduser("~/.mac-dev-setup-aliases")
PATTERN = re.compile(r"^\s*alias\s+([\w.\-]+)='([^']+)'(?:\s*#\s*(.*))?")

def load_aliases(path: str) -> List[Dict[str, str]]:
    """Parse the alias file and return [{alias, cmd, desc}] list."""
    items: List[Dict[str, str]] = []
    
    if not os.path.exists(path):
        print(f"Alias file not found: {path}")
        print("\nMake sure mac-dev-setup is installed and aliases are linked.")
        return []
    
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                m = PATTERN.match(line)
                if not m:
                    continue
                alias, cmd, comment = m.groups()
                desc = (comment or cmd).strip()
                items.append({"alias": alias, "cmd": cmd, "desc": desc})
    except Exception as e:
        print(f"Error reading alias file: {e}")
        return []

    return items


def quiz(items: List[Dict[str, str]]):
    """Run the interactive quiz."""
    if not items:
        print("No aliases found to quiz on.")
        return
        
    random.shuffle(items)
    score = 0
    total = len(items)

    print("\nMac Dev Setup Alias Quiz")
    print("========================")
    print(f"Total aliases to learn: {total}")
    print("Press Ctrl+C to quit at any time\n")

    try:
        for idx, item in enumerate(items, 1):
            print(f"[{idx}/{total}] {item['desc']}")
            answer = input("Alias -> ").strip()
            if answer == item["alias"]:
                print("Correct!\n")
                score += 1
            else:
                print(
                    f"Nope - the right alias is '{item['alias']}'\n"
                    f"   which runs: {item['cmd']}\n"
                )
    except KeyboardInterrupt:
        print("\n\nQuiz aborted by user.\n")

    print(f"\nYour final score: {score}/{total}")
    
    if score == total:
        print("Full score! You know all your aliases!")
    elif score >= total * 0.8:
        print("Great job! You know most of your aliases.")
    elif score >= total * 0.5:
        print("Good progress. Keep practicing!")
    else:
        print("Keep practicing - these aliases will save you time!")
    print()


def main():
    """Main entry point for the CLI."""
    aliases = load_aliases(ALIAS_FILE)
    if aliases:
        quiz(aliases)
    else:
        print("Please install mac-dev-setup first: https://github.com/nikolay-e/mac-dev-setup")


if __name__ == "__main__":
    main()