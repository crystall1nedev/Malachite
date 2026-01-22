# mlchtCamera  

*noun*; the name of my app to take back control of your iPhone or iPad's camera lenses.

---
## What is it?
With a name loosely based on the **malachite crystal** with properties of revealing hidden parts of yourself, mlchtCamera is a **work-in-progress** camera app, designed to put pro controls into the hands of even more users.

## What do I need?[^1]
mlchtCamera will run on any iPhone or iPad with **iOS 15.0** or later.

I recommend one of the following configurations...
- An iPhone or iPad with one of the following...
  - A built-in ultra-wide camera that supports Apple's macro mode:
    - iPhone 13 Pro or iPhone 13 Pro Max
    - iPhone 14 Pro or iPhone 14 Pro Max
    - iPhone 15 Pro or iPhone 15 Pro Max
    - iPhone 16 or later (excluding iPhone 16e)
- ...and/or a third-party lens attachment

## What can I do with this?  
- [x] Enjoy a fully-native, no-external library Swift app
- [x] Quickly open Malachite with a lock screen widget, Control Center, Action Button, or Camera Control
- [x] Quickly access controls using Camera Control
- [x] Basic camera view, with buttons that are out of the way  
- [x] Switch between the ultra-wide and wide cameras, with fallback support for devices with one camera  
- [x] Pinch-to-zoom gesture[^2]  
- [x] Autofocus and autoexposure adjustments by tapping and holding the display 
- [x] Manual focus adjustments by adjusting a slider next to the other controls  
- [x] Photo capture support, even when library access is set to Limited
- [x] JPEG and HEIC support[^3]
- [x] 48MP and high dynamic range support
- [x] Watermarking support! 
- [ ] More features, coming soon...  

## What's it look like?
I don't currently have images for it; I'll be adding some as I get closer to my first release.

## How do I get it?
### TestFlight
Malachite is on TestFlight, but only for **[my Patrons](https://patreon.com/crystall1nedev) on the Friend tier and above.** 

### Building from source
1. Clone this repo
2. Open `Codesigning.example.xcconfig`, make changes, and save it as `Codesigning.xcconfig`.
3. Open `mlchtCamera.xcodeproj`
4. Build!

## What started this one, Eva?
So, I live with my love: @ThatStella7922. She and I are both big nerds, and I caught her using her macro lens on an Xbox 360 motherboard to let her work with traces and pads while she was RGH'ing it. The idea for a magnifier app came from how much time it took for her to get into the right camera setting, turn the flashlight on, and still not have much control beyond autofocus and zooming. With Malachite, I strove to solve this problem - and thus, we had Malachite with its original purpose: a macro magnifier.

As I was working on it, I'd drop builds into my Discord server. A few users came in and asked for various features - including image capture. I was originally opposed to it, since it *was* just for magnification... and yet, a few hours later, I'd hooked everything up to add image capture support - saving HEICs to the user's library or directly out of the share sheet. mlchtCamera ended up morphing into a macro photography app that people used and enjoyed - and requested more out of.

At this point, I've added plenty of extras. Camera switching, manual exposure, hardware button controls - those are just a few and I plan to implement so much more in the future. It took me a while to accept it, but this little side-project of mine was becoming something different, and the goal solidified itself as this: creating a powerful pro camera app that truly harnesses iPhone and iPad hardware, while staying simplistic in its design and accessible to anyone who wants to get into photography.

To the people who helped get me here (and you know who you are), I thank you for helping me figure it out.

### Addendum

This app was originally named "Malachite" - directly after the crystal mentioned before. However, bouncing between Apple Developer accounts resulted in issues with the name and bundle identifiers used in the past. The rename to "mlchtCamera" keeps the core name while also making it unique.

[^1]: mlcht is validated against iPhone SE (1st generation) with no lens attachment, iPhone 8 Plus with no working main camera, iPhone 11, iPhone 17 Pro Max, and iPad Pro (11-inch). Not all features are available across all devices, due to hardware and software limitations. iOS version support may change depending on the difficulty of targeting older iOS versions and/or other factors.
[^2]: Pinch-to-zoom will feature haptic feedback when reaching the minimum and maximum zoom levels in a future commit.
[^3]: Capturing images in RAW and ProRAW is being looked into. HEIC requires iPhone 7 or later, iPad (6th generation) or later, iPad Air (3rd generation) or later, iPad mini (5th generation) or later, iPad Pro (12.9-inch, 2nd generation) or later, iPad Pro (10.5-inch), iPad Pro (11-inch) or later, or iPod touch (7th generation)
