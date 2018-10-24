//
//  ViewController.swift
//  parte3IOS
//
//  Created by Laura Corssac on 16/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var options: [MenuOption] = []
    
    var captureSession: AVCaptureSession?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var movieCaptureOutput = AVCaptureMovieFileOutput()
    var videoPreviewOutput: AVCaptureVideoDataOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var viewAnimator: ViewAnimator?
    var outputURL: URL?
    
    var context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.slider.maximumValue = 50
        self.slider.minimumValue = 0
        self.slider.isContinuous = false
        self.slider.value = 0
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        configureSession()
        viewAnimator = ViewAnimator(mainView: self.view, viewToTap: headerView, heightConstraint: containerHeightConstraint)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentMenuVC()
        containerHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func presentMenuVC() {
       
        let viewController = MenuViewController(nibName: nil, bundle: nil)
        viewController.delegate = self
        self.addChildViewController(viewController)
        menuContainerView.addSubview(viewController.view)
        viewController.view.frame = menuContainerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
    
    
    func configureSession() {
        self.captureSession = AVCaptureSession()
        
        self.captureSession?.sessionPreset = AVCaptureSession.Preset.cif352x288
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        self.rearCamera = session.devices.first

        if let rearCamera = self.rearCamera {
            try? rearCamera.lockForConfiguration()
            rearCamera.focusMode = .autoFocus
            rearCamera.unlockForConfiguration()
        }
        
        if let rearCamera = self.rearCamera {
            
            self.rearCameraInput = try? AVCaptureDeviceInput(device: rearCamera)
            
            if let rearCameraInput = rearCameraInput {
                
                if captureSession?.canAddInput(rearCameraInput) ?? false {
                    
                    captureSession?.addInput(rearCameraInput)
                }
            }
        }
        
        if let captureSession = captureSession {
            
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoPreviewLayer?.connection?.videoOrientation = .portrait
            
            self.photoContainerView.layer.insertSublayer(self.videoPreviewLayer!, at: 0)
            self.videoPreviewLayer?.frame = self.photoContainerView.bounds
        }
        
        self.videoPreviewOutput = AVCaptureVideoDataOutput()
        videoPreviewOutput?.alwaysDiscardsLateVideoFrames = true
        videoPreviewOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)] as! [String : Any]
        self.videoPreviewOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))

        if captureSession?.canAddOutput(self.videoPreviewOutput!) ?? false {
            captureSession?.addOutput(self.videoPreviewOutput!)
            print("oi")
        }
        
        guard let connection = videoPreviewOutput?.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = false
        self.captureSession?.startRunning()
        
        
    }
    func startRecording() {
        
        if !movieCaptureOutput.isRecording {
            
            self.captureSession?.removeOutput(videoPreviewOutput!)
            
            if (captureSession?.canAddOutput(movieCaptureOutput))! {
                captureSession?.addOutput(movieCaptureOutput)
            }
            
            let connection = movieCaptureOutput.connection(with: .video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = .portrait
            }
            connection?.isVideoMirrored = false
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = .auto
            }
            
            let device = rearCameraInput?.device
            if (device?.isSmoothAutoFocusSupported)! {
                do {
                    try device?.lockForConfiguration()
                    device?.isSmoothAutoFocusEnabled = false
                    device?.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let url =  urls.first!.appendingPathComponent("output.mov")
            outputURL = url
            movieCaptureOutput.startRecording(to: outputURL!, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
    }
    func stopRecording() {
        
        if movieCaptureOutput.isRecording {
            movieCaptureOutput.stopRecording()
            captureSession?.removeOutput(movieCaptureOutput)
            if captureSession?.canAddOutput(self.videoPreviewOutput!) ?? false {
                captureSession?.addOutput(self.videoPreviewOutput!)
                
            }
            guard let connection = videoPreviewOutput?.connection(with: .video) else { return }
            guard connection.isVideoOrientationSupported else { return }
            guard connection.isVideoMirroringSupported else { return }
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = false
            
        }
    }
   
    func display(image: UIImage) {
        
        var newImage = image
        
        for option in options {
            switch option {
            case .contrast:
                DispatchQueue.main.async { [weak self] in
                    newImage = OpenCVWrapper.contrast(newImage, alpha: Double(self?.slider.value ?? 0 / 40))
                }
            case .negative:
                newImage = OpenCVWrapper.negative(newImage)
            case .brightness:
                DispatchQueue.main.async { [weak self] in
                    newImage = OpenCVWrapper.brightness(newImage, beta: Int32(self?.slider.value ?? 0 - 50) )
                }
            case .flipVertical:
                newImage = OpenCVWrapper.flipVertical(newImage)
            case .flipHorizontal:
                newImage = OpenCVWrapper.flipHorizontal(newImage)
            case .grayScale:
                newImage = OpenCVWrapper.toGray(newImage)
            case .startRecording:
                return
            case .sobel:
                newImage = OpenCVWrapper.sobel(newImage)
            case .canny:
                newImage = OpenCVWrapper.canny(newImage)
            case .gaussianBlur:
                DispatchQueue.main.async { [weak self] in
                    newImage = OpenCVWrapper.gaussianBlur(newImage, slider: Int32(self?.slider.value ?? 0))
                }
            case .rotate:
                newImage = OpenCVWrapper.rotate(newImage)
            case .scale:
                
                newImage = OpenCVWrapper.resize(newImage, size: CGSize(width: image.size.width / 2, height: image.size.height / 2))
            }
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.imageView.image = newImage
        }
        
    }
    
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        
        self.display(image: image)
    }
    
}
extension ViewController: ControlVCDelegate {
    func didDeselect(option: MenuOption) {
        if option == .startRecording {
            stopRecording()
            return
        }
        if option == .scale {
            imageView.contentMode = .scaleAspectFill
        }
        self.options.remove(at: self.options.index(of: option)!)
    }
    
    func didSelect(option: MenuOption) {
        if option == .startRecording {
            startRecording()
            return
        }
        if option == .scale {
            imageView.contentMode = .center
        }
        self.options.append(option)
    }
}
extension ViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("que comece a gravacao")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        } else {
            print(error!.localizedDescription)
        }
        outputURL = nil
    }
}
