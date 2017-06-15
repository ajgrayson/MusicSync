//
//  ListTableViewController.swift
//  MusicSync
//
//  Created by Johnathan Grayson on 9/01/15.
//  Copyright (c) 2015 Johnathan Grayson. All rights reserved.
//

import UIKit
import MediaPlayer

class ListTableViewController: UITableViewController {

    var status = "Searching"
    
    var music : [MusicTrack]!
    
    @IBAction func connectClicked(_ sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
        //self.tableView.separatorStyle = .none
        self.tableView.separatorInset = .zero
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        self.music = []
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.loadMusic()
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            } else {
                self.displayMediaLibraryError()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.music.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as UITableViewCell

        let item = self.music[indexPath.item]
        
        // Configure the cell...
        cell.textLabel!.text = item.title
        cell.detailTextLabel!.text = item.album
        if item.selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let track = self.music[indexPath.item]
        track.selected = false
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = self.music[indexPath.item]
        track.selected = true
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func loadMusic() {
        let albumTitleFilter = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyHasProtectedAsset, comparisonType: MPMediaPredicateComparison.contains)
        
        let myFilterSet: Set<MPMediaPropertyPredicate> = [albumTitleFilter]
        
        let query = MPMediaQuery(filterPredicates: myFilterSet)
        
        for item in query.items! {
            let track = MusicTrack()
            track.title = item.title!
            track.album = item.albumTitle!
            track.selected = false
            self.music.append(track)
        }
    }

    func displayMediaLibraryError() {
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}
