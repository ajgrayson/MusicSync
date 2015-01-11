//
//  ListTableViewController.swift
//  MusicSync
//
//  Created by Johnathan Grayson on 9/01/15.
//  Copyright (c) 2015 Johnathan Grayson. All rights reserved.
//

import UIKit
import MediaPlayer

class ListTableViewController: UITableViewController, BLEDelegate {

    var ble : BLE!
    
    var device : CBPeripheral?
    
    var status = "Searching"
    
    @IBAction func connectClicked(sender: AnyObject) {
        self.findDevice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        ble = BLE()
        ble.controlSetup()
        ble.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
        return MPMediaQuery.songsQuery().items.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as UITableViewCell

        var item = MPMediaQuery.songsQuery().items[indexPath.item] as MPMediaItem
        
        // Configure the cell...
        cell.textLabel!.text = item.title
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openSettings") {
            var vc : SettingsViewController = segue.destinationViewController as SettingsViewController
            
            vc.list = self
        } else if (segue.identifier == "openTrack") {
            var vc : TrackViewController = segue.destinationViewController as TrackViewController
            
            vc.list = self
            
            var track = MPMediaQuery.songsQuery().items[self.tableView.indexPathForSelectedRow()!.item] as MPMediaItem
            
            vc.track =  track
        }
    }
    
    // MARK: - BLE
    
    func connectionTimer(timer: NSTimer) {
        self.device = nil
        
        if(self.ble.peripherals != nil && self.ble.peripherals.count > 0) {
            var i = 0, len = self.ble.peripherals.count;
            for(i = 0; i < len; i++) {
                var p : CBPeripheral = self.ble.peripherals.objectAtIndex(i) as CBPeripheral
                if(p.identifier != nil && p.identifier.UUIDString == "FE618D99-88A7-0E49-47EF-4A9062908AAC") {
                    self.device = p
                    self.status = "Connecting"
                    println("->Connecting");
                    self.ble.connectPeripheral(self.device)
                }
            }
        }
        
        if(self.device == nil) {
            self.findDevice()
        }
    }
    
    func refreshPeripherals() {
        self.status = "Searching"
        println("->Searching");
        
//        if(self.ble.activePeripheral != nil) {
//            return;
//        }
        
        if(self.ble.peripherals != nil) {
            self.ble.peripherals = nil
        }
        
        self.ble.findBLEPeripherals(3)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "connectionTimer:", userInfo: nil, repeats: false)
    }
    
    func findDevice() {
        //self.ble.connectPeripheral()
        self.refreshPeripherals()
    }
    
    func bleDidConnect()
    {
        println("->Connected");
        self.status = "Connected"
        //self.navigationItem.leftBarButtonItem?.title = "Connected"
        //self.navigationItem.leftBarButtonItem?.enabled = false
    }
    
    func bleDidDisconnect()
    {
        println("->Disconnected");
        self.status = "Disconnected"
        //self.navigationItem.leftBarButtonItem?.title = "Connect"
        //self.navigationItem.leftBarButtonItem?.enabled = true
        self.findDevice()
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {
        
    }

}
