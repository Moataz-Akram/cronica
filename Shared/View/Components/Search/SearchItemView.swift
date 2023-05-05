//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct SearchItemView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @State private var canReview = false
    @State private var showNote = false
    private let context = PersistenceController.shared
    var isSidebar = false
    var body: some View {
        if item.media == .person {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                    .draggable(item)
                    .contextMenu { ShareLink(item: item.itemSearchURL) }
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                        .draggable(item)
                        .contextMenu { ShareLink(item: item.itemSearchURL) }
                }
            }
        } else {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                    .draggable(item)
                    .task {
                        isInWatchlist = context.isItemSaved(id: item.itemNotificationID)
                        if isInWatchlist {
                            isWatched = context.isMarkedAsWatched(id: item.itemNotificationID)
                        }
                    }
                    .itemContentContextMenu(item: item,
                                            isWatched: $isWatched,
                                            showConfirmation: $showConfirmation,
                                            isInWatchlist: $isInWatchlist,
                                            showNote: $showNote)
                    .modifier(
                        SearchItemSwipeGesture(item: item,
                                               showConfirmation: $showConfirmation,
                                               isInWatchlist: $isInWatchlist,
                                               isWatched: $isWatched)
                    )
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                        .draggable(item)
                        .task {
                            isInWatchlist = context.isItemSaved(id: item.itemNotificationID)
                            if isInWatchlist {
                                isWatched = context.isMarkedAsWatched(id: item.itemNotificationID)
                                canReview = true
                            }
                        }
                        .itemContentContextMenu(item: item,
                                                isWatched: $isWatched,
                                                showConfirmation: $showConfirmation,
                                                isInWatchlist: $isInWatchlist,
                                                showNote: $showNote)
                        .modifier(
                            SearchItemSwipeGesture(item: item,
                                                   showConfirmation: $showConfirmation,
                                                   isInWatchlist: $isInWatchlist,
                                                   isWatched: $isWatched)
                        )
                }
            }
            
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    @State private static var show: Bool = false
    static var previews: some View {
        SearchItemView(item: ItemContent.example, showConfirmation: $show)
    }
}
#endif
