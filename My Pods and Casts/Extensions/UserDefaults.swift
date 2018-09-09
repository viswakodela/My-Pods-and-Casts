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
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    func savedPodcasts() -> [Podcast] {
        
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoretedPodcastKey) else {return []}
        guard let savedPodcast = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else {return []}
        return savedPodcast
    }
    
    func downloadEpisodes(episode: Episode) {
        
        do {
            var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            downloadedEpisodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        } catch {
            print("Failed to Encode the Episode into UserDefaults:", error)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodeKey) else {return []}
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: data)
            return episodes
        } catch {
            print("Error Decoding the dat from UserDefaults", error)
        }
        return []
    }
}
