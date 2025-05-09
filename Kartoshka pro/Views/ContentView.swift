//
//  ContentView.swift
//  Kartoshka pro
//
//  Created by Alexander Knyazev on 06.11.2021.
//


import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = FoodViewModel()
    
    // MARK: - Colors and UI
    @Environment(\.colorScheme) var colorScheme
    let normalColor = Color(UIColor.systemGray2)
    @State private var colHighlightColor = Color(UIColor(red: 246/255, green: 103/255, blue: 111/255, alpha: 1))
    @State private var colDefaultColor: Color = .black
    @State private var rowBackgroundColor: Color = Color(UIColor.systemBackground)
    @State private var rowBackgroundColorHighlight = Color(UIColor(red: 246/255, green: 140/255, blue: 150/255, alpha: 0.8))
    @State private var rowForegroundColor: Color = .black
    @State private var rowForegroundColorHighlight = Color.white
    let linkColor = Color(UIColor(red: 245/255, green: 143/255, blue: 63/255, alpha: 0.9))
    
    // MARK: - Other properties
    @State private var selection = Set<String>()
    @State private var isEditMode: EditMode = .active
    let items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    @State private var sort: Int = 0
    @State private var x = 0

    var body: some View {
        NavigationView {
            VStack {
                searchBar
                
                GeometryReader { geometry in
                    ScrollView {
                        if viewModel.showProgress {
                            loadingView(geometry: geometry)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            VStack {
                                foodTableView
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                paginationView
                                    .transition(.opacity)
                            }
                        }
                    }
                    .task {
                        await viewModel.loadData()
                    }
                    .padding(10)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    nutrientsButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    categoriesMenu
                }
            }
            .navigationTitle(Locale.current.languageCode != "ru" ? viewModel.categoryCurrent.title_en : viewModel.categoryCurrent.title)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            updateColors()
        }
        .onChange(of: colorScheme) { newValue in
            DispatchQueue.main.async {
                updateColors()
            }
        }
    }
    
    // Updates colors based on the current color scheme
    private func updateColors() {
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark
        colDefaultColor = isDark ? .white : .black
        rowForegroundColor = isDark ? .white : .black
        rowBackgroundColor = Color(UIColor.systemBackground)
    }
    
    // MARK: - UI Components
    
    // Search bar with real-time filtering
    private var searchBar: some View {
        HStack(spacing: 5) {
            TextField(
                Locale.current.languageCode != "ru" ? "Search (min 3 symbols)" : "Поиск (минимум 3 буквы)",
                text: $viewModel.textSearch
            )
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.body)
            .accessibilityLabel(Locale.current.languageCode != "ru" ? "Search field" : "Поле поиска")
            .accessibilityHint(Locale.current.languageCode != "ru" ? "Enter at least 3 characters to search" : "Введите минимум 3 символа для поиска")
            .onChange(of: viewModel.textSearch) { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    if newValue.isEmpty {
                        Task {
                            await viewModel.filterFoodByTitle("")
                        }
                    } else if newValue.count > Config.searchMinLength {
                        Task {
                            await viewModel.filterFoodByTitle(newValue)
                        }
                    }
                }
            }
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if viewModel.isEditing {
                        Button(action: {
                            viewModel.textSearch = ""
                            viewModel.isEditing = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .onTapGesture {
                viewModel.isEditing = true
            }
        }
        .padding(.horizontal, 15)
    }
    
    // Loading indicator with progress
    private func loadingView(geometry: GeometryProxy) -> some View {
        VStack {
            ProgressView("Loading products", value: viewModel.progressValue, total: 100)
                .progressViewStyle(CircularProgressViewStyle())
                .accessibilityLabel(Locale.current.languageCode != "ru" ? "Loading progress" : "Прогресс загрузки")
                .accessibilityValue("\(Int(viewModel.progressValue))%")
        }
        .frame(width: geometry.size.width)
        .frame(minHeight: geometry.size.height)
    }
    
    // Main table view displaying food items and their nutrients
    private var foodTableView: some View {
        HStack(alignment: .top, spacing: 0) {
            nutrientColumns
            foodNamesColumn
        }
    }
    
    // Nutrient columns component
    private var nutrientColumns: some View {
        VStack(alignment: .leading, spacing: 3) {
            nutrientHeaders
            nutrientDataRows
        }.frame(
            minWidth: 0,
            maxWidth: 49*4,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
    
    // Nutrient headers component
    private var nutrientHeaders: some View {
        HStack(spacing: 1) {
            ForEach(viewModel.selectedNutrients, id: \.id) { nutrient in
                ColumnHeader(title: nutrient.name, literal: nutrient.id)
                    .foregroundColor(viewModel.sortType == "n\(nutrient.id)" ? colHighlightColor : linkColor)
                    .onTapGesture {
                        Task {
                            await viewModel.changeSort("n\(nutrient.id)")
                        }
                    }
                    .accessibilityLabel("\(nutrient.name)")
                    .accessibilityHint(Locale.current.languageCode != "ru" ? "Tap to sort by this nutrient" : "Нажмите для сортировки по этому питательному веществу")
                    .frame(
                        minWidth: 0,
                        maxWidth: 49,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
            }
        }
        .frame(height: 100)
    }
    
    // Nutrient data rows component
    private var nutrientDataRows: some View {
        ForEach(viewModel.foods, id: \.id) { item in
            HStack(spacing: 1) {
                ForEach(viewModel.selectedNutrients, id: \.id) { nutrient in
                    NutrientCell(item: item, nutrient: nutrient)
                        .frame(
                            minWidth: 0,
                            maxWidth: 49,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(item.description)
            .background(viewModel.selectedFoodId == item.id ? rowBackgroundColorHighlight : rowBackgroundColor)
            .font(Font.headline.weight(.light).monospacedDigit())
            .onTapGesture {
                viewModel.selectedFoodId = item.id
            }
        }
    }
    
    // Individual nutrient cell component
    private func NutrientCell(item: Food, nutrient: Nutrient) -> some View {
        let val = item.nutrientValues["n\(nutrient.id)"] ?? 0.0
        let safeValue = val.isNaN || val.isInfinite ? 0.0 : val
        return AnyView(
            Text(String(format: safeValue > 100 ? "%.0f" : "%.1f", locale: Locale.current, safeValue))
                .foregroundColor(viewModel.selectedFoodId == item.id ? rowForegroundColorHighlight : 
                                viewModel.sortType == "n\(nutrient.id)" ? colHighlightColor : colDefaultColor)
                .frame(
                    minWidth: 0,
                    maxWidth: 49,
                    minHeight: 0,
                    alignment: .trailing
                )
                .font(.body)
                .accessibilityLabel("\(nutrient.name): \(String(format: safeValue > 100 ? "%.0f" : "%.1f", locale: Locale.current, safeValue))")
        )
    }
    
    // Food names column component
    private var foodNamesColumn: some View {
        VStack(alignment: .leading, spacing: 3) {
            foodNamesHeader
            foodNamesList
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
    
    // Food names header component
    private var foodNamesHeader: some View {
        VStack {
            Text("in 100 grams")
                .frame(height: 100, alignment: .bottomLeading)
                .font(.body)
                .foregroundColor(Color(UIColor.systemGray2))
                .offset(x: 10, y: -3)
        }
        .frame(height: 100)
    }
    
    // Food names list component
    private var foodNamesList: some View {
        ForEach(viewModel.foods, id: \.id) { item in
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(Locale.current.languageCode != "ru" ? item.description : item.description)
                        .lineLimit(1)
                        .onTapGesture {
                            viewModel.selectedFoodId = item.id
                        }
                        .onLongPressGesture {
                            viewModel.modalFood = item
                        }
                }
                .foregroundColor(viewModel.selectedFoodId == item.id ? rowForegroundColorHighlight : rowForegroundColor)
                .sheet(item: $viewModel.modalFood) {
                    DetailView(food: $0).onTapGesture {
                        viewModel.modalFood = nil
                    }
                }
            }
            .padding(.leading, 10.0)
            .background(viewModel.selectedFoodId == item.id ? rowBackgroundColorHighlight : rowBackgroundColor)
            .accessibilityIdentifier("foodItem")
            .accessibilityLabel(item.description)
            .accessibilityElement(children: .combine)
        }
    }
    
    // Pagination controls and results count
    private var paginationView: some View {
        VStack {
            let pages: Int = Int(ceil(Double(viewModel.count) / Double(100)))
            Text("Results: \(viewModel.count), page \(viewModel.page) of \(pages)")
                .padding(.top, 15)
                .foregroundColor(.gray)
                .font(.body)
            
            HStack {
                if viewModel.page > 1 {
                    Button("Previous page") {
                        viewModel.page -= 1
                        Task {
                            await viewModel.loadData()
                        }
                    }
                }
                
                if Double(viewModel.count) / Double(100) > Double(viewModel.page) {
                    Button("Next page") {
                        viewModel.page += 1
                        Task {
                            await viewModel.loadData()
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // Button to select nutrients to display
    private var nutrientsButton: some View {
        Button(action: {
            viewModel.showLanguageSheet.toggle()
        }) {
            Text("Nutrients").foregroundColor(linkColor)
                .font(.body)
        }
        .sheet(isPresented: $viewModel.showLanguageSheet) {
            MultipleSelectionList(nutrients: $viewModel.nutrients, selectedNutrients: $viewModel.selectedNutrients)
                .onDisappear {
                    Task {
                        await viewModel.loadData()
                    }
                }
        }
    }
    
    // Menu for selecting food categories
    private var categoriesMenu: some View {
        Menu {
            ForEach(viewModel.categories, id: \.self) { category in
                Button(action: {
                    Task {
                        await viewModel.filterFood(category)
                    }
                }) {
                    if viewModel.categoryCurrent == category {
                        if category.id == "branded_food" {
                            Label("\(category.title) \n(may contain incorrect data)", systemImage: "checkmark")
                                .lineLimit(2)
                        } else {
                            Label("\(category.title)", systemImage: "checkmark")
                        }
                    } else {
                        if category.id == "branded_food" {
                            Text("\(category.title) \n(may contain incorrect data)")
                                .lineLimit(2)
                        } else {
                            Text("\(category.title)")
                        }
                    }
                }
            }
        } label: {
            Text("Categories").foregroundColor(linkColor)
                .font(.body)
        }
    }
}

// Custom view for rotated column headers
struct ColumnHeader: View {
    var title: String
    var literal: String
    
    var body: some View {
        Text(title)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: true)
            .frame(width: 39, height: 100, alignment: .leading)
            .rotationEffect(.degrees(-90))
            .offset(x: 10, y: 25)
            .font(Font.headline.weight(.light))
    }
}
