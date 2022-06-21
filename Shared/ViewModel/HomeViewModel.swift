//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation
import CoreData
import TelemetryClient

@MainActor class HomeViewModel: ObservableObject {
    @Published private(set) var trendingPhase: DataFetchPhase<[ItemContent]?> = .empty
    @Published private(set) var phase: DataFetchPhase<[ItemContentSection]?> = .empty
    private let service: NetworkService = NetworkService.shared
    var trendingSection: [ItemContent]? {
        trendingPhase.value ?? nil
    }
    var sections: [ItemContentSection]? {
        phase.value ?? nil
    }
    
    @Published var trendingItems: [ItemContent]?
    @Published var sectionsItems: [ItemContentSection]?
    
    func load() async {
        Task {
            if Task.isCancelled { return }
            if case .success = phase { return }
            phase = .empty
            do {
                var items: [ItemContentSection] = []
                let movies = try await self.fetchEndpoints()
                if Task.isCancelled { return }
                for movie in movies {
                    items.append(movie)
                }
                phase = .success(movies)
            } catch {
                if Task.isCancelled { return }
                phase = .failure(error)
            }
            if case .success = trendingPhase { return }
            trendingPhase = .empty
            do {
                let trendingContent = try await self.service.fetchContents(from: "trending/all/week")
                let trending = trendingContent.filter { $0.itemContentMedia != .person }
                trendingPhase = .success(trending)
            } catch {
                if Task.isCancelled { return }
                trendingPhase = .failure(error)
            }
        }
    }
    
    private func fetchTrending() async {
        let result = try? await self.service.fetchContents(from: "trending/all/week")
        if let result {
            let trending = result.filter { $0.itemContentMedia != .person }
            trendingPhase = .success(trending)
        }
    }
    
    private func fetchEndpoints(_ endpoint: [Endpoints] = Endpoints.allCases) async throws -> [ItemContentSection] {
        let results: [Result<ItemContentSection, Error>] = await withTaskGroup(of: Result<ItemContentSection,
                                                                           Error>.self) { group in
            for endpoint in endpoint {
                group.addTask { await self.fetchFrom(endpoint, type: .movie) }
            }
            var results = [Result<ItemContentSection, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var sections = [ItemContentSection]()
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let section):
                sections.append(section)
            case .failure(let error):
                TelemetryClient.TelemetryManager.send("endpointFailed", with: ["Error":"\(error.localizedDescription)"])
                errors.append(error)
            }
        }
        
        if errors.count == results.count,
           let error = errors.first {
            throw error
        }
        
        return sections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchFrom(_ endpoint: Endpoints, type: MediaType) async -> Result<ItemContentSection, Error> {
        do {
            let section = try await service.fetchContents(from: "\(type.rawValue)/\(endpoint.rawValue)")
            return .success(.init(results: section, endpoint: endpoint))
        } catch {
            TelemetryManager.send("HomeViewModel_fetchFromError",
                                  with: ["Error:":"\(error.localizedDescription)"])
            return .failure(error)
        }
    }
}
