//
//  EpisodesController.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    fileprivate let cellId = "episodeCellId"
    
    var episodes = [Episode]()
    
    var selectedPodcast: Podcast? {
        didSet{
            navigationItem.title = selectedPodcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        print(self.selectedPodcast?.feedUrl ?? "")
        guard let feedUrl = URL(string: selectedPodcast?.feedUrl ?? "") else {return}
        let parser = FeedParser(URL: feedUrl)
        parser?.parseAsync(result: { (result) in
            print(result.isSuccess)
            
            switch result {
                
            case let .rss(feed):
                var episodes = [Episode]()
                feed.items?.forEach({ (feeditem) in
//                    print(feeditem.title ?? "")
                    let episode = Episode(feedItem: feeditem)
                    episodes.append(episode)
                })
                self.episodes = episodes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
                
            case let .failure(error):
                print("Failed to parse feed:", error)
                break
                
            default: print("Found a feed")
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUptableView()
    }
    
    
    
    
//MARK:- Setup tableView
    func setUptableView() {
        let nib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "episodeCellId")
        tableView.tableFooterView = UIView()
    }
}

//MARK:- TableView Methods
extension EpisodesController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCellTableViewCell
        
        let episode = episodes[indexPath.row]
        cell.episode = episode
//        let episode = self.episodes[indexPath.row]
//        cell.textLabel?.numberOfLines = 0
//        cell.textLabel?.text = episode.title + "\n" + episode.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
