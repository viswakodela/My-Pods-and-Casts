//
//  FavoriteCollectionViewCell.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 9/6/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import SDWebImage

class FavoriteCollectionViewCell: UICollectionViewCell {
    
    
    var podcast: Podcast? {
        didSet {
            self.trackName.text = podcast?.trackName
            self.artistNameLabel.text = podcast?.artistName
            guard let imageUrl = podcast?.artworkUrl600 else {return}
            guard let url = URL(string: imageUrl) else {return}
            imageView.sd_setImage(with: url, completed: nil)
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "appicon")
        return iv
    }()
    
    let trackName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Album Title"
        label.numberOfLines = 0
        return label
    }()
    
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.text = "Artisty Name"
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate func setupConstraints() {
        
        let stackView = UIStackView(arrangedSubviews: [imageView, trackName, artistNameLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
    }
    
}
