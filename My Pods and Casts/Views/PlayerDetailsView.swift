//
//  PlayerDetailsView.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/23/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    @IBAction func dismissButton(_ sender: Any) {
            let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
            mainTabBarController?.minimizePlayerDetails()
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!{
        didSet{
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var playerDetailsImageView: UIImageView!
    @IBOutlet weak var episodTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration =  player.currentItem?.duration else {return}
        let duratiionInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds =  Float64(percentage) * duratiionInSeconds
        let seekTime = CMTimeMake(Int64(seekTimeInSeconds), 1)
        player.seek(to: seekTime)
    }
    
    func sliderTimeChange(delta: Int64){
        let fifteenSeconds = CMTimeMake(delta, 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    @IBAction func farwardButton(_ sender: Any) {
        sliderTimeChange(delta: 15)
    }
    @IBAction func backWardButton(_ sender: Any) {
        sliderTimeChange(delta: -15)
    }
    @IBAction func volumeSlider(_ sender: Any) {
        player.volume = volumeSliderChange.value
    }
    @IBOutlet weak var volumeSliderChange: UISlider!
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    //MARK:- Mini Player Outlets
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniFarwardButton: UIButton! {
        didSet {
            miniFarwardButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        }
    }
    
    @IBOutlet weak var miniEpisodeTitleLabel: UILabel!
    @IBAction func miniFastFarwardButton(_ sender: Any) {
        sliderTimeChange(delta: 15)
    } 
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            miniPlayPauseButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        }
    }
    
    
    var episode: Episode? {
        didSet{
            episodTitle.text = episode?.title
            let imageUrl = episode?.imageUrl ?? ""
            guard let url = URL(string: imageUrl) else {return}
            playerDetailsImageView.sd_setImage(with: url, completed: nil)
            authorLabel.text = episode?.author
            
            miniEpisodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeTitleLabel.text = episode?.title
            
            playEpispde()
        }
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGesture)))
        
        setupAudioSession()
        setupRemoteControl()
        
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        
        // player has a reference to self
        // self has a reference to player
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            self?.enlargeEpisodeImageView()
        }
    }
    
    fileprivate func setupAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error capturing the Audio Session:", error)
        }
        
    }
    
    fileprivate func setupRemoteControl() {
        
        let controlCenter = MPRemoteCommandCenter.shared()
        
        controlCenter.playCommand.isEnabled = true
        controlCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            return .success
        }
        
        controlCenter.pauseCommand.isEnabled = true
        controlCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            return .success
        }
        
        controlCenter.togglePlayPauseCommand.isEnabled = true
        controlCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
    }
    
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func playEpispde() {
        
        guard let episode = self.episode else {return}
        let streamUrl = URL(string: episode.streamUrl)
        guard let url = streamUrl else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        playerLabelAndSliderUpdates()
    }
    
    fileprivate func playerLabelAndSliderUpdates() {
        
        let interval = CMTimeMake(1, 2)
        
        //player has areference to self
        // self has a reference to player
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            guard let durationTime = self?.player.currentItem?.duration else{return}
            self?.durationLabel.text = durationTime.toDisplayString()
            
            guard let time = self?.player.currentTime() else{return}
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTimeMake(1, 1))
            
            let sliderPercentage = currentTime / duration
            self?.currentTimeSlider.value = Float(sliderPercentage)
        }
    }
    
    func enlargeEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        }, completion: nil)
    }
    
    fileprivate func shrinkEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let scale: CGFloat = 0.7
            self.episodeImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.shrinkEpisodeImageView()
        }
    }
}
