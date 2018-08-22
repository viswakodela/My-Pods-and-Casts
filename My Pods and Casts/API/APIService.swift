//
//  APIServiceClass.swift
//  My Pods and Casts
//
//  Created by Viswa Kodela on 8/16/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    
    //Singleton
    static let shared = APIService()
    
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
//                print(searchResults)
//                self.podcast = searchResults.results
//                self.tableView.reloadData()
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
