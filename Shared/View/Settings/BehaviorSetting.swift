//
//  BehaviorSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct BehaviorSetting: View {
    @StateObject private var store = SettingsStore.shared
#if os(macOS)
    @State private var showWatchProvidersSelector = false
#endif
    var body: some View {
        Form {
            gesture
#if os(iOS)
            swipeGesture
            links
#endif
            otherOptions
            watchProviders
#if os(iOS)
            accessibility
            Button("changeLanguage") {
                Task {
                    // Create the URL that deep links to your app's custom settings.
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }
                }
            }
#endif
        }
        .navigationTitle("behaviorTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var gesture: some View {
        Section {
#if os(iOS)
            Picker(selection: $store.gesture) {
                ForEach(UpdateItemProperties.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                InformationalLabel(title: "behaviorDoubleTapTitle",
                                   subtitle: "behaviorDoubleTapSubtitle")
            }
#endif
            Toggle(isOn: $store.markEpisodeWatchedOnTap) {
                InformationalLabel(title: "behaviorEpisodeTitle")
            }
        } header: {
            Text("behaviorGestureTitle")
        }
    }
    
    private var otherOptions: some View {
        Section {
#if os(iOS)
            if UIDevice.isIPhone {
                Toggle("enablePreferredLaunchScreen", isOn: $store.isPreferredLaunchScreenEnabled)
                Picker(selection: $store.preferredLaunchScreen) {
                    ForEach(Screens.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    Text("preferredLaunchScreen")
                }
                .disabled(!store.isPreferredLaunchScreenEnabled)
            }
#endif
        }
    }
    
    private var swipeGesture: some View {
        Section {
            Picker("behaviorPrimaryLeftGesture", selection: $store.primaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("behaviorSecondaryLeftGesture", selection: $store.secondaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("behaviorPrimaryRightGesture", selection: $store.primaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("behaviorSecondaryRightGesture", selection: $store.secondaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Toggle(isOn: $store.allowFullSwipe) {
                InformationalLabel(title: "behaviorAllowFullSwipeTitle",
                                   subtitle: "behaviorAllowFullSwipeSubtitle")
            }
            Button("resetToDefault") {
                store.primaryLeftSwipe = .markWatch
                store.secondaryLeftSwipe = .markFavorite
                store.primaryRightSwipe = .delete
                store.secondaryRightSwipe = .markArchive
                store.allowFullSwipe = false
            }
        } header: {
            Text("behaviorSwipeTitle")
        }
    }
    
    private var links: some View {
        Section {
            Toggle(isOn: $store.openInYouTube) {
                InformationalLabel(title: "behaviorYouTubeTitle")
            }
        }
    }
    
    private var watchProviders: some View {
        Section {
            Toggle(isOn: $store.isWatchProviderEnabled) {
                InformationalLabel(title: "behaviorWatchProvidersTitle",
                                   subtitle: "behaviorWatchProvidersSubtitle")
            }
            if store.isWatchProviderEnabled {
                Picker(selection: $store.watchRegion) {
                    ForEach(WatchProviderOption.allCases.sorted { $0.localizableTitle < $1.localizableTitle}) { region in
                        Text(region.localizableTitle)
                            .tag(region)
                    }
                } label: {
                    InformationalLabel(title: "watchRegionTitle", subtitle: "watchRegionSubtitle")
                }
                .onChange(of: store.watchRegion) { _ in
                    if !store.selectedWatchProviders.isEmpty { store.selectedWatchProviders = "" }
                }
#if os(macOS)
                .pickerStyle(.automatic)
#else
                .pickerStyle(.navigationLink)
#endif
#if os(iOS)
                NavigationLink("selectedWatchProvider", destination: WatchProviderSelectorSetting())
#elseif os(macOS)
                Button("selectedWatchProvider") {
                    showWatchProvidersSelector.toggle()
                }.buttonStyle(.link)
#endif
            }
        }
#if os(macOS)
        .sheet(isPresented: $showWatchProvidersSelector) {
            NavigationStack {
                WatchProviderSelectorSetting(showView: $showWatchProvidersSelector)
            }
            .presentationDetents([.large])
            .frame(width: 400, height: 500, alignment: .center)
        }
#endif
    }
    
    private var accessibility: some View {
        Section {
            Toggle(isOn: $store.hapticFeedback) {
                InformationalLabel(title: "hapticFeedbackTitle")
            }
            .onChange(of: store.hapticFeedback) { newValue in
                CronicaTelemetry.shared.handleMessage("\(newValue)", for: "haptic.Feedback.Settings")
            }
        }
    }
}

struct BehaviorSetting_Previews: PreviewProvider {
    static var previews: some View {
        BehaviorSetting()
            .preferredColorScheme(.light)
        BehaviorSetting()
            .preferredColorScheme(.dark)
        BehaviorSetting()
            .previewDevice("iPad Air (5th generation)")
            .previewInterfaceOrientation(.landscapeRight)
    }
}
