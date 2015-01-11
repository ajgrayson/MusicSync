//
//  FilesTableTableViewController.swift
//  MusicSync
//
//  Created by Johnathan Grayson on 10/01/15.
//  Copyright (c) 2015 Johnathan Grayson. All rights reserved.
//

import UIKit

import MediaPlayer

import AVFoundation

class FilesTableViewController: UITableViewController, AVAudioPlayerDelegate {

    var filesList : [String]!
    
    var audioPlayer : AVAudioPlayer!
    
    @IBAction func playClicked(sender: AnyObject) {
        self.playTrack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.findFiles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.filesList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("fileCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        var file = self.filesList[indexPath.item]
        
        cell.textLabel?.text = file

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func findFiles() {
        self.filesList = [String]()

        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(applicationDocumentsDirectory())
        while let file = files?.nextObject() as String! {
            println(file)
            
            var attrs = NSFileManager().attributesOfItemAtPath(applicationDocumentsDirectory().stringByAppendingString("/").stringByAppendingString(file), error: nil)
            
            var size = attrs![NSFileSize] as NSNumber
            
            var sizeInMb = size.integerValue / 1000000
            
            self.filesList.append(file) // + " " + sizeInMb.description)
        }
    }
    
    func applicationDocumentsDirectory() -> String {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let basePath: AnyObject! = (paths.count > 0) ? paths.objectAtIndex(0) : nil
        return basePath as String;
    }
    
    func playTrack() {
        if(self.tableView.indexPathForSelectedRow() != nil) {            
            var fileName = self.filesList[self.tableView.indexPathForSelectedRow()!.item]
            
            var alertSound = NSURL(fileURLWithPath: NSHomeDirectory().stringByAppendingString("/Documents/".stringByAppendingString(fileName)))
            println(alertSound)
            
            // Removed deprecated use of AVAudioSessionDelegate protocol
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            var error:NSError?
            self.audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            
            
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.play()
            

        }
    }

}
