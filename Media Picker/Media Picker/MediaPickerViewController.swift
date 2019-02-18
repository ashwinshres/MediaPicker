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
import CropViewController

class MediaPickerViewController: UIViewController {

    public var pickerMode: PickerMode  = .all
    public var mediaType : MediaType = .all
    public weak var delegate: MediaPickerDelegate?
    public var isCroppingEnabled = false
    public var aspectRatioPreset: TOCropViewControllerAspectRatioPreset = .preset4x3
    public var aspectRatioLockEnabled: Bool = true
    public var resetAspectRatioEnabled: Bool = true
    public var rotateButtonsHidden: Bool = true
    public var croppingStyle: TOCropViewCroppingStyle = .default
    public var maximumVideoSizeInMb: Int?
    public var maximumImageSizeInMb: Int?
    
    private var hasCameraAccess = false
    private var hasLibraryAccess = false
    
    private var imagePicker = UIImagePickerController()
    private var selectedImage: UIImage?
    
    private var imageCropper: CropViewController?
    
    class func getMediaPicker(with pickerMode: PickerMode)-> (UINavigationController,MediaPickerViewController) {
        let mediaPicker = MediaPickerViewController(nibName: MPConstants.strings.controllerName, bundle: nil)
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
            switch mediaType {
            case .all, .video:
                if let _ = dictRoot?[MPConstants.usageDescription.cameraUsage] as? String,
                    let _ = dictRoot?[MPConstants.usageDescription.microPhoneUsage] as? String{
                    return true
                }
            case .photo:
                if let _ = dictRoot?[MPConstants.usageDescription.cameraUsage] as? String {
                    return true
                }
            }
       
        case .library:
            if let _ = dictRoot?[MPConstants.usageDescription.libraryUsage] as? String {
                return true
            }
            
        case .all:
            if let _ = dictRoot?[MPConstants.usageDescription.libraryUsage] as? String ,
                let _ = dictRoot?[MPConstants.usageDescription.cameraUsage] as? String {
                return true
            }
        }
        return false
    }
    
    private func showPermissionInvalidAlert() {
        var alertMessageSubString = ""
        switch pickerMode {
        case .camera:
            switch mediaType {
            case .all, .video:
                alertMessageSubString = " camera and microphone access."
            case .photo:
                alertMessageSubString = " camera access."
            }
            
        case .library:
            alertMessageSubString = " photo library access."
        case .all:
            alertMessageSubString = " photo library and camera access."
        }
        let alertMessage = "There seems to be no permission in info plist file for \(alertMessageSubString)"
        showErrorAlert(with: alertMessage)
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
                showErrorAlert(with: MPConstants.strings.noCameraAvailable)
                return
            }
            selectMediaFromCamera()
        } else {
            if !hasLibraryAccess {
                showErrorAlert(with: MPConstants.strings.noLibraryAvailable)
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
                    self.showErrorAlert(with: MPConstants.strings.cameraPermissionError)
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
            showErrorAlert(with: MPConstants.strings.noAccessTypeAvailable)
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
            self.delegate?.didClose(viewController: self)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func setDefaultImagePickerConfiguration() {
        pickerMode = .all
        mediaType = .photo
        isCroppingEnabled = true
        croppingStyle = .default
        aspectRatioPreset = .presetSquare
        aspectRatioLockEnabled = true
        resetAspectRatioEnabled = false
        rotateButtonsHidden = true
    }
    
}


extension MediaPickerViewController {
    
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
    
    func showMediaPickerAlertWithOkAndCancelHandler(_ message: String = "Something went wrong.\nPlease try again later.", okTitle: String = "Ok", okHandler: @escaping () -> (), cancelTitle: String = "Cancel", cancelHandler: @escaping () -> () ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Media Picker", message: message, preferredStyle: .alert)
            
            let okAction =  UIAlertAction(title: okTitle, style: .default) { handler in
                okHandler()
            }
            alert.addAction(okAction)
            
            let cancelAction =  UIAlertAction(title: cancelTitle, style: .default) { handler in
                cancelHandler()
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showErrorAlert(with message: String) {
        showMediaPickerAlertWithOkHandler(message) {
            self.delegate?.didClose(viewController: self)
        }
    }
    
    private func showSizeLimitExceedView(with message: String) {
        showMediaPickerAlertWithOkHandler(message) {
            self.showMediaPicker()
        }
    }
    
    private func restrictVideoSize() -> Bool {
        guard let _ = maximumVideoSizeInMb else { return false }
        return true
    }
    
    private func restrictImageSize() -> Bool {
        guard let _ = maximumImageSizeInMb else { return false }
        return true
    }
    
}

extension MediaPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.delegate?.didClose(viewController: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if MediaPickerHelper.isMediaImage(info: info) {
                self.configureImagePicked(with: info)
            } else {
                self.configuredVideoPicked(with: info)
            }
        }
    }
    
}

extension MediaPickerViewController {
    
    private func configureImagePicked(with info: [UIImagePickerController.InfoKey : Any])  {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if self.isCroppingEnabled {
                self.selectedImage = image
                self.configureImageCropper(with: image)
            } else {
                self.checkSelectedImageSizeAndProceed(with: image)
            }
        } else {
            self.showErrorAlert(with: MPConstants.strings.errorPickingMedia)
        }
    }
    
    private func configureImageCropper(with image: UIImage) {
        if let _ = imageCropper {} else {
            imageCropper = CropViewController(croppingStyle: croppingStyle, image: image)
            imageCropper?.delegate = self
            imageCropper?.aspectRatioLockEnabled = aspectRatioLockEnabled
            imageCropper?.aspectRatioPreset = aspectRatioPreset
            imageCropper?.resetAspectRatioEnabled = resetAspectRatioEnabled
            imageCropper?.rotateButtonsHidden = rotateButtonsHidden
        }
        present(self.imageCropper!, animated: true, completion: nil)
    }
    
    private func checkSelectedImageSizeAndProceed(with image: UIImage) {
        if restrictImageSize() {
            let imageSize = (image.sizeInMB ?? 0)
            checkImageSize(for: image, imageSize: imageSize)
        } else {
            delegate?.didPickImage(image)
            delegate?.didClose(viewController: self)
        }
    }
    
    private func checkImageSize(for image: UIImage, imageSize: Int) {
        if imageSize < maximumImageSizeInMb! {
            delegate?.didPickImage(image)
            delegate?.didClose(viewController: self)
        } else {
            showSizeLimitExceedView(with: "Please choose image of size \(self.maximumImageSizeInMb!)MB or less")
        }
    }
   
}

extension MediaPickerViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: false) {
            self.showMediaPickerAlertWithOkAndCancelHandler(MPConstants.strings.mediaCropTitle, okTitle: "Yes", okHandler: {
                self.checkSelectedImageSizeAndProceed(with: self.selectedImage!)
            }, cancelTitle: MPConstants.strings.cropBtnTitle) {
                self.configureImageCropper(with: self.selectedImage!)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.checkSelectedImageSizeAndProceed(with: image)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.checkSelectedImageSizeAndProceed(with: image)
        }
    }
}

// MARK: - Video Picker Methods
extension MediaPickerViewController {
    
    private func configuredVideoPicked(with info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let videoAsset = AVURLAsset(url: url , options: nil)
            let videoSize = (videoAsset.fileSizeInMB)
            
            if restrictVideoSize() {
                checkVideoSize(forVideoat: url, videoSize: videoSize)
            } else {
                didChooseVideo(at: url)
            }
        } else {
            showErrorAlert(with: MPConstants.strings.errorPickingMedia)
        }
    }
    
    private func checkVideoSize(forVideoat url: URL, videoSize: Int) {
        if videoSize < maximumVideoSizeInMb! {
            didChooseVideo(at: url)
        } else {
            showSizeLimitExceedView(with: "Please choose video of size \(self.maximumVideoSizeInMb!)MB or less")
        }
    }
    
    private func didChooseVideo(at url: URL) {
        delegate?.didPickVideo(url)
        delegate?.didClose(viewController: self)
    }
    
}


