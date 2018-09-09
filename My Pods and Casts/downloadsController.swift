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
        
        
        setupTableView()
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
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
//
//            guard let index = tableView.indexPathForSelectedRow else {return}
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.downlaodedEpisodes.remove(at: index.row)
//            tableView.reloadData()
//            var episodes = UserDefaults.standard.downloadedEpisodes()
//            episodes.remove(at: indexPath.row)
//        }
//        return [deleteAction]
//    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("printing")
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
