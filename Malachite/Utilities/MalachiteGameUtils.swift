//
//  MalachiteGameUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 2/23/24.
//

import Foundation
import GameKit

public class MalachiteGameUtils : NSObject, GKGameCenterControllerDelegate {
    public var gameCenterEnabled = false
    public var achievements = [GKAchievement]()
    public var achievementNames = [
        "first_photo",
        "icon.default",
        "icon.wifey",
        "icon.marimo",
        "your_mother"
    ]
    
    func setupGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            NSLog("[Game Center] Signing into Game Center...")
            
            if error != nil {
                print("[Game Center] Couldn't sign in: ", error?.localizedDescription as Any)
                return
            }
            NSLog("[Game Center] Enabling the easter eggs...")
            self.gameCenterEnabled = true
        }
        
        achievements = self.loadAchievements()
    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated:true)
    }
    
    public func loadAchievements() -> [GKAchievement] {
        var finishedAchievements = [GKAchievement]()
        var wait = true
        
        GKAchievement.loadAchievements(completionHandler: { achievements, error in
            for achievementName in self.achievementNames {
                let achievementID = "dev.crystall1ne.Malachite.achievement." + achievementName
                var achievement: GKAchievement? = nil
                
                // Find an existing achievement.
                achievement = achievements?.first(where: { $0.identifier == achievementID})
                
                // Otherwise, create a new achievement.
                if achievement == nil {
                    achievement = GKAchievement(identifier: achievementID)
                }
                
                // Insert code to report the percentage.
                print("[Game Center] Initialized achievement: ", achievement?.identifier as Any)
                
                if error != nil {
                    // Handle the error that occurs.
                    print("[Game Center] Hit an error: \(String(describing: error))")
                } else {
                    finishedAchievements.append(achievement!)
                }
            }
            wait = false
        })
        
        while wait {
            sleep(1)
        }
        
        print("[Game Center] Dumping all achievements that are known by Malachite: ", finishedAchievements)
        return finishedAchievements
    }
    
    public func pullAchievement(achievementName achievementID: String) -> GKAchievement {
        let fullID = "dev.crystall1ne.Malachite.achievement." + achievementID
        return self.achievements.first(where: { $0.identifier == fullID})!
    }
    
    public func pushAchievement(achievementBody achievement: GKAchievement) {
        GKAchievement.report([achievement])
    }
    
    public func resetAchievements() {
        GKAchievement.resetAchievements(completionHandler: { error in
            NSLog("[Game Center] Resetting all Game Center achievements...")
            
            if error != nil {
                print("[Game Center] Couldn't reset: ", error?.localizedDescription as Any)
                return
            }
        })
    }
}
