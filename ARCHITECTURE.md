# PhaseIWireframe Architecture Documentation

## Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Core Components](#core-components)
- [Design Patterns](#design-patterns)
- [Data Flow](#data-flow)
- [Authentication Flow](#authentication-flow)
- [Audio Processing Architecture](#audio-processing-architecture)
- [UI Component System](#ui-component-system)
- [Technology Stack](#technology-stack)
- [File Organization](#file-organization)

## Overview

PhaseIWireframe is an iOS application built with Swift 3.0+ that provides two primary features:
1. **Real-time Noise Meter** - Displays ambient noise levels in decibels
2. **14-Band Dual-Channel Audio Equalizer** - Processes and equalizes audio in real-time

The application follows the **Model-View-Controller (MVC)** architectural pattern with additional singleton managers for cross-cutting concerns.

## System Architecture

```
+──────────────────────────────────────────────────────────────+
│                      Presentation Layer                      │
│  +──────────────+  +──────────────+  +──────────────+        │
│  │ View         │  │ View         │  │ View         │        │
│  │ Controllers  │  │ Controllers  │  │ Controllers  │        │
│  │ (Auth)       │  │ (Equalizer)  │  │ (Noise Meter)│        │
│  +──────+───────┘  +───────+──────+  +────────+─────+        │
│         │                  │                  │              │
+─────────+──────────────────+──────────────────+──────────────+
          │                  │                  │
+─────────+──────────────────+──────────────────+──────────────+
│         │         Business Logic Layer        │              │
│  +──────▼───────+  +───────▼──────+  +────────▼─────+        │
│  │ APIManager   │  │ Audio        │  │ Data Models  │        │
│  │ (Singleton)  │  │ (Singleton)  │  │ (User, etc.) │        │
│  +──────+───────┘  +───────+──────+  +──────────────+        │
+─────────+──────────────────+─────────────────────────────────+
          │                  │
+─────────+──────────────────+─────────────────────────────────+
│         │         Services & Frameworks Layer                │
│  +──────▼───────+  +───────▼──────+  +──────────────+        │
│  │ Firebase     │  │ AVFoundation │  │ Core Audio   │        │
│  │ - Auth       │  │ - Recording  │  │ - Processing │        │
│  │ - Database   │  │ - Playback   │  │              │        │
│  +──────────────+  +──────────────+  +──────────────+        │
│                                                              │
│  +──────────────+  +──────────────+                          │
│  │ Facebook SDK │  │ Google       │                          │
│  │              │  │ Sign-In SDK  │                          │
│  +──────────────+  +──────────────+                          │
+──────────────────────────────────────────────────────────────+
```

## Core Components

### 1. Application Entry Point
- **AppDelegate.swift** - Application lifecycle management
  - Firebase configuration
  - Google Sign-In setup
  - Facebook SDK initialization
  - Navigation bar appearance configuration
  - Root view controller switching

### 2. Singleton Managers

#### APIManager (Authentication & Data)
**Purpose**: Centralized authentication and data persistence manager

**Responsibilities**:
- Email/password authentication via Firebase
- Social login (Facebook, Google) integration
- User session management
- Firebase Realtime Database operations
- Alert presentation for user feedback

**Key Properties**:
- `user: User?` - Current authenticated user
- `ref: DatabaseReference` - Firebase database reference
- `initialNotification` / `demoNotification` - View transition notifications

**Authentication Methods**:
- `createUser()` - Create new Firebase account
- `loginUser()` - Email/password login
- `fbSignIn()` - Facebook OAuth login
- `googleSignIn()` - Google OAuth login
- `logoutUser()` - Sign out and clear session

#### Audio (Audio Processing)
**Purpose**: Audio recording, playback, and equalizer processing singleton

**Responsibilities**:
- AVAudioSession configuration
- Audio recording via AVAudioRecorder
- Audio playback with real-time equalizer processing
- 14-band dual-channel equalization
- Recording file management

**Key Components**:
- Recording setup and delegate handling
- Playback with EQ node graph
- Equalizer parameter management (28 float values: 14 bands × 2 channels)

### 3. View Controllers

#### Authentication Flow
- **InitialViewController** - Landing page with authentication options
- **LoginViewController** - Email/password login form
- **SignUpViewController** - Account creation with social login options
  - Uses `SignUpTableViewCell` for reusable UI components
  - TableView-based layout for flexible scrolling

#### Main Features
- **EqualizerViewController** - 14-band audio equalizer interface
  - Manages equalizer table view
  - Handles slider interactions for each band
  - Communicates with Audio singleton for processing

- **RecorderViewController** - Audio recording interface
  - Record/pause/stop controls
  - Integrates with Audio singleton
  - Transitions to equalizer after successful recording

- **NoiseMeterViewController** - Real-time noise level display
  - Shows decibel levels with color-coded ranges
  - Uses AVAudioRecorder metering
  - Converts Apple's power levels to standard decibels

- **EqualizerTabBarController** - Tab navigation between features

#### Supporting View Controllers
- **GeneralUIViewController** - Base class for consistent UI styling
  - Shared navigation bar configuration
  - Common view lifecycle handling

### 4. Data Models

#### User
**Purpose**: Represents authenticated user with data persistence

**Properties**:
- Authentication credentials (uid, password, token, email flag)
- `data: [Float]` - 28-element array storing equalizer settings
  - 14 bands × 2 channels (left/right)
  - Persisted to Firebase for cross-device sync

**Authentication Support**:
- Email/password authentication
- OAuth token-based authentication (Facebook, Google)

#### RecordedAudioObject
**Purpose**: Encapsulates recorded audio file information

**Properties**:
- `filePathUrl: URL` - Location of recorded audio file
- `title: String` - Display name for the recording

## Design Patterns

### 1. Singleton Pattern
Used for shared resources and cross-cutting concerns:
- **APIManager**: Single point of authentication and data access
- **Audio**: Centralized audio processing and session management

**Benefits**:
- Prevents multiple audio sessions
- Ensures consistent authentication state
- Simplifies access to shared resources

### 2. Delegation Pattern
Standard iOS pattern for event handling:
- **AVAudioRecorderDelegate**: Recording lifecycle events
  - `RecorderViewController` implements for recording completion
  - `NoiseMeterViewController` implements for metering
- **GIDSignInDelegate**: Google Sign-In callbacks
- **TableView Delegates**: Data source and user interaction handling

### 3. Notification Pattern
Used for loosely-coupled view controller communication:
- `initialNotification` - Navigate to authentication screen
- `demoNotification` - Navigate to main app features
- Sent by APIManager, observed by AppDelegate for root VC switching

### 4. Custom UI Component System
Reusable, styled UI components with consistent theming:
- `GeneralUIButton` - Styled buttons
- `GeneralUILabel` - Custom font labels
- `GeneralUITextField` - Themed text inputs
- `GeneralUITableView` / `GeneralUITableViewCell` - Styled tables
- `GeneralUIViewController` - Base view controller with shared setup

**Benefits**:
- Consistent visual design across application
- Centralized styling through extensions (UIColor, UIFont)
- Easy theme updates

### 5. Extension Pattern
Swift extensions for cross-cutting functionality:
- **UIColor Extension**: Application color palette
- **UIFont Extension**: Typography system
- **UINavigationBar Extension**: Custom border styling
- **Array Extension**: Utility functions

## Data Flow

### Authentication Data Flow

```
User Input (Login/SignUp View)
        │
        ▼
   APIManager
        │
        ├──► Firebase Authentication
        │         │
        │         ▼
        │    Auth Success/Failure
        │         │
        │         ▼
        ├──► Create User Object
        │         │
        │         ▼
        └──► Firebase Database (Save/Load EQ Data)
                  │
                  ▼
             Post Notification
                  │
                  ▼
             AppDelegate
                  │
                  ▼
        Switch Root View Controller
                  │
                  ▼
          Main App Features
```

### Audio Recording Data Flow

```
RecorderViewController
        │
        ├──► Start Recording
        │         │
        │         ▼
        │    Audio Singleton
        │         │
        │         ▼
        │    AVAudioRecorder
        │         │
        │         ▼
        │    Record to File
        │         │
        │         ▼
        │    Recording Complete
        │         │
        │         ▼
        └──► Create RecordedAudioObject
                  │
                  ▼
          Segue to Equalizer
                  │
                  ▼
        EqualizerViewController
```

### Equalizer Data Flow

```
User Adjusts Slider (EqualizerViewController)
        │
        ▼
Update UI Immediately
        │
        ▼
Calculate EQ Values (band frequency, gain)
        │
        ▼
Store in User.data Array (28 floats)
        │
        ▼
Audio Singleton
        │
        ▼
Apply to AVAudioUnitEQ Nodes
        │
        │
        ├──► Left Channel (14 bands)
        │
        └──► Right Channel (14 bands)
                  │
                  ▼
        Real-time Audio Processing
                  │
                  ▼
        Save to Firebase (APIManager)
```

## Authentication Flow

### Email/Password Authentication

```
┌──────────────────┐
│ SignUpViewController │
└─────────┬──────────┘
          │
          ▼
    Create User Object
    (email, password)
          │
          ▼
   APIManager.createUser()
          │
          ▼
   Firebase.Auth.createUser()
          │
          ├─── Success ───┐
          │                │
          │                ▼
          │          Store User Data
          │          (Firebase DB)
          │                │
          │                ▼
          │          Post Notification
          │                │
          │                ▼
          │          Switch to Main App
          │
          └─── Failure ───┐
                          │
                          ▼
                    Show Alert
```

### Social OAuth Flow (Facebook/Google)

```
User Taps Social Login Button
          │
          ▼
   Launch SDK Auth UI
   (Safari/WebView)
          │
          ▼
   User Authenticates
   with Provider
          │
          ▼
   Receive Access Token
          │
          ▼
   APIManager Delegates
   (fbDidCompleteLogin / googleSignIn)
          │
          ▼
   Create Firebase Credential
   from Token
          │
          ▼
   Firebase.Auth.signIn(credential)
          │
          ├─── Success ───┐
          │                │
          │                ▼
          │          Create User Object
          │                │
          │                ▼
          │          Post Notification
          │                │
          │                ▼
          │          Switch to Main App
          │
          └─── Failure ───┐
                          │
                          ▼
                    Show Alert
```

## Audio Processing Architecture

### Recording Architecture

```
┌─────────────────────────────────────────┐
│        AVAudioSession Setup             │
│  - Category: PlayAndRecord              │
│  - Default to Speaker                   │
│  - Metering Enabled                     │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│        AVAudioRecorder                  │
│  - Format: MPEG4AAC                     │
│  - Sample Rate: 44.1kHz                 │
│  - Channels: Stereo (2)                 │
│  - Quality: High                        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│        Audio File Storage               │
│  - Location: Documents Directory        │
│  - Format: .m4a                         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    RecordedAudioObject Created          │
│  - File URL                             │
│  - Metadata                             │
└─────────────────────────────────────────┘
```

### Equalizer Processing Architecture

```
┌────────────────────────────────────────────┐
│         Recorded Audio File                │
│         (.m4a format)                      │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│         AVAudioEngine                      │
│  - Player Node                             │
│  - EQ Nodes (Left/Right Channels)          │
│  - Output Node                             │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│    14-Band Parametric EQ × 2 Channels      │
│                                            │
│    Left Channel:  14 AVAudioUnitEQFilter   │
│    Right Channel: 14 AVAudioUnitEQFilter   │
│                                            │
│    Each Band:                              │
│    - Center Frequency (Hz)                 │
│    - Gain (-12dB to +12dB)                 │
│    - Bandwidth (Q factor)                  │
│    - Filter Type: Parametric               │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│         Real-time Audio Output             │
│         (Speaker/Headphones)               │
└────────────────────────────────────────────┘

User Interaction:
  Slider Adjustment → Update EQ Parameters → Instant Audio Change
```

### Noise Meter Architecture

```
┌────────────────────────────────────────────┐
│         AVAudioSession Setup               │
│         (Metering Enabled)                 │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│         AVAudioRecorder                    │
│         (Background Recording)             │
│         - updateMeters() called on Timer   │
│         - averagePower(forChannel: 0)      │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│      Power Level Conversion                │
│      Apple Scale [-160, 0] dB              │
│              ↓                             │
│      Standard Scale [0, 120] dB            │
│      (convertToDecibel function)           │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│      UI Update (Color-Coded Display)       │
│      - Silent:  < 50 dB  (Blue)            │
│      - Quiet:   < 75 dB  (Green)           │
│      - Average: < 90 dB  (Purple)          │
│      - Noisy:   < 100 dB (Orange)          │
│      - Loud:    < 120 dB (Red)             │
└────────────────────────────────────────────┘
```

## UI Component System

### Color Palette System

Defined in `UIColor` extension (`GeneralUIColor.swift`):

**Slate Colors** (Grayscale Foundation):
- `WHITE` (Isabelline: #edeeef) - Primary text color
- `CREME` (Silver Chalice: #a8aeaf) - Navigation bar highlights, headings
- `CHARCOAL` (Outer Space: #414e51) - TextField backgrounds
- `BACKGROUND` (Gunmetal: #282d34) - View backgrounds
- `BLACK` (Raisin Black: #1d2025) - Dark text, login button

**Highlight Colors** (Accent Palette):
- `RED` (Light Red Ochre: #ea6552) - Alerts, loud noise indicator
- `GREEN` (Very Light Malachite: #58e69a) - Success, quiet noise
- `PURPLE` (Pale Violet: #d0a5ff) - Average noise level
- `BLUE` (Maya Blue: #7cc6fe) - Silent noise level
- `ORANGE` (Macaroni and Cheese: #ffc689) - Noisy level

**Social Media Colors**:
- `FB_BLUE` (#3b5998) - Facebook button background
- `GOOGLE_RED` (#dd4b39) - Google button background

### Typography System

Defined in `UIFont` extension (`GerneralFonts.swift`):

- `BUTTON` - Roboto-Medium, 15pt (Button text)
- `LABEL` - Roboto-Regular, 12pt (Standard labels)
- `TEXTFIELD` - Roboto-Bold, 14pt (Input fields)
- `LARGE` - Roboto-Bold, 80pt (Large displays - noise meter)
- `CAPTION` - Roboto-Regular, 10pt (Small captions)

### Component Hierarchy

```
GeneralUIViewController (Base)
    │
    ├─ Applies standard background color
    ├─ Configures navigation bar styling
    └─ Sets up common view lifecycle

GeneralUIButton
    │
    ├─ Custom background colors from palette
    ├─ Roboto-Medium font
    ├─ Rounded corners
    └─ Touch interaction styling

GeneralUILabel
    │
    ├─ Custom text colors from palette
    ├─ Roboto font family
    └─ Consistent sizing

GeneralUITextField (extends CustomUITextField)
    │
    ├─ Left icon support (imageWidth, leftPadding)
    ├─ Charcoal background
    ├─ White text color
    ├─ Roboto-Bold font
    └─ Placeholder styling

GeneralUITableView / GeneralUITableViewCell
    │
    ├─ Background color matching theme
    ├─ Separator styling
    └─ Cell reuse identifiers
```

## Technology Stack

### Core iOS Frameworks
- **UIKit** - User interface components and view management
- **Foundation** - Core object types and utilities
- **AVFoundation** - Audio/video capture and playback
- **CoreAudio** - Low-level audio processing

### Third-Party Dependencies (CocoaPods)

#### Authentication & Backend
- **Firebase/Core** (4.0.0) - Backend infrastructure
- **Firebase/Auth** - User authentication system
- **Firebase/Database** - Real-time data synchronization
- **FacebookCore** / **FacebookLogin** / **FBSDKCoreKit** - Facebook OAuth integration
- **GoogleSignIn** - Google OAuth authentication

#### Development Tools
- **Jazzy** - Swift/Objective-C documentation generator
  - Generates API documentation from inline comments
  - Deployed to GitHub Pages via GitHub Actions

### Build Tools
- **Xcode** 8.0+
- **CocoaPods** 1.0.0+
- **Swift** 3.0+

### Platform Requirements
- **iOS** 10.0+

## File Organization

```
Phase 1 Wireframe/
├── Application Core
│   ├── AppDelegate.swift           # App lifecycle, Firebase setup
│   └── Info.plist                  # App configuration
│
├── Managers (Singletons)
│   ├── APIManager.swift            # Authentication & data persistence
│   └── AudioSingletons.swift       # Audio processing (Audio class)
│
├── View Controllers
│   ├── Authentication
│   │   ├── InitialViewController.swift
│   │   ├── LoginViewController.swift
│   │   └── SignUpViewController.swift
│   │
│   ├── Main Features
│   │   ├── EqualizerViewController.swift
│   │   ├── RecorderViewController.swift
│   │   ├── NoiseMeterViewController.swift
│   │   └── EqualizerTabBarController.swift
│   │
│   └── Base
│       └── GeneralUIViewController.swift
│
├── Custom UI Components
│   ├── GeneralUIButton.swift
│   ├── GeneralUILabel.swift
│   ├── GeneralUITextField.swift
│   ├── CustomUITextField.swift
│   ├── GeneralUITableView.swift
│   ├── GeneralUITableViewCell.swift
│   ├── EqualizerTableViewCell.swift
│   └── SignUpTableViewCell.swift
│
├── UI Extensions
│   ├── GeneralUIColor.swift        # Color palette
│   ├── GerneralFonts.swift         # Typography
│   ├── GeneralUINavigationBar.swift
│   └── GeneralArray.swift
│
├── Data Models
│   ├── User.swift                  # User account model
│   └── RecordedAudioObject.swift   # Audio file metadata
│
├── Storyboards
│   └── Base.lproj/
│       ├── Main.storyboard         # App UI layout
│       └── LaunchScreen.storyboard # Launch screen
│
└── Configuration
    └── GoogleService-Info.plist    # Firebase configuration
```

### Documentation Structure
```
docs/                       # Generated documentation (gh-pages only)
├── index.html             # Documentation homepage
├── Classes/               # Class documentation pages
│   ├── APIManager.html
│   ├── AppDelegate.html
│   ├── User.html
│   └── ...
├── Extensions/            # Extension documentation
│   ├── UIColor.html
│   ├── UIFont.html
│   └── UINavigationBar.html
└── assets/
    └── images/
        └── color-palette.png

.jazzy.yaml                # Documentation generation config
scripts/
└── replace-undocumented.py # Post-process Jazzy HTML output
```

## Key Architectural Decisions

### 1. Singleton Pattern for Managers
**Decision**: Use singletons for APIManager and Audio
**Rationale**:
- Only one authentication session should exist
- Only one AVAudioSession can be active
- Simplifies access from any view controller
- Prevents resource conflicts

### 2. Notification-Based Navigation
**Decision**: Use NotificationCenter for root view controller switching
**Rationale**:
- Decouples authentication logic from view hierarchy
- AppDelegate can respond to auth state changes globally
- Avoids complex navigation dependencies

### 3. Custom UI Component System
**Decision**: Create GeneralUI* wrapper components
**Rationale**:
- Ensures consistent theming across entire app
- Centralizes styling logic
- Easy to update design system-wide
- Follows iOS design patterns with added customization

### 4. Extension-Based Theming
**Decision**: Use Swift extensions for colors and fonts
**Rationale**:
- Type-safe color/font references
- Autocomplete support in Xcode
- Semantic naming (e.g., `UIColor.BACKGROUND` vs hex codes)
- Single source of truth for design tokens

### 5. Firebase for Backend
**Decision**: Use Firebase for auth and data storage
**Rationale**:
- Real-time sync for EQ settings across devices
- Built-in authentication with social providers
- No custom backend infrastructure needed
- Suitable for MVP/prototype phase

### 6. Dual-Channel Equalizer Architecture
**Decision**: Separate EQ processing for left/right channels
**Rationale**:
- True stereo processing capability
- Industry-standard approach
- Enables advanced panning effects
- 28 float values (14 bands × 2 channels) stored per user

## Future Architectural Considerations

### Scalability
- Current Firebase architecture suitable for small-medium user base
- Consider migration to custom backend for large scale
- Potential for caching layer for EQ presets

### Code Organization
- Consider MVVM or VIPER for better testability
- Extract business logic from view controllers
- Separate networking layer from APIManager

### Testing
- Unit tests for business logic (APIManager, Audio processing)
- UI tests for critical user flows
- Mock Firebase for testing

### Performance
- Audio processing is real-time optimized
- Consider lazy loading for large user datasets
- Profile and optimize AVAudioEngine node graph

---

**Last Updated**: November 2025
**Author**: Kevin Rajan
**Documentation**: https://kvnloo.github.io/AudioEngine
