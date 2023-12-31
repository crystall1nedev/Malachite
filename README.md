# Malachite
*noun*
1. a crystal with the properties of revealing hidden parts of yourself
2. the name of my app to take control of the macro lens on iPhone
---
## What is it?
Malachite is a **work-in-progress** app that gives you more control over the macro lens of (or connected to) your iPhone.

## What do I need?[^1]
You'll need one of the following configurations...
- iPhone 13 Pro/Pro Max or later Pro models
- An iPhone or iPad with a macro lens accessory attached  
...and **iOS 14.1** or later.

## What can I do with this?  
- [x] Basic camera view, with buttons that are out of the way  
- [x] Switch between the ultra-wide and wide cameras, with fallback support for devices with one camera  
- [x] Pinch-to-zoom gesture[^2]  
- [x] Autofocus adjustments by tapping and holding the display[^3]  
- [x] Manual focus adjustments by adjusting a slider next to the other controls  
- [x] Photo capture support, even when library access is set to Limited[^4]  
- [ ] More features, coming soon...  

## What's it look like?
I don't currently have images for it; I'll be adding some as I get closer to my first release.

## How do I get it?
I'll release the first build of Malachite in the Releases tab when it's ready for prime time. Until then:
1. Clone this repo
2. Open `Malachite.xcodeproj`
3. Change the codesigning team in `Signing & Capabilities`
4. Build!

## What started this one, Eva?
So, I live with my love: @ThatStella7922. She and I are both big nerds, and I caught her using her macro lens on an Xbox 360 motherboard to let her work with traces and pads while she was RGH'ing it. The idea for a magnifier app came from how much time it took for her to get into the right camera setting, turn the flashlight on, and still not have much control beyond autofocus and zooming. With Malachite, I strove to solve this problem - and then I ended up making it even greater for the people who love macro photography on their own iPhones.

[^1]: This list is what I hope to target all the way through. If development hurdles come up, some functionality may be restricted to newer releases that are not listed here. Configurations that are not listed are not tested.
[^2]: Pinch-to-zoom will feature haptic feedback when reaching the minimum and maximum zoom levels in a future commit.
[^3]: Autofocus currently features haptic feedback. On-screen feedback will be featured in a future commit.
[^4]: Taking photos is locked to portrait mode - rotating the phone doesn't currently rotate the captured photo! This will be fixed in a future commit, alongside proper orientation enhancements.
