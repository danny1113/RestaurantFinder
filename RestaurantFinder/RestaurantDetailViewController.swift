//
//  RestaurantDetailViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit

final class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    var shop: RestaurantResponse.Result.Shop!
    
    var imageCacheManager: ImageCacheManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = shop.name
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        
        let url = shop.logoImage
        imageCacheManager.getImage(for: url) { image in
            self.imageView.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageCacheManager.cancel(for: shop.logoImage)
    }
}
