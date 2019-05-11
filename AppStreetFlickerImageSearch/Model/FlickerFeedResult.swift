//
//  FlickerFeedResult.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import Foundation

struct FlickerFeedResult: Decodable {
    var photos: FlickerResult
    var stat: String
}

struct FlickerResult: Decodable{
    
    var page: Int
    var pages: Int
    var perpage: Int
    var photo: [FlikerPhoto]
}

struct FlikerPhoto: Decodable, Hashable {
    
    
    static func ==(lhs: FlikerPhoto, rhs: FlikerPhoto) -> Bool {
        
        guard let urlL = lhs.photoURL, let urlR = rhs.photoURL else{return false}
        return urlL.absoluteString == urlR.absoluteString
    }
    
    var hashValue: Int{
        return photoURL?.absoluteString.hashValue ?? 0
    }
    
    
    let farm: Int
    let server: String
    let id: String
    let secret: String
    let title: String
    var state = PhotoRecordState.New
    
    enum CodingKeys: String, CodingKey {
        case farm, server, id, secret, title
    }
    
    
    var photoURL: URL?{
        
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")
    }
    
    var thumbnailURL: URL?{
        
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_t.jpg")
    }
    
}

