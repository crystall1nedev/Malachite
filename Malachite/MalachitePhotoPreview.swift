//
//  MalachitePhotoPreview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/27/23.
//

import Foundation
import UIKit
import Photos

class MalachitePhotoPreview : UIViewController {
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var photoImage = UIImage()
    
    var savePhotoButton = UIButton()
    var dismissButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        photoImageView.image = photoImage
        self.view.addSubview(photoImageView)
        
        dismissButton = MalachiteView().returnProperButton(symbolName: "xmark")
        self.view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 60),
            dismissButton.heightAnchor.constraint(equalToConstant: 60),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -28),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        dismissButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        
        savePhotoButton = MalachiteView().returnProperButton(symbolName: "square.and.arrow.down")
        self.view.addSubview(savePhotoButton)
        NSLayoutConstraint.activate([
            savePhotoButton.widthAnchor.constraint(equalToConstant: 60),
            savePhotoButton.heightAnchor.constraint(equalToConstant: 60),
            savePhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 41),
            savePhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        savePhotoButton.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
    }
    
    @objc private func dismissView() {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    
    @objc private func savePhoto() {
        
        guard let previewImage = self.photoImageView.image else { return }
        
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
                NSLog("[Capture Photo] Photo has been saved to the user's library.")
                self.dismissView()
            }
        } catch let error {
            NSLog("[Capture Photo] Photo couldn't be saved to the user's library: %@", error.localizedDescription)
        }
        
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
}
