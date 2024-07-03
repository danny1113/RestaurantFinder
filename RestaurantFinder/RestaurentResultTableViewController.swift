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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        var content = cell.defaultContentConfiguration()
        content.text = shop.name
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shop = shops[indexPath.row]
        print(shop)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(shop: shop)
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

protocol RestaurantResultTableViewDelegate: AnyObject {
    func didSelect(shop: RestaurantResponse.Result.Shop)
}
