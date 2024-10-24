//
//  MalachiteGameUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 2/23/24.
//

import Foundation
import GameKit

public class MalachiteGameUtils : NSObject, GKGameCenterControllerDelegate {
    /// Determines whether or not GameKit should be enabled.
    public var gameCenterEnabled = false
    /// An instance of ``MalachiteGameAchievementUtils``.
    public let achievements = MalachiteGameAchievementUtils()
    /// An instance of ``MalachiteGameLeaderboardUtils``.
    public let leaderboards = MalachiteGameLeaderboardUtils()
    
    /// Function to handle leaving the GameKit dashboard.
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated:true)
    }
    
    /// Function to set up GameKit.
    public func setupGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            MalachiteClassesObject().internalNSLog("[Game Center] Signing into Game Center...")
            
            if error != nil {
                print("[Game Center] Couldn't sign in: ", error?.localizedDescription as Any)
                return
            }
            
            self.gameCenterEnabled = GKLocalPlayer.local.isAuthenticated
            
            MalachiteClassesObject().internalNSLog("[Game Center] Enabling the easter eggs...")
        }
        
        if gameCenterEnabled {
            achievements.loadAchievements()
            leaderboards.loadLeaderboards()
        }
    }
}

public class MalachiteGameAchievementUtils : NSObject {
    /// An array of `GKAchievements` used to store achievement information.
    public var achievements = [GKAchievement]()
    /// An array of `String` that serves as truncated achievment names.
    public var achievementNames = [
        "first_photo",
        "icon.default",
        "icon.wifey",
        "icon.marimo",
        "your_mother"
    ]
    
    /// Function that loads all achievements and any progress into the ``achievements`` array.
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
    
    /// Function that pulls an achievement from ``achievements``.
    public func pullAchievement(achievementName achievementID: String) -> GKAchievement {
        let fullID = "dev.crystall1ne.Malachite.achievement.\(achievementID)"
        return self.achievements.first(where: { $0.identifier == fullID})!
    }
    
    /// Function that reports an array of achievements to GameKit.
    public func pushAchievement(achievementBody achievement: GKAchievement) {
        GKAchievement.report([achievement])
    }
    
    /// Function that resets all achievement data for the local player.
    public func resetAchievements() {
        GKAchievement.resetAchievements(completionHandler: { error in
            MalachiteClassesObject().internalNSLog("[Game Center] Resetting all Game Center achievements...")
            
            if error != nil {
                print("[Game Center] Couldn't reset: ", error?.localizedDescription as Any)
                return
            }
        })
    }
}

public class MalachiteGameLeaderboardUtils : NSObject {
    /// An array of `GKLeaderboard` used to store leaderboard information.
    public var leaderboards = [GKLeaderboard]()
    /// An array of `String` that serves as truncated leaderboards names.
    public var leaderboardNames = [
        "photos_taken"
    ]
    
    /// Function that loads all leaderboards and any progress into the ``leaderboards`` array.
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
    
    /// Function to report new leaderboard progress to GameKit.
    public func pushLeaderboard(scoreToSubmit score: Int, leaderboardToSubmit leaderboard: String) {
        let leaderboardID = "dev.crystall1ne.Malachite.board.\(leaderboard)"
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID], completionHandler: {error in} )
    }
}
