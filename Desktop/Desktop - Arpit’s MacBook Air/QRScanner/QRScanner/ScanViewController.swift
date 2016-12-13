//
//  ViewController.swift
//  QRScanner
//
//  Created by Arpit Hamirwasia on 2016-12-13.
//  Copyright © 2016 Arpit. All rights reserved.
//
 
import UIKit
import AVFoundation
import Foundation

class ScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
     @IBOutlet weak var messageLabel: UILabel!
 
     override func viewDidLoad() {
         super.viewDidLoad()
     
             // this is the capture device which captures the video
         let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
         var input =  AVCaptureDeviceInput()
         do {
                 input = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
             }
         catch {
                print("Could not access camera. Exiting. ")
                return
             }
     
             // using a capture Session to coordinate flow of data from input to output
         let captureSession = AVCaptureSession()
         captureSession.addInput(input)
        
 
         // instantiating output now
 
         let metaDataOutput =  AVCaptureMetadataOutput()
         captureSession.addOutput(metaDataOutput)

         // Setting self as MetaData Receiver Delegate which will be taken care of in the del methods
 
         /* process of capturing is highly time consuming. It's preferred to dispatch
          this process on a serial queue */
 
         let serialQueue = DispatchQueue(label: "QRserialQueue")
         metaDataOutput.setMetadataObjectsDelegate(self, queue: serialQueue)
 
         // now, we must specify what type of meta data we are interested in
 
         metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
 
         /* to show the video thats being recorded, we need to use an
          AVCaptureVideoPreviewLayer which does exactly that */
 
         let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
         videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
         videoPreviewLayer?.frame = view.layer.bounds
         view.layer.addSublayer(videoPreviewLayer!)
         view.bringSubview(toFront: messageLabel)
         
         // and now, the video recording takes place asynchronously
         captureSession.startRunning()
        
        // QR Scanning logic 
        
        // MARK:- AVCaptureMetadataOutputObjects Delegate Methods 
        
        
    }
 }
