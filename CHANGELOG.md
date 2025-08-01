# 1.0.0 (build xxx)

- **Increased the minimum version requirement from iOS 14.1 to iOS 15**
    - Supporting the few users on iOS 14 is no longer worth the extra complexity for my workflow
- Fixed an issue where the camera switching alert would display on launch
- Fixed an issue where the padding between Photo and Watermark settings would be too large
- Changed the way the Settings view is presented on iPadOS
    - It now uses a popover, check it out!
- Moved the About screen to using a simpler navigation flow
- Add support for watchOS
    - Working on Malachite Remote, not much to see yet!
- Add support for Camera Control on iPhone 16 series (excluding 16e)
    - Press Camera Control to take photos
    - Light-press to access controls
- Add support for iOS 26
    - Updated app icon with Liquid Glass
    - Support Liquid Glass in UI elements
- Switch to Codesigning.xcconfig to prevent conflicts when changing development teams or bundle identifiers
- Adds support for customizable digital zoom levels
- Switched from Photo library access permission to Photo library additions permission
- Fixed an issue where Malachite would disable HDR even if the device supports it
- Added more descriptive errors for exposure and flashlight
- Localize the lock screen, control center, and Action Button widgets
- Fix an issue where the resolution controls in Settings wouldn't appear
    - Addressed an internal check in the wrong place
- Fix an issue where the resolution UserDefaults keys would not populate on launch
    - This only affected devices without the Pro camera system.
- Fix an issue where the lock screen widget would not show its icon
    - This was fixed by properly stubbing the methods for the required intent


# 1.0.0 (build 115)

- Add localization capability
    - Currently Malachite is only localized for English
- Implement a complete Settings help function
- Support iOS 18 features
    - Action button (iOS 17 and later)
    - Control Center button 
    - Dark and tinted app icons 
- Mitigate Apple breaking my HDR
    - By waiting, not a fix by me
- Separate INTERNAL vs DEBUG builds
    - INTERNAL is meant for the completely unfinished, very rough around the edges features
    - DEBUG is meant to be exactly the same as RELEASE, with more logging
- Rewrite camera switching to be more efficient
- Support 48MP main and ultrawide
    - 48MP main requires iPhone 14 Pro and later Pro, iPhone 16 and later (excluding iPhone SE)
    - 48MP ultrawide requires iPhone 16 Pro and iPhone 16 Pro Max
- Enable support for the telephoto camera
- Customizable options for the user interface
    - Added the ability to enable gestures while the UI is hidden
    - Added the ability to enable auto exposure and/or auto focus on tap and hold
    - Added the ability to disable the system's built-in idle timer.
    - Added the ability to launch the app without the UI present.
- Support continuous auto focus and auto exposure
    - Also configurable in Settings
- Fixed a *lot* of bugs
    - Various bad programming issues that made Xcode complain behind the scenes
    - Colors are now more accurate when HDR is on
    - iPhones with fixed-focus ultrawide cameras crashing with the focus slider
    - A8/A9 devices crashing with default settings

# 1.0.0 (build 70)

Initial previews of Malachite. 
