//
//  MainTabBarController.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/15/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBar.tintColor = .purple
        tabBar.unselectedItemTintColor = .gray
        
        tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        
        let favoritesNavController = generateNavigationController(with: FavoritesController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites"))
        
        let searchBarNavController = generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search"))
        
        let downLoadsNavController = generateNavigationController(with: downloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        
        viewControllers = [favoritesNavController, searchBarNavController, downLoadsNavController]
        print(tabBar.frame)
        setUpPlayerDetailView()
//        perform(#selector(maximizePlayerDetails), with: nil, afterDelay: 1)
    }
    
    func maximizePlayerDetails(episode: Episode?) {
        
        minimizedTopAnchorConstraint?.isActive = false
        maximizedTopAnchorConstraint?.isActive = true
        maximizedTopAnchorConstraint?.constant = 0
        
        self.bottomAnchorConstraint?.constant = 0
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.miniPlayerView.isHidden = true
//            self.playerDetailsView.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
        }, completion: nil)
    }
    
    func minimizePlayerDetails() {
        maximizedTopAnchorConstraint?.isActive = false
        bottomAnchorConstraint?.constant = view.frame.height
        minimizedTopAnchorConstraint?.isActive = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.isHidden = false
            self.playerDetailsView.miniPlayerView.alpha = 1
        }, completion: nil)
    }
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint?
    var minimizedTopAnchorConstraint: NSLayoutConstraint?
    var bottomAnchorConstraint: NSLayoutConstraint?
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    
    func setUpPlayerDetailView() {
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        
        playerDetailsView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        playerDetailsView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint?.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//        minimizedTopAnchorConstraint?.isActive = true
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint?.isActive = true
    }
    
    //MARK:- Helper Function
    
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController{
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        return navigationController
        
    }
    
}
