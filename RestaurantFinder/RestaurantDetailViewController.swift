//
//  RestaurantDetailViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    var shop: RestaurantResponse.Result.Shop!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = shop.name
    }
}
