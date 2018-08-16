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
    
    
    var podcast = [Podcast(trackName:"Viswa", artistName: "Viswajith Kodela"),
                   Podcast(trackName:"Mounika", artistName: "Mounika Kodela")]
    
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
        
        let url = "https://itunes.apple.com/search"
        let paramenters = ["term": searchText, "media": "podcast"]
        
        Alamofire.request(url, method: .get, parameters: paramenters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if dataResponse.error != nil{
                print("Failed to connect to Podcasts")
            }
            guard let data = dataResponse.data else {return}
            
            do{
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                self.podcast = searchResults.results
                self.tableView.reloadData()
            }catch{
                print(error)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
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

