//
//  FileUploader.swift
//  MusicSync
//
//  Created by Johnathan Grayson on 19/06/2017.
//  Copyright © 2017 Johnathan Grayson. All rights reserved.
//

import UIKit
import AVFoundation

class FileUploader: NSObject {

    func uploadRequest(track: MusicTrack, whenCompleted: @escaping () -> Void, whenFailed: @escaping () -> Void) {
        let myUrl = URL(string: "http://172.20.10.8:8080/upload/");
        
        let request = NSMutableURLRequest(url: myUrl!);
        request.httpMethod = "POST";
        
        let params : [String : String] = [
            "trackName"  : track.title
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        export(track.path) { (url, error) in
            if (error == nil) {
                let trackData = NSData(contentsOf: url!)
                if (trackData == nil)  { return; }
                
                request.httpBody = self.createBodyWithParameters(parameters: params, filePathKey: "file", dataKey: trackData! as Data, boundary: boundary)
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                    data, response, error in
                    
                    if error != nil {
                        whenFailed()
                        return
                    }

                    // Print out reponse body
                    // let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

                    do {
                        // let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
 
                        DispatchQueue.main.async(execute: {
                            whenCompleted()
                        });
                    }
                    catch
                    {
                        whenFailed()
                    }
                }
                
                task.resume()
            } else {
                whenFailed()
            }
        }
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, dataKey: Data, boundary: String) -> Data {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "file.mp4"
        let mimetype = "audio/mp4"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(dataKey)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, nil)
            return
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")
        
        exporter.outputURL = fileURL
        exporter.outputFileType = "com.apple.m4a-audio"
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
