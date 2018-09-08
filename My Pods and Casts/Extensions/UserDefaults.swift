//
//  UserDefaults.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 9/7/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoretedPodcastKey = "favoretedPodcastKey"
    func savedPodcasts() -> [Podcast] {
        
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoretedPodcastKey) else {return []}
        guard let savedPodcast = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else {return []}
        return savedPodcast
    }
    
}
