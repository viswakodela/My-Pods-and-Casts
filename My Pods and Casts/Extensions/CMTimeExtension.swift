//
//  CMTimeExtension.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/26/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import AVKit

extension CMTime {
        
        func toDisplayString() -> String {
            if CMTimeGetSeconds(self).isNaN {
                return "--:--"
            }
            
            let totalSeconds = Int(CMTimeGetSeconds(self))
            print(totalSeconds)
            let seconds = totalSeconds % 60
            let minutes = totalSeconds % (60 * 60) / 60
            let hours = totalSeconds / 60 / 60
            let timeFormatString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            return timeFormatString
        
    }
    
//    func toDisplayStringOfSeconds() -> String {
    
       
//        let totalseconds = Int(CMTimeGetSeconds(self))
//        let seconds = totalseconds % 60
//        let minutes =  totalseconds  / 60 % 60
//        let hours = totalseconds / 60 / 60
//
//        let timeFormat = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//        return timeFormat
//    }
}
