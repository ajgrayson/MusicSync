//
//  UISyncTableViewController.swift
//  MusicSync
//
//  Created by Johnathan Grayson on 19/06/2017.
//  Copyright © 2017 Johnathan Grayson. All rights reserved.
//

import UIKit

class UISyncTableViewController: UITableViewController {

    @IBAction func beginSync(_ sender: Any) {
        self.uploadNext()
    }
    
    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var trackName: UILabel!
    
    var tracksToSync : [MusicTrack]!
    var progress = 0
    var headerTitle = "No Tracks Selected"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.headerTitle = "Sync " + String(tracksToSync.count) + " tracks"
        self.progressIndicator.progress = 0
        self.progress = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.headerTitle
    }
    
    // MARK: - Sync
    
    func uploadNext() {
        self.progressIndicator.progress = Float(self.progress / self.tracksToSync.count)
        
        if (self.progress < self.tracksToSync.count) {
            let track = self.tracksToSync[self.progress]
            self.trackName.text = String(self.progress + 1) + " / " + String(tracksToSync.count) + " " + track.title
            self.uploadTrack(track: track)
            self.progress += 1
        } else {
            self.trackName.text = String(tracksToSync.count) + " / " + String(tracksToSync.count) + " Upload complete"
        }
    }
    
    func uploadTrack(track: MusicTrack) {
        let uploader = FileUploader()
        uploader.uploadRequest(track: track, whenCompleted: {
            self.uploadNext()
        }) { 
            self.uploadNext()
        }
    }
}
