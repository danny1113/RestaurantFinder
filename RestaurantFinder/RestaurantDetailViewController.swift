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
    @IBOutlet private var subtitleLabel: UILabel!
    
    @IBOutlet private var addressStackView: UIStackView!
    @IBOutlet private var addressLabel: UILabel!
    
    @IBOutlet private var accessStackView: UIStackView!
    @IBOutlet private var accessLabel: UILabel!
    
    var shop: RestaurantResponse.Result.Shop!
    
    var imageCacheManager: ImageCacheManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        
        addressStackView.layer.cornerRadius = 8
        
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.numberOfLines = 0
        
        accessStackView.layer.cornerRadius = 8
        
        accessLabel.lineBreakMode = .byWordWrapping
        accessLabel.numberOfLines = 0
        
        configure(with: shop)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageCacheManager.cancel(for: shop.logoImage)
    }
    
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension RestaurantDetailViewController {
    func configure(with shop: RestaurantResponse.Result.Shop) {
        titleLabel.text = shop.name
        titleLabel.sizeToFit()
        
        subtitleLabel.text = shop.nameKana
        subtitleLabel.sizeToFit()
        
        addressLabel.text = shop.address
        addressLabel.sizeToFit()
        
        accessLabel.text = shop.access
        accessLabel.sizeToFit()
        
        imageView.image = nil
        
        let url = shop.logoImage
        imageCacheManager.getImage(for: url) { image in
            self.imageView.image = image
        }
    }
}
