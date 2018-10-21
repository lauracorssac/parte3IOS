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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var option: MenuOption = .original
    
    var captureSession: AVCaptureSession?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var videoPreviewOutput: AVCaptureVideoDataOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var viewAnimator: ViewAnimator?
    //var didOutputNewImage: ((UIImage) -> Void)?
    
    var context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = OpenCVWrapper.gaussianBlur(#imageLiteral(resourceName: "gigio"))
        configureSession()
        viewAnimator = ViewAnimator(mainView: self.view, viewToTap: headerView, heightConstraint: containerHeightConstraint)
        presentMenuVC()
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
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        self.rearCamera = session.devices.first

        if let rearCamera = self.rearCamera {
            try? rearCamera.lockForConfiguration()
            rearCamera.focusMode = .autoFocus
            rearCamera.unlockForConfiguration()
        }
        
        if let rearCamera = self.rearCamera {
            
            // we try to create the input from the found camera
            self.rearCameraInput = try? AVCaptureDeviceInput(device: rearCamera)
            
            if let rearCameraInput = rearCameraInput {
                
                // always make sure the AVCaptureSession can accept the selected input
                if captureSession?.canAddInput(rearCameraInput) ?? false {
                    
                    // add the input to the current session
                    captureSession?.addInput(rearCameraInput)
                }
            }
        }
        
        if let captureSession = captureSession {
            // create the preview layer with the configuration you want
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoPreviewLayer?.connection?.videoOrientation = .portrait
            
            // then add the layer to your current view
            self.photoContainerView.layer.insertSublayer(self.videoPreviewLayer!, at: 0)
            self.videoPreviewLayer?.frame = self.photoContainerView.frame
        }
        
        self.videoPreviewOutput = AVCaptureVideoDataOutput()
        videoPreviewOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)] as! [String : Any]
        self.videoPreviewOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        
        // always make sure the AVCaptureSession can accept the selected output
        if captureSession?.canAddOutput(self.videoPreviewOutput!) ?? false {
            
            // add the output to the current session
            captureSession?.addOutput(self.videoPreviewOutput!)
        }
        guard let connection = videoPreviewOutput?.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = false
        self.captureSession?.startRunning()
        
    }
   
    func display(image: UIImage) {
        
        var newImage = UIImage()
        
        switch self.option {
        case .contrast:
            newImage = OpenCVWrapper.contrast(image, alpha: 0.5)
        case .negative:
            newImage = OpenCVWrapper.negative(image)
        case .brightness:
            newImage = OpenCVWrapper.brightness(image, beta: 50)
        case .original:
            newImage = image
        case .flipVertical:
            newImage = OpenCVWrapper.flipVertical(image)
        case .flipHorizontal:
            newImage = OpenCVWrapper.flipHorizontal(image)
        case .grayScale:
            newImage = OpenCVWrapper.toGray(image)
        case .startRecording:
            //newImage = OpenCVWrapper.
            break
        case .stopRecording:
            //newImage = OpenCVWrapper.contrast(image, alpha: 0.5)
            break
        case .sobel:
            newImage = OpenCVWrapper.sobel(image)
        case .canny:
            newImage = OpenCVWrapper.canny(image)
        case .gaussianBlur:
            newImage = OpenCVWrapper.gaussianBlur(image)
        case .rotate:
            newImage = OpenCVWrapper.rotate(image)
        case .scale:
            //newImage = OpenCVWrapper.contrast(image, alpha: 0.5)
            break
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.imageView.image = OpenCVWrapper.flipHorizontal(newImage)
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
        
        display(image: image)
//        DispatchQueue.main.async { [unowned self] in
//            self.imageView.image = OpenCVWrapper.rotate(image)
//        }
    }
    
}
extension ViewController: ControlVCDelegate {
    func didSelect(option: MenuOption) {
        self.option = option
    }
}
