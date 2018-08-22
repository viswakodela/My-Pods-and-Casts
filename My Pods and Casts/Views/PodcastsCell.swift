//
//  PodcastsCell.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

class PodcastsCell: UITableViewCell {
    
    @IBOutlet weak var podCastsImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet{
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) episodes"
            
            guard let imageUrl = podcast.artworkUrl600 else {return}
            guard let url = URL(string: imageUrl) else {return}
            
            URLSession.shared.dataTask(with: url) { (data, _, _) in
//               print(data ?? "")
                guard let data = data else {return}
                DispatchQueue.main.async {
                    self.podCastsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
