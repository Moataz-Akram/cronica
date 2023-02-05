//
//  SeasonViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import SwiftUI

@MainActor
class SeasonViewModel: ObservableObject {
    private let service = NetworkService.shared
    private let persistence = PersistenceController.shared
    private let network = NetworkService.shared
    private var hasFirstLoaded = false
    @Published var season: Season?
    @Published var isLoading = true
    @Published var isItemInWatchlist = false
    
    func load(id: Int, season: Int, isInWatchlist: Bool) async {
        if Task.isCancelled { return }
        isItemInWatchlist = isInWatchlist
        DispatchQueue.main.async {
            withAnimation { self.isLoading = true }
        }
        do {
            self.season = try await self.service.fetchSeason(id: id, season: season)
        } catch {
            let message = "Season \(season), id: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "SeasonViewModel.load()")
        }
        if !hasFirstLoaded {
            hasFirstLoaded.toggle()
        }
        DispatchQueue.main.async {
            withAnimation { self.isLoading = false }
        }
    }
    
    func markSeasonAsWatched(id: Int) async {
        if let season, let episodes = season.episodes {
            if !isItemInWatchlist {
                await saveItemOnList(id: id)
            }
            for episode in episodes {
                if !persistence.isEpisodeSaved(show: id, season: season.seasonNumber, episode: episode.id) {
                    persistence.updateEpisodeList(show: id, season: season.seasonNumber, episode: episode.id)
                }
            }
        }
    }
    
    func markThisAndPrevious(until id: Int, show: Int) async {
        if !isItemInWatchlist {
            await saveItemOnList(id: show)
        }
        if let season {
            if let episodes = season.episodes {
                for episode in episodes {
                    if !persistence.isEpisodeSaved(show: show, season: season.seasonNumber, episode: episode.id) {
                        persistence.updateEpisodeList(show: show, season: season.seasonNumber, episode: episode.id)
                    }
                    if episode.id == id { return }
                }
            }
        }
    }
    
    private func saveItemOnList(id: Int) async {
        do {
            let content = try await network.fetchItem(id: id, type: .tvShow)
            persistence.save(content)
            isItemInWatchlist = true
            if content.itemCanNotify && content.itemFallbackDate.isLessThanTwoMonthsAway() {
                NotificationManager.shared.schedule(content)
            }
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "SeasonViewModel.saveItemOnList")
        }
    }
}
