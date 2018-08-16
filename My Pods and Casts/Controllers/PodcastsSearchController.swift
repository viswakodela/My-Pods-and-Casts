//
//  ViewController.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/15/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    
    var podcast = [Podcast]()
    
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
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        APIService.shared.fetchPodCasts(searchText: searchText) { (searchResults) in
            let results = searchResults.results
            self.podcast = results
            self.tableView.reloadData()
        }
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
        cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }
    
    
    
}

