# Media Picker

Media Picker is an ios reusable component written in Swift 4.2. <br>
This is an attempt to make an easy photo / video picking library from camera / gallery with image crop feature.

## Features:
1. Picker Mode: <br>
        enum PickerMode {
          case all
          case camera
          case library
        }

      <p>
      When user chooses picker mode `.all` ,
      the media picker library checks if both camera and photo library is available or not. If both is available, action sheet is shown to choose from. If one of the picker type is not available, it directly opens the other available picker type
      </p>

2. Media Type: <br>
        enum MediaType: Int {
          case all
          case video
          case photo
        }

      <p>
        When user chooses media type mode `.all` ,
        both video and image selection is enabled from gallery or video and image capture is enabled from camera.
        </p>

3. Cropping Enabled? <br>
  One can enable/disable cropping of the photo selected/clicked.  If cropping is enabled, here are a few options one can choose from for cropping feature <br>

        public var aspectRatioPreset: TOCropViewControllerAspectRatioPreset = .preset4x3
        public var aspectRatioLockEnabled: Bool = true
        public var resetAspectRatioEnabled: Bool = true
        public var rotateButtonsHidden: Bool = true
        public var croppingStyle: TOCropViewCroppingStyle = .default`

      croping style are `.default` and `.circular`

4. Maximum Photo/video size:
    There is no restriction in the size of photo or video selected, but if user wants to restrict, there are two public variables available to do so.
        public var maximumVideoSizeInMb: Int?
        public var maximumImageSizeInMb: Int?




## Steps:
1. Copy and paste the "Media Picker" folder i.e the library folder in your project.

![Folder to copy and paste](https://drive.google.com/uc?export=view&id=1f7Sd7JdC2b5FLCZgLnxjXDxTTqun82bp)


2. Add the pod 'CropViewController' in your pod file and install the pod.
https://github.com/TimOliver/TOCropViewController
'CropViewController' is the swift version of 'TOCropViewController'. We use 'CropViewController' as our cropping library.

3.  Add permissions in info.plist file: <br>
    If picker mode is camera only, add camera usage description in plist file. <br>
    `NSCameraUsageDescription` <br> <br>

    If picker mode is gallery only, add  photo library usage description  in plist file. <br>
    `NSPhotoLibraryUsageDescription` <br> <br>

    For video recording, add microphone usage in plist file: <br>
    `NSMicrophoneUsageDescription` <br> <br>



4. You are now ready to use the Media Picker library.



## Usages:
 On your button click, or place from where you want to open the picker: <br>

        let mediaPicker =   MediaPickerViewController.getMediaPicker(with: .camera)
        mediaPicker.1.mediaType = .all
        mediaPicker.1.pickerMode = .all
        mediaPicker.1.isCroppingEnabled = true
        mediaPicker.1.delegate = self
        mediaPicker.1.maximumImageSizeInMb = 3
        mediaPicker.1.maximumVideoSizeInMb = 5
        mediaPicker.0.modalTransitionStyle = .crossDissolve
        mediaPicker.0.modalPresentationStyle = .custom
        present(mediaPicker.0, animated: false, completion: nil)

Actionsheet can not be displayed in ipad so, we need to make UIPopOverController, to choose between camera and gallery when used in iPad. <br>
Thus, add:

        mediaPicker.1.sourceView = your button or view where the popover controller is to be presenter


  Here <br>
  `let mediaPicker =   MediaPickerViewController.getMediaPicker(with: .camera)`

  returns {`UINavigationcontroller, MediaPickerViewController`},
  `MediaPickerViewController` instance is the root of `UINavigationcontroller` returned.

  If you want a default configuration:
  ` mediaPicker.1.setDefaultImagePickerConfiguration()`

      func setDefaultImagePickerConfiguration() {
        pickerMode = .all
        mediaType = .all
        isCroppingEnabled = true
        croppingStyle = .default
        aspectRatioPreset = .presetSquare
        aspectRatioLockEnabled = true
        resetAspectRatioEnabled = false
        rotateButtonsHidden = true
      }

Now add delegate to get the selected media in your view controller: <br>

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
