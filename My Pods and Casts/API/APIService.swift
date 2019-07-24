//
//  APIServiceClass.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/16/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension NSNotification.Name {
    static let downloadProgressNotification = NSNotification.Name("downloadProfressNotification")
    static let downloadCompleteNotification = NSNotification.Name("downloadCompleteNotification")
}

class APIService {
    
    //Singleton
    static let shared = APIService()
    
    func downloadEpisode(episode: Episode) {
        
        let streamUrl = episode.streamUrl
        
        let downloadDestination = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(streamUrl, to: downloadDestination).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            
            NotificationCenter.default.post(name: .downloadProgressNotification, object: nil, userInfo: ["title" : episode.title, "progress" : progress.fractionCompleted])
            
            
            }.response { (resp) in
                print(resp.destinationURL ?? "")
                
                NotificationCenter.default.post(name: .downloadCompleteNotification, object: nil, userInfo: ["title": episode.title, "fileUrl": resp.destinationURL?.absoluteString ?? ""])
                
                // we have to update UserDefaults downloaded episodes
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.index(where: { (ep) -> Bool in
                    ep.title == episode.title && ep.author == episode.author
                }) else {return}
                downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString
                
                print(resp.destinationURL?.absoluteString ?? "")
                
                do {
                      let data = try JSONEncoder().encode(downloadedEpisodes)
                      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
                } catch {
                    print("Error encoding the FileUrl:", error)
                }
        }
    }
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        
//        print(self.selectedPodcast?.feedUrl ?? "")
        guard let feedUrl = URL(string: feedUrl) else {return}
        DispatchQueue.global(qos: .background).async {
            
            let parser = FeedParser(URL: feedUrl)
            parser?.parseAsync(result: { (result) in
                
                switch result {
                    
                case let .rss(feed):
                    let episodes = feed.toEpisodes()
                    completionHandler(episodes)
                    break
                case let .failure(error):
                    print("Failed to parse feed:", error)
                    break
                default: print("Found a feed")
                }
            })
        }
    }
    
    func fetchPodCasts(searchText: String, completiopnHandler: @escaping (SearchResults) -> Void) {
        
        let url = "https://itunes.apple.com/search"
        let paramenters = ["term": searchText, "media": "podcast"]
        
        Alamofire.request(url, method: .get, parameters: paramenters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if dataResponse.error != nil{
                print("Failed to connect to Podcasts:", dataResponse.error ?? "")
            }
            guard let data = dataResponse.data else {return}
            let dummy = String(data: data, encoding: .utf8)
            print(dummy ?? "")
            
            do{
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                completiopnHandler(searchResults)
            } catch {
                print(error)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
