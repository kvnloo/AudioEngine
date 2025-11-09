#!/usr/bin/env python3
"""
Inject inline Swift documentation comments into existing Jazzy HTML files.
Takes pre-built HTML from dev branch and enhances with inline doc comments.
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Optional
from bs4 import BeautifulSoup

def extract_doc_comment(lines: List[str], start_idx: int) -> Optional[str]:
    """Extract documentation comment block above a declaration."""
    doc_lines = []
    i = start_idx - 1

    # Go backwards to find start of doc comment
    while i >= 0:
        line = lines[i].strip()
        if line.startswith('///'):
            doc_lines.insert(0, line[3:].strip())
            i -= 1
        elif line == '':
            i -= 1
        else:
            break

    if doc_lines:
        return '\n'.join(doc_lines)
    return None

def parse_swift_inline_docs(swift_file: Path) -> Dict[str, str]:
    """Parse Swift file and extract inline documentation for each declaration."""
    docs = {}

    with open(swift_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        # Match class/struct/enum/protocol declarations
        if re.match(r'^\s*(class|struct|enum|protocol)\s+(\w+)', line):
            match = re.match(r'^\s*(class|struct|enum|protocol)\s+(\w+)', line)
            name = match.group(2)
            doc = extract_doc_comment(lines, i)
            if doc:
                docs[name] = doc

        # Match function/method declarations
        elif re.match(r'^\s*(func|var|let)\s+(\w+)', line):
            match = re.match(r'^\s*(func|var|let)\s+(\w+)', line)
            name = match.group(2)
            doc = extract_doc_comment(lines, i)
            if doc:
                docs[name] = doc

    return docs

def inject_docs_into_html(html_file: Path, inline_docs: Dict[str, str]):
    """Inject inline documentation into HTML file."""
    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')

    # Find all task items (methods/properties)
    task_items = soup.find_all('li', class_='item')

    injected_count = 0
    for item in task_items:
        # Get the declaration name from the anchor
        token_link = item.find('a', class_='token')
        if not token_link:
            continue

        name = token_link.get_text().strip()
        # Remove function parentheses if present
        name = re.sub(r'\(.*\)$', '', name)

        # Check if we have inline docs for this
        if name not in inline_docs:
            continue

        # Find the section tag
        section = item.find('section', class_='section')
        if not section:
            continue

        # Create inline docs div
        doc_div = soup.new_tag('div', **{'class': 'inline-documentation', 'style': 'background: #f9f9f9; padding: 10px; margin: 10px 0; border-left: 3px solid #007aff;'})
        doc_heading = soup.new_tag('p')
        doc_heading.append(soup.new_tag('strong'))
        doc_heading.strong.string = '📝 Inline Documentation:'
        doc_div.append(doc_heading)

        doc_content = soup.new_tag('p')
        doc_content.string = inline_docs[name]
        doc_div.append(doc_content)

        # Insert at beginning of section
        section.insert(0, doc_div)
        injected_count += 1

    # Write modified HTML
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(str(soup))

    return injected_count

def main():
    swift_dir = Path('Phase 1 Wireframe')
    html_dir = Path('docs/Classes')

    if not swift_dir.exists():
        print(f"Error: Swift directory not found: {swift_dir}")
        sys.exit(1)

    if not html_dir.exists():
        print(f"Error: HTML directory not found: {html_dir}")
        sys.exit(1)

    print("🔍 Extracting inline documentation from Swift files...")

    # Process each Swift file
    for swift_file in swift_dir.glob('*.swift'):
        class_name = swift_file.stem
        html_file = html_dir / f"{class_name}.html"

        if not html_file.exists():
            print(f"  ⚠️  No HTML file for {class_name}, skipping...")
            continue

        print(f"  📝 Processing {class_name}...")

        # Extract inline docs
        inline_docs = parse_swift_inline_docs(swift_file)

        if not inline_docs:
            print(f"      No inline docs found")
            continue

        print(f"      Found {len(inline_docs)} documented items")

        # Inject into HTML
        injected = inject_docs_into_html(html_file, inline_docs)
        print(f"      Injected {injected} items into HTML")

    print("✅ Documentation injection complete!")

if __name__ == '__main__':
    main()
