//
//  ContentView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var packingViewModel = PackingListViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                PackingListView()
                    .environmentObject(packingViewModel)
            }
            .tabItem {
                Label("Packing", systemImage: "checklist")
            }
            .tag(0)
            
            NavigationView {
                JournalView()
            }
            .tabItem {
                Label("Journal", systemImage: "book")
            }
            .tag(1)
            
            NavigationView {
                TravelToolsView()
            }
            .tabItem {
                Label("Tools", systemImage: "gear")
            }
            .tag(2)
        }
        .tint(.blue)
    }
}
