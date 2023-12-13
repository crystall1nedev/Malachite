//
//  MalachiteTutorialUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import UIKit

public class MalachiteTooltipUtils : NSObject {
    var cameraTitle = UILabel()
    var flashlightTitle = UILabel()
    var captureTitle = UILabel()
    var focusTitle = UILabel()
    var aboutTitle = UILabel()
    var currentYPosition = 10.0
    public func tooltipFlow(viewForBounds view: UIView) {
        cameraTitle = MalachiteViewUtils().returnProperLabel(viewForBounds: view, text: "Switch camera", textColor: .white)
        flashlightTitle = MalachiteViewUtils().returnProperLabel(viewForBounds: view, text: "Toggle flashlight", textColor: .white)
        captureTitle = MalachiteViewUtils().returnProperLabel(viewForBounds: view, text: "Capture photo", textColor: .white)
        focusTitle = MalachiteViewUtils().returnProperLabel(viewForBounds: view, text: "Manual focus slider", textColor: .white)
        aboutTitle = MalachiteViewUtils().returnProperLabel(viewForBounds: view, text: "Settings", textColor: .white)
        
        cameraTitle.textAlignment = .right
        flashlightTitle.textAlignment = .right
        captureTitle.textAlignment = .right
        focusTitle.textAlignment = .right
        aboutTitle.textAlignment = .right
        
        cameraTitle.font = UIFont.boldSystemFont(ofSize: 15)
        flashlightTitle.font = UIFont.boldSystemFont(ofSize: 15)
        captureTitle.font = UIFont.boldSystemFont(ofSize: 15)
        focusTitle.font = UIFont.boldSystemFont(ofSize: 15)
        aboutTitle.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(cameraTitle)
        view.addSubview(flashlightTitle)
        view.addSubview(captureTitle)
        view.addSubview(focusTitle)
        view.addSubview(aboutTitle)
        
        NSLayoutConstraint.activate([
            cameraTitle.widthAnchor.constraint(equalToConstant: 180),
            cameraTitle.heightAnchor.constraint(equalToConstant: 60),
            cameraTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cameraTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
            
            flashlightTitle.widthAnchor.constraint(equalToConstant: 180),
            flashlightTitle.heightAnchor.constraint(equalToConstant: 60),
            flashlightTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            flashlightTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
            
            captureTitle.widthAnchor.constraint(equalToConstant: 180),
            captureTitle.heightAnchor.constraint(equalToConstant: 60),
            captureTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            captureTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
            
            focusTitle.widthAnchor.constraint(equalToConstant: 180),
            focusTitle.heightAnchor.constraint(equalToConstant: 60),
            focusTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 290),
            focusTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
            
            aboutTitle.widthAnchor.constraint(equalToConstant: 180),
            aboutTitle.heightAnchor.constraint(equalToConstant: 60),
            aboutTitle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            aboutTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
        ])
        
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.animate(withDuration: 1, animations: { [self] in
                cameraTitle.alpha = 0.0
                flashlightTitle.alpha = 0.0
                captureTitle.alpha = 0.0
                focusTitle.alpha = 0.0
                aboutTitle.alpha = 0.0
            }, completion: { [self](finished:Bool) in
                cameraTitle.removeFromSuperview()
                flashlightTitle.removeFromSuperview()
                captureTitle.removeFromSuperview()
                focusTitle.removeFromSuperview()
                aboutTitle.removeFromSuperview()
            })
        }
    }
}
