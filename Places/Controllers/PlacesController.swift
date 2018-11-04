//
//  PlacesController.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class PlacesController: UITableViewController {
    
    //MARK: - Loading view
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }

    //MARK: - Navigation bar button
    var selectedPlace: Place?
    @IBAction func addPlaceAction(_ sender: Any) {
        selectedPlace = Place.newPlace(name: "")
        selectedPlace?.addCurrentLocation()
        performSegue(withIdentifier: "addPlace", sender: self)
    }
    
    //MARK: - Filling table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count != 0 {
            return places.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlacesCell
        cell.initCell(place: places[indexPath.row], index: indexPath)
        return cell
    }

    //MARK: - Deleting table view cells
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentPlace = places[indexPath.row]
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentPlace)
            CoreDataManager.sharedInstance.saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }    
    }
    
    //MARK: - Segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentPlace = places[indexPath.row]
        selectedPlace = currentPlace
        performSegue(withIdentifier: "addPlace", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlace" {
            (segue.destination as! PlaceController).place = selectedPlace
        }
    }

}