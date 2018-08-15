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
        
        let searchBarNavController = UINavigationController(rootViewController: SearchBarController())
        searchBarNavController.tabBarItem.title = "Search"
        searchBarNavController.tabBarItem.image = #imageLiteral(resourceName: "search")
        
        let favoritesNavController = UINavigationController(rootViewController: FavoritesController())
        favoritesNavController.tabBarItem.title = "Favorites"
        favoritesNavController.tabBarItem.image = #imageLiteral(resourceName: "favorites")
        
        viewControllers = [searchBarNavController, favoritesNavController]
    }
    
}
