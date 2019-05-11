//
//  Endpoint.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import Foundation

protocol Endpoint {
    
    var url: URL {get}
    var httpMethod: String {get}
}

extension Endpoint {
    
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}


struct FlickerFeed: Endpoint {
    
    var url: URL
    var httpMethod: String
}








