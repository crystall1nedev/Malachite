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
    
    public let achievements = MalachiteGameAchievementUtils()
    public let leaderboards = MalachiteGameLeaderboardUtils()
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated:true)
    }
    
    public func setupGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            NSLog("[Game Center] Signing into Game Center...")
            
            if error != nil {
                print("[Game Center] Couldn't sign in: ", error?.localizedDescription as Any)
                return
            }
            NSLog("[Game Center] Enabling the easter eggs...")
            self.gameCenterEnabled = true
        }
        
        achievements.loadAchievements()
        leaderboards.loadLeaderboards()
    }
}

public class MalachiteGameAchievementUtils : NSObject {
    public var achievements = [GKAchievement]()
    public var achievementNames = [
        "first_photo",
        "icon.default",
        "icon.wifey",
        "icon.marimo",
        "your_mother"
    ]
    
    public func loadAchievements() {
        var wait = true
        
        GKAchievement.loadAchievements(completionHandler: { achievements, error in
            for achievementName in self.achievementNames {
                let achievementID = "dev.crystall1ne.Malachite.achievement.\(achievementName)"
                var achievement: GKAchievement? = nil
                
                achievement = achievements?.first(where: { $0.identifier == achievementID})
                
                if achievement == nil {
                    achievement = GKAchievement(identifier: achievementID)
                }
                
                print("[Game Center] Initialized achievement: ", achievement?.identifier as Any)
                
                if error != nil {
                    print("[Game Center] Hit an error: \(String(describing: error))")
                } else {
                    self.achievements.append(achievement!)
                }
            }
            wait = false
        })
        
        while wait {
            sleep(1)
        }
        
        print("[Game Center] Dumping all achievements that are known by Malachite: ", self.achievements)
    }
    
    public func pullAchievement(achievementName achievementID: String) -> GKAchievement {
        let fullID = "dev.crystall1ne.Malachite.achievement.\(achievementID)"
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

public class MalachiteGameLeaderboardUtils : NSObject {
    public var leaderboards = [GKLeaderboard]()
    public var leaderboardNames = [
        "photos_taken"
    ]
    
    public func loadLeaderboards() {
        var fullIDs = [String]()
        var wait = true

        for leaderboardName in self.leaderboardNames {
            fullIDs.append("dev.crystall1ne.Malachite.board.\(leaderboardName)")
        }
        
        GKLeaderboard.loadLeaderboards(IDs: fullIDs) { leaderboards, _ in
            self.leaderboards = leaderboards!
            wait = false
        }
        
        while wait {
            sleep(1)
        }
        
        print("[Game Center] Dumping all leaderboards that are known by Malachite: ", self.leaderboards)
        
    }
    
    public func pushLeaderboard(scoreToSubmit score: Int, leaderboardToSubmit leaderboard: String) {
        let leaderboardID = "dev.crystall1ne.Malachite.board.\(leaderboard)"
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID], completionHandler: {error in} )
    }
}
