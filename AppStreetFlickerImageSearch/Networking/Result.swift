//
//  Result.swift
//  AppStreetFlickerImageSearch
//
//  Created by Mohan Pandey on 11/05/19.
//  Copyright © 2019 AppStreet. All rights reserved.
//

import Foundation

import Foundation

enum Result<T, U> where U: Error  {
    case success(T)
    case failure(U)
}
