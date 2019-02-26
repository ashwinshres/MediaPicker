//
//  ViewController.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onPickerBtnClick(_ sender: UIButton) {
        
        let mediaPicker = MediaPickerViewController.getMediaPicker(with: .camera)
        mediaPicker.1.setDefaultImagePickerConfiguration()
        mediaPicker.1.mediaType = .video
        mediaPicker.1.pickerMode = .all
        mediaPicker.1.sourceView = sender
        mediaPicker.1.isCroppingEnabled = true
        mediaPicker.1.delegate = self
        mediaPicker.1.maximumImageSizeInMb = 3
        mediaPicker.1.maximumVideoSizeInMb = 5
        mediaPicker.0.modalTransitionStyle = .crossDissolve
        mediaPicker.0.modalPresentationStyle = .custom
        present(mediaPicker.0, animated: false, completion: nil)
        
    }
    
}

extension ViewController: MediaPickerDelegate {
    
    func didPickImage(_ image: UIImage) {
        print("Image Picked")
    }
    
    func didClose(viewController: MediaPickerViewController) {
        viewController.dismiss(animated: false, completion: nil)
    }
    
    func didPickVideo(_ withPath: URL) {
        print("Did Pick Video")
    }
    
    func showErrorMessage(_ message: String) {
        print(message)
    }
    
}

