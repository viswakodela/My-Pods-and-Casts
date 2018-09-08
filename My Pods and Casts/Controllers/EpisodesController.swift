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

//MARK:- Fetching Episodes Function
    fileprivate func fetchEpisodes() {
        
        guard let feedUrl = self.selectedPodcast?.feedUrl else {return}
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUptableView()
        setUpNavigationBarButtons()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }
    
    fileprivate func setUpNavigationBarButtons() {
        navigationItem.rightBarButtonItems = [ UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
            UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetch))
        ]
    }
    @objc fileprivate func handleSaveFavorite() {
        print("Handling favorite")
        
        guard let podcast = self.selectedPodcast else {return}
        
        
        
        // 1. Transform Podcast into Data
        
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        
        UserDefaults.standard.set(data, forKey: UserDefaults.favoretedPodcastKey)
    }
    
    @objc fileprivate func handleFetch(){
        print("handling Fetch")
        
        // 2. Tranform Data into Podcast
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoretedPodcastKey) else {return}
        
        let savedPodcast = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        
        savedPodcast?.forEach({ (pod) in
            print(pod.trackName ?? "", pod.artistName ?? "")
        })
    }
    
    deinit {
        print("EpisodesView being reclaimed...")
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = .darkGray
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episodes = self.episodes[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mainTabBarControoler = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarControoler?.maximizePlayerDetails(episode: episodes, playListOfEpispdes: self.episodes)
        
//        guard let window = UIApplication.shared.keyWindow else {return}
//
//        let playerDetailsView = PlayerDetailsView.initFromNib()
//        playerDetailsView.episode = episodes
//        playerDetailsView.frame = window.frame
//        window.addSubview(playerDetailsView)
    }
}
