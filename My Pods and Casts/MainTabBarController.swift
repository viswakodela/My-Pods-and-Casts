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
        
        
        
        let favoritesNavController = generateNavigationController(with: FavoritesController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites"))
        
        let searchBarNavController = generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search"))
        
        let downLoadsNavController = generateNavigationController(with: downloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        
        viewControllers = [favoritesNavController, searchBarNavController, downLoadsNavController]
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
