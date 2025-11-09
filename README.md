# [![PhaseIWireframe](Assets/header-image/header@3x.png)](https://kvnloo.github.io/PhaseIWireframe/)

[![Doc coverage](https://img.shields.io/badge/docs-100%25-brightgreen.svg)](https://kvnloo.github.io/PhaseIWireframe/) [![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://kvnloo.github.io/PhaseIWireframe/) [![License MIT](https://img.shields.io/badge/license-MIT-4481C7.svg)](https://opensource.org/licenses/MIT)

## 📚 Documentation

Documentation is automatically generated from source code using [Jazzy](https://github.com/realm/jazzy) and deployed to GitHub Pages.

### Viewing Documentation
Visit: https://kvnloo.github.io/PhaseIWireframe/

### Building Documentation Locally
```bash
# Install Jazzy
gem install jazzy

# Generate documentation
jazzy --config .jazzy.yaml

# View locally (if docs/ folder exists)
open docs/index.html
```

### Documentation Structure
- **Source**: Documentation is generated from inline code comments
- **Configuration**: `.jazzy.yaml` defines documentation settings
- **Deployment**: GitHub Actions automatically builds and deploys on push to master
- **Output**: Generated documentation is published to gh-pages branch only

**Note**: The `docs/` folder is generated and not committed to the master branch. Documentation is only stored in the gh-pages branch

## Description

Phase I Project is a project to develop an iOS Application with two main purposes:

  1. Create a noise meter that can display a noise level in decibels in real-time.

  2. Construct a 14-band dual-channel audio equalizer that is able to process audio in real-time.

The application was developed based on wireframe specifications for the JubiAudio Phase I project.


## 🛠️ Technology Stack

### Core Technologies
- **Language**: Swift 3.0+
- **Platform**: iOS 10.0+
- **IDE**: Xcode 8.0+
- **Architecture**: MVC (Model-View-Controller)

### Backend & Authentication
- **Firebase**
  - Firebase Authentication (Email/Password, Google Sign-In, Facebook Login)
  - Firebase Realtime Database (User data persistence)
- **Google Sign-In SDK** (`GoogleSignIn`)
- **Facebook SDK** (`FBSDKCoreKit`, `FBSDKLoginKit`)

### Audio Processing
- **AVFoundation**
  - `AVAudioRecorder` - Audio recording functionality
  - `AVAudioPlayer` - Audio playback with equalizer
  - `AVAudioEngine` - Real-time audio processing
  - `AVAudioPlayerNode` - Audio node management
  - `AVAudioUnitEQ` - 14-band dual-channel equalizer implementation
  - `AVAudioUnitTimePitch` - Time-stretching and pitch-shifting
- **CoreAudio** - Low-level audio processing

### UI Framework
- **UIKit** - Native iOS UI components
- **Custom UI Components**
  - `GeneralUIButton` - Styled buttons with custom colors
  - `GeneralUILabel` - Consistent typography system
  - `GeneralUITextField` - Styled input fields
  - `GeneralUIViewController` - Base view controller with navigation
  - `GeneralUINavigationBar` - Custom navigation bar styling

### Design System
- **Color Palette**: Custom slate color system
  - Isabelline (White) - `#F4F4F2`
  - Silver Chalice (Creme) - `#ABABAB`
  - Outer Space (Charcoal) - `#495159`
  - Gunmetal (Background) - `#2C3539`
  - Raisin Black (Black) - `#232B2B`
- **Typography**: System fonts with custom sizing
  - Title: 32pt
  - Heading: 24pt
  - Body: 18pt
  - Caption: 14pt

### Dependency Management
- **CocoaPods** - Dependency manager for iOS libraries
  - Firebase/Core
  - Firebase/Auth
  - Firebase/Database
  - Google Sign-In
  - Facebook SDK

### Development Tools
- **Jazzy** - Swift documentation generator
- **GitHub Actions** - CI/CD for automated documentation deployment
- **GitHub Pages** - Documentation hosting

### Design Patterns
- **Singleton Pattern**: `APIManager`, `Audio` for global state management
- **Delegation Pattern**: `AVAudioRecorderDelegate`, `GIDSignInDelegate`, `GIDSignInUIDelegate`
- **Notification Pattern**: Cross-component communication via `NotificationCenter`
- **Extension Pattern**: UI component customization via Swift extensions

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).


## Requirements

- iOS 10.0+
- Xcode 8.0+
- Swift 3.0+


## Instalation


### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
> CocoaPods 1.0.0+ is required to build this project.

Once, cocoapods has been installed, run the following command:

```bash
$ pod install
```

This will install all of the required dependencies to edit, run, and test this project. These can all be done by opening `~/PhaseIWireframe.xcuserstate` using Xcode.

## Creation

I started building this project by planning out the key components that it would include. Initially, after looking at the provided wireframe I decided to go with a simple design for logging in / creating an account. I also added in another option to test out the demo tools without needing to sign in. When creating the demo tools, I started out by creating a color palette. I initially browsed through [coolors.co](https://coolors.co) until I found a color that I liked for the background. This color ended up being Gunmetal (`UIColor.BACKGROUND`).

Once I had this color, I generated different shades of this color to find a set of slate colors for the application. These slate colors include Isabelline (`UIColor.WHITE`), Silver Chalice (`UIColor.CREME`), Outter Space (`UIColor.CHARCOAL`), Gunmetal (`UIColor.BACKGROUND`), and Raisin Black (`UIColor.BLACK`). Once these slate colors were found, I browsed through [coolors.co](https://coolors.co) until I found good highlight colors that I could use for `GeneralUIButton`, `GeneralUILabel`, `GeneralUITextField`, `GeneralUIViewController`, and `UINavigationBar`.

Here is the final color palette:

![final_color_palette](Assets/Color%20Palettes/Color%20Palette%20Final/ColorPalette.png)

Once the color palette was created I started to design custom UI Components, which can be seen below.

Here are the Custom UI Components:


![custom_ui_components](Assets/UIComponents/UIComponents@3x.png)

Once these components were created, I started to create the layout for the application. Namely, I began designing the MVC (Model View Controller) logic to control the flow of the application.

The application follows a structured authentication flow, where users can either create an account, login with existing credentials (email/password), or use social authentication (Google Sign-In, Facebook Login). Once authenticated, users can access the demo tools which include the 14-band dual-channel equalizer and real-time noise meter.

## Support

Please [open an issue](https://github.com/kvnloo/PhaseIWireframe/issues/new) for support.


## Contributing 

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/kvnloo/PhaseIWireframe/compare/).


## License

This project is licensed under the MIT License. For a full copy of this license take a look at the LICENSE file.
