//
//  RestaurentResultTableViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit
import CoreLocation

final class RestaurentResultTableViewController: UITableViewController {
    
    static let identifier = "cell"
    
    weak var delegate: RestaurantResultTableViewDelegate?
    
    var shops: [RestaurantResponse.Result.Shop] = []
    
    private let imageCacheManager = ImageCacheManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.register(RestaurentResultTableViewCell.self, forCellReuseIdentifier: Self.identifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.identifier, for: indexPath)
        guard let cell = cell as? RestaurentResultTableViewCell else {
            return cell
        }
        
        let shop = shops[indexPath.row]
        cell.shop = shop
        
        imageCacheManager.getImage(for: shop.logoImage) { image in
            var content = cell.defaultContentConfiguration()
            content.text = shop.name
            content.image = image
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shop = shops[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(shop: shop)
        pushDetailView(with: shop)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let shop = shops[indexPath.row]
        imageCacheManager.cancel(for: shop.logoImage)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RestaurentResultTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let shop = shops[indexPath.row]
            imageCacheManager.getImage(for: shop.logoImage) { _ in }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let shop = shops[indexPath.row]
            imageCacheManager.cancel(for: shop.logoImage)
        }
    }
}

extension RestaurentResultTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}

extension RestaurentResultTableViewController {
    func pushDetailView(with shop: RestaurantResponse.Result.Shop) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailView") as! RestaurantDetailViewController
        detailViewController.shop = shop
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

protocol RestaurantResultTableViewDelegate: AnyObject {
    func didSelect(shop: RestaurantResponse.Result.Shop)
}
