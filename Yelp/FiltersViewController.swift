//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Nikrad Mahdi on 9/22/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
  optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

  @IBOutlet weak var tableView: UITableView!

  weak var delegate: FiltersViewControllerDelegate?

  var categoryFilters = [Int: Bool]()
  var expandedSections = [Int: Bool]()
  var filters: [SearchFilterType: AnyObject?] = [
    SearchFilterType.Deals: false,
    SearchFilterType.Distance: 0,
    SearchFilterType.SortBy: 0,
  ]

  var categories: [[String: String]]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load categories
    categories = yelpCategories()

    // Set up table view
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: "FilterHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeader")
    tableView.estimatedSectionHeaderHeight = 40
    
    // Set navigation bar appearance
    let navigationBarAppearance = UINavigationBar.appearance()
    navigationBarAppearance.barTintColor = UIColor(red: 196/255.0, green: 18/255.0, blue: 0, alpha: 1)
    navigationBarAppearance.tintColor = UIColor.whiteColor()
    navigationBarAppearance.translucent = true
    navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return SearchFilterType.values.count
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let filter = SearchFilterType.values[section]
    switch filter {
    case .Deals:
      return 1
    case .Distance:
      if isSectionExpanded(section) {
        return DistanceFilter.values.count
      }
      return 1
    case .SortBy:
      if isSectionExpanded(section) {
        return SortFilter.values.count
      }
      return 1
    case .Category:
      if isSectionExpanded(section) {
        return categories.count
      }
      return 4
    }
  }
  
  func isSectionExpanded(section: Int) -> Bool {
    return expandedSections[section] ?? false
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let filterType = SearchFilterType.values[indexPath.section]
    let isExpanded = isSectionExpanded(indexPath.section)
    switch filterType {
    case .Category:
      if !isExpanded && indexPath.row == 3 {
        expandedSections[indexPath.section] = true
      }
    case .SortBy, .Distance:
      if isExpanded {
        filters[filterType] = indexPath.row
      }
      expandedSections[indexPath.section] = !isExpanded
    default:
      break
    }
    tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    let filterType = SearchFilterType.values[indexPath.section]
    let isExpanded = isSectionExpanded(indexPath.section)
    switch filterType {
    case .Deals:
      return nil
    case .Category:
      if !isExpanded && indexPath.row == 3 {
        return indexPath
      }
      return nil
    case .SortBy, .Distance:
      return indexPath
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let filterType = SearchFilterType.values[indexPath.section]
    switch filterType {
    case .Category, .Deals:
      if filterType == .Category && !isSectionExpanded(indexPath.section) && indexPath.row == 3 {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! LabelCell
        return cell
      }
      
      let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
      cell.selectionStyle = .None
      cell.delegate = self
      if filterType == .Category {
        cell.switchLabel.text = categories[indexPath.row]["name"]
        cell.onSwitch.on = categoryFilters[indexPath.row] ?? false
      } else {
        // .Deals
        cell.switchLabel.text = "Offering a Deal"
        cell.onSwitch.on = filters[.Deals] as! Bool
      }
      return cell
    case .Distance:
      let cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath) as! SelectCell
      cell.accessoryType = .None
      cell.accessoryView = nil

      let selectedFilterIndex = filters[filterType] as! Int
      var distanceType: DistanceFilter
      if isSectionExpanded(indexPath.section) {
        if (selectedFilterIndex) == indexPath.row {
          cell.accessoryType = .Checkmark
        }
        distanceType = DistanceFilter.values[indexPath.row]
      } else {
        cell.accessoryView = UIImageView(image: UIImage(named: "DownArrow@2x.png"))
        distanceType = DistanceFilter.values[selectedFilterIndex]
      }
      cell.selectLabel.text = distanceType.label()
      
      return cell
      
    case .SortBy:
      let cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath) as! SelectCell
      cell.accessoryType = .None
      cell.accessoryView = nil

      let selectedFilterIndex = filters[filterType] as! Int
      var sortType: SortFilter
      if isSectionExpanded(indexPath.section) {
        if (selectedFilterIndex) == indexPath.row {
          cell.accessoryType = .Checkmark
        }
        sortType = SortFilter.values[indexPath.row]
      } else {
        cell.accessoryView = UIImageView(image: UIImage(named: "DownArrow@2x.png"))
        sortType = SortFilter.values[selectedFilterIndex]
      }
      cell.selectLabel.text = sortType.label()
      
      return cell
    }
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("FilterHeader") as! FilterHeader
    
    let filter = SearchFilterType.values[section]
    switch filter {
    case .Deals:
      return nil
    case .Distance:
      header.filterNameLabel.text = "Distance"
    case .SortBy:
      header.filterNameLabel.text = "Sort By"
    case .Category:
      header.filterNameLabel.text = "Category"
    }
    return header
  }

  @IBAction func onCancelButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func onSearchButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)

    var queryFilters = [String: AnyObject]()
    
    for filterType in SearchFilterType.values {
      switch filterType {
      case .Distance:
        queryFilters["distance"] = filters[filterType] as! Int
        
      case .SortBy:
        queryFilters["sort"] = filters[filterType] as! Int
  
      case .Deals:
        queryFilters["deals"] = filters[filterType]!
        
      case .Category:
        var selectedCategories = [String]()
        for (category, isSelected) in categoryFilters {
          if isSelected {
            selectedCategories.append(categories[category]["code"]!)
          }
        }
        if selectedCategories.count > 0 {
          queryFilters["categories"] = selectedCategories
        }
      }
    }
    
    delegate?.filtersViewController?(self, didUpdateFilters: queryFilters)
  }

  func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
    let indexPath = tableView.indexPathForCell(switchCell)!
    let filterType = SearchFilterType.values[indexPath.section]
    if filterType == .Deals {
      filters[.Deals] = value
    } else if filterType == .Category {
      categoryFilters[indexPath.row] = value
    } else {
      assert(false, "Received invalid filter type \(filterType)")
    }
    
  }

  func yelpCategories() -> [[String: String]] {
    return [["name" : "Afghan", "code": "afghani"],
      ["name" : "African", "code": "african"],
      ["name" : "American (New)", "code": "newamerican"],
      ["name" : "American (Traditional)", "code": "tradamerican"],
      ["name" : "Arabian", "code": "arabian"],
      ["name" : "Argentine", "code": "argentine"],
      ["name" : "Armenian", "code": "armenian"],
      ["name" : "Asian Fusion", "code": "asianfusion"],
      ["name" : "Asturian", "code": "asturian"],
      ["name" : "Australian", "code": "australian"],
      ["name" : "Austrian", "code": "austrian"],
      ["name" : "Baguettes", "code": "baguettes"],
      ["name" : "Bangladeshi", "code": "bangladeshi"],
      ["name" : "Barbeque", "code": "bbq"],
      ["name" : "Basque", "code": "basque"],
      ["name" : "Bavarian", "code": "bavarian"],
      ["name" : "Beer Garden", "code": "beergarden"],
      ["name" : "Beer Hall", "code": "beerhall"],
      ["name" : "Beisl", "code": "beisl"],
      ["name" : "Belgian", "code": "belgian"],
      ["name" : "Bistros", "code": "bistros"],
      ["name" : "Black Sea", "code": "blacksea"],
      ["name" : "Brasseries", "code": "brasseries"],
      ["name" : "Brazilian", "code": "brazilian"],
      ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
      ["name" : "British", "code": "british"],
      ["name" : "Buffets", "code": "buffets"],
      ["name" : "Bulgarian", "code": "bulgarian"],
      ["name" : "Burgers", "code": "burgers"],
      ["name" : "Burmese", "code": "burmese"],
      ["name" : "Cafes", "code": "cafes"],
      ["name" : "Cafeteria", "code": "cafeteria"],
      ["name" : "Cajun/Creole", "code": "cajun"],
      ["name" : "Cambodian", "code": "cambodian"],
      ["name" : "Canadian", "code": "New)"],
      ["name" : "Canteen", "code": "canteen"],
      ["name" : "Caribbean", "code": "caribbean"],
      ["name" : "Catalan", "code": "catalan"],
      ["name" : "Chech", "code": "chech"],
      ["name" : "Cheesesteaks", "code": "cheesesteaks"],
      ["name" : "Chicken Shop", "code": "chickenshop"],
      ["name" : "Chicken Wings", "code": "chicken_wings"],
      ["name" : "Chilean", "code": "chilean"],
      ["name" : "Chinese", "code": "chinese"],
      ["name" : "Comfort Food", "code": "comfortfood"],
      ["name" : "Corsican", "code": "corsican"],
      ["name" : "Creperies", "code": "creperies"],
      ["name" : "Cuban", "code": "cuban"],
      ["name" : "Curry Sausage", "code": "currysausage"],
      ["name" : "Cypriot", "code": "cypriot"],
      ["name" : "Czech", "code": "czech"],
      ["name" : "Czech/Slovakian", "code": "czechslovakian"],
      ["name" : "Danish", "code": "danish"],
      ["name" : "Delis", "code": "delis"],
      ["name" : "Diners", "code": "diners"],
      ["name" : "Dumplings", "code": "dumplings"],
      ["name" : "Eastern European", "code": "eastern_european"],
      ["name" : "Ethiopian", "code": "ethiopian"],
      ["name" : "Fast Food", "code": "hotdogs"],
      ["name" : "Filipino", "code": "filipino"],
      ["name" : "Fish & Chips", "code": "fishnchips"],
      ["name" : "Fondue", "code": "fondue"],
      ["name" : "Food Court", "code": "food_court"],
      ["name" : "Food Stands", "code": "foodstands"],
      ["name" : "French", "code": "french"],
      ["name" : "French Southwest", "code": "sud_ouest"],
      ["name" : "Galician", "code": "galician"],
      ["name" : "Gastropubs", "code": "gastropubs"],
      ["name" : "Georgian", "code": "georgian"],
      ["name" : "German", "code": "german"],
      ["name" : "Giblets", "code": "giblets"],
      ["name" : "Gluten-Free", "code": "gluten_free"],
      ["name" : "Greek", "code": "greek"],
      ["name" : "Halal", "code": "halal"],
      ["name" : "Hawaiian", "code": "hawaiian"],
      ["name" : "Heuriger", "code": "heuriger"],
      ["name" : "Himalayan/Nepalese", "code": "himalayan"],
      ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
      ["name" : "Hot Dogs", "code": "hotdog"],
      ["name" : "Hot Pot", "code": "hotpot"],
      ["name" : "Hungarian", "code": "hungarian"],
      ["name" : "Iberian", "code": "iberian"],
      ["name" : "Indian", "code": "indpak"],
      ["name" : "Indonesian", "code": "indonesian"],
      ["name" : "International", "code": "international"],
      ["name" : "Irish", "code": "irish"],
      ["name" : "Island Pub", "code": "island_pub"],
      ["name" : "Israeli", "code": "israeli"],
      ["name" : "Italian", "code": "italian"],
      ["name" : "Japanese", "code": "japanese"],
      ["name" : "Jewish", "code": "jewish"],
      ["name" : "Kebab", "code": "kebab"],
      ["name" : "Korean", "code": "korean"],
      ["name" : "Kosher", "code": "kosher"],
      ["name" : "Kurdish", "code": "kurdish"],
      ["name" : "Laos", "code": "laos"],
      ["name" : "Laotian", "code": "laotian"],
      ["name" : "Latin American", "code": "latin"],
      ["name" : "Live/Raw Food", "code": "raw_food"],
      ["name" : "Lyonnais", "code": "lyonnais"],
      ["name" : "Malaysian", "code": "malaysian"],
      ["name" : "Meatballs", "code": "meatballs"],
      ["name" : "Mediterranean", "code": "mediterranean"],
      ["name" : "Mexican", "code": "mexican"],
      ["name" : "Middle Eastern", "code": "mideastern"],
      ["name" : "Milk Bars", "code": "milkbars"],
      ["name" : "Modern Australian", "code": "modern_australian"],
      ["name" : "Modern European", "code": "modern_european"],
      ["name" : "Mongolian", "code": "mongolian"],
      ["name" : "Moroccan", "code": "moroccan"],
      ["name" : "New Zealand", "code": "newzealand"],
      ["name" : "Night Food", "code": "nightfood"],
      ["name" : "Norcinerie", "code": "norcinerie"],
      ["name" : "Open Sandwiches", "code": "opensandwiches"],
      ["name" : "Oriental", "code": "oriental"],
      ["name" : "Pakistani", "code": "pakistani"],
      ["name" : "Parent Cafes", "code": "eltern_cafes"],
      ["name" : "Parma", "code": "parma"],
      ["name" : "Persian/Iranian", "code": "persian"],
      ["name" : "Peruvian", "code": "peruvian"],
      ["name" : "Pita", "code": "pita"],
      ["name" : "Pizza", "code": "pizza"],
      ["name" : "Polish", "code": "polish"],
      ["name" : "Portuguese", "code": "portuguese"],
      ["name" : "Potatoes", "code": "potatoes"],
      ["name" : "Poutineries", "code": "poutineries"],
      ["name" : "Pub Food", "code": "pubfood"],
      ["name" : "Rice", "code": "riceshop"],
      ["name" : "Romanian", "code": "romanian"],
      ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
      ["name" : "Rumanian", "code": "rumanian"],
      ["name" : "Russian", "code": "russian"],
      ["name" : "Salad", "code": "salad"],
      ["name" : "Sandwiches", "code": "sandwiches"],
      ["name" : "Scandinavian", "code": "scandinavian"],
      ["name" : "Scottish", "code": "scottish"],
      ["name" : "Seafood", "code": "seafood"],
      ["name" : "Serbo Croatian", "code": "serbocroatian"],
      ["name" : "Signature Cuisine", "code": "signature_cuisine"],
      ["name" : "Singaporean", "code": "singaporean"],
      ["name" : "Slovakian", "code": "slovakian"],
      ["name" : "Soul Food", "code": "soulfood"],
      ["name" : "Soup", "code": "soup"],
      ["name" : "Southern", "code": "southern"],
      ["name" : "Spanish", "code": "spanish"],
      ["name" : "Steakhouses", "code": "steak"],
      ["name" : "Sushi Bars", "code": "sushi"],
      ["name" : "Swabian", "code": "swabian"],
      ["name" : "Swedish", "code": "swedish"],
      ["name" : "Swiss Food", "code": "swissfood"],
      ["name" : "Tabernas", "code": "tabernas"],
      ["name" : "Taiwanese", "code": "taiwanese"],
      ["name" : "Tapas Bars", "code": "tapas"],
      ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
      ["name" : "Tex-Mex", "code": "tex-mex"],
      ["name" : "Thai", "code": "thai"],
      ["name" : "Traditional Norwegian", "code": "norwegian"],
      ["name" : "Traditional Swedish", "code": "traditional_swedish"],
      ["name" : "Trattorie", "code": "trattorie"],
      ["name" : "Turkish", "code": "turkish"],
      ["name" : "Ukrainian", "code": "ukrainian"],
      ["name" : "Uzbek", "code": "uzbek"],
      ["name" : "Vegan", "code": "vegan"],
      ["name" : "Vegetarian", "code": "vegetarian"],
      ["name" : "Venison", "code": "venison"],
      ["name" : "Vietnamese", "code": "vietnamese"],
      ["name" : "Wok", "code": "wok"],
      ["name" : "Wraps", "code": "wraps"],
      ["name" : "Yugoslav", "code": "yugoslav"]]
  }

}
