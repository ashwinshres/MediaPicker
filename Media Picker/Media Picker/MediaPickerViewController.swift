//
//  MediaPickerViewController.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

class MediaPickerViewController: UIViewController {

    var pickerMode: PickerMode  = .all
    var mediaType : MediaType = .all
    weak var delegate: MediaPickerDelegate?
    
    var hasCameraAccess = false
    var hasLibraryAccess = false
    var imagePicker = UIImagePickerController()
    
    var isCroppingEnabled = false
    
    class func getMediaPicker(with pickerMode: PickerMode)-> (UINavigationController,MediaPickerViewController) {
        let mediaPicker = MediaPickerViewController(nibName: "MediaPickerViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: mediaPicker)
        nav.modalPresentationStyle = .custom
        nav.modalTransitionStyle = .crossDissolve
        nav.setNavigationBarHidden(true, animated: false)
        return (nav,mediaPicker)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hasValidPermissions() {
            configureMediaSources()
        } else {
            showPermissionInvalidAlert()
        }
        
    }
    
    private func configureMediaSources() {
        checkForMediaSources()
        setUpImgePickerController()
        showMediaPicker()
    }
    
    private func checkForMediaSources() {
        hasCameraAccess = UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        hasLibraryAccess = UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
    }
    
    private func setUpImgePickerController() {
        imagePicker.allowsEditing = isCroppingEnabled
        imagePicker.delegate = self
        switch mediaType {
        case .all:
             imagePicker.mediaTypes = [kUTTypeVideo as String, kUTTypeMovie as String, kUTTypeImage as String]
        case .photo:
            imagePicker.mediaTypes = [kUTTypeImage as String]
        case .video:
            imagePicker.mediaTypes = [kUTTypeVideo as String, kUTTypeMovie as String]
        }
    }
    
    private func hasValidPermissions() -> Bool {
        var dictRoot: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info" , ofType: "plist") {
            dictRoot = NSDictionary(contentsOfFile: path)
        }
        switch pickerMode {
        case .camera:
            if let _ = dictRoot?["NSCameraUsageDescription"] as? String {
                return true
            }
            
        case .library:
            if let _ = dictRoot?["NSPhotoLibraryUsageDescription"] as? String {
                return true
            }
            
        case .all:
            if let _ = dictRoot?["NSPhotoLibraryUsageDescription"] as? String ,
                let _ = dictRoot?["NSCameraUsageDescription"] as? String {
                return true
            }
        }
        return false
    }
    
    private func showPermissionInvalidAlert() {
        var alertMessageSubString = ""
        switch pickerMode {
        case .camera:
            alertMessageSubString = " camera access."
        case .library:
            alertMessageSubString = " photo library access."
        case .all:
            alertMessageSubString = " photo library and camera access."
        }
        let alertMessage = "There seems to be no permission in info plist file for \(alertMessageSubString)."
        showMediaPickerAlertWithOkHandler(alertMessage) {
            self.delegate?.didClose(viewController: self)
        }
    }

    private func showMediaPicker() {
        switch pickerMode {
        case .all:
            configureViewForMediaTypeWithSheeet()
        case .camera, .library:
            showMediaPickerFromSelectedMode()
        }
    }
    
    private func configureViewForMediaTypeWithSheeet() {
        if hasCameraAccess && hasLibraryAccess {
            showMediaPickerActionSheet()
        } else{
            selectMediaFromModeAvailable()
        }
    }
    
    private func showMediaPickerFromSelectedMode() {
        if pickerMode == .camera {
            if !hasCameraAccess {
                showMediaPickerAlertWithOkHandler("No camera available.") {
                    self.delegate?.didClose(viewController: self)
                }
                return
            }
            selectMediaFromCamera()
        } else {
            if !hasLibraryAccess {
                showMediaPickerAlertWithOkHandler("No  library available.") {
                    self.delegate?.didClose(viewController: self)
                }
                return
            }
            selectMediaFromGallery()
        }
    }
    
    private func selectMediaFromCamera(){
        imagePicker.sourceType = .camera
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            
            present(imagePicker, animated: true, completion: nil)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted :Bool) -> Void in
                if granted == true {
                    self.present(self.imagePicker, animated: true, completion: nil)
                } else {
                    self.showMediaPickerAlertWithOkHandler("App needs camera permission to capture media", okHandler: {})
                }
            });
        }
    }
    
    private func selectMediaFromGallery() {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func selectMediaFromModeAvailable() {
        if hasCameraAccess {
            selectMediaFromCamera()
        } else if hasLibraryAccess {
            selectMediaFromGallery()
        } else{
            self.showMediaPickerAlertWithOkHandler("No access type available to select from") {}
        }
    }
    
    private func showMediaPickerActionSheet() {
        let actionSheet = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { handler in
            self.selectMediaFromGallery()
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { handler in
            self.selectMediaFromCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { cancel in
            self.dismiss(animated: true, completion: nil)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
}


extension MediaPickerViewController {
    
    func showMediaPickerAlertWithOkAndCancelHandler(_ message: String = "Something went wrong.\nPlease try again later.", okTitle: String = "Ok", okHandler: @escaping () -> (), cancelTitle: String = "Cancel", cancelHandler : @escaping () -> ()) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Media Picker", message: message, preferredStyle: .alert)
            let okAction =  UIAlertAction(title: okTitle, style: .default){
                handler in
                okHandler()
            }
            alert.addAction(okAction)
            let cancelAction =  UIAlertAction(title: cancelTitle, style: .cancel){
                handler in
                cancelHandler()
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showMediaPickerAlertWithOkHandler(_ message: String = "Something went wrong.\nPlease try again later.", okHandler: @escaping () -> ()) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Media Picker", message: message, preferredStyle: .alert)
            
            let okAction =  UIAlertAction(title: "OK", style: .default){
                handler in
                okHandler()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension MediaPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    
}


