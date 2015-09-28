//
//  SearchFilter.swift
//  Yelp
//
//  Created by Nikrad Mahdi on 9/26/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import Foundation

enum SearchFilterType {
  case Deals, Distance, SortBy, Category
  static let values = [Deals, Distance, SortBy, Category]
}

enum DistanceFilter: Int {
  case BestMatch, QuarterMile = 402, HalfMile = 805, OneMile = 1609, FiveMiles = 8047
  
  static let values = [BestMatch, QuarterMile, HalfMile, OneMile, FiveMiles]
  
  func label() -> String {
    switch self {
    case BestMatch:
      return "Best Match"
    case QuarterMile:
      return "0.25 miles"
    case HalfMile:
      return "0.5 miles"
    case OneMile:
      return "1 mile"
    case FiveMiles:
      return "5 miles"
    }
  }
}

enum SortFilter: Int {
  case BestMatched, Distance, HighestRated
  
  static let values = [BestMatched, Distance, HighestRated]
  
  func label() -> String {
    switch self {
    case BestMatched:
      return "Best Match"
    case Distance:
      return "Distance"
    case HighestRated:
      return "Highest Rated"
    }
  }
}