//
//  WatchlistItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemView: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    private let context = PersistenceController.shared
    private let notification = NotificationManager.shared
    init(content: WatchlistItem) {
        self.content = content
    }
    var body: some View {
        NavigationLink(value: content) {
            HStack {
                ZStack {
                    WebImage(url: content.image)
                        .placeholder {
                            ZStack {
                                Color.secondary
                                Image(systemName: "film")
                            }
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                    if isWatched || content.watched {
                        Color.black.opacity(0.6)
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                VStack(alignment: .leading) {
                    HStack {
                        Text(content.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                    }
                    HStack {
                        Text(content.itemMedia.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
#if os(watchOS)
#else
                if isFavorite || content.favorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .symbolRenderingMode(.multicolor)
                        .padding(.trailing)
                        .accessibilityLabel("\(content.itemTitle) is favorite.")
                }
#endif
            }
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
            }
            .accessibilityElement(children: .combine)
            .contextMenu {
#if os(watchOS)
#else
                watchedButton
                favoriteButton
                ShareLink(item: content.itemLink)
                Divider()
                deleteButton
#endif
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                watchedButton
                    .tint(content.isWatched ? .yellow : .green)
                    .disabled(content.isInProduction || content.isUpcoming)
                favoriteButton
                    .tint(content.isFavorite ? .orange : .blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteButton
            }
        }
    }
    
    private var watchedButton: some View {
        Button(action: {
            withAnimation {
                HapticManager.shared.softHaptic()
                withAnimation {
                    isWatched.toggle()
                }
                context.updateMarkAs(id: content.itemId, watched: !content.watched)
            }
        }, label: {
            Label(content.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: content.isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation {
                HapticManager.shared.softHaptic()
                withAnimation {
                    isFavorite.toggle()
                }
                context.updateMarkAs(id: content.itemId, favorite: !content.favorite)
            }
        }, label: {
            Label(content.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: content.isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            HapticManager.shared.softHaptic()
            if content.notify {
                notification.removeNotification(identifier: content.notificationID)
            }
            withAnimation {
                context.delete(content)
            }
        }, label: {
            Label("Remove", systemImage: "trash")
        })
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemView(content: WatchlistItem.example)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
