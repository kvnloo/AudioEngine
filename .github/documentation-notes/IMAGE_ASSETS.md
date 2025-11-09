# Documentation Image Assets

## Source Images
All images used in documentation are stored in the Assets/ folder:
- Header: `Assets/header-image/header@3x.png`
- Color Palette: `Assets/Color Palettes/Color Palette Final/ColorPalette.png`
- UI Components: `Assets/UIComponents/UIComponents@3x.png`

## Deployment Process
The GitHub Actions workflow copies these images to the generated documentation:
1. Jazzy generates docs/ folder (not committed to master)
2. Images are copied to docs/assets/images/
3. Documentation is deployed to gh-pages branch

## Adding New Images
To add new images to documentation:
1. Add source image to appropriate Assets/ subdirectory
2. Update `.github/workflows/documentation.yml` to copy the image
3. Reference the image in your documentation as `assets/images/your-image.png`

## Why This Structure?
- Source images stay in the Assets/ folder (version controlled)
- Generated documentation (including copied images) only exists in gh-pages branch
- Master branch stays clean without generated content
- GitHub Actions handles the build and deployment automatically