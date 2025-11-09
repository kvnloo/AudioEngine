#!/usr/bin/env python3
"""
Clean documentation files by removing TODOs, replacing Undocumented, and updating copyright
"""
import os
import re
from pathlib import Path

# Documentation root
DOCS_ROOT = Path(__file__).parent.parent / "docs"

# Replacement mappings
REPLACEMENTS = {
    # User class description
    r'<p>Undocumented</p>\s*<a href="Classes/User\.html"':
        '<p>Represents an authenticated user account with credentials and equalizer settings data.</p>\n\n                        <a href="Classes/User.html"',

    # AppDelegate description
    r'<p>Undocumented</p>\s*<a href="Classes/AppDelegate\.html"':
        '<p>Application lifecycle management, Firebase configuration, and root view controller switching.</p>\n\n                        <a href="Classes/AppDelegate.html"',

    # Remove TODO from EqualizerViewController
    r'<pre class="highlight plaintext"><code>TODO: cleanup code\.\s*</code></pre>':
        '',

    # Remove TODO from InitialViewController
    r'<pre class="highlight plaintext"><code>TODO: add in appdelegate to check if the user is signed in\.\s*</code></pre>':
        '',

    # Remove TODO from LoginViewController
    r'<pre class="highlight plaintext"><code>TODO: configure firebase backend system\. Create an api-manager to control https requests\. input validation for email/phone number\.\s*</code></pre>':
        '',

    # Fix RecordedAudioObject TODO in description
    r'This is a custom model that allows to store both a URL and a title for an audio clip\.\s*// TODO: create a mechanism to display and edit the name of the file\.':
        'Data model that encapsulates recorded audio file information including file URL and display title.',

    # Fix APIManager description (currently shows RecordedAudioObject TODO)
    r'<p>This is a custom model that allows to store both a URL and a title for an audio clip\.\s*// TODO: create a mechanism to display and edit the name of the file\.</p>\s*<a href="Classes/APIManager\.html"':
        '<p>Singleton manager for Firebase authentication, social login integration, and user data persistence.</p>\n\n                        <a href="Classes/APIManager.html"',

    # Fix SignUpViewController TODO
    r'<p>TODO: configure firebase backend system\. Create an api-manager to control https requests\. input validation for email/phone number\.</p>':
        '<p>Handles account creation with email/password and social authentication through Firebase, Google Sign-In, and Facebook Login.</p>',

    # Fix RecorderViewController TODO
    r'<p>TODO: Use singleton instead of local variables and methods\. This is just to allow for code abstraction and reduce viewcontroller complexity\.</p>':
        '<p>Provides audio recording functionality for the equalizer, allowing users to pre-record audio clips for processing.</p>',

    # Update copyright 2017 to 2025
    r'&copy; 2017':
        '&copy; 2025',

    # Update GitHub username in footer
    r'github\.com/lesseradmin':
        'github.com/kvnloo',
}

def clean_file(filepath):
    """Clean a single HTML file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        # Apply all replacements
        for pattern, replacement in REPLACEMENTS.items():
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)

        # Only write if changed
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Process all HTML files in docs directory"""
    changed_files = []

    # Find all HTML files
    for html_file in DOCS_ROOT.rglob("*.html"):
        if clean_file(html_file):
            changed_files.append(str(html_file.relative_to(DOCS_ROOT.parent)))

    if changed_files:
        print(f"✅ Cleaned {len(changed_files)} files:")
        for f in changed_files:
            print(f"  - {f}")
    else:
        print("✅ No changes needed")

    return len(changed_files)

if __name__ == "__main__":
    exit(0 if main() >= 0 else 1)
