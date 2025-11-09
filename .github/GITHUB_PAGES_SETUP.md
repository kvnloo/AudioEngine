# GitHub Pages Documentation Setup

This repository is configured to automatically build and deploy documentation to GitHub Pages using Jazzy.

## Overview

- **Documentation Tool**: Jazzy (Swift/Objective-C documentation generator)
- **Hosting**: GitHub Pages
- **Automation**: GitHub Actions
- **Documentation URL**: https://kvnloo.github.io/PhaseIWireframe/

## How It Works

### Automatic Builds

Every push to the `master` branch triggers an automated workflow that:

1. Checks out the repository
2. Sets up Ruby environment
3. Installs Jazzy
4. Builds documentation from source code
5. Deploys generated docs to `gh-pages` branch
6. GitHub Pages serves the documentation

### Manual Builds

You can also manually trigger documentation builds:

1. Go to Actions tab in GitHub
2. Select "Build and Deploy Documentation" workflow
3. Click "Run workflow"

## Local Documentation Build

To build documentation locally:

```bash
# Install Jazzy (one-time setup)
gem install jazzy

# Build documentation
jazzy --config .jazzy.yaml

# View documentation
open docs/index.html
```

## Configuration

### Jazzy Configuration

Documentation settings are in `.jazzy.yaml`:

- **Module**: Phase_1_Wireframe
- **Swift Version**: 3.0
- **Output Directory**: docs/
- **Theme**: fullwidth
- **Min ACL**: internal

### Customizing Documentation

Edit `.jazzy.yaml` to customize:

- Categories and organization
- Included/excluded files
- Theme and styling
- Documentation coverage

## GitHub Pages Settings

**Required Repository Settings:**

1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: `gh-pages` / `root`
4. Save

The repository is already configured with these settings.

## File Organization

```
PhaseIWireframe/
├── .github/
│   └── workflows/
│       └── documentation.yml    # GitHub Actions workflow
├── .jazzy.yaml                  # Jazzy configuration
├── docs/                        # Generated documentation (git ignored in master)
└── Phase 1 Wireframe/          # Source code with doc comments
```

## Documentation Coverage

Current documentation includes:

- **Core Classes**: APIManager, AppDelegate, Audio, User
- **View Controllers**: All UI view controllers
- **UI Components**: Custom UI elements
- **Models**: Data models and objects
- **Extensions**: Swift extensions

## Best Practices

### Writing Documentation

Use Swift documentation comments:

```swift
/// Brief description of the class
///
/// Detailed description with more information.
///
/// - Note: Important notes
/// - Warning: Warnings for users
class MyClass {
    /// Description of the property
    var myProperty: String

    /// Description of the method
    ///
    /// - Parameters:
    ///   - param1: Description of param1
    ///   - param2: Description of param2
    /// - Returns: Description of return value
    /// - Throws: Description of errors
    func myMethod(param1: String, param2: Int) throws -> Bool {
        // Implementation
    }
}
```

### Commit Messages

When updating documentation:

```bash
git commit -m "docs: Update APIManager documentation"
git commit -m "docs: Add code examples to LoginViewController"
```

## Troubleshooting

### Build Failures

If documentation build fails:

1. Check workflow run in Actions tab
2. Review Jazzy output logs
3. Verify `.jazzy.yaml` syntax
4. Ensure Swift code compiles

### Missing Documentation

If classes/methods are missing:

1. Check `min_acl` setting in `.jazzy.yaml`
2. Verify access level (public, internal, private)
3. Add documentation comments
4. Check `skip_undocumented` setting

### GitHub Pages Not Updating

If documentation doesn't update:

1. Check Actions tab for build status
2. Verify gh-pages branch exists
3. Check Pages settings in repository
4. Clear browser cache

## Maintenance

### Regular Updates

- Review and update documentation comments
- Keep `.jazzy.yaml` configuration current
- Monitor workflow runs for failures
- Update Swift version as needed

### Version Updates

When updating Swift version:

1. Update `.jazzy.yaml` swift_version
2. Update workflow if needed
3. Test documentation build locally
4. Commit and push changes

## Additional Resources

- [Jazzy Documentation](https://github.com/realm/jazzy)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Swift Documentation Markup](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/)

## Support

For issues with:

- Documentation generation: Check Jazzy configuration
- Deployment: Review GitHub Actions logs
- GitHub Pages: Verify repository settings
- Content: Update source code documentation
