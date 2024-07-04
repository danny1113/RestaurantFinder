//
//  RestaurantResultTableViewCell.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit

final class RestaurantResultTableViewCell: UITableViewCell {
    
    var shop: RestaurantResponse.Result.Shop!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
