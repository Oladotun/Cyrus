
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

protocol SearchTableDelegate {
    func cancel()
    func selected(address:String,completeAddress:String,coordinate:CLLocationCoordinate2D)
}

class SearchTableViewController: UITableViewController,UISearchResultsUpdating {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var theMap: MKMapView!
    var userLocation:CLLocation!
    var itemsFound = [MKMapItem]()
    var selected: MKMapItem!
    var keyWordSearch:String!
    
    var resultSearchController:UISearchController!
    
    var searchProtocol : SearchTableDelegate?
    
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
        resultSearchController.searchBar.delegate = self
        
        
        // 7
        self.tableView.tableHeaderView = resultSearchController.searchBar
        
        appDelegate.locationManager.delegate = self
        appDelegate.locationManager.startUpdatingLocation()
        appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        theMap = MKMapView()
        theMap.delegate = self
        
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
        

    }
    deinit {
        
        resultSearchController.searchBar.delegate = nil
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        theMap.delegate = nil
        appDelegate.locationManager.stopUpdatingLocation()

        
    }
    
    func performSearch() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = keyWordSearch
        request.region = theMap.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({
            (response,error) in
            if error != nil {
//                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
//                print("No matches found")
            } else {
                self.itemsFound = [MKMapItem]()
                for item in response!.mapItems {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (itemsFound.count > indexPath.row) {
            
            resultSearchController.searchBar.text = ""
            var addressJoined = ""
            
            if let addressString = itemsFound[indexPath.row].placemark.addressDictionary {
                if let addressInfo  = addressString["FormattedAddressLines"] {
                    addressJoined = (addressInfo as! [String]).joinWithSeparator(",")
                }
            }
            let completeWord = itemsFound[indexPath.row].name!
            
            let coordinate = itemsFound[indexPath.row].placemark.coordinate
            searchProtocol?.selected(completeWord,completeAddress: addressJoined,coordinate: coordinate)
            
            if (resultSearchController.searchBar.isFirstResponder()){
                 dismissViewControllerAnimated(true, completion: nil)
            }
           
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
extension SearchTableViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchProtocol?.cancel()
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}


extension SearchTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
        
        if (userLocation != nil) {
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
            theMap.setRegion(region, animated: false)
        }
        
    }
    
}

extension SearchTableViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        theMap.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
}
