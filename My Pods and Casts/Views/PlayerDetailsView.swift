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
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
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
            miniFarwardButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
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
            miniEpisodeTitleLabel.text = episode?.title
            
            miniEpisodeImageView.sd_setImage(with: url, completed: nil)
            
            setUpNowPlayingInfo()
            
            playEpispde()
        }
    }
    
    fileprivate func setUpNowPlayingInfo() {
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.episode?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.episode?.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Lock Screen Artwork
        let imageUrl = episode?.imageUrl ?? ""
        guard let url = URL(string: imageUrl) else {return}
        miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
            let image = self.miniEpisodeImageView.image ?? UIImage()
            let artwork =  MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                return image
            })
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        }
        
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func observeBoundryTime() {
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        
        // player has a reference to self
        // self has a reference to player
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            self?.enlargeEpisodeImageView()
            self?.setUpLockScreenDuration()
        }
    }
    
    func setUpLockScreenDuration() {
        
        guard let currentItem = player.currentItem else {return}
        let duration = CMTimeGetSeconds(currentItem.duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGesture)))
        
        setupAudioSession()
        setupRemoteControl()
        setupNotificationObserver()
        
        observeBoundryTime()
    }
    
    fileprivate func setupNotificationObserver() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruction), name: .AVAudioSessionInterruption, object: nil)
    }
    
    @objc fileprivate func handleInterruction(notification: Notification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        if type == AVAudioSessionInterruptionType.began.rawValue {
            print("inderruptions Began")
            player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            print("Interruptions Ended")
            player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
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
            self.enlargeEpisodeImageView()
            
            self.setUpElapsedTime()
            return .success
        }
        
        controlCenter.pauseCommand.isEnabled = true
        controlCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.shrinkEpisodeImageView()
            
            self.setUpElapsedTime()
            return .success
        }
        
        controlCenter.togglePlayPauseCommand.isEnabled = true
        controlCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        controlCenter.nextTrackCommand.isEnabled = true
        controlCenter.nextTrackCommand.addTarget(self, action: #selector(handleNext))
        controlCenter.previousTrackCommand.isEnabled = true
        controlCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevious))
    }
    
    var playList = [Episode]()
    @objc func handleNext() {
        
        if playList.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playList.index { (ep) -> Bool in
            return ep.author == self.episode?.author && ep.title == self.episode?.title
        }
        
        guard let index = currentEpisodeIndex else {return}
        
        var nextEpisode: Episode
        if index == playList.count - 1 {
            nextEpisode = playList[0]
        } else {
            nextEpisode = playList[index + 1]
        }
        self.episode = nextEpisode
    }
    
    @objc func handlePrevious() {
        
        if playList.count == 0 {
            return
        }
        
        let currentIndex = playList.index { (ep) -> Bool in
            return ep.author == self.episode?.author && ep.title == self.episode?.title
        }
        let previousEpisode: Episode
        guard let index = currentIndex else {return}
        if index == 0 {
            previousEpisode = playList[playList.count - 1]
        } else {
            previousEpisode = playList[index - 1]
        }
        self.episode = previousEpisode
    }
    
    func setUpElapsedTime() {
        
        let currentTime = player.currentTime()
        let elapsedTime = CMTimeGetSeconds(currentTime)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
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
        
        if episode.fileUrl != nil {
            
//            print(episode.fileUrl)
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
            print(trueLocation.absoluteString)
            
            guard let fileUrl = URL(string: episode.fileUrl ?? "") else {return}
            let fileName = fileUrl.lastPathComponent
            
            print(trueLocation.appendPathComponent(fileName))
            
            let playerItem = AVPlayerItem(url: trueLocation)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            playerLabelAndSliderUpdates()
            
        } else {
            
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            playerLabelAndSliderUpdates()
        }
        
    }
    
    fileprivate func playerLabelAndSliderUpdates() {
        
        let interval = CMTimeMake(1, 2)
        
        //player has a reference to self
        // self has a reference to player
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            guard let durationTime = self?.player.currentItem?.duration else{return}
            self?.durationLabel.text = durationTime.toDisplayString()
            
//            self?.setUpLockscreenCurrentTime()
            
            guard let time = self?.player.currentTime() else{return}
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTimeMake(1, 1))
            
            let sliderPercentage = currentTime / duration
            self?.currentTimeSlider.value = Float(sliderPercentage)
        }
    }
    
//    func setUpLockscreenCurrentTime() {
//        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//
//        guard let currentItem = player.currentItem else {return}
//        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
//        let elapsedTime = CMTimeGetSeconds(player.currentTime())
//        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
//        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
    
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
