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
        self.nameLabel.text = place.name == "" ? "Place".localize() + " \(index.row + 1)" : place.name
        self.dateLabel.text = place.dateString
        self.placeImage.image = place.imageSmall == nil ? #imageLiteral(resourceName: "logoRed") : UIImage(data: place.imageSmall! as Data)
        self.placeImage.layer.cornerRadius = placeImage.frame.height / 2
        self.placeImage.layer.masksToBounds = true
    }
}
