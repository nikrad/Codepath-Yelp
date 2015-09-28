//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {

  @IBOutlet weak var tableView: UITableView!

  var searchBar: UISearchBar!
  var businesses: [Business]!
  var hud: MBProgressHUD!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.navigationBar.backgroundColor = UIColor.redColor()
    searchBar = UISearchBar(frame: CGRectMake(0, 0, 0, 0))
    searchBar.delegate = self
    searchBar.placeholder = "Search..."
    navigationItem.titleView = searchBar

    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 83
    
    let tap = UITapGestureRecognizer(target: self, action: "onTableViewTap:")
    tableView.addGestureRecognizer(tap)
    
    showHUD()

    Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.tableView.reloadData()
      dispatch_async(dispatch_get_main_queue()) {
        self.hud.hide(true)
      }
    })
  }
  
  func onTableViewTap(sender: AnyObject?) {
    searchBar.endEditing(true)
  }
  
  func showHUD() {
    hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
    hud.labelText = "Loading..."
  }

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    showHUD()
    Business.searchWithTerm(searchBar.text!, completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.tableView.reloadData()
      dispatch_async(dispatch_get_main_queue()) {
        self.hud.hide(true)
      }
    })
    searchBar.endEditing(true)
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if businesses != nil {
      return businesses.count
    } else {
      return 0
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
    cell.business = businesses[indexPath.row]
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let navigationController = segue.destinationViewController as! UINavigationController
    let filtersViewController = navigationController.topViewController as! FiltersViewController

    filtersViewController.delegate = self
  }

  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    showHUD()
    
    let deals = filters["deals"] as? Bool
    let sortIndex = filters["sort"] as? Int
    let sort = SortFilter.values[sortIndex!]
    let distanceIndex = filters["distance"] as? Int
    let distance = DistanceFilter.values[distanceIndex!]

    let categories = filters["categories"] as? [String]
    Business.searchWithTerm(searchBar.text!, sort: sort, categories: categories, deals: deals, distance: distance) { (businesses: [Business]?, error: NSError!) -> Void in
      if let businesses = businesses {
        self.businesses = businesses
        self.tableView.reloadData()
      } else {
        print("Couldn't find any restaurants")
      }
      self.hud.hide(true)

    }
  }

}
