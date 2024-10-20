//
//  LockedCameraExtensionViewFinder.swift
//  LockedCameraExtension
//
//  Created by Eva Isabella Luna on 10/17/24.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import LockedCameraCapture

@main
struct LockedCameraExtension: LockedCameraCaptureExtension {
    var body: some LockedCameraCaptureExtensionScene {
        LockedCameraCaptureUIScene { session in
            LockedCameraExtensionViewFinder(session: session)
        }
    }
}

struct LockedCameraExtensionViewFinder: UIViewControllerRepresentable {
    let session: LockedCameraCaptureSession
    var sourceType: UIImagePickerController.SourceType = .camera

    init(session: LockedCameraCaptureSession) {
        self.session = session
    }
 
    func makeUIViewController(context: Self.Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        imagePicker.cameraDevice = .rear
 
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Self.Context) {
    }
}

struct bruhView: UIViewRepresentable {
    typealias UIViewType = UIViewController
    
    let bruh = MalachiteView
    
}
