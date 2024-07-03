//
//  RestaurentAnnotation.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import MapKit

class RestaurentAnnotation: MKPointAnnotation {
    let shop: RestaurantResponse.Result.Shop
    
    init(shop: RestaurantResponse.Result.Shop) {
        self.shop = shop
        
        super.init()
        self.coordinate = shop.coordinate
        self.title = shop.name
        self.subtitle = shop.nameKana
    }
}
