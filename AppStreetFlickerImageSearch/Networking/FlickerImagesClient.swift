//
//  FlickerImagesClient.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import Foundation

class FlickerImagesClient: APIClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getFeed(from movieFeedType: FlickerFeed, completion: @escaping (Result<FlickerFeedResult?, APIError>) -> Void) {
        
        let endpoint = movieFeedType
        let request = endpoint.request
        
        fetch(with: request, decode: { json -> FlickerFeedResult? in
            guard let movieFeedResult = json as? FlickerFeedResult else { return  nil }
            return movieFeedResult
        }, completion: completion)
    }
}
