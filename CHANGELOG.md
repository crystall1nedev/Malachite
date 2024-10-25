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
