#!/usr/bin/env python3
"""
Merge SourceKitten structure and doc data to create complete Jazzy JSON.

This script:
1. Takes SourceKitten structure output (with offsets/lengths)
2. Takes SourceKitten doc output (with documentation)
3. Extracts declaration source code using offsets
4. Adds syntax highlighting
5. Outputs enhanced JSON for Jazzy consumption
"""

import json
import sys
import argparse
import re
from typing import Dict, List, Any


def extract_declaration(source_code: str, offset: int, length: int) -> str:
    """Extract declaration source code using byte offset and length."""
    # Convert to bytes for accurate offset handling
    source_bytes = source_code.encode('utf-8')
    decl_bytes = source_bytes[offset:offset + length]
    return decl_bytes.decode('utf-8', errors='ignore')


def highlight_swift(code: str) -> str:
    """
    Apply basic Swift syntax highlighting.
    Returns HTML with <span> tags for syntax highlighting.
    """
    # Escape HTML
    code = code.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

    # Swift keywords
    keywords = [
        'class', 'struct', 'enum', 'protocol', 'extension', 'func', 'var', 'let',
        'if', 'else', 'for', 'while', 'return', 'import', 'public', 'private',
        'internal', 'fileprivate', 'static', 'final', 'override', 'init', 'deinit',
        'self', 'super', 'true', 'false', 'nil', 'as', 'is', 'switch', 'case',
        'default', 'break', 'continue', 'guard', 'defer', 'do', 'try', 'catch',
        'throw', 'throws', 'rethrows', 'async', 'await', 'mutating', 'nonmutating',
        'convenience', 'required', 'lazy', 'weak', 'unowned', 'indirect'
    ]

    # Highlight keywords (word boundaries)
    for kw in keywords:
        code = re.sub(
            r'\b' + kw + r'\b',
            f'<span class="kd">{kw}</span>',
            code
        )

    # Highlight strings
    code = re.sub(
        r'"([^"\\]|\\.)*"',
        lambda m: f'<span class="s">{m.group(0)}</span>',
        code
    )

    # Highlight comments
    code = re.sub(
        r'//.*$',
        lambda m: f'<span class="c1">{m.group(0)}</span>',
        code,
        flags=re.MULTILINE
    )

    # Highlight numbers
    code = re.sub(
        r'\b\d+\.?\d*\b',
        lambda m: f'<span class="m">{m.group(0)}</span>',
        code
    )

    return f'<pre class="highlight swift"><code>{code}</code></pre>'


def merge_structure_and_docs(
    structure: Dict[str, Any],
    docs: List[Dict[str, Any]],
    source_code: str
) -> List[Dict[str, Any]]:
    """
    Merge structure data (with offsets) and doc data.
    Add declaration source code extracted from offsets.
    """
    # Create lookup by USR for matching
    structure_map = {}

    def build_structure_map(item: Dict[str, Any]):
        """Recursively build map of USR -> structure item."""
        if 'key.usr' in item:
            structure_map[item['key.usr']] = item
        if 'key.substructure' in item:
            for sub in item['key.substructure']:
                build_structure_map(sub)

    # Build structure map
    if isinstance(structure, list):
        for item in structure:
            build_structure_map(item)
    else:
        build_structure_map(structure)

    # Enhance docs with declaration source code
    result = []

    for doc_item in docs:
        # Try to match with structure by USR
        usr = doc_item.get('key.usr')
        struct_item = structure_map.get(usr) if usr else None

        # Get offset and length from structure or doc
        offset = None
        length = None

        if struct_item:
            offset = struct_item.get('key.offset')
            length = struct_item.get('key.length')
        elif 'key.offset' in doc_item and 'key.length' in doc_item:
            offset = doc_item['key.offset']
            length = doc_item['key.length']

        # Extract and add declaration if we have offset/length
        if offset is not None and length is not None:
            try:
                decl_code = extract_declaration(source_code, offset, length)

                # Add both raw and highlighted declarations
                doc_item['key.parsed_declaration'] = decl_code
                doc_item['key.annotated_decl'] = highlight_swift(decl_code)

                # Also add Swift declaration specifically
                doc_item['key.swift_declaration'] = decl_code

            except Exception as e:
                print(f"Warning: Failed to extract declaration at offset {offset}: {e}", file=sys.stderr)

        result.append(doc_item)

    return result


def main():
    parser = argparse.ArgumentParser(
        description='Merge SourceKitten structure and doc data for Jazzy'
    )
    parser.add_argument('--structure', required=True, help='SourceKitten structure JSON')
    parser.add_argument('--docs', required=True, help='SourceKitten doc JSON')
    parser.add_argument('--source', required=True, help='Swift source code')
    parser.add_argument('--output', required=True, help='Output JSON file')

    args = parser.parse_args()

    try:
        # Parse inputs with validation
        structure = json.loads(args.structure)
        docs = json.loads(args.docs)

        # Validate and normalize types
        if not isinstance(structure, (dict, list)):
            print(f"Warning: Invalid structure type {type(structure)}, using empty dict", file=sys.stderr)
            structure = {}

        # SourceKitten doc returns dict for single file, list for multiple
        if isinstance(docs, dict):
            # Wrap single dict in list
            docs = [docs] if docs else []
        elif not isinstance(docs, list):
            print(f"Warning: Invalid docs type {type(docs)}, using empty list", file=sys.stderr)
            docs = []

        # Merge data
        merged = merge_structure_and_docs(structure, docs, args.source)

        # Write output
        with open(args.output, 'w') as f:
            json.dump(merged, f, indent=2)

        print(f"✅ Successfully merged data for {len(merged)} items", file=sys.stderr)

    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
