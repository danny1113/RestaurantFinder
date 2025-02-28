//
//  RestaurantAPIService.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import Foundation
import CoreLocation

struct RestaurantAPIService {
    static func getNearbyRestaurants(
        with coordinate: CLLocationCoordinate2D,
        range: Int
    ) async throws -> RestaurantResponse.Result {
        let baseUrl = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
        var url = URL(string: baseUrl)!
        url.append(queryItems: [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "key", value: Secrets.apiKey),
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lng", value: String(coordinate.longitude)),
            URLQueryItem(name: "range", value: String(range)),
            URLQueryItem(name: "count", value: "50"),
        ])
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let restaurant = try JSONDecoder().decode(RestaurantResponse.self, from: data)
        
        return restaurant.results
    }
}
