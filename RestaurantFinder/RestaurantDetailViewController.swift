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
    
    private var loadImageTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = shop.name
        
        loadImageTask = Task {
            do {
                let url = shop.logoImage
                let image = try await imageCacheManager.getImage(for: url)
                imageView.image = image
            } catch {
                print(error)
            }
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
        loadImageTask?.cancel()
    }
}
