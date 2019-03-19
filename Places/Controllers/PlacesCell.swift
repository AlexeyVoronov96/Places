//
//  PlacesCell.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class PlacesCell: UITableViewCell {
    //MARK: - Properties
    var place: Place?

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var placeImage: UIImageView!
    
    //MARK: - Initializing cell
    func initCell(place: Place, index: IndexPath) {
        self.place = place
        if place.name != "" {
            nameLabel.text = place.name
        } else {
            nameLabel.text = "Place".localize() + " \(index.row + 1)"
        }
        dateLabel.text = place.dateString
        if place.imageSmall != nil {
            placeImage.image = UIImage(data: place.imageSmall! as Data)
        } else {
            placeImage.image = UIImage(named: "logoRed.png")
        }
        placeImage.layer.cornerRadius = placeImage.frame.height / 2
        placeImage.layer.masksToBounds = true
    }
}
