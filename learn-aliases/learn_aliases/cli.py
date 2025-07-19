#!/usr/bin/env python3
"""
learn-aliases - Interactive quiz to master your mac-dev-setup shortcuts.

Scans your ~/.mac-dev-setup-aliases file and presents an interactive quiz
to help you learn and memorize aliases and functions with categories,
progress tracking, and multiple quiz modes.
"""

import os
import random
import re
import readline  # noqa: F401  # history + arrow-key editing on most systems
import argparse
from typing import List, Dict, Set
from dataclasses import dataclass
from collections import defaultdict

# Configuration
ALIAS_FILE = os.path.expanduser("~/.mac-dev-setup-aliases")
ALIAS_PATTERN = re.compile(r"^\s*alias\s+([\w.\-]+)='([^']+)'(?:\s*#\s*(.*))?")
FUNCTION_PATTERN = re.compile(r"^([a-z][a-z_]*)\(\)\s*\{")
COMMENT_PATTERN = re.compile(r"^##\s*(.+)")

# ANSI color codes for better UI
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    YELLOW = '\033[93m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

@dataclass
class Item:
    name: str
    command: str
    description: str
    category: str
    item_type: str  # 'alias' or 'function'

def extract_category_from_comment(comment: str) -> str:
    """Extract category from section comments like '## Git' -> 'Git'"""
    if not comment:
        return "Other"

    # Common category mappings
    category_map = {
        "modern cli replacements": "CLI Tools",
        "navigation": "Navigation",
        "git": "Git",
        "kubernetes": "Kubernetes",
        "docker": "Docker",
        "terraform": "Terraform",
        "aws cli": "AWS",
        "python": "Python",
        "homebrew": "Homebrew",
        "npm": "Node.js",
        "productivity": "Productivity",
        "utilities": "Utilities",
        "kafka": "Kafka",
        "neovim": "Editor"
    }

    comment_lower = comment.lower()
    for key, value in category_map.items():
        if key in comment_lower:
            return value

    return comment.title()

def load_items(path: str) -> List[Item]:
    """Parse the alias file and return list of Items (aliases + functions)."""
    items: List[Item] = []
    current_category = "Other"

    if not os.path.exists(path):
        print(f"{Colors.RED}Alias file not found: {path}{Colors.RESET}")
        print("\nMake sure mac-dev-setup is installed and aliases are linked.")
        return []

    try:
        with open(path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        i = 0
        while i < len(lines):
            line = lines[i].strip()

            # Check for category comment
            comment_match = COMMENT_PATTERN.match(line)
            if comment_match:
                current_category = extract_category_from_comment(comment_match.group(1))
                i += 1
                continue

            # Check for alias
            alias_match = ALIAS_PATTERN.match(line)
            if alias_match:
                alias, cmd, comment = alias_match.groups()
                desc = (comment or cmd).strip()
                items.append(Item(
                    name=alias,
                    command=cmd,
                    description=desc,
                    category=current_category,
                    item_type="alias"
                ))
                i += 1
                continue

            # Check for function
            func_match = FUNCTION_PATTERN.match(line)
            if func_match:
                func_name = func_match.group(1)

                # Look for function description in comments before or after
                desc = f"Function: {func_name}"

                # Check previous lines for comments
                for j in range(max(0, i-3), i):
                    prev_line = lines[j].strip()
                    if prev_line.startswith('#') and not prev_line.startswith('##'):
                        potential_desc = prev_line.lstrip('# ').strip()
                        if len(potential_desc) > 5:  # Reasonable description length
                            desc = potential_desc
                            break

                # Try to extract a simple description from the function body
                if desc == f"Function: {func_name}":
                    for j in range(i+1, min(i+5, len(lines))):
                        body_line = lines[j].strip()
                        if body_line.startswith('echo ') and 'Usage:' in body_line:
                            desc = body_line.replace('echo "', '').replace('"', '').replace('echo ', '')
                            break
                        elif body_line.startswith('#'):
                            potential_desc = body_line.lstrip('# ').strip()
                            if len(potential_desc) > 5:
                                desc = potential_desc
                                break

                items.append(Item(
                    name=func_name,
                    command=f"{func_name}()",
                    description=desc,
                    category=current_category,
                    item_type="function"
                ))
                i += 1
                continue

            i += 1

    except Exception as e:
        print(f"{Colors.RED}Error reading alias file: {e}{Colors.RESET}")
        return []

    return items

def display_stats(items: List[Item]):
    """Display statistics about available items."""
    by_category = defaultdict(list)
    by_type = defaultdict(int)

    for item in items:
        by_category[item.category].append(item)
        by_type[item.item_type] += 1

    print(f"\n{Colors.BOLD}{Colors.CYAN}📊 Available Items{Colors.RESET}")
    print("=" * 50)
    print(f"Total: {Colors.BOLD}{len(items)}{Colors.RESET} items")
    print(f"  • {Colors.GREEN}{by_type['alias']}{Colors.RESET} aliases")
    print(f"  • {Colors.BLUE}{by_type['function']}{Colors.RESET} functions")

    print(f"\n{Colors.BOLD}By Category:{Colors.RESET}")
    for category, category_items in sorted(by_category.items()):
        aliases = sum(1 for item in category_items if item.item_type == 'alias')
        functions = sum(1 for item in category_items if item.item_type == 'function')
        print(f"  {Colors.YELLOW}{category:<15}{Colors.RESET} {aliases:>2} aliases, {functions:>2} functions")

def quiz_all(items: List[Item]):
    """Run quiz on all items."""
    if not items:
        print(f"{Colors.RED}No items found to quiz on.{Colors.RESET}")
        return

    random.shuffle(items)
    run_quiz(items, "All Items")

def quiz_by_category(items: List[Item]):
    """Let user choose a category to quiz on."""
    by_category = defaultdict(list)
    for item in items:
        by_category[item.category].append(item)

    print(f"\n{Colors.BOLD}{Colors.CYAN}📚 Select Category{Colors.RESET}")
    print("=" * 30)
    categories = sorted(by_category.keys())

    for i, category in enumerate(categories, 1):
        count = len(by_category[category])
        print(f"{i:>2}. {Colors.YELLOW}{category:<15}{Colors.RESET} ({count} items)")

    try:
        choice = input(f"\n{Colors.BOLD}Choose category (1-{len(categories)}): {Colors.RESET}").strip()
        idx = int(choice) - 1
        if 0 <= idx < len(categories):
            selected_category = categories[idx]
            category_items = by_category[selected_category]
            random.shuffle(category_items)
            run_quiz(category_items, f"{selected_category} Category")
        else:
            print(f"{Colors.RED}Invalid choice!{Colors.RESET}")
    except (ValueError, KeyboardInterrupt):
        print(f"\n{Colors.YELLOW}Cancelled.{Colors.RESET}")

def quiz_by_type(items: List[Item]):
    """Quiz by item type (aliases vs functions)."""
    print(f"\n{Colors.BOLD}{Colors.CYAN}🎯 Select Type{Colors.RESET}")
    print("=" * 25)
    print(f"1. {Colors.GREEN}Aliases only{Colors.RESET}")
    print(f"2. {Colors.BLUE}Functions only{Colors.RESET}")

    try:
        choice = input(f"\n{Colors.BOLD}Choose type (1-2): {Colors.RESET}").strip()
        if choice == "1":
            alias_items = [item for item in items if item.item_type == 'alias']
            random.shuffle(alias_items)
            run_quiz(alias_items, "Aliases Only")
        elif choice == "2":
            func_items = [item for item in items if item.item_type == 'function']
            random.shuffle(func_items)
            run_quiz(func_items, "Functions Only")
        else:
            print(f"{Colors.RED}Invalid choice!{Colors.RESET}")
    except (ValueError, KeyboardInterrupt):
        print(f"\n{Colors.YELLOW}Cancelled.{Colors.RESET}")

def run_quiz(items: List[Item], quiz_name: str):
    """Run the interactive quiz."""
    score = 0
    total = len(items)

    print(f"\n{Colors.BOLD}{Colors.MAGENTA}🎓 {quiz_name} Quiz{Colors.RESET}")
    print("=" * (len(quiz_name) + 10))
    print(f"Total items: {Colors.BOLD}{total}{Colors.RESET}")
    print(f"{Colors.CYAN}Press Ctrl+C to quit at any time{Colors.RESET}\n")

    try:
        for idx, item in enumerate(items, 1):
            # Display item info
            type_color = Colors.GREEN if item.item_type == 'alias' else Colors.BLUE
            type_symbol = "📎" if item.item_type == 'alias' else "⚙️"

            print(f"{Colors.BOLD}[{idx}/{total}]{Colors.RESET} "
                  f"{type_symbol} {Colors.YELLOW}{item.category}{Colors.RESET}")
            print(f"   {item.description}")

            answer = input(f"   {Colors.BOLD}Enter command: {Colors.RESET}").strip()

            if answer == item.name:
                print(f"   {Colors.GREEN}✅ Correct!{Colors.RESET}\n")
                score += 1
            else:
                print(f"   {Colors.RED}❌ Incorrect{Colors.RESET}")
                print(f"   {Colors.BOLD}Answer:{Colors.RESET} {Colors.CYAN}{item.name}{Colors.RESET}")
                print(f"   {Colors.BOLD}Runs:{Colors.RESET} {item.command}\n")

    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Quiz interrupted by user.{Colors.RESET}\n")

    # Show final score with colors
    percentage = (score / total * 100) if total > 0 else 0
    print(f"\n{Colors.BOLD}{Colors.CYAN}🏆 Final Score{Colors.RESET}")
    print("=" * 20)
    print(f"Score: {Colors.BOLD}{score}/{total}{Colors.RESET} ({percentage:.1f}%)")

    if score == total:
        print(f"{Colors.GREEN}🎉 Perfect! You know all the {quiz_name.lower()}!{Colors.RESET}")
    elif percentage >= 80:
        print(f"{Colors.GREEN}🌟 Excellent! You know most of the {quiz_name.lower()}.{Colors.RESET}")
    elif percentage >= 60:
        print(f"{Colors.YELLOW}👍 Good progress! Keep practicing.{Colors.RESET}")
    elif percentage >= 40:
        print(f"{Colors.YELLOW}📚 Getting there! These shortcuts will save you time.{Colors.RESET}")
    else:
        print(f"{Colors.RED}📖 Keep practicing - these tools boost productivity!{Colors.RESET}")
    print()

def show_main_menu(items: List[Item]):
    """Show interactive main menu."""
    while True:
        print(f"\n{Colors.BOLD}{Colors.CYAN}🚀 Mac Dev Setup - Learn Shortcuts{Colors.RESET}")
        print("=" * 40)
        print(f"1. {Colors.GREEN}📊 Show Statistics{Colors.RESET}")
        print(f"2. {Colors.MAGENTA}🎯 Quiz All Items{Colors.RESET}")
        print(f"3. {Colors.YELLOW}📚 Quiz by Category{Colors.RESET}")
        print(f"4. {Colors.BLUE}🎭 Quiz by Type{Colors.RESET}")
        print(f"5. {Colors.RED}🚪 Exit{Colors.RESET}")

        try:
            choice = input(f"\n{Colors.BOLD}Choose option (1-5): {Colors.RESET}").strip()

            if choice == "1":
                display_stats(items)
            elif choice == "2":
                quiz_all(items)
            elif choice == "3":
                quiz_by_category(items)
            elif choice == "4":
                quiz_by_type(items)
            elif choice == "5":
                print(f"{Colors.CYAN}Happy coding! 🎉{Colors.RESET}")
                break
            else:
                print(f"{Colors.RED}Invalid choice! Please enter 1-5.{Colors.RESET}")

        except (KeyboardInterrupt, EOFError):
            print(f"\n{Colors.CYAN}Goodbye! 👋{Colors.RESET}")
            break

def main():
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description="Interactive quiz to master mac-dev-setup shortcuts",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  learn-aliases              # Interactive menu
  learn-aliases --stats      # Show statistics only
  learn-aliases --quick      # Quick quiz (all items)
        """
    )
    parser.add_argument("--stats", action="store_true", help="Show statistics and exit")
    parser.add_argument("--quick", action="store_true", help="Start quick quiz immediately")
    parser.add_argument("--no-color", action="store_true", help="Disable colored output")

    args = parser.parse_args()

    if args.no_color:
        # Disable all colors
        for attr in dir(Colors):
            if not attr.startswith('_'):
                setattr(Colors, attr, '')

    items = load_items(ALIAS_FILE)
    if not items:
        print(f"{Colors.RED}Please install mac-dev-setup first: https://github.com/nikolay-e/mac-dev-setup{Colors.RESET}")
        return

    if args.stats:
        display_stats(items)
    elif args.quick:
        quiz_all(items)
    else:
        show_main_menu(items)

if __name__ == "__main__":
    main()
