//
//  WatchlistSectionDetails.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 28/01/23.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct WatchlistSectionDetails: View {
    var title = "Upcoming"
    let items: [WatchlistItem]
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        VStack {
            switch settings.sectionStyleType {
            case .list: listStyle
            case .card: cardStyle
            case .poster: posterStyle
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                styleOptions
            }
#endif
        }
        .actionPopup(isShowing: $showPopup, for: popupType)
        .navigationTitle(LocalizedStringKey(title))
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
    }
    
    private var listStyle: some View {
        Form {
            Section {
                List {
                    ForEach(items) { item in
                        WatchlistItemRowView(content: item, showPopup: $showPopup, popupType: $popupType)
                    }
                }
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var cardStyle: some View {
        ScrollView {
            LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                ForEach(items) { item in
                    WatchlistItemCardView(content: item, showPopup: $showPopup, popupType: $popupType)
                        .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private var posterStyle: some View {
        ScrollView {
            LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactPosterColumns : DrawingConstants.posterColumns,
                      spacing: settings.isCompactUI ? DrawingConstants.compactSpacing : DrawingConstants.spacing) {
                ForEach(items) { item in
                    WatchlistItemPosterView(content: item, showPopup: $showPopup, popupType: $popupType)
                }
            }.padding(.all, settings.isCompactUI ? 10 : nil)
        }
    }
    
#if os(iOS) || os(macOS)
    private var styleOptions: some View {
        Menu {
            Picker(selection: $settings.sectionStyleType) {
                ForEach(SectionDetailsPreferredStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
            }
        } label: {
            Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
#endif
}

private struct DrawingConstants {
#if os(macOS)
    static let columns = [GridItem(.adaptive(minimum: 240))]
#else
    static let columns = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160))]
#endif
#if os(macOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
#elseif os(iOS)
    static let posterColumns  = [GridItem(.adaptive(minimum: 160))]
#endif
    static let compactPosterColumns = [GridItem(.adaptive(minimum: 80))]
    static let compactSpacing: CGFloat = 20
    static let spacing: CGFloat = 10
}

#Preview {
    WatchlistSectionDetails(items: [.example])
}
#endif
