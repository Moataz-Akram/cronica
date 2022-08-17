//
//  WatchlistItem-CoreDataHelpers.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import Foundation
import CoreData

extension WatchlistItem {
    var itemTitle: String {
        title ?? "No title available"
    }
    var itemId: Int {
        Int(id)
    }
    var itemMedia: MediaType {
        switch contentType {
        case 0: return .movie
        case 1: return .tvShow
        case 2: return .person
        default: return .movie
        }
    }
    var itemSchedule: ItemSchedule {
        switch schedule {
        case 0: return .soon
        case 1: return .released
        case 2: return .production
        case 3: return .cancelled
        case 5: return .renewed
        default: return .unknown
        }
    }
    var itemLink: URL {
        return URL(string: "https://www.themoviedb.org/\(itemMedia.rawValue)/\(itemId)")!
    }
    var itemGlanceInfo: String? {
        switch itemMedia {
        case .tvShow:
            if upcomingSeason {
                if let formattedDate {
                    return "Season \(nextSeasonNumber) • \(formattedDate)"
                }
                return "Season \(nextSeasonNumber)"
            }
        default:
            if let formattedDate {
                return formattedDate
            }
        }
        return nil
    }
    var isWatched: Bool {
        return watched
    }
    var isFavorite: Bool {
        return favorite
    }
    var isMovie: Bool {
        if itemMedia == .movie { return true }
        return false
    }
    var isTvShow: Bool {
        if itemMedia == .tvShow { return true }
        return false
    }
    var isReleased: Bool {
        if itemMedia == .movie {
            return isReleasedMovie
        } else {
            return isReleasedTvShow
        }
    }
    var isUpcoming: Bool {
        if itemMedia == .movie {
            return isUpcomingMovie
        } else {
            return isUpcomingTvShow
        }
    }
    var isReleasedMovie: Bool {
        if itemMedia == .movie {
            if itemSchedule == .released && !notify && !isWatched {
                return true
            }
        }
        return false
    }
    var isReleasedTvShow: Bool {
        if itemMedia == .tvShow {
            if itemSchedule == .renewed { return true }
            if itemSchedule == .released && !isWatched { return true }
            if itemSchedule == .cancelled && !isWatched { return true }
        }
        return false
    }
    var isUpcomingMovie: Bool {
        if itemMedia == .movie {
            if itemSchedule == .soon && notify { return true }
            if itemSchedule == .soon { return true }
        }
        return false
    }
    var isUpcomingTvShow: Bool {
        if itemMedia == .tvShow {
            if itemSchedule == .soon && upcomingSeason && notify { return true }
            if itemSchedule == .soon && upcomingSeason { return true }
            if itemSchedule == .renewed && notify && date != nil && upcomingSeason { return true }
        }
        return false
    }
    var isInProduction: Bool {
        if nextSeasonNumber == 1 && itemSchedule == .soon && !isWatched && !notify { return true }
        if itemSchedule == .production { return true }
        return false
    }
    static var example: WatchlistItem {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.title = ItemContent.previewContent.itemTitle
        item.id = Int64(ItemContent.previewContent.id)
        item.image = ItemContent.previewContent.cardImageMedium
        item.contentType = 0
        item.notify = false
        return item
    }
}
