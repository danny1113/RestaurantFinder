//
//  RestaurentResultTableViewCell.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit

class RestaurentResultTableViewCell: UITableViewCell {
    
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
