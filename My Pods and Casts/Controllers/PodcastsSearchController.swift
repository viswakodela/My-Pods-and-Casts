//
//  ViewController.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/15/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    
    
    let podcast = [Podcast(name:"Viswa", artistName: "Viswajith Kodela"),
                   Podcast(name:"Mounika", artistName: "Mounika Kodela")]
    
    let cellid = "cellId"
    
    //SearchBarController Implementation
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellid)
        setUpsearchBar()  
    }
    
    fileprivate func setUpsearchBar(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self
//        searchController.dimsBackgroundDuringPresentation = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text ?? "")
    }
}

//MARK:- UITableViewController functions

extension PodcastsSearchController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcast.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath)
        
        let podcast = self.podcast[indexPath.row]
        cell.textLabel?.numberOfLines = -1
        cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        
        return cell
    }
    
    
    
}

