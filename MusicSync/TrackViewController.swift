//
//  TrackViewController.swift
//  MusicSync
//
//  Created by Johnathan Grayson on 9/01/15.
//  Copyright (c) 2015 Johnathan Grayson. All rights reserved.
//

import UIKit

import MediaPlayer

import AVFoundation

class TrackViewController: UIViewController {

    var list : ListTableViewController!
    
    var track : MPMediaItem!
    
    var timer : NSTimer!
    
    var exporter : AVAssetExportSession!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func uploadClicked(sender: AnyObject) {
        self.upload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.nameLabel.text = self.track.title + (self.track.cloudItem ? " (Cloud)" : " (Device)")
        
        self.progressView.progress = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func upload() {
        var assetUrl : NSURL = self.track.valueForProperty(MPMediaItemPropertyAssetURL) as NSURL
        
        var asset : AVURLAsset = AVURLAsset(URL: assetUrl, options: nil)
        
        self.exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        
        exporter.outputFileType = "com.apple.m4a-audio"
        
        var file = NSHomeDirectory().stringByAppendingString("/Documents/exported.m4a")
        
        println(file)
        
        var exportUrl = NSURL(fileURLWithPath: file)
        
        var error : NSError?
        NSFileManager().removeItemAtURL(exportUrl!, error: nil)
        
        exporter.outputURL = exportUrl
        
        exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
            var exportStatus = self.exporter.status
            
            switch (exportStatus) {
                case AVAssetExportSessionStatus.Failed:
                    println("AVAssetExportSessionStatusFailed");
                    // log error to text view
//                    NSError *exportError = exporter.error;
//                    NSLog (@"AVAssetExportSessionStatusFailed: %@",
//                    exportError);
//                    errorView.text = exportError ?
//                    [exportError description] : @"Unknown failure";
//                    errorView.hidden = NO;
                    
                    println(self.exporter.error)
                    println(self.exporter.description)
                    break;
                case AVAssetExportSessionStatus.Completed:
                    println("AVAssetExportSessionStatusCompleted");
                    
                    
//                    NSLog (@"AVAssetExportSessionStatusCompleted");
//                    fileNameLabel.text =
//                    [exporter.outputURL lastPathComponent];
//                    // set up AVPlayer
//                    [self setUpAVPlayerForURL: exporter.outputURL];
//                    [self enablePCMConversionIfCoreAudioCanOpenURL:
//                    exporter.outputURL];
                    
                    self.sendFile(file)
                    
                    break;
                case AVAssetExportSessionStatus.Unknown:
                    println("AVAssetExportSessionStatusUnknown");
                    break;
                
                case AVAssetExportSessionStatus.Exporting:
                    println("AVAssetExportSessionStatusExporting");
                    break;
                
                case AVAssetExportSessionStatus.Cancelled:
                    println("AVAssetExportSessionStatusCancelled");
                    break;
                case AVAssetExportSessionStatus.Waiting:
                    println("AVAssetExportSessionStatusWaiting");
                    break;
                default:
                    println ("didn't get export status");
                    break;
            }
        }
        
        self.watchProgress()
        
        //var exportFile =
        
        /*AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
            initWithAsset: songAsset
            presetName: AVAssetExportPresetAppleM4A];
        
        NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        
        NSString *exportFile = [myDocumentsDirectory()
        
        stringByAppendingPathComponent: @"exported.m4a"];
        
        myDeleteFile(exportFile);
        
        [exportURL release];
        
        exportURL = [[NSURL fileURLWithPath:exportFile] retain];
        
        exporter.outputURL = exportURL;*/
        
        //NSURL *assetURL = [song valueForProperty:MPMiaItemPropertyAssetURL];
        //AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    }
    
    func applicationDocumentsDirectory() -> String! {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        //let basePath: String? = (paths.count > 0) ? paths[0] as? String : nil
        return paths[0] as String
    }
    
    func watchProgress() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "updateProgress:", userInfo: nil, repeats: true)
    }
    
    func updateProgress(timer: NSTimer) {
        self.progressView.progress = self.exporter.progress
    }
    
    func sendFile(file : String!) {
        var fileUrl = NSURL(fileURLWithPath: file)
        var data = NSData(contentsOfURL: fileUrl!)
        var len = data?.length
        
        self.progressView.progress = 0
        
        if(self.list.status == "Connected") {
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
            
            dispatch_async(backgroundQueue, {
                self.uploadBytes(data!, len: len!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    println("Upload completed!!! Aysnc Ending")
                    
                    self.sendStopSignal()
                    self.uploadComplete()
                })
            })
        }
    }
    
    func uploadBytes(data : NSData, len : Int) {
        var didSend = true
        var sendDataIndex = 0
        
        self.sendStartSignal()
        
        while (didSend) {
            // Work out how big it should be
            var amountToSend = data.length - sendDataIndex;
            
            // Can't be longer than 20 bytes
            if (amountToSend > 20) {
                amountToSend = 20
            }
            
            if(amountToSend == 0) {
                
                return
            }
            
            //self.progressView.progress = Float(sendDataIndex) / Float(len)
            
            dispatch_async(dispatch_get_main_queue(),{
                //let delegateObj =
                //delegateObj.
                self.progressView.progress = Float(sendDataIndex) / Float(len)
            });
            
            println(Float(sendDataIndex) / Float(len))
            
            // Copy out the data we want
            var chunk = NSData(bytes: (data.bytes + sendDataIndex), length:amountToSend);
            
            sendDataIndex += amountToSend
            
            self.list.ble.write(chunk)
            
        }

    }

    func sendStartSignal() {
        var cmd : [Byte] = [getByte("S"), getByte("O"), getByte("M")]
        
        var data : NSData? = NSData(bytes: cmd, length: 3)
        
        self.list.ble.write(data)
    }
    
    func sendStopSignal() {
        var cmd : [Byte] = [getByte("E"), getByte("O"), getByte("M")]
        
        var data : NSData? = NSData(bytes: cmd, length: 3)
        
        self.list.ble.write(data)
    }
    
    func getByte(a : String!) -> Byte {
        return a.utf8[a.utf8.startIndex]
    }
    
    func uploadComplete() {
        println("upload completed")
    }

}
