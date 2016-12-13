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

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var messageLabel: UILabel!
    var qrFrameView: UIView!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // and now, the video recording takes place asynchronously
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        qrFrameView = UIView()
        
             // this is the capture device which captures the video
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input =  AVCaptureDeviceInput()
        do {
                input = try AVCaptureDeviceInput(device: captureDevice)
            }
        catch {
            print("Could not access camera. Exiting. ")
            return
        }
     
        // using a capture Session to coordinate flow of data from input to output
        
        if (captureSession.canAddInput(input)) {
            captureSession.addInput(input)
        }
        else {
            print("cannot add input!")
            return
        }
        

        // instantiating output now

        let metaDataOutput =  AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metaDataOutput)) {
            captureSession.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // now, we must specify what type of meta data we are interested in
            metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            print("cannot add output")
            return
        }
        
        /* to show the video thats being recorded, we need to use an
        AVCaptureVideoPreviewLayer which does exactly that */

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        view.bringSubview(toFront: messageLabel)
        
        print("Input: \(captureSession.inputs)")
        print("Output: \(captureSession.outputs)")
        captureSession.startRunning()
    // QR Scanning logic
    }
    
    
    private func openUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK:- AVCaptureMetadataOutputObjects Delegate Methods
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        print("in delegate")
        // check if metadataObject is nil or empty 
        
        if metadataObjects == nil || metadataObjects.isEmpty {
            qrFrameView.frame = CGRect.zero // there is on qrFrame if there is no QR code
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
            let qrCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject)
            // tranforedMetadataObject returns a metadataObject whose visual properties have been converted into layer coordinates and can be extracted from this object 
            
            qrFrameView.frame = (qrCodeObject?.bounds)!
            
            if metadataObject.stringValue != nil {
                print("got the string value!")
                print(metadataObject.stringValue)
                DispatchQueue.main.async {
                    self.messageLabel.text = "Last Scanned: " + metadataObject.stringValue
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    self.openUrl(urlString: metadataObject.stringValue)
                }
            }
        }
    }
 }
