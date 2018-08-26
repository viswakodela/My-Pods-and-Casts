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

class APIService {
    
    //Singleton
    static let shared = APIService()
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        
//        print(self.selectedPodcast?.feedUrl ?? "")
        guard let feedUrl = URL(string: feedUrl) else {return}
        let parser = FeedParser(URL: feedUrl)
        parser?.parseAsync(result: { (result) in
//            print(result.isSuccess)
            
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
    
    func fetchPodCasts(searchText: String, completiopnHandler: @escaping (SearchResults) -> ()) {
        
        let url = "https://itunes.apple.com/search"
        let paramenters = ["term": searchText, "media": "podcast"]
        
        Alamofire.request(url, method: .get, parameters: paramenters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if dataResponse.error != nil{
                print("Failed to connect to Podcasts:", dataResponse.error ?? "")
            }
            guard let data = dataResponse.data else {return}
//            let dummy = String(data: data, encoding: .utf8)
//            print(dummy ?? "")
            
            do{
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                completiopnHandler(searchResults)
            }catch{
                print(error)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
