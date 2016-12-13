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
    var qrFrameView: UIView?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
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
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        

        // instantiating output now

        let metaDataOutput =  AVCaptureMetadataOutput()
        captureSession?.addOutput(metaDataOutput)

        // Setting self as MetaData Receiver Delegate which will be taken care of in the del methods

        /* process of capturing is highly time consuming. It's preferred to dispatch
        this process on a serial queue */

        let serialQueue = DispatchQueue(label: "QRserialQueue")
        metaDataOutput.setMetadataObjectsDelegate(self, queue: serialQueue)

        // now, we must specify what type of meta data we are interested in

        metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

        /* to show the video thats being recorded, we need to use an
        AVCaptureVideoPreviewLayer which does exactly that */

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        view.bringSubview(toFront: messageLabel)
         
        // and now, the video recording takes place asynchronously
        captureSession?.startRunning()
        
    // QR Scanning logic
    }
    
    // MARK:- AVCaptureMetadataOutputObjects Delegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        print("in delegate")
        // check if metadataObject is nil or empty 
        
        if metadataObjects == nil || metadataObjects.isEmpty {
            qrFrameView?.frame = CGRect.zero // there is on qrFrame if there is no QR code
            DispatchQueue.main.async {
                self.messageLabel.text = "Looks like there's nothing here..."
            }
            return
        }
        
        // else we have valid metadata
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // now this metadata can be of any type. The type that we are interested in 
        // is MetaData related to QRCode
        if metadataObject.type == AVMetadataObjectTypeQRCode {
            // get the layer coordinates of the QRCode metadata 
            print("qr code detected!")
            let qrCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            // tranforedMetadataObject returns a metadataObject whose visual properties have been converted into layer coordinates and can be extracted from this object 
            
            qrFrameView?.frame = (qrCodeObject?.bounds)!
            
            if metadataObject.stringValue != nil {
                print("got the string value!")
                print(metadataObject.stringValue)
                DispatchQueue.main.async {
                    self.messageLabel.text = metadataObject.stringValue
                }
            }
        }
    }
 }
