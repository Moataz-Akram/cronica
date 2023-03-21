//
//  ItemContentDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
    let itemUrl: URL
    @StateObject private var viewModel: ItemContentViewModel
    @StateObject private var store: SettingsStore
    @State private var showConfirmation = false
    @State private var showSeasonConfirmation = false
    @State private var switchMarkAsView = false
    @State private var showMarkAsConfirmation = false
    @State private var markAsMessage = ""
    @State private var markAsImage = ""
    @State private var showCustomList = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        _store = StateObject(wrappedValue: SettingsStore())
        self.title = title
        self.id = id
        self.type = type
        self.itemUrl = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            if viewModel.isLoading { ProgressView() }
            VStack {
                ScrollView {
                    CoverImageView(title: title)
                        .environmentObject(viewModel)
                    
                    WatchlistButtonView()
                        .keyboardShortcut("l", modifiers: [.option])
                        .environmentObject(viewModel)
                    
                    OverviewBoxView(overview: viewModel.content?.itemOverview,
                                    title: title)
                    .padding()
                    
                    TrailerListView(trailers: viewModel.content?.itemTrailers)
                    
                    SeasonListView(numberOfSeasons: viewModel.content?.itemSeasons,
                                   tvId: id,
                                   inWatchlist: $viewModel.isInWatchlist,
                                   seasonConfirmation: $showSeasonConfirmation)
                    .padding(0)
                    
                    WatchProvidersList(id: id, type: type)
                    
                    CastListView(credits: viewModel.credits)
                    
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: nil,
                                        addedItemConfirmation: $showConfirmation,
                                        displayAsCard: true)
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    AttributionView()
                        .padding([.top, .bottom])
                }
            }
            .background {
                TranslucentBackground(image: viewModel.content?.cardImageLarge)
            }
            .task {
                await viewModel.load()
                viewModel.registerNotification()
            }
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Image(systemName: viewModel.hasNotificationScheduled ? "bell.fill" : "bell")
                            .opacity(viewModel.isNotificationAvailable ? 1 : 0)
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                        ShareLink(item: itemUrl)
                            .disabled(viewModel.isLoading ? true : false)
                        if UIDevice.isIPad {
                            watchButton
                            favoriteButton
                        } else {
                            moreMenu
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("Cancel") { }
                Button("Retry") { Task { await viewModel.load() } }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showCustomList) {
                ItemContentCustomListSelector(item: $viewModel.watchlistItem, showView: $showCustomList)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
                .appTheme()
                .appTint()
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
            ConfirmationDialogView(showConfirmation: $showSeasonConfirmation,
                                   message: "Season Marked as Watched", image: "tv.fill")
            ConfirmationDialogView(showConfirmation: $showMarkAsConfirmation,
                                   message: markAsMessage, image: markAsImage)
        }
    }
    
    private var addToCustomListButton: some View {
        Button {
            showCustomList.toggle()
        } label: {
            Label("addToCustomList", systemImage: "rectangle.on.rectangle.angled")
        }
    }
    
    private var watchButton: some View {
        Button {
            if UIDevice.isIPad {
                if viewModel.isFavorite {
                    markAsMessage = "removedFromWatched"
                    markAsImage = "minus.circle"
                } else {
                    markAsMessage = "markedAsWatched"
                    markAsImage = "checkmark.circle"
                }
            }
            
            viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
            
            if UIDevice.isIPad {
                showMarkAsConfirmation.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation {
                        showMarkAsConfirmation = false
                        markAsMessage = ""
                        markAsImage = ""
                    }
                }
            }
        } label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
        }
        .keyboardShortcut("w", modifiers: [.option])
    }
    
    private var favoriteButton: some View {
        Button {
            if UIDevice.isIPad {
                if viewModel.isFavorite {
                    markAsMessage = "removedFromFavorites"
                    markAsImage = "heart.circle.fill"
                } else {
                    markAsMessage = "markedAsFavorite"
                    markAsImage = "heart.circle"
                }
            }
            
            viewModel.updateMarkAs(markAsFavorite: !viewModel.isFavorite)
            
            if UIDevice.isIPad {
                showMarkAsConfirmation.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation {
                        showMarkAsConfirmation = false
                        markAsMessage = ""
                        markAsImage = ""
                    }
                }
            }
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
        }
        .keyboardShortcut("f", modifiers: [.option])
    }
    
    private var archiveButton: some View {
        Button {
            viewModel.updateMarkAs(archive: true)
        } label: {
            Label(viewModel.isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox")
        }
    }
    
    private var pinButton: some View {
        Button {
            viewModel.updateMarkAs(pin: true)
        } label: {
            Label(viewModel.isPin ? "Unpin Item" : "Pin Item",
                  systemImage: viewModel.isPin ? "pin.slash.fill" : "pin.fill")
        }
    }
    
    private var openInMenu: some View {
        Menu {
            if viewModel.content?.hasIMDbUrl ?? false {
                Button("IMDb") {
                    if let url = viewModel.content?.imdbUrl {
                        UIApplication.shared.open(url)
                    }
                }
            }
            Button("TMDb") {
                if let url = viewModel.content?.itemURL {
                    UIApplication.shared.open(url)
                }
            }
        } label: {
            Text("Open in")
        }
    }
    
    private var moreMenu: some View {
        Menu {
            if viewModel.isInWatchlist {
                addToCustomListButton
                archiveButton
                pinButton
            }
            watchButton
            favoriteButton
            openInMenu
        } label: {
            Label("More Options", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .disabled(viewModel.isLoading ? true : false)
    }
}

struct ItemContentDetails_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentDetails(title: ItemContent.previewContent.itemTitle,
                           id: ItemContent.previewContent.id,
                           type: MediaType.movie)
    }
}


