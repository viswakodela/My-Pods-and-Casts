//
//  Extensions.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/23/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode] {
        
        let imageUrl = self.iTunes?.iTunesImage?.attributes?.href
        var episodes = [Episode]()
        self.items?.forEach({ (feeditem) in
            var episode = Episode(feedItem: feeditem)
            
            if feeditem.iTunes?.iTunesImage?.attributes?.href == nil{
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
    }
    
}
