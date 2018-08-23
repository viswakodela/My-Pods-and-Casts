//
//  EpisodeCellTableViewCell.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodePubDate: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeDescription: UILabel!
    
    var episode: Episode? {
        didSet{
            
            episodeTitle.text = episode?.title
            episodeDescription.text = episode?.description
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "MMM dd, yyyy"
            
            guard let date = episode?.pubDate else {return}
            episodePubDate.text = dateformatter.string(from: date)
            
            guard let imageUrl = episode?.imageUrl else {return}
            guard let url = URL(string: imageUrl) else {return}
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    
}
