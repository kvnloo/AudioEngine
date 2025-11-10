#!/usr/bin/env python3
"""
Replace 'Undocumented' placeholders in HTML with inline documentation from Swift files.
This script directly modifies the HTML files to replace the text.
"""

import re
from pathlib import Path
from typing import Dict, List, Optional
from bs4 import BeautifulSoup

def extract_doc_comment(lines: List[str], start_idx: int) -> Optional[str]:
    """Extract documentation comment block above a declaration (both /// and /** */ styles)."""
    doc_lines = []
    i = start_idx - 1
    in_block_comment = False

    # Go backwards to find start of doc comment
    while i >= 0:
        line = lines[i].strip()

        # Handle /** */ block comments
        if line.endswith('*/'):
            in_block_comment = True
            # Extract content before */
            content = line[:-2].strip()
            if content and content != '/**':
                doc_lines.insert(0, content)
            i -= 1
            continue
        elif in_block_comment:
            if line.startswith('/**'):
                # Found start of block comment
                content = line[3:].strip()
                if content:
                    doc_lines.insert(0, content)
                break
            else:
                # Middle of block comment
                content = line.lstrip('*').strip()
                if content:
                    doc_lines.insert(0, content)
                i -= 1
                continue
        # Handle /// inline comments
        elif line.startswith('///'):
            doc_lines.insert(0, line[3:].strip())
            i -= 1
        elif line == '':
            i -= 1
        # Skip Swift decorators (@UIApplicationMain, @IBOutlet, @objc, etc.)
        elif line.startswith('@'):
            i -= 1
        else:
            break

    if doc_lines:
        return ' '.join(doc_lines)
    return None

def parse_swift_inline_docs(swift_file: Path) -> Dict[str, str]:
    """Parse Swift file and extract inline documentation for each declaration."""
    docs = {}

    with open(swift_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        # Match class/struct/enum/protocol/extension declarations
        if re.match(r'^\s*(public\s+)?(class|struct|enum|protocol|extension)\s+(\w+)', line):
            match = re.match(r'^\s*(public\s+)?(class|struct|enum|protocol|extension)\s+(\w+)', line)
            name = match.group(3)  # group 3 because group 1 is optional 'public', group 2 is type
            doc = extract_doc_comment(lines, i)
            if doc:
                docs[name] = doc

        # Match init() methods (including private init)
        elif re.match(r'^\s*(private\s+)?init\s*\(', line):
            doc = extract_doc_comment(lines, i)
            if doc:
                docs['init'] = doc

        # Match @IBOutlet properties
        elif re.match(r'^\s*@IBOutlet\s+weak\s+var\s+(\w+)', line):
            match = re.match(r'^\s*@IBOutlet\s+weak\s+var\s+(\w+)', line)
            name = match.group(1)
            doc = extract_doc_comment(lines, i)
            if doc:
                docs[name] = doc

        # Match function/method declarations (including public/private/internal)
        elif re.match(r'^\s*(public\s+|private\s+|internal\s+)?func\s+(\w+)', line):
            match = re.match(r'^\s*(public\s+|private\s+|internal\s+)?func\s+(\w+)', line)
            name = match.group(2)  # group 2 because group 1 is optional access modifier
            doc = extract_doc_comment(lines, i)
            if doc:
                docs[name] = doc

        # Match regular var/let properties (including static)
        elif re.match(r'^\s*(static\s+)?(var|let)\s+(\w+)', line):
            match = re.match(r'^\s*(static\s+)?(var|let)\s+(\w+)', line)
            name = match.group(3)  # group 3 because group 1 is optional static, group 2 is var/let
            doc = extract_doc_comment(lines, i)
            if doc:
                docs[name] = doc

    return docs

def convert_backticks_to_code(text: str, soup) -> list:
    """Convert markdown-style backticks to HTML <code> tags.
    Returns a list of strings and BeautifulSoup tags to append to a paragraph."""
    parts = []
    current_text = ""
    in_code = False
    i = 0

    while i < len(text):
        if text[i] == '`':
            if current_text:
                parts.append(current_text)
                current_text = ""
            in_code = not in_code
            if not in_code and i + 1 < len(text):
                # Just closed a code block, create the tag
                pass
        else:
            if in_code:
                # Look ahead to find the closing backtick
                end = text.find('`', i)
                if end != -1:
                    code_content = text[i:end]
                    code_tag = soup.new_tag('code')
                    code_tag.string = code_content
                    parts.append(code_tag)
                    i = end  # Will be incremented at loop end
                    in_code = False
                else:
                    current_text += text[i]
            else:
                current_text += text[i]
        i += 1

    if current_text:
        parts.append(current_text)

    return parts

def replace_undocumented_in_html(html_file: Path, inline_docs: Dict[str, str]):
    """Replace 'Undocumented' text in HTML with inline documentation."""
    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')

    replaced_count = 0

    # First, handle class-level documentation (h1 + p directly under section-content)
    for section in soup.find_all('section', class_='section'):
        section_content = section.find('div', class_='section-content')
        if section_content:
            h1 = section_content.find('h1')
            if h1:
                class_name = h1.get_text().strip()
                # Find the <p>Undocumented</p> that's a direct child
                p_tag = section_content.find('p', string='Undocumented')
                if p_tag and class_name in inline_docs:
                    # Clear the paragraph and add formatted content
                    p_tag.clear()
                    doc_text = inline_docs[class_name]
                    # Convert backticks to <code> tags
                    parts = convert_backticks_to_code(doc_text, soup)
                    for part in parts:
                        p_tag.append(part)
                    replaced_count += 1

    # Then handle method/property level documentation
    task_items = soup.find_all('li', class_='item')

    for item in task_items:
        # Get the declaration name from the anchor
        token_link = item.find('a', class_='token')
        if not token_link:
            continue

        name = token_link.get_text().strip()
        original_name = name

        # Remove Swift parameter syntax like (_:) or (_:didSignInFor:withError:)
        name = re.sub(r'\(.*\)$', '', name)

        # Try exact match first
        doc = None
        if name in inline_docs:
            doc = inline_docs[name]
        # For methods with parameters, try base name
        elif '(' in original_name:
            # Extract just the base function name before first parenthesis
            base_name = original_name.split('(')[0]
            if base_name in inline_docs:
                doc = inline_docs[base_name]

        # If still no match, try partial matching for delegate methods
        if not doc:
            for key, value in inline_docs.items():
                if name.startswith(key) or key in name:
                    doc = value
                    break

        if not doc:
            continue

        # Find the abstract section with "Undocumented"
        abstract = item.find('div', class_='abstract')
        if not abstract:
            continue

        # Find the <p>Undocumented</p> tag
        undoc_p = abstract.find('p')
        if undoc_p and undoc_p.get_text().strip() == 'Undocumented':
            # Clear the paragraph and add formatted content
            undoc_p.clear()
            # Convert backticks to <code> tags
            parts = convert_backticks_to_code(doc, soup)
            for part in parts:
                undoc_p.append(part)
            replaced_count += 1

    # Dictionary mapping class/extension names to their declarations (syntax-highlighted HTML code)
    declarations_to_inject = {
        'AppDelegate': '<span class="kd">class</span> <span class="kt">AppDelegate</span><span class="p">:</span> <span class="kt">UIResponder</span><span class="p">,</span> <span class="kt">UIApplicationDelegate</span>',
        'User': '<span class="kd">class</span> <span class="kt">User</span><span class="p">:</span> <span class="kt">NSObject</span>',
        'UIColor': '<span class="kd">public</span> <span class="kd">extension</span> <span class="kt">UIColor</span>',
        'UIFont': '<span class="kd">extension</span> <span class="kt">UIFont</span>',
        'UINavigationBar': '<span class="kd">extension</span> <span class="kt">UINavigationBar</span>'
    }

    # Inject missing declarations for classes/extensions
    for class_name, declaration_code in declarations_to_inject.items():
        if class_name in str(html_file):
            # Find the h1 heading
            h1 = soup.find('h1', string=class_name)
            if h1:
                # Check if declaration already exists
                parent_section = h1.find_parent('section')
                if parent_section and not parent_section.find('div', class_='declaration'):
                    # Create declaration div to insert BEFORE the description
                    declaration_html = f'''<div class="declaration">
<div class="language">
<pre class="highlight"><code>{declaration_code}</code></pre>
</div>
</div>
'''
                    # Find the description paragraph and insert declaration before it
                    section_content = parent_section.find('div', class_='section-content')
                    if section_content:
                        description_p = section_content.find('p')
                        if description_p:
                            # Parse the declaration HTML and insert before description
                            from bs4 import BeautifulSoup as BS
                            decl_soup = BS(declaration_html, 'html.parser')
                            description_p.insert_before(decl_soup)

    # Special handling for UIColor - add color palette image and fix links
    if 'UIColor' in str(html_file):
        section_content = soup.find('div', class_='section-content')
        if section_content:
            # Fix Swift filename mentions to link to proper classes
            for p in section_content.find_all('p'):
                if p.string and 'GeneralUIColor.swift' in p.string:
                    # Replace plain text mentions with proper structure
                    new_content = p.string.replace(
                        '`GeneralUIColor.swift` is an extension on the UIColor class',
                        'This extension on the <code>UIColor</code> class'
                    )
                    p.string = new_content

                # Add color palette image after the main description
                if 'color palette generated for this application' in (p.string or ''):
                    # Create image element to insert after this paragraph
                    img_html = '''<p><img src="../assets/images/color-palette.png" alt="Color Palette" /></p>'''
                    from bs4 import BeautifulSoup as BS
                    img_soup = BS(img_html, 'html.parser')
                    p.insert_after(img_soup)

            # Fix SeeAlso references to link to actual classes
            for p in section_content.find_all('p'):
                if p.string and 'SeeAlso' in p.string:
                    text = p.string
                    # Convert backtick class names to proper links
                    classes_to_link = [
                        ('GeneralUIButton', '../Classes/GeneralUIButton.html'),
                        ('GeneralUILabel', '../Classes/GeneralUILabel.html'),
                        ('GeneralUITextField', '../Classes/GeneralUITextField.html'),
                        ('GeneralUIViewController', '../Classes/GeneralUIViewController.html')
                    ]

                    # Build new content with links
                    p.clear()
                    p.append('SeeAlso: ')
                    for i, (class_name, link) in enumerate(classes_to_link):
                        if i > 0:
                            p.append(', ')
                        a = soup.new_tag('a', href=link)
                        code = soup.new_tag('code')
                        code.string = class_name
                        a.append(code)
                        p.append(a)
                    p.append(' for UI components using this palette')

    # Special handling for UIFont - fix links to referenced classes
    if 'UIFont' in str(html_file):
        section_content = soup.find('div', class_='section-content')
        if section_content:
            # Fix Swift filename mentions and class references
            for p in section_content.find_all('p'):
                if p.string and 'GeneralUIFont.swift' in p.string:
                    # Convert to proper links
                    p.clear()
                    p.append('This extension on the ')
                    code = soup.new_tag('code')
                    code.string = 'UIFont'
                    p.append(code)
                    p.append(' class defines different fonts to use in specific scenarios. This ensures consistency among ')

                    # Add linked references
                    classes = [
                        ('GeneralUILabel', '../Classes/GeneralUILabel.html'),
                        ('GeneralUITextField', '../Classes/GeneralUITextField.html')
                    ]
                    for i, (class_name, link) in enumerate(classes):
                        if i > 0:
                            p.append(' objects, ')
                        a = soup.new_tag('a', href=link)
                        code = soup.new_tag('code')
                        code.string = class_name
                        a.append(code)
                        p.append(a)
                    p.append(' objects, and ')
                    code = soup.new_tag('code')
                    code.string = 'UIButton'
                    p.append(code)
                    p.append(' objects.')

    # Special handling for UINavigationBar - fix links to referenced classes
    if 'UINavigationBar' in str(html_file):
        section_content = soup.find('div', class_='section-content')
        if section_content:
            # Find the "Undocumented" paragraph and replace it
            p_tag = section_content.find('p', string='Undocumented')
            if p_tag:
                # Replace with proper documentation
                p_tag.clear()
                p_tag.append('Extension created to allow the developer to modify the \'bottom border\' of the ')

                code = soup.new_tag('code')
                code.string = 'UINavigationBar'
                p_tag.append(code)
                p_tag.append('. This allows for the white highlight under the ')
                code2 = soup.new_tag('code')
                code2.string = 'UINavigationBar'
                p_tag.append(code2)
                p_tag.append('.')

                replaced += 1

            # Also check for paragraphs with 'GeneralUINavigationBar' text
            for p in section_content.find_all('p'):
                if p.string and 'GeneralUINavigationBar' in p.string:
                    # Convert to proper links
                    p.clear()
                    p.append('Extension created to allow the developer to modify the \'bottom border\' of the ')

                    code = soup.new_tag('code')
                    code.string = 'UINavigationBar'
                    p.append(code)
                    p.append('. This allows for the white highlight under the ')
                    code2 = soup.new_tag('code')
                    code2.string = 'UINavigationBar'
                    p.append(code2)
                    p.append('.')

    # Special handling for AppDelegate class - fix formatting and structure
    if 'AppDelegate' in str(html_file):
        section_content = soup.find('div', class_='section-content')
        if section_content:
            # Find the main class description paragraph
            for p in section_content.find_all('p', recursive=False):
                text_content = p.get_text()

                # Check if this is the AppDelegate class description
                if 'This file handles special UIApplication states' in text_content:
                    # Parse and rebuild with proper structure
                    p.clear()

                    # Main description
                    p_main = soup.new_tag('p')
                    p_main.string = 'This file handles special UIApplication states including the following:'

                    # Handled states list
                    ul_states = soup.new_tag('ul')

                    li_launch = soup.new_tag('li')
                    strong_launch = soup.new_tag('strong')
                    strong_launch.string = 'applicationDidFinishLaunching:'
                    li_launch.append(strong_launch)
                    li_launch.append(' - handles on-startup configuration and construction')
                    ul_states.append(li_launch)

                    li_terminate = soup.new_tag('li')
                    strong_terminate = soup.new_tag('strong')
                    strong_terminate.string = 'applicationWillTerminate:'
                    li_terminate.append(strong_terminate)
                    li_terminate.append(' - handles clean up at the end, when the application terminates')
                    ul_states.append(li_terminate)

                    # Warning paragraph
                    p_warning = soup.new_tag('p')
                    p_warning.string = 'Extraneous functionality should NOT be placed in the AppDelegate since they don\'t really belong there. This includes the following:'

                    # What NOT to include list
                    ul_exclude = soup.new_tag('ul')

                    li_doc = soup.new_tag('li')
                    strong_doc = soup.new_tag('strong')
                    strong_doc.string = 'Document data'
                    li_doc.append(strong_doc)
                    li_doc.append(' -- this should be placed in a document manager singleton')
                    ul_exclude.append(li_doc)

                    li_ui = soup.new_tag('li')
                    strong_ui = soup.new_tag('strong')
                    strong_ui.string = 'Button/table/view controllers, view delegate methods or other view handling'
                    li_ui.append(strong_ui)
                    li_ui.append(' (top-level view in applicationDidFinishLaunching: is still allowed) -- this work should be in respective view controller classes.')
                    ul_exclude.append(li_ui)

                    # Insert all elements
                    p.insert_after(ul_exclude)
                    ul_exclude.insert_before(p_warning)
                    p_warning.insert_before(ul_states)
                    ul_states.insert_before(p_main)

                    # Remove the now-empty original paragraph
                    p.decompose()

    # Special handling for User class - fix formatting and APIManager reference to link
    if 'User' in str(html_file):
        section_content = soup.find('div', class_='section-content')
        if section_content:
            # Find the main class description paragraph
            for p in section_content.find_all('p', recursive=False):
                text_content = p.get_text()

                # Check if this is the User class description (contains "Authentication Methods")
                if 'Authentication Methods' in text_content:
                    # Parse and rebuild the entire description with proper structure
                    p.clear()

                    # Main description
                    p_main = soup.new_tag('p')
                    p_main.string = ('Represents a user account within the JubiAudio application with authentication '
                                   'and data storage capabilities. The User model supports multiple authentication methods '
                                   'and stores audio equalizer settings for persistence across sessions. User data is '
                                   'synchronized with Firebase Realtime Database to provide cross-device consistency.')

                    # Authentication Methods section
                    p_auth_header = soup.new_tag('p')
                    strong_auth = soup.new_tag('strong')
                    strong_auth.string = 'Authentication Methods:'
                    p_auth_header.append(strong_auth)

                    ul_auth = soup.new_tag('ul')

                    li_email = soup.new_tag('li')
                    strong_email = soup.new_tag('strong')
                    strong_email.string = 'Email/Password'
                    li_email.append(strong_email)
                    li_email.append(': Traditional Firebase authentication with username and password')
                    ul_auth.append(li_email)

                    li_oauth = soup.new_tag('li')
                    strong_oauth = soup.new_tag('strong')
                    strong_oauth.string = 'Social OAuth'
                    li_oauth.append(strong_oauth)
                    li_oauth.append(': Facebook and Google Sign-In via access tokens')
                    ul_auth.append(li_oauth)

                    # Data Storage section
                    p_storage_header = soup.new_tag('p')
                    strong_storage = soup.new_tag('strong')
                    strong_storage.string = 'Data Storage:'
                    p_storage_header.append(strong_storage)

                    p_storage = soup.new_tag('p')
                    p_storage.string = ('User equalizer settings (28 float values representing 14-band dual-channel EQ) '
                                      'are stored in the data property and persisted to Firebase using a hash of the user\'s '
                                      'email as the key.')

                    # Notes section (as a list)
                    ul_notes = soup.new_tag('ul')

                    li_note1 = soup.new_tag('li')
                    strong_note = soup.new_tag('strong')
                    strong_note.string = 'Note'
                    li_note1.append(strong_note)
                    li_note1.append(': At least one authentication method must be used (uid/pw OR token)')
                    ul_notes.append(li_note1)

                    li_note2 = soup.new_tag('li')
                    strong_important = soup.new_tag('strong')
                    strong_important.string = 'Important'
                    li_note2.append(strong_important)
                    li_note2.append(': The data array contains 28 float values: 14 bands × 2 channels (left/right)')
                    ul_notes.append(li_note2)

                    li_seealso = soup.new_tag('li')
                    strong_seealso = soup.new_tag('strong')
                    strong_seealso.string = 'SeeAlso'
                    li_seealso.append(strong_seealso)
                    li_seealso.append(': ')
                    a_api = soup.new_tag('a', href='APIManager.html')
                    code_api = soup.new_tag('code')
                    code_api.string = 'APIManager'
                    a_api.append(code_api)
                    li_seealso.append(a_api)
                    li_seealso.append(' for authentication flow and data synchronization')
                    ul_notes.append(li_seealso)

                    # Insert all elements after the original paragraph
                    p.insert_after(ul_notes)
                    ul_notes.insert_before(p_storage)
                    p_storage.insert_before(p_storage_header)
                    p_storage_header.insert_before(ul_auth)
                    ul_auth.insert_before(p_auth_header)
                    p_auth_header.insert_before(p_main)

                    # Remove the now-empty original paragraph
                    p.decompose()

    # Remove all TODO comments from the HTML (in both <p> and <pre>/<code> tags)
    for element in soup.find_all(['p', 'pre', 'code']):
        text = element.get_text()

        # If entire element is just a TODO, remove the whole element
        if text.strip().startswith('TODO:'):
            print(f"      Removing TODO {element.name}: {text[:80]}...")
            element.decompose()
        # If TODO is embedded in the element, just remove the TODO part
        elif 'TODO:' in text or '// TODO:' in text:
            # Remove TODO portions (both "TODO:" and "// TODO:" formats)
            # Match: optional whitespace + optional // + TODO: + everything until end of line or period
            cleaned_text = re.sub(r'\s*//?\s*TODO:.*?(?=\.|$)', '', text)

            # If we removed something meaningful, update the element
            if cleaned_text.strip() and cleaned_text != text:
                print(f"      Cleaning TODO from {element.name}: {text[:80]}...")
                print(f"      Result: {cleaned_text[:80]}...")
                element.string = cleaned_text.strip()
            # If nothing meaningful left after removing TODO, remove whole element
            elif not cleaned_text.strip():
                print(f"      Removing empty TODO {element.name}: {text[:80]}...")
                element.decompose()

    # Write modified HTML
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(str(soup))

    return replaced_count

def convert_markdown_to_html(markdown_content: str) -> str:
    """Convert markdown content to HTML suitable for insertion into docs."""
    lines = markdown_content.split('\n')
    html_lines = []
    in_code_block = False
    in_list = False

    for line in lines:
        # Handle code blocks
        if line.strip().startswith('```'):
            if in_code_block:
                html_lines.append('</code></pre>')
                in_code_block = False
            else:
                html_lines.append('<pre><code>')
                in_code_block = True
            continue

        if in_code_block:
            html_lines.append(line)
            continue

        # Handle headers
        if line.startswith('# '):
            html_lines.append(f'<h1>{line[2:]}</h1>')
        elif line.startswith('## '):
            html_lines.append(f'<h2>{line[3:]}</h2>')
        elif line.startswith('### '):
            html_lines.append(f'<h3>{line[4:]}</h3>')
        elif line.startswith('#### '):
            html_lines.append(f'<h4>{line[5:]}</h4>')
        # Handle unordered lists
        elif line.strip().startswith('- '):
            if not in_list:
                html_lines.append('<ul>')
                in_list = True
            html_lines.append(f'<li>{line.strip()[2:]}</li>')
        # Handle ordered lists
        elif re.match(r'^\d+\.\s', line.strip()):
            if not in_list:
                html_lines.append('<ol>')
                in_list = True
            html_lines.append(f'<li>{re.sub(r"^\d+\.\s", "", line.strip())}</li>')
        # Close list if needed
        elif in_list and line.strip() == '':
            html_lines.append('</ul>' if html_lines[-1].endswith('</li>') else '</ol>')
            in_list = False
        # Handle bold text **text**
        elif '**' in line:
            line = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', line)
            html_lines.append(f'<p>{line}</p>')
        # Handle inline code `code`
        elif '`' in line:
            line = re.sub(r'`(.+?)`', r'<code>\1</code>', line)
            html_lines.append(f'<p>{line}</p>')
        # Regular paragraphs
        elif line.strip():
            html_lines.append(f'<p>{line}</p>')
        else:
            html_lines.append('')

    # Close any open lists
    if in_list:
        html_lines.append('</ul>')

    return '\n'.join(html_lines)

def update_documentation_page(md_file: Path, html_file: Path, page_title: str):
    """Update documentation HTML page with content from markdown file"""

    if not md_file.exists():
        print(f"  ⚠️  {md_file} not found, skipping...")
        return

    if not html_file.exists():
        print(f"  ⚠️  {html_file} not found, skipping...")
        return

    print(f"  📝 Updating {html_file.name} from {md_file.name}...")

    # Read markdown content
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()

    # Parse HTML
    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'html.parser')

    # Find the main article section
    article = soup.find('article', class_='main-content')
    if not article:
        print("  ⚠️  Could not find main-content article")
        return

    # Find the first section > div.section-content (the main content area)
    section = article.find('section', class_='section')
    if not section:
        print("  ⚠️  Could not find section element")
        return

    section_content = section.find('div', class_='section-content')
    if not section_content:
        print("  ⚠️  Could not find section-content div")
        return

    # Clear existing content
    section_content.clear()

    # Convert markdown to HTML
    html_content = convert_markdown_to_html(md_content)

    # Parse and insert new content
    new_soup = BeautifulSoup(html_content, 'html.parser')
    section_content.append(new_soup)

    # Collect all classes and extensions for linking and navigation
    classes_dir = Path('docs/Classes')
    extensions_dir = Path('docs/Extensions')

    class_links = []
    extension_links = []
    class_map = {}  # Map class names to their HTML file paths

    if classes_dir.exists():
        for html_file in sorted(classes_dir.glob('*.html')):
            class_name = html_file.stem
            class_links.append((class_name, f'Classes/{class_name}.html'))
            class_map[class_name] = f'Classes/{class_name}.html'

    if extensions_dir.exists():
        for html_file in sorted(extensions_dir.glob('*.html')):
            ext_name = html_file.stem
            extension_links.append((ext_name, f'Extensions/{ext_name}.html'))
            class_map[ext_name] = f'Extensions/{ext_name}.html'

    # Convert code references to links in the architecture content
    links_added = 0
    for code_tag in section_content.find_all('code'):
        code_text = code_tag.get_text().strip()

        # Check if this code reference matches a class or extension
        if code_text in class_map:
            # Wrap code tag with link
            a_tag = soup.new_tag('a', href=class_map[code_text])
            # Move code tag inside the link
            code_tag.wrap(a_tag)
            links_added += 1

    if links_added > 0:
        print(f"      Converted {links_added} class references to links")

    # Update navigation links
    nav = soup.find('nav', class_='navigation')
    if nav:
        # Find Classes nav group
        for nav_group in nav.find_all('li', class_='nav-group-name'):
            group_link = nav_group.find('a', class_='nav-group-name-link')
            if group_link and 'Classes' in group_link.get_text():
                tasks_ul = nav_group.find('ul', class_='nav-group-tasks')
                if tasks_ul:
                    tasks_ul.clear()
                    for name, link in class_links:
                        li = soup.new_tag('li', **{'class': 'nav-group-task'})
                        a = soup.new_tag('a', **{'class': 'nav-group-task-link'}, href=link)
                        a.string = name
                        li.append(a)
                        tasks_ul.append(li)

            elif group_link and 'Extensions' in group_link.get_text():
                tasks_ul = nav_group.find('ul', class_='nav-group-tasks')
                if tasks_ul:
                    tasks_ul.clear()
                    for name, link in extension_links:
                        li = soup.new_tag('li', **{'class': 'nav-group-task'})
                        a = soup.new_tag('a', **{'class': 'nav-group-task-link'}, href=link)
                        a.string = name
                        li.append(a)
                        tasks_ul.append(li)

        # Add Guides section at the end with Architecture and Technology Stack links
        nav_groups = nav.find('ul', class_='nav-groups')
        if nav_groups:
            # Create Guides nav group (using "Guides" to avoid confusion with "Architecture" sub-item)
            guides_nav_group = soup.new_tag('li', **{'class': 'nav-group-name'})
            guides_group_link = soup.new_tag('a', **{'class': 'nav-group-name-link'}, href='../Architecture.html')
            guides_group_link.string = 'Guides'
            guides_nav_group.append(guides_group_link)

            # Create tasks list for guide links
            guides_tasks_ul = soup.new_tag('ul', **{'class': 'nav-group-tasks'})

            # Add Architecture link
            arch_li = soup.new_tag('li', **{'class': 'nav-group-task'})
            arch_a = soup.new_tag('a', **{'class': 'nav-group-task-link'}, href='../Architecture.html')
            arch_a.string = 'Architecture'
            arch_li.append(arch_a)
            guides_tasks_ul.append(arch_li)

            # Add Technology Stack link
            tech_li = soup.new_tag('li', **{'class': 'nav-group-task'})
            tech_a = soup.new_tag('a', **{'class': 'nav-group-task-link'}, href='../TechnologyStack.html')
            tech_a.string = 'Technology Stack'
            tech_li.append(tech_a)
            guides_tasks_ul.append(tech_li)

            guides_nav_group.append(guides_tasks_ul)
            nav_groups.append(guides_nav_group)

    # Write updated HTML
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(str(soup))

    print(f"  ✅ {html_file.name} updated successfully")
    print(f"      Added {len(class_links)} class links to navigation")
    print(f"      Added {len(extension_links)} extension links to navigation")

def update_architecture_page():
    """Update Architecture.html with content from ARCHITECTURE.md"""
    update_documentation_page(
        Path('ARCHITECTURE.md'),
        Path('docs/Architecture.html'),
        'Architecture Documentation'
    )

def update_technology_stack_page():
    """Update TechnologyStack.html with content from TECHNOLOGY_STACK.md"""
    update_documentation_page(
        Path('TECHNOLOGY_STACK.md'),
        Path('docs/TechnologyStack.html'),
        'Technology Stack'
    )

def main():
    swift_dir = Path('Phase 1 Wireframe')
    classes_dir = Path('docs/Classes')
    extensions_dir = Path('docs/Extensions')

    if not swift_dir.exists():
        print(f"Error: Swift directory not found: {swift_dir}")
        return

    if not classes_dir.exists():
        print(f"Error: HTML directory not found: {classes_dir}")
        return

    # Update Architecture.html from ARCHITECTURE.md
    print("\n📄 Updating documentation pages...")
    update_architecture_page()
    update_technology_stack_page()

    # Map Swift filenames to HTML class names and their directory when they don't match
    filename_to_classname = {
        'AudioSingletons': ('Audio', 'Classes'),
        'GeneralUIColor': ('UIColor', 'Extensions'),
        'GerneralFonts': ('UIFont', 'Extensions'),
        'GeneralUINavigationBar': ('UINavigationBar', 'Extensions'),
        'GeneralArray': ('Array', 'Extensions')
    }

    print("🔍 Extracting inline documentation from Swift files...")

    # Collect all inline docs from all Swift files
    all_inline_docs = {}

    # Process each Swift file
    for swift_file in swift_dir.glob('*.swift'):
        file_stem = swift_file.stem

        # Use mapped class name and directory if available
        if file_stem in filename_to_classname:
            class_name, doc_type = filename_to_classname[file_stem]
            html_dir = Path(f'docs/{doc_type}')
        else:
            class_name = file_stem
            html_dir = classes_dir

        html_file = html_dir / f"{class_name}.html"

        if not html_file.exists():
            print(f"  ⚠️  No HTML file for {file_stem} → {class_name} in {html_dir}, skipping...")
            continue

        print(f"  📝 Processing {class_name}...")

        # Extract inline docs
        inline_docs = parse_swift_inline_docs(swift_file)

        if not inline_docs:
            print(f"      No inline docs found")
            continue

        print(f"      Found {len(inline_docs)} documented items")

        # Store for summary pages
        all_inline_docs[class_name] = inline_docs

        # Replace "Undocumented" in HTML
        replaced = replace_undocumented_in_html(html_file, inline_docs)
        print(f"      Replaced {replaced} 'Undocumented' instances in HTML")

    # Process summary pages (Classes.html and Extensions.html)
    print("\n🔍 Processing summary pages...")

    # Add links to class references in Extensions.html
    def add_class_links_to_extensions(html_file: Path):
        """Convert class name references to proper links in Extensions.html"""
        with open(html_file, 'r', encoding='utf-8') as f:
            soup = BeautifulSoup(f.read(), 'html.parser')

        # Dictionary of class names to link to
        class_links = {
            'GeneralUIButton': 'Classes/GeneralUIButton.html',
            'GeneralUILabel': 'Classes/GeneralUILabel.html',
            'GeneralUITextField': 'Classes/GeneralUITextField.html',
            'GeneralUIViewController': 'Classes/GeneralUIViewController.html',
            'EqualizerViewController': 'Classes/EqualizerViewController.html',
            'UIButton': None  # UIButton is a system class, just keep as code
        }

        links_added = 0

        # Find all abstract sections in the summary page
        for abstract in soup.find_all('div', class_='abstract'):
            for p in abstract.find_all('p'):
                # Check if paragraph contains class names in backticks
                text = p.get_text()
                needs_update = False

                for class_name in class_links.keys():
                    if f'`{class_name}`' in text:
                        needs_update = True
                        break

                if needs_update:
                    # Rebuild paragraph with links
                    p.clear()
                    current_text = text

                    # Process the text and replace backtick class names with links
                    import re
                    parts = re.split(r'`([^`]+)`', current_text)

                    for i, part in enumerate(parts):
                        if i % 2 == 0:
                            # Regular text
                            if part:
                                p.append(part)
                        else:
                            # Text that was in backticks
                            if part in class_links:
                                if class_links[part]:
                                    # Create link
                                    a = soup.new_tag('a', href=class_links[part])
                                    code = soup.new_tag('code')
                                    code.string = part
                                    a.append(code)
                                    p.append(a)
                                    links_added += 1
                                else:
                                    # Just code, no link (system classes)
                                    code = soup.new_tag('code')
                                    code.string = part
                                    p.append(code)
                            else:
                                # Keep as code
                                code = soup.new_tag('code')
                                code.string = part
                                p.append(code)

        # Write back if changes were made
        if links_added > 0:
            with open(html_file, 'w', encoding='utf-8') as f:
                f.write(str(soup))

        return links_added

    # Add missing declarations to summary pages
    def add_missing_declarations_to_summary(html_file: Path):
        """Add missing declaration sections for User and AppDelegate in Classes.html"""
        with open(html_file, 'r', encoding='utf-8') as f:
            soup = BeautifulSoup(f.read(), 'html.parser')

        # Dictionary of classes missing declarations with their declaration code
        missing_declarations = {
            'AppDelegate': '<span class="kd">class</span> <span class="kt">AppDelegate</span><span class="p">:</span> <span class="kt">UIResponder</span><span class="p">,</span> <span class="kt">UIApplicationDelegate</span>',
            'User': '<span class="kd">class</span> <span class="kt">User</span><span class="p">:</span> <span class="kt">NSObject</span>'
        }

        added_count = 0

        for class_name, declaration_code in missing_declarations.items():
            # Find the anchor for this class
            anchor = soup.find('a', {'name': f'//apple_ref/swift/Class/{class_name}'})
            if anchor:
                # Find the parent section
                section = anchor.find_parent('section', class_='section')
                if section:
                    # Check if declaration already exists
                    if not section.find('div', class_='declaration'):
                        # Find the abstract div to insert declaration after it
                        abstract = section.find('div', class_='abstract')
                        if abstract:
                            # Create declaration HTML
                            declaration_html = f'''<div class="declaration">
                        <h4>Declaration</h4>
                        <div class="language">
                          <p class="aside-title">Swift</p>
                          <pre class="highlight"><code>{declaration_code}</code></pre>

                        </div>
                      </div>'''

                            # Parse and insert
                            from bs4 import BeautifulSoup as BS
                            decl_soup = BS(declaration_html, 'html.parser')
                            abstract.insert_after(decl_soup)
                            added_count += 1
                            print(f"      Added declaration for {class_name}")

        # Write back if changes were made
        if added_count > 0:
            with open(html_file, 'w', encoding='utf-8') as f:
                f.write(str(soup))

        return added_count

    summary_pages = [
        Path('docs/Classes.html'),
        Path('docs/Extensions.html')
    ]

    for summary_page in summary_pages:
        if summary_page.exists():
            print(f"  📝 Processing {summary_page.name}...")

            # Add missing declarations
            if summary_page.name == 'Classes.html':
                added = add_missing_declarations_to_summary(summary_page)
                if added > 0:
                    print(f"      Added {added} missing declarations")

            # Add class links in Extensions.html
            if summary_page.name == 'Extensions.html':
                links_added = add_class_links_to_extensions(summary_page)
                if links_added > 0:
                    print(f"      Added {links_added} class reference links")

            # Merge all inline docs for this summary page
            merged_docs = {}
            for class_docs in all_inline_docs.values():
                merged_docs.update(class_docs)

            replaced = replace_undocumented_in_html(summary_page, merged_docs)
            print(f"      Replaced {replaced} 'Undocumented' instances in summary page")

    print("\n✅ Documentation replacement complete!")

if __name__ == '__main__':
    main()
