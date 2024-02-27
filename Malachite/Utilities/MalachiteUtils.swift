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
    public let versions  = MalachiteVersion()
    public let haptics   = MalachiteHapticUtils()
    public let views     = MalachiteViewUtils()
    public let function  = MalachiteFunctionUtils()
    public let settings  = MalachiteSettingsUtils()
    public let tooltips  = MalachiteTooltipUtils()
    public let games     = MalachiteGameUtils()
    
    public let idiom     = UIDevice.current.userInterfaceIdiom
}
