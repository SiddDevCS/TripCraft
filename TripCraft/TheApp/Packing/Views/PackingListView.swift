//
//  PackingListView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI
import Foundation

struct PackingListView: View {
    @StateObject private var viewModel = PackingListViewModel()
    @StateObject private var aiService = AIService()
    @State private var showingAddItem = false
    @State private var showingAIAssistant = false
    @State private var showingCreateScreen = false
    @State private var showTemplatesList = false
    @State private var searchText = ""
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showingDeleteAlert = false
    @State private var selectedTrip: Trip?
    @State private var showingTripSelector = false
    @State private var showingTripDeleteAlert = false
    @State private var tripToDelete: Trip?
    
    // Animation state variables
    @State private var isViewAppearing = false
    @State private var isSearchVisible = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Track tab bar navigation
    @AppStorage("lastSelectedTab") private var lastSelectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced background with subtle gradient
                backgroundGradient
                    .ignoresSafeArea()
                
                // Content based on state
                mainContentView
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTrip)
            .toolbar {
                toolbarItems
            }
            .toolbarBackground(toolbarBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    isViewAppearing = true
                }
                
                // Clear search when view appears
                searchText = ""
                
                // Set up notification observer for tab bar navigation
                setupTabChangeObserver()
            }
            .onDisappear {
                // Remove observer when view disappears
                NotificationCenter.default.removeObserver(self)
            }
            // Sheets and alerts
            .sheet(isPresented: $showingAddItem) {
                AddItemView(viewModel: viewModel, tripId: selectedTrip?.id)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showingAIAssistant) {
                AIAssistantView(viewModel: viewModel, tripId: selectedTrip?.id)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showingCreateScreen) {
                PackingListCreationView { trip in
                    viewModel.addTrip(trip)
                    selectedTrip = trip
                }
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
            }
            .alert("Delete All Items", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllItems()
                }
            } message: {
                Text("Are you sure you want to delete all packing items for this trip? This action cannot be undone.")
            }
            .alert("Delete Trip", isPresented: $showingTripDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let tripToDelete = tripToDelete {
                        deleteTrip(tripToDelete)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this trip? All packing items associated with it will also be deleted. This action cannot be undone.")
            }
        }
        .tint(.blue)
    }
    
    // MARK: - Tab Navigation
    
    private func setupTabChangeObserver() {
        // Remove any existing observers first
        NotificationCenter.default.removeObserver(self)
        
        // Add observer for tab changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TabSelectionChanged"),
            object: nil,
            queue: .main
        ) { notification in
            if let selectedTab = notification.userInfo?["selectedTab"] as? Int, 
               selectedTab == 0 {  // 0 is the Packing tab
                resetToMainView()
            }
        }
        
        // Handle tab selection from AppStorage
        if lastSelectedTab == 0 {
            // Reset view when returning to packing tab
            resetToMainView()
                    }
    }
    
    private func resetToMainView() {
        // Reset to trip selection view or empty state when tab is pressed
        withAnimation {
            selectedTrip = nil
            isSelectionMode = false
            selectedItems.removeAll()
            searchText = ""
                    }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var mainContentView: some View {
        if viewModel.trips.isEmpty {
            emptyStateView
        } else if selectedTrip == nil {
            tripSelectionView
        } else if viewModel.packingItemsForTrip(tripId: selectedTrip!.id).isEmpty {
            emptyTripStateView
            } else {
            packingListContentView
        }
    }
    
    private var emptyStateView: some View {
        // Empty state - no trips
        EmptyStateView(onCreateTapped: { showingCreateScreen = true })
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var tripSelectionView: some View {
        // No trip selected
        TripSelectionView(
            viewModel: viewModel,
            onTripSelected: { selectedTrip = $0 },
            onCreateTapped: { showingCreateScreen = true },
            onDeleteTrip: confirmDeleteTrip
        )
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
        .onAppear {
            // Clear search when trip selection view appears
            searchText = ""
        }
    }
    
    private var emptyTripStateView: some View {
        // Empty state - trip selected but no items
        EmptyTripStateView(
            trip: selectedTrip,
            aiService: aiService,
            onAIAssistantTapped: { showingAIAssistant = true },
            onAddItemTapped: { showingAddItem = true },
            onBackTapped: { 
                withAnimation {
                    selectedTrip = nil
                }
            }
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .onAppear {
            // Clear search when empty trip state appears
            searchText = ""
        }
    }
    
    private var packingListContentView: some View {
        // Main packing list view
        PackingListContentView(
            viewModel: viewModel,
            trip: selectedTrip!,
            searchText: $searchText,
            isSelectionMode: $isSelectionMode,
            selectedItems: $selectedItems,
            onAddItemTapped: { showingAddItem = true },
            onAIAssistantTapped: { showingAIAssistant = true },
            onBackTapped: {
                withAnimation {
                    selectedTrip = nil
                        }
                    }
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
        .onAppear {
            // Ensure selection mode is off when viewing the content
            if isSelectionMode {
                isSelectionMode = false
                selectedItems.removeAll()
                }
            
            // Show search field with animation
            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                isSearchVisible = true
            }
            }
        .onDisappear {
            // Hide search when leaving this view
            isSearchVisible = false
        }
    }
    
    // MARK: - UI Elements
    
            // Background gradient
    private var backgroundGradient: some View {
            LinearGradient(
                gradient: Gradient(colors: [
                colorScheme == .dark ? Color.black : Color.white,
                colorScheme == .dark ? Color.black.opacity(0.95) : Color.blue.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        .opacity(isViewAppearing ? 1 : 0)
    }
    
    // Toolbar background color
    private var toolbarBackgroundColor: Color {
        if selectedTrip != nil {
            return colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.8)
                        } else {
            return Color.clear
                    }
                }
                
    // MARK: - Navigation Title
    private var navigationTitle: String {
                if let trip = selectedTrip {
            return trip.name
        } else if viewModel.trips.isEmpty {
            return "Packing"
                        } else {
            return "Trips"
        }
    }
    
    // MARK: - Toolbar Items
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        // Check if we have a selected trip with items
        if let trip = selectedTrip {
            let tripHasItems = !viewModel.packingItemsForTrip(tripId: trip.id).isEmpty
            
            if tripHasItems {
                // Trip with items - show full toolbar
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { isSelectionMode.toggle() }) {
                            Label(isSelectionMode ? "Cancel Selection" : "Select Items",
                                  systemImage: isSelectionMode ? "xmark.circle" : "checkmark.circle")
                    }
                    
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete All", systemImage: "trash")
                        }
                        
                        Button(action: {
                            withAnimation {
                                selectedTrip = nil
                            }
                        }) {
                            Label("Change Trip", systemImage: "arrow.left")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.blue)
                            .frame(width: 32, height: 32)
                .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelectionMode {
                        Button(action: { deleteSelectedItems() }) {
                            Text("Delete Selected")
                                .foregroundStyle(.red)
                                .fontWeight(.medium)
                                .opacity(selectedItems.isEmpty ? 0.5 : 1)
        }
                        .disabled(selectedItems.isEmpty)
                    } else {
                    Button(action: { showingAddItem = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.blue)
                                .frame(width: 32, height: 32)
                .background(
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                )
            }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            } else {
                // Trip selected but empty
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            selectedTrip = nil
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        } else if !viewModel.trips.isEmpty {
            // Trip selection screen
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateScreen = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)
        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.15))
        )
    }
                .buttonStyle(ScaleButtonStyle())
                }
        }
    }
    
    // MARK: - Actions
    private func deleteAllItems() {
        withAnimation {
            guard let tripId = selectedTrip?.id else { return }
            viewModel.deleteAllItemsForTrip(tripId: tripId)
        }
    }
    
    private func deleteSelectedItems() {
        withAnimation {
            viewModel.deleteItems(with: selectedItems)
            selectedItems.removeAll()
            isSelectionMode = false
        }
    }
    
    private func confirmDeleteTrip(_ trip: Trip) {
        tripToDelete = trip
        showingTripDeleteAlert = true
    }
    
    private func deleteTrip(_ trip: Trip) {
        withAnimation {
            // Reset selected trip if currently selected
            if selectedTrip?.id == trip.id {
                selectedTrip = nil
            }
            
            // Delete trip and associated items
            viewModel.deleteTrip(trip)
        }
    }
}
