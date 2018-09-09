//
//  FavoritesController.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/15/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   
    
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weak var mainTabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabController?.viewControllers?[0].tabBarItem.badgeValue = nil
        
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(FavoriteCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else {return}
        
        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            
            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView?.deleteItems(at: [selectedIndexPath])
            
            // Deleting the index of the Podcasts Array that is saved in the UserDefaults
            var podcasts = UserDefaults.standard.savedPodcasts()
            podcasts.remove(at: selectedIndexPath.item)
            
            let data = NSKeyedArchiver.archivedData(withRootObject: podcasts)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoretedPodcastKey)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK:- UICollectionView delegate and Spacing Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print(podcasts.count)
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let podcast = self.podcasts[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoriteCollectionViewCell
        cell.podcast = podcast
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 48) / 2
        return CGSize(width: width, height: width + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodesViewController = EpisodesController()
        episodesViewController.selectedPodcast = self.podcasts[indexPath.item]
        navigationController?.pushViewController(episodesViewController, animated: true)
    }
    
}
