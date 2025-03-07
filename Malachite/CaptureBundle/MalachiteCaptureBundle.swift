//
//  MalachiteCaptureBundle.swift
//  MalachiteCaptureBundle
//
//  Created by Eva Isabella Luna on 11/1/24.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import LockedCameraCapture
import SwiftUI

@available(iOS 18.0, *)
@main
struct MalachiteCaptureBundle: LockedCameraCaptureExtension {
    var body: some LockedCameraCaptureExtensionScene {
        LockedCameraCaptureUIScene { session in
            MalachiteCaptureBundleViewFinder(session: session)
        }
    }
}

@available(iOS 18.0, *)
struct MalachiteCaptureBundleViewFinder: UIViewControllerRepresentable {
    // Apple's sample LockedCameraCapture code
    let session: LockedCameraCaptureSession
    var sourceType: UIImagePickerController.SourceType = .camera

    init(session: LockedCameraCaptureSession) {
        self.session = session
    }
 
    func makeUIViewController(context: Self.Context) -> MalachiteView {
        return MalachiteView()
    }
 
    func updateUIViewController(_ uiViewController: MalachiteView, context: Self.Context) {
    }
}

