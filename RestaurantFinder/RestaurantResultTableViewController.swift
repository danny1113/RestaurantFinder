//
//  RestaurantResultTableViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit
import CoreLocation

/// レストランを表示するリスト
final class RestaurantResultTableViewController: UIViewController {
    
    static let identifier = "cell"
    
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var searchRadiusSlider: UISlider!
    @IBOutlet private var searchRadiusLabel: UILabel!
    @IBOutlet private var searchButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: RestaurantResultTableViewDelegate?
    
    private var detailViewController: RestaurantDetailViewController?
    
    private var shops: [RestaurantResponse.Result.Shop] = []
    private(set) var filteredShops: [RestaurantResponse.Result.Shop] = []
    
    private let imageCacheManager = ImageCacheManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        if let sheet = navigationController?.sheetPresentationController {
            sheet.invalidateDetents()
        }
        
        tableView.register(RestaurantResultTableViewCell.self, forCellReuseIdentifier: Self.identifier)
    }
    
    @IBAction private func searchButtonTapped() {
        Task {
            startAnimating()
            let range = Int(searchRadiusSlider.value)
            await delegate?.searchButtonDidTap(range: range)
            stopAnimating()
        }
    }
    
    @IBAction private func searchRadiusSliderValueChanged(_ sender: UISlider) {
        let text = switch Int(sender.value) {
        case 1: "300m"
        case 2: "500m"
        case 3: "1000m"
        case 4: "2000m"
        case 5: "3000m"
        default:
            "1000m"
        }
        searchRadiusLabel.text = text
    }
}

extension RestaurantResultTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredShops.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.identifier, for: indexPath)
        guard let cell = cell as? RestaurantResultTableViewCell else {
            return cell
        }
        
        let shop = filteredShops[indexPath.row]
        cell.shop = shop
        
        imageCacheManager.getImage(for: shop.logoImage) { image in
            var content = cell.defaultContentConfiguration()
            content.text = shop.name
            content.secondaryText = shop.access
            content.image = image
            let size = CGSize(width: 60, height: 60)
            content.imageProperties.maximumSize = size
            content.imageProperties.reservedLayoutSize = size
            content.imageProperties.cornerRadius = 8
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shop = filteredShops[indexPath.row]
        delegate?.didSelect(shop: shop)
        pushDetailView(with: shop)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < filteredShops.count {
            let shop = filteredShops[row]
            imageCacheManager.cancel(for: shop.logoImage)
        }
    }
}

extension RestaurantResultTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let shop = filteredShops[indexPath.row]
            imageCacheManager.getImage(for: shop.logoImage) { _ in }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let shop = filteredShops[indexPath.row]
            imageCacheManager.cancel(for: shop.logoImage)
        }
    }
}

extension RestaurantResultTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredShops = shops
        } else {
            filteredShops = shops.filter { shop in
                shop.name.contains(searchText)
            }
        }
        tableView.reloadData()
    }
}

extension RestaurantResultTableViewController {
    func calculateDetentHeight() -> CGFloat? {
        guard let headerView = headerView,
              let searchBar = searchBar else {
            return nil
        }
        return headerView.frame.height + searchBar.frame.height
    }
    
    func pushDetailView(with shop: RestaurantResponse.Result.Shop) {
        if detailViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailView") as! RestaurantDetailViewController
            detailViewController.shop = shop
            detailViewController.imageCacheManager = imageCacheManager
            self.detailViewController = detailViewController
        } else {
            detailViewController?.configure(with: shop)
        }
        
        if let sheet = detailViewController?.sheetPresentationController {
            let currentSelectedDetent = self.sheetPresentationController?.selectedDetentIdentifier
            var detents: [UISheetPresentationController.Detent] = [.large()]
            if currentSelectedDetent != .large {
                detents.append(.medium())
                detents.append(.custom(identifier: .small, resolver: { [weak self] _ in
                    return self?.calculateDetentHeight()
                }))
            }
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = currentSelectedDetent ?? .medium
            }
        }
        
        if detailViewController?.presentingViewController == nil {
            self.present(detailViewController!, animated: true)
        }
    }
    
    func setSelectedDetent(_ identifier: UISheetPresentationController.Detent.Identifier) {
        if let sheet = sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = identifier
            }
        }
        if let sheet = detailViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = identifier
            }
        }
    }
    
    func updateShops(_ shops: [RestaurantResponse.Result.Shop]) {
        self.shops = shops
        self.filteredShops = shops
    }
    
    func updateTableView(with shops: [RestaurantResponse.Result.Shop]) {
        updateShops(shops)
        tableView.reloadData()
    }
    
    func selectRow(with shop: RestaurantResponse.Result.Shop) {
        guard let index = filteredShops.firstIndex(of: shop) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    func startAnimating() {
        searchButton.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        searchButton.isHidden = false
        activityIndicator.stopAnimating()
    }
}

protocol RestaurantResultTableViewDelegate: AnyObject {
    func didSelect(shop: RestaurantResponse.Result.Shop)
    func searchButtonDidTap(range: Int) async
}
