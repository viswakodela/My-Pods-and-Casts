//
//  downloadsController.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/15/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

class downloadsController: UITableViewController {
    
    let cellId = "episodeCellId"
    
    var downlaodedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.tableFooterView = UIView()
        
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgressNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownlaodComplete), name: .downloadCompleteNotification, object: nil)
        
    }
    
    @objc func handleDownlaodComplete(notification: Notification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let title = userInfo["title"] as? String else {return}
        guard let fileUrl = userInfo["fileUrl"] as? String else {return}
        
        guard let index = self.downlaodedEpisodes.index(where: { (ep) -> Bool in
            ep.title == title
        }) else {return}
        self.downlaodedEpisodes[index].fileUrl = fileUrl
        
    }
    
    
    @objc func handleDownloadProgress(notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String : Any] else {return}
        guard let title = userInfo["title"] as? String else {return}
        guard let progress = userInfo["progress"] as? Double else {return}
        
        guard let index = self.downlaodedEpisodes.index(where: { (ep) -> Bool in
            ep.title == title
        }) else {return}
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCellTableViewCell
        
        cell?.progressLabel.isHidden = false
        cell?.progressLabel.text = "\(Int(progress * 100))%"
        
        if progress == 1 {
            cell?.progressLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let episodes = UserDefaults.standard.downloadedEpisodes()
        self.downlaodedEpisodes = episodes
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.viewControllers?[2].tabBarItem.badgeValue = nil
        tableView.reloadData()
    }
    
    fileprivate func setupTableView () {
        
        let uiNib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: cellId)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downlaodedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCellTableViewCell
        let episodes = downlaodedEpisodes[indexPath.row]
        cell.episode = episodes
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episodes = self.downlaodedEpisodes[indexPath.row]
        
        if episodes.fileUrl != nil {
            let mainTabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
            mainTabController?.maximizePlayerDetails(episode: episodes, playListOfEpispdes: self.downlaodedEpisodes)
            print(episodes.fileUrl ?? "")
        } else {
            let alertController = UIAlertController(title: "The Episode is still in the process of Dowloading", message: "If you want to stream online press Yes", preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Yes", style: .default) { (alert) in
                let mainTabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                mainTabController?.maximizePlayerDetails(episode: episodes, playListOfEpispdes: self.downlaodedEpisodes)
            }
            
            alertController.addAction(action)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var episodes = UserDefaults.standard.downloadedEpisodes()
            episodes.remove(at: indexPath.row)
            
            do {
                let data = try JSONEncoder().encode(episodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
            }catch {
                print(error)
            }
            self.downlaodedEpisodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
