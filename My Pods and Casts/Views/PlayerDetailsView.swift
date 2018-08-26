//
//  PlayerDetailsView.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/23/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
    
    @IBAction func dismissButton(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var playerDetailsImageView: UIImageView!
    @IBOutlet weak var episodTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var episode: Episode! {
        didSet{
            episodTitle.text = episode.title
            let imageUrl = episode.imageUrl ?? ""
            guard let url = URL(string: imageUrl) else {return}
            playerDetailsImageView.sd_setImage(with: url, completed: nil)
            authorLabel.text = episode.author
            
            playEpispde()
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        return avPlayer
    }()
    
    fileprivate func playEpispde() {
        
        let imageUrl = URL(string: episode.streamUrl)
        guard let url = imageUrl else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        
        enlargeEpisodeImageView()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        player.play()
        
    }
    
    fileprivate func enlargeEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        }, completion: nil)
    }
    
    fileprivate func delargeEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let scale: CGFloat = 0.7
            self.episodeImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.delargeEpisodeImageView()
        }
    }
}
