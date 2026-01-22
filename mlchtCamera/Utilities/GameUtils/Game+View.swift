//
//  Game+View.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/29/25.
//

import Foundation
import UIKit

extension MalachiteGameUtils {
    func setupGameKitAlert() -> UIAlertController {
        let alert = UIAlertController(title: "alert.title.gamekit".localized, message: "alert.detail.gamekit".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "alert.button.reopen".localized, style: .default, handler: { _ in exit(11) }))
        alert.addAction(UIAlertAction(title: "alert.button.report".localized, style: .default, handler: { _ in
            guard let url = URL(string: "https://www.youtube.com/watch?v=At8v_Yc044Y") else { return }
#if MAIN_APP
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
#endif
        }))
        alert.addAction(UIAlertAction(title: "alert.button.ignore".localized, style: .default, handler: { _ in
            MalachitePreferencesUtils.shared.preferences.general.gamekit.alerted = false
        }))
        
        return alert
    }
}
