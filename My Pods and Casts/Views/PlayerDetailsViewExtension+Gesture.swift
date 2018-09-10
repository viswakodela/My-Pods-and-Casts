//
//  PlayerDetailsViewExtension+Gesture.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 9/3/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import AVKit

extension PlayerDetailsView {
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .began {
            
        }
        else if gesture.state == .changed {
            handlePanGestureChanged(gesture: gesture)
        }
        else if gesture.state == .ended {
            handlePanGestureEnded(gesture: gesture)
        }
    }
    
    func handlePanGestureChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        miniPlayerView.alpha = 1 + translation.y / 200
        //        let trans = gesture.translation(in: maximizedStackView)
        maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanGestureEnded(gesture : UIPanGestureRecognizer) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let translation = gesture.translation(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)
            //                print("Ended:", translation.y)
            self.transform = .identity
            self.layoutIfNeeded()
            if translation.y < -200 || velocity.y < -500 {
                let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                mainTabBarController?.maximizePlayerDetails(episode: nil)
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }, completion: nil)
    }
    
    @objc func handleDismissPanGesture(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: superview)
        if gesture.state == .changed {
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }
        else if gesture.state == .ended {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.maximizedStackView.transform = .identity
                self.miniPlayerView.alpha = 0
                if translation.y > 30 {
                    
                    self.miniPlayerView.alpha = 1
                    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                    mainTabBarController?.minimizePlayerDetails()
                }
            })
        }
    }
    
    @objc func handleTapMaximize() {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: nil)
    }
    
}
