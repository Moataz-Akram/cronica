//
//  CustomList-Extensions.swift
//  Story
//
//  Created by Alexandre Madeira on 13/02/23.
//

import Foundation

extension CustomList {
    var itemTitle: String {
        return title ?? NSLocalizedString("Untitled List", comment: "")
    }
    var itemLastUpdateFormatted: String {
        if let updatedDate {
            return updatedDate.convertDateToShortString()
        }
        return ""
    }
    var itemGlanceInfo: String {
        if let notes {
            if !notes.isEmpty {
                return notes
            }
        }
        if let items {
            return NSLocalizedString("\(items.count) items", comment: "")
        }
        return NSLocalizedString("Last update on \(itemLastUpdateFormatted)", comment: "")
    }
    var itemListHeader: String {
        if let items, let updatedDate {
            return NSLocalizedString("\(items.count) items • \(updatedDate.convertDateToString())", comment: "") 
        }
        return ""
    }
    var itemsSet: Set<WatchlistItem> {
        return items as? Set<WatchlistItem> ?? []
    }
    var itemsArray: [WatchlistItem] {
        let set = items as? Set<WatchlistItem> ?? []
        return set.sorted {
            $0.itemTitle < $1.itemTitle
        }
    }
}
