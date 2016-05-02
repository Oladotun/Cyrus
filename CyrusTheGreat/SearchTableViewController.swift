
//
//  SearchTableViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 5/2/16.
//  Copyright © 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SearchTableViewController: UITableViewController,UISearchResultsUpdating {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var theMap: MKMapView!
    var userLocation:CLLocation!
    var itemsFound = [MKMapItem]()
    var selected: MKMapItem!
    var keyWordSearch:String!
    
    var resultSearchController:UISearchController!
    
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var headerView: UIView!
//    @IBOutlet weak var searchLocal: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CheckCell")
        
        resultSearchController = UISearchController(searchResultsController: nil)
        // 2
        resultSearchController.searchResultsUpdater = self
        // 3
        resultSearchController.hidesNavigationBarDuringPresentation = false
        // 4
        resultSearchController.dimsBackgroundDuringPresentation = false
        // 5
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
        // 6
        resultSearchController.searchBar.sizeToFit()
        // 7
        self.tableView.tableHeaderView = resultSearchController.searchBar
        
        appDelegate.locationManager.delegate = self
        appDelegate.locationManager.startUpdatingLocation()
        appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        theMap = MKMapView()

        tableView.dataSource = self
        tableView.delegate = self
        self.edgesForExtendedLayout = UIRectEdge.None
//        self.tableView.tableHeaderView = headerView
//        self.tableView.tableHeaderView.size

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsFound.count
    }
    

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if (searchController.searchBar.text?.characters.count > 0) {
            keyWordSearch = searchController.searchBar.text
            performSearch()
            
        }
        
        if !searchController.active {
            print("Cancelled")
            self.itemsFound.removeAll()
            tableView.reloadData()
        }

        
        
    }
    
    func performSearch() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = keyWordSearch
        request.region = theMap.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({
            (response,error) in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                self.itemsFound = [MKMapItem]()
                for item in response!.mapItems {
                    print("Name = \(item.name)")
                    print(item.placemark.addressDictionary!["FormattedAddressLines"])
                    self.itemsFound.append(item)
                }

                self.tableView.reloadData()
            }
        })
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CheckCell", forIndexPath: indexPath) as UITableViewCell!

        // Configure the cell...
        
        cell.textLabel?.numberOfLines = 5
        cell.textLabel?.font = UIFont(name: "HoeflerText-Regular", size: 11)
        var addressJoined = ""
        
        if let addressString = itemsFound[indexPath.row].placemark.addressDictionary {
            if let addressInfo  = addressString["FormattedAddressLines"] {
                
                addressJoined = (addressInfo as! [String]).joinWithSeparator(",")
            }
        }
 
        cell.textLabel?.text = itemsFound[indexPath.row].name! + "\n" + addressJoined
        return cell
    }

}


extension SearchTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
        
        if (userLocation != nil) {
            let region = MKCoordinateRegionMakeWithDistance(
                userLocation.coordinate, 2000, 2000)
            
            theMap.setRegion(region, animated: false)
        }
        
    }
    
}

extension SearchTableViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        theMap.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
}
