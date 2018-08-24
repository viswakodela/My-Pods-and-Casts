//
//  PlayerDetailsView.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/23/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
    
    @IBAction func dismissButton(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBOutlet weak var playerDetailsImageView: UIImageView!
    @IBOutlet weak var episodTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBAction func playPauseButton(_ sender: Any) {
        
    }
    
    
    
    
    var episode: Episode! {
        didSet{
            episodTitle.text = episode.title
            let imageUrl = episode.imageUrl ?? ""
            guard let url = URL(string: imageUrl) else {return}
            playerDetailsImageView.sd_setImage(with: url, completed: nil)
            authorLabel.text = episode.author
        }
    }
}
