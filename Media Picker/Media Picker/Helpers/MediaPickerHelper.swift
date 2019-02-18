//
//  MediaPickerHelper.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MobileCoreServices

class MediaPickerHelper {
    
    static func isMediaImage(info: [UIImagePickerController.InfoKey : Any]) -> Bool {
        return (info[UIImagePickerController.InfoKey.mediaType] as? String ?? "") == "public.image"
    }
    
}

extension AVURLAsset {
    
    var fileSize: Int? {
        var keys = Set<URLResourceKey>()
        keys.insert(.totalFileSizeKey)
        keys.insert(.fileSizeKey)
        
        do {
            let resourceValues = try self.url.resourceValues(forKeys: keys)
            
            return resourceValues.fileSize ?? resourceValues.totalFileSize
        } catch {
            return nil
        }
    }
    
    var fileSizeInMB: Int {
       return ((self.fileSize ?? 0) / 1024)/1024
    }
    
}

extension UIImage {
    
    var sizeInMB: Int? {
        let imgData = jpegData(compressionQuality: 1.0)!
        let sizeInMB = (((NSData(data: imgData).length)/1024)/1024)
        return sizeInMB
    }
}
