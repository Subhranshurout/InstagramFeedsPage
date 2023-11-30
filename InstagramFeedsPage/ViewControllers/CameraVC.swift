//
//  CameraVC.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 23/10/23.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

class CameraVC: UIViewController {
    //MARK: Outlets
    @IBOutlet var crossBtn: UIButton!
    @IBOutlet var switchCameraBtnClick: UIImageView! {
        didSet {
            switchCameraBtnClick.isUserInteractionEnabled = true
            switchCameraBtnClick.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCameraType)))
        }
    }
    @IBOutlet var torchButton: UIButton!
    @IBOutlet var clickView: UIView!
    @IBOutlet var clickImagesBtn: UIButton!
    @IBOutlet var cameraView: UIView!
    
    //MARK: Properties
    var session: AVCaptureSession?
    /// for recording video
    var movieOutput = AVCaptureMovieFileOutput()
    /// camera output
    var output = AVCapturePhotoOutput()
    /// for camera view
    var previewLayer = AVCaptureVideoPreviewLayer()
    /// camera input
    var input : AVCaptureDeviceInput?
    /// for recording audio for video
    var audioInput : AVCaptureDeviceInput?
    /// manageing front and back caera
    var devicePosition: AVCaptureDevice.Position = .back
    var customAlbumLocalIdentifier: String?
    var videoMode = false
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAudioAuthorizationStatus()
        checkPhotosAuthorizationStatus()
        checkCameraAuthorizationStatus()
        prepareUI()
        clickImagesBtn.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(recoedVideo)))
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.frame = cameraView.bounds
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.session?.startRunning()
        }
    }
    
    
    //Prepareing User interface
    func prepareUI() {
        cameraView.layer.cornerRadius = 8.0
        clickView.makeCircularView(with: .white, boarder: 3.0)
        clickView.backgroundColor = .clear
        clickImagesBtn.makeCircularViewBtn()
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.cornerRadius = 8.0
    }
    //Authentication for audio
    ///audio authentication is needed for video recording
    func checkAudioAuthorizationStatus() {
        func requestMicrophonePermission() {
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("Audio access granted")
                } else {
                    self.popupAlert(title: "Audio access denied", message: "Audio permission is required for this app to record videos. Please grant permission from the app settings.")
                }
            }
        }
    }
    
    //Authentication for Photos
    ///photos authentication is needed for saving photos to gallery
    func checkPhotosAuthorizationStatus() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined, .restricted, .denied, .limited :
                self.popupAlert(title: "Photos access denied", message: "Photos permission is required for this app to function. Please grant permission from the app settings.")
            case .authorized:
                print("Photos access granted")
            @unknown default:
                break
            }
        }
    }
    
    //Authentication for camera
    ///camera authentication is needed for photo and video
    func checkCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    self?.popupAlert(title: "Camera Permission Denied", message: "Camera permission is required for this app to function. Please grant permission from the app settings.")
                    return
                }
                DispatchQueue.main.async {
                    self?.setupCameraAndVideoCapture()
                }
            }
        case .restricted, .denied:
            popupAlert(title: "Camera Permission Denied", message: "Camera permission is required for this app to function. Please grant permission from the app settings.")
        case .authorized:
            setupCameraAndVideoCapture()
        @unknown default:
            break
        }
    }
  
}
//MARK: - Helper Methods: -
extension CameraVC {
    func popupAlert(title : String ,message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func createCustomAlbumIfNeeded() {
        let albumName = "InstagramFeedsPage"
        
        /// Check if the album already exists
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let customAlbum = collection.firstObject {
            /// The album already exists, store its localIdentifier
            customAlbumLocalIdentifier = customAlbum.localIdentifier
        } else {
            /// Create a new album
            PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            } completionHandler: {  success, error in
                if success {
                    /// Album created successfully, store its localIdentifier
                    if let customAlbum = collection.firstObject {
                        self.customAlbumLocalIdentifier = customAlbum.localIdentifier
                    }
                } else if let error = error {
                    print("Error creating album: \(error)")
                }
            }
        }
    }
    
    func setupCameraAndVideoCapture() {
        session = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition) {
            do {
                input = try AVCaptureDeviceInput(device: device)
                
                if session?.canAddInput(input!) == true {
                    session?.addInput(input!)
                }
                
                if videoMode {
                    if let audio = AVCaptureDevice.default(for: .audio) {
                        audioInput = try AVCaptureDeviceInput(device: audio)
                        if session?.canAddInput(audioInput!) == true {
                            session?.addInput(audioInput!)
                        }
                    }
                    
                    if session?.canAddOutput(movieOutput) == true {
                        session?.addOutput(movieOutput)
                    }
                    
                    session?.sessionPreset = .high
                } else {
                    if session?.canAddOutput(output) == true {
                        session?.addOutput(output)
                    }
                    
                    session?.sessionPreset = .photo
                }
                
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                if let session = session, !session.isRunning {
                    DispatchQueue.global(qos: .background).async {
                        session.startRunning()
                    }
                }
            } catch {
                print("Error setting up the camera: \(error.localizedDescription)")
            }
        }
    }
    // Start recording the video
    func startVideoRecording() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoFilename = "output.mp4"
        let videoPath = documentsDirectory.appendingPathComponent(videoFilename)
        movieOutput.startRecording(to: videoPath, recordingDelegate: self)
    }
    // Stop recording the video
    func stopVideoRecording() {
        movieOutput.stopRecording()
    }
    
    //    func setupCamera() {
    //        session = AVCaptureSession()
    //        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition) {
    //            do {
    //                input = try AVCaptureDeviceInput(device: device)
    //                if session?.canAddInput(input!) == true {
    //                    session?.addInput(input!)
    //                }
    //                if session?.canAddOutput(output) == true {
    //                    session?.addOutput(output)
    //                }
    //                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    //                previewLayer.videoGravity = .resizeAspectFill
    //                previewLayer.session = session
    //                session?.sessionPreset = .photo
    //                if let session = session, !session.isRunning {
    //                    DispatchQueue.global(qos: .background).async {
    //                        session.startRunning()
    //                    }
    //                }
    //            } catch {
    //                print("Error setting up the camera: \(error.localizedDescription)")
    //            }
    //        }
    //    }
    //    func setupVideoCapture() {
    //        session = AVCaptureSession()
    //        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition), let audio = AVCaptureDevice.default(for: .audio) {
    //            do {
    //                input = try AVCaptureDeviceInput(device: device)
    //                audioInput = try AVCaptureDeviceInput(device: audio)
    //                if session?.canAddInput(input!) == true {
    //                    session?.addInput(input!)
    //                    session?.addInput(audioInput!)
    //                }
    //                if session?.canAddOutput(movieOutput) == true {
    //                    session?.addOutput(movieOutput)
    //                }
    //                previewLayer.videoGravity = .resizeAspectFill
    //                previewLayer.session = session
    //                session?.sessionPreset = .high
    //                if let session = session, !session.isRunning {
    //                    DispatchQueue.global(qos: .background).async {
    //                        session.startRunning()
    //                    }
    //                }
    //            } catch {
    //                print("Error setting up the camera: \(error.localizedDescription)")
    //            }
    //        }
    //    }
  
}
//MARK: - Phpicker Delegate Method
extension CameraVC :PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                } else if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "StoryPreviewVC") as! StoryPreviewVC
                        destinationVC.delegate = self
                        destinationVC.storyImage = image
                        if self.devicePosition == .back {
                            self.turnOffTorch()
                        }
                        self.navigationController?.present(destinationVC, animated: true)
                    }
                }
            }
        }
        
        picker.dismiss(animated:true)
    }
}

//MARK: - Button-Clicks: -
extension CameraVC {
    
    @IBAction func importImagesBtn(_ sender: Any) {
        print(#function)
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let phPickerVC = PHPickerViewController(configuration: config)
        phPickerVC.delegate = self
        self.present(phPickerVC, animated: true, completion: nil)
    }
    
    @IBAction func crossBtnClick(_ sender: Any) {
        if let pageViewController = self.parent as? PageViewController {
            pageViewController.setViewControllers([pageViewController.viewControllersList[1]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsBtnClick(_ sender: Any) {
        print("Settings button tapped")
    }
    
    @IBAction func flashBtnClick(_ sender: UIButton) {
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                try device.lockForConfiguration()
                if devicePosition == .back {
                    if device.hasTorch {
                        if device.torchMode == .on {
                            torchButton.setImage(UIImage(named: "flash (1)"), for: .normal)
                            device.torchMode = .off
                        } else {
                            try device.setTorchModeOn(level: 1.0)
                            torchButton.setImage(UIImage(named: "flash"), for: .normal)
                        }
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print("Error toggling flash: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func clickImageBtnClick(_ sender: UIButton) {
        print(#function)
        flashBtnClick(sender)
        if let session = session, session.isRunning {
            output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        } else {
            setupCameraAndVideoCapture()
        }
        flashBtnClick(sender)
    }
    @objc func recoedVideo(sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("began")
            do {
                session?.removeOutput(output)
                if let audio = AVCaptureDevice.default(for: .audio) {
                    audioInput =  try AVCaptureDeviceInput(device: audio)
                    if session?.canAddInput(audioInput!) == true {
                        session?.addInput(audioInput!)
                    }
                }
                if session?.canAddOutput(movieOutput) == true {
                    session?.addOutput(movieOutput)
                }
                session?.sessionPreset = .high
            } catch {
                print("Error setting up the camera: \(error.localizedDescription)")
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 3), execute: startVideoRecording)
        } else if sender.state == .ended {
            print("ended")
            stopVideoRecording()
            session?.removeInput(audioInput!)
            session?.removeOutput(movieOutput)
            setupCameraAndVideoCapture()
        }
    }
    @objc func toggleCameraType() {
        /// toggle between front and back  camera
        devicePosition = (devicePosition == .back) ? .front : .back
        /// animation
        let rotationAngle: CGFloat = (devicePosition == .back) ? 0.0 : .pi
        UIView.animate(withDuration: 1.0) {
            self.switchCameraBtnClick.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
        UIView.transition(with: cameraView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            /// Removing input and output before switching camaeras
            self.session?.removeInput(self.input!)
            self.session?.removeOutput(self.output)
            self.setupCameraAndVideoCapture()
        }) {  done in
            if done {
                /// hiding the torch button for front camera
                if self.devicePosition == .front {
                    self.torchButton.isHidden = true
                } else {
                    self.torchButton.isHidden = false
                }
            }
        }
    }
}


extension CameraVC : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        print("image output url : \(image)")
        if let error = error {
            print("Image click error: \(error)")
        } else {
            print("Image clicked")
            /// check if custom album is avaliable
            /// if not then create album
            createCustomAlbumIfNeeded()
            /// accessing the album using local identifier
            if let albumLocalIdentifier = customAlbumLocalIdentifier {
                PHPhotoLibrary.shared().performChanges {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier], options: nil).firstObject!)
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                    albumChangeRequest?.addAssets([assetPlaceholder!] as NSArray)
                } completionHandler: { success, error in
                    if success {
                        print("Image saved to custom album")
                    } else if let error = error {
                        print("Error saving image: \(error)")
                    }
                }
            }
            let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "StoryPreviewVC") as! StoryPreviewVC
            destinationVC.delegate = self
            destinationVC.storyImage = image
            if devicePosition == .back {
                turnOffTorch()
            }
            self.present(destinationVC, animated: true)
            
        }
        
    }
    func turnOffTorch() {
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                try device.lockForConfiguration()
                if device.torchMode == .on {
                    torchButton.setImage(UIImage(named: "flash (1)"), for: .normal)
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
extension CameraVC: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Video recording finished with error: \(error)")
        } else {
            print("Video recording finished")
        }
        /// check if custom album is avaliable
        /// if not then create album
        createCustomAlbumIfNeeded()
        print("Album identifier : \(customAlbumLocalIdentifier!)")
        /// accessing the album using local identifier
        if let albumLocalIdentifier = customAlbumLocalIdentifier {
            PHPhotoLibrary.shared().performChanges {
                print("Video output url : \(outputFileURL)")
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                if let assetPlaceholder = assetRequest?.placeholderForCreatedAsset {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier], options: nil).firstObject!)
                    albumChangeRequest?.addAssets([assetPlaceholder] as NSArray)
                }
            } completionHandler: { success, error in
                if success {
                    print("Video saved to custom album")
                } else if let error = error {
                    print("Error saving video: \(error)")
                }
            }
        }
    }
}

// MARK: - AddingStory :-
extension CameraVC : NewStory {
    func addStory(storyimage: UIImage,isCloseFriedStory : Bool) {
        if let pageViewController = self.parent as? PageViewController {
            pageViewController.setViewControllers([pageViewController.viewControllersList[1]], direction: .forward, animated: true, completion: nil)
            if let vc = pageViewController.viewControllersList[1] as? InstagramFeedsVC {
                vc.addMyStory(storyImage: storyimage, isCloseFriedStory : isCloseFriedStory)
                self.session?.stopRunning()
            }
            
        }
    }
}
