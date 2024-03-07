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
    public let versionMajor = "1"
    /// A variable that denotes the minor version of Malachite.
    public let versionMinor = "0"
    /// A variable that denotes the bugfix version of Malachite.
    public let versionFixer = "0"
    /// A variable that denotes whether or not the copy of Malachite is in beta.
    public let versionBeta  = true
    
    /// A variable that determines the type of device Malachite is running on.
    public let idiom     = UIDevice.current.userInterfaceIdiom
}
