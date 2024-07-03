//
//  RestaurentResponse.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import Foundation
import CoreLocation

struct RestaurantResponse: Decodable {
    let results: Result
    
    struct Result: Decodable {
        let apiVersion: String
        let resultsAvailable: Int
        let resultsReturned: String
        let resultsStart: Int
        let shops: [Shop]
        
        enum CodingKeys: String, CodingKey {
            case apiVersion = "api_version"
            case resultsAvailable = "results_available"
            case resultsReturned = "results_returned"
            case resultsStart = "results_start"
            case shops = "shop"
        }
        
        struct Shop: Decodable, Identifiable {
            let id: String
            let name: String
            let logoImage: URL
            let nameKana: String
            let address: String
            let stationName: String
            let ktaiCoupon: Int
            let latitude, longitude: Double
            let access: String
            
            var coordinate: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            
            enum CodingKeys: String, CodingKey {
                case id
                case name
                case logoImage = "logo_image"
                case nameKana = "name_kana"
                case address
                case stationName = "station_name"
                case ktaiCoupon = "ktai_coupon"
                case latitude = "lat"
                case longitude = "lng"
                case access = "mobile_access"
            }
        }
    }
}
