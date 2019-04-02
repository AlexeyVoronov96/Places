//
//  PlacesController.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class PlacesController: UITableViewController {
    //MARK: - Properties
    var selectedPlace: Place?
    
    //MARK: - Loading view
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
    }

    //MARK: - Navigation bar button
    @IBAction func addPlaceAction(_ sender: Any) {
        self.selectedPlace = Place.newPlace(name: "")
        self.selectedPlace?.addCurrentLocation()
        self.performSegue(withIdentifier: "addPlace", sender: self)
    }
    
    //MARK: - Data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlacesCell
        cell.initCell(place: places[indexPath.row], index: indexPath)
        return cell
    }

    //MARK: - Delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentPlace = places[indexPath.row]
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentPlace)
            CoreDataManager.sharedInstance.saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentPlace = places[indexPath.row]
        self.selectedPlace = currentPlace
        self.performSegue(withIdentifier: "addPlace", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlace" {
            (segue.destination as! PlaceController).place = selectedPlace
        }
    }
}
