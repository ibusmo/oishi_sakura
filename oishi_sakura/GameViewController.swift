//
//  GameViewController.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/17/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileVision

class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - UI elements
    @IBOutlet weak var placeHolder: UIView!
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: - Video objects
    
    var session: AVCaptureSession?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var lastKnownDeviceOrientation: UIDeviceOrientation?
    
    // MARK: - Detector
    
    var faceDetector: GMVDetector?
    
    // MARK: - Game scene
    
    var scene: GameScene?
    var skView: SKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // video
        self.session = AVCaptureSession()
        self.session?.sessionPreset = AVCaptureSessionPresetHigh
        self.updateCameraSelection()
        
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        
        self.setupVideoProcessing()
        self.setupCameraPreview()
        
        // gmvdetector
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorFaceMinSize: 0.3,
            GMVDetectorFaceTrackingEnabled: true,
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue
        ]
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        // game scene
        self.skView = SKView(frame: self.view.frame)
        self.skView?.backgroundColor = UIColor.clear
        
        self.scene = GameScene(size: UIScreen.main.bounds.size)
        self.scene?.scaleMode = .aspectFill
        self.scene?.backgroundColor = UIColor.clear
        self.skView?.presentScene(self.scene)
       
        self.skView?.ignoresSiblingOrder = true
        
        self.skView?.showsFPS = true
        self.skView?.showsNodeCount = true
        
        self.view.addSubview(self.skView!)
        self.view.bringSubview(toFront: self.skView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.previewLayer?.frame = self.view.layer.bounds
        self.previewLayer?.position = CGPoint(x: (self.previewLayer?.frame)!.midX, y: (self.previewLayer?.frame)!.midY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.stopRunning()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - AVCaptureVideoPreviewLayer Helper method
    
    func scaledRect(rect: CGRect, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGRect {
        let resultRect = CGRect(x: rect.origin.x * xScale, y: rect.origin.y * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
        return resultRect
    }
    
    func scaledPoint(point: CGPoint, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGPoint {
        let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: point.y * yScale + offset.y)
        return resultPoint
    }
    
    func scaledPointForScene(point: CGPoint, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGPoint {
        let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: UIScreen.main.bounds.size.height - (point.y * yScale + offset.y))
        return resultPoint
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer)
        // let image = UIImage(cgImage: GMVUtility.sampleBufferTo32RGBA(sampleBuffer).cgImage!, scale: 1.0, orientation: UIImageOrientation.left)
        
        let orientation = GMVUtility.imageOrientation(from: UIDevice.current.orientation, with: AVCaptureDevicePosition.front, defaultDeviceOrientation: .unknown)
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorImageOrientation: orientation.rawValue
        ]
        let faces = self.faceDetector?.features(in: image, options: options) as! [GMVFaceFeature]
        
        let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false)
        let parentFrameSize = self.previewLayer?.frame.size
        
        let cameraRatio = clap.size.height / clap.size.width
        let viewRatio = (parentFrameSize?.width)! / (parentFrameSize?.height)!
        var xScale: CGFloat = 1
        var yScale: CGFloat = 1
        var videoBox = CGRect.zero
       
        if (viewRatio > cameraRatio) {
            videoBox.size.width = (parentFrameSize?.height)! * clap.size.width / clap.size.height
            videoBox.size.height = (parentFrameSize?.height)!
            videoBox.origin.x = ((parentFrameSize?.width)! - videoBox.size.width) / 2
            videoBox.origin.y = (videoBox.size.height - (parentFrameSize?.height)!) / 2

            xScale = videoBox.size.width / clap.size.width
            yScale = videoBox.size.height / clap.size.height
        } else {
            videoBox.size.width = (parentFrameSize?.width)!
            videoBox.size.height = clap.size.width * ((parentFrameSize?.width)! / clap.size.height)
            videoBox.origin.x = (videoBox.size.width - (parentFrameSize?.width)!) / 2
            videoBox.origin.y = ((parentFrameSize?.height)! - videoBox.size.height) / 2

            xScale = videoBox.size.width / clap.size.height;
            yScale = videoBox.size.height / clap.size.width;
        }
        
        DispatchQueue.main.sync {
            // Remove previously added feature views.
            for featureView in self.overlayView.subviews {
                featureView.removeFromSuperview()
            }
            
            if (faces.count == 0) {
                self.scene?.noPointDetected()
            }
            
            // Display detected features in overlay.
            for face in faces {
                let faceRect = self.scaledRect(rect: face.bounds, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                DrawingUtility.addRectangle(faceRect, to: self.overlayView, with: UIColor.red)
                
                if (face.hasMouthPosition == true) {
                    let point = self.scaledPointForScene(point: face.mouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    // self.scene?.pointDetected(atPoint: point)
                    self.scene?.pointDetected(atPoint: point, headEulerAngleY: face.headEulerAngleY, headEulerAngleZ: face.headEulerAngleZ)
                }
                
                // Ears
                if (face.hasLeftEarPosition) {
                    let point = self.scaledPoint(point: face.leftEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overlayView, with: UIColor.purple, withRadius: 10)
                }
                
                if (face.hasRightEarPosition) {
                    let point = self.scaledPoint(point: face.rightEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overlayView, with: UIColor.purple, withRadius: 10)
                }
            }
        }
    }
    
    // MARK: - Camera Settings
    
    func cleanupVideoProcessing() {
        if ((self.videoDataOutput) != nil) {
           self.session?.removeOutput(self.videoDataOutput)
        }
        self.videoDataOutput = nil
    }
    
    func setupVideoProcessing() {
        self.videoDataOutput = AVCaptureVideoDataOutput()
        let rgbOutputSettings: Dictionary<AnyHashable, Any> = ["\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA]
        self.videoDataOutput?.videoSettings = rgbOutputSettings
        
        if (!(self.session?.canAddOutput(self.videoDataOutput))!) {
            self.cleanupVideoProcessing()
            return
        }
        
        self.videoDataOutput?.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput?.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
        self.session?.addOutput(self.videoDataOutput)
    }
    
    func setupCameraPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.backgroundColor = UIColor.clear.cgColor
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
        let rootLayer: CALayer = self.placeHolder.layer
        rootLayer.masksToBounds = true
        self.previewLayer?.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer!)
    }
    
    func updateCameraSelection() {
        self.session?.beginConfiguration()
        
        // Remove old inputs
        let oldInputs = self.session?.inputs
        for oldInput in oldInputs! {
            self.session?.removeInput(oldInput as! AVCaptureInput)
        }
        
        let desiredPosition = AVCaptureDevicePosition.front
        let input = self.cameraForPosition(desiredPosition: desiredPosition)
        
        if (input == nil) {
            for oldInput in oldInputs! {
                self.session?.addInput(oldInput as! AVCaptureInput)
            }    
        } else {
            self.session?.addInput(input!)
        }
        
        self.session?.commitConfiguration()
    }
    
    func cameraForPosition(desiredPosition: AVCaptureDevicePosition) -> AVCaptureDeviceInput? {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
            if (device.position == desiredPosition) {
                let input = try! AVCaptureDeviceInput(device: device)
                if ((self.session?.canAddInput(input))!) {
                    return input
                }
            }    
        }
        return nil
    }
    
}
