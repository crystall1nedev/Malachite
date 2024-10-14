# Malachite
*noun*
1. a crystal with the properties of revealing hidden parts of yourself
2. the name of my app to take control of the macro lens on iPhone
---
## What is it?
Malachite is a **work-in-progress** app that gives you more control over the macro lens of (or connected to) your iPhone.

## What do I need?[^1]
I recommend one of the following configurations...
- An iPhone or iPad with one of the following:
  - A built-in ultra-wide camera[^2]:
    - iPhone 11 or later (excluding iPhone SE)
    - iPad Pro (11-inch, 2nd, 3rd, and 4th generation)
    - iPad Pro (12.9-inch, 4th, 5th, and 6th generation)
  - A third-party lens attachment
...and **iOS 14.1** or later.

## What can I do with this?  
- [x] Enjoy a fully-native, no-external library Swift app
- [x] Basic camera view, with buttons that are out of the way  
- [x] Switch between the ultra-wide and wide cameras, with fallback support for devices with one camera  
- [x] Pinch-to-zoom gesture[^3]  
- [x] Autofocus adjustments by tapping and holding the display[^4]  
- [x] Manual focus adjustments by adjusting a slider next to the other controls  
- [x] Photo capture support, even when library access is set to Limited
- [x] JPEG and HEIC support[^5]
- [x] High dynamic range support[^6]
- [x] Watermarking support! 
- [ ] More features, coming soon...  

## What's it look like?
I don't currently have images for it; I'll be adding some as I get closer to my first release.

## How do I get it?
### TestFlight
Malachite is available on TestFlight!  
https://testflight.apple.com/join/Bj2HlOQV

### Building from source
1. Clone this repo
2. Open `Malachite.xcodeproj`
3. Change the codesigning team in `Signing & Capabilities`[^7]
4. Build!

## What started this one, Eva?
So, I live with my love: @ThatStella7922. She and I are both big nerds, and I caught her using her macro lens on an Xbox 360 motherboard to let her work with traces and pads while she was RGH'ing it. The idea for a magnifier app came from how much time it took for her to get into the right camera setting, turn the flashlight on, and still not have much control beyond autofocus and zooming. With Malachite, I strove to solve this problem - and then I ended up making it even greater for the people who love macro photography on their own iPhones.

[^1]: Malachite is validated against iPhone SE (1st generation) with no lens attachment, iPhone 8 Plus with no working main camera, iPhone 15 Pro Max, and iPad Pro (11-inch). Not all features are available across all devices, due to hardware and software limitations. iOS version support may change depending on the difficulty of targeting older iOS versions and/or other factors.
[^2]: For the best experience, I would recommend devices that support Apple's native macro mode: iPhone 13 Pro, iPhone 13 Pro Max, iPhone 14 Pro, iPhone 14 Pro Max, iPhone 15 Pro, iPhone 15 Pro Max, or iPhone 16 and later (excluding iPhone SE).
[^3]: Pinch-to-zoom will feature haptic feedback when reaching the minimum and maximum zoom levels in a future commit.
[^4]: Autofocus currently features haptic feedback. On-screen feedback will be featured in a future commit.
[^5]: Capturing images in RAW and ProRAW is being looked into. HEIC requires iPhone 7 or later, iPad (6th generation) or later, iPad Air (3rd generation) or later, iPad mini (5th generation) or later, iPad Pro (12.9-inch, 2nd generation) or later, iPad Pro (10.5-inch), iPad Pro (11-inch) or later, or iPod touch (7th generation)
[^6]: High dynamic range is currently limited to HEIC-supporting devices to investigate issues with older models.
[^7]: This will be unnecessary in a future commit.
