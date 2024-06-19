//
//  MalachiteUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/10/23.
//

import AVFoundation
import Foundation
import Photos
import UIKit

public class MalachiteClassesObject : NSObject {
    /// An instance of ``MalachiteHapticUtils``
    public let haptics   = MalachiteHapticUtils()
    /// An instance of ``MalachiteViewUtils``
    public let views     = MalachiteViewUtils()
    /// An instance of ``MalachiteFunctionUtils``
    public let function  = MalachiteFunctionUtils()
    /// An instance of ``MalachiteSettingsUtils``
    public let settings  = MalachiteSettingsUtils()
    /// An instance of ``MalachiteTooltipUtils``
    public let tooltips  = MalachiteTooltipUtils()
    /// An instance of ``MalachiteGameUtils``
    public let games     = MalachiteGameUtils()
    
    /// A variable that denotes the major version of Malachite.
    public let versionMajor    = "1"
    /// A variable that denotes the minor version of Malachite.
    public let versionMinor    = "0"
    /// A variable that denotes the bugfix version of Malachite.
    public let versionFixer    = "0"
    /// A variable that can be used to pull the git commit hash from the Info.plist
    public let versionHash     = Bundle.main.object(forInfoDictionaryKey: "CFBuildHash") as? String ?? "undefined"
    /// A variable that can be used to pull the build time from the Info.plist
    public let versionDate     = Bundle.main.object(forInfoDictionaryKey: "CFBuildDate") as? String ?? "undefined"
    /// A variable that can be used to identify the variant of the build from the Info.plist
    public let versionType     = Bundle.main.object(forInfoDictionaryKey: "CFBuildType") as? String ?? "undefined"
    
    /// A variable that determines the type of device Malachite is running on.
    public let idiom     = UIDevice.current.userInterfaceIdiom
    
}
