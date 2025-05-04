//
// Created by Alexander Knyazev on 27.11.2021.
//

import SwiftUI
// import UIKit // UIKit не нужен для SwiftUI

// MARK: - DetailView
struct DetailView: View {
    var food: Food
    @StateObject private var viewModel: DetailViewModel

    init(food: Food) {
        self.food = food
        _viewModel = StateObject(wrappedValue: DetailViewModel(food: food))
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if viewModel.showProgress {
                    loadingView(geometry: geometry)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    foodDetailView
                        .padding(20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .task {
            await viewModel.loadFoodItem()
        }
    }
    
    // MARK: - Loading View
    private func loadingView(geometry: GeometryProxy) -> some View {
        VStack {
            ProgressView("Loading info", value: max(0, min(viewModel.progressValue, 100)), total: 100)
                .progressViewStyle(CircularProgressViewStyle())
                .accessibilityLabel(Locale.current.languageCode != "ru" ? "Loading progress" : "Прогресс загрузки")
                .accessibilityValue("\(Int(max(0, min(viewModel.progressValue, 100))))%")
        }
        .frame(width: max(0, geometry.size.width))
        .frame(minHeight: max(0, geometry.size.height))
    }
    
    // MARK: - Food Detail View
    private var foodDetailView: some View {
        VStack(alignment: .leading) {
            // Header
            Text(viewModel.foodItem?.common.description ?? "")
                .font(.title)
                .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                .accessibilityLabel(Locale.current.languageCode != "ru" ? "Food name" : "Название продукта")
                .accessibilityValue(viewModel.foodItem?.common.description ?? "")
                .transition(.opacity)
            
            HStack {
                Text("FDC ID: ")
                    .font(.body)
                Text(String(viewModel.foodItem?.common.fdc_id ?? 0))
                    .font(.body)
            }
            .padding(.top, 5)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Locale.current.languageCode != "ru" ? "Food Database Center ID" : "Идентификатор базы данных продуктов")
            .accessibilityValue(String(viewModel.foodItem?.common.fdc_id ?? 0))
            
            HStack {
                Text("Publication date: ")
                    .font(.body)
                Text(viewModel.foodItem?.common.publication_date ?? "")
                    .font(.body)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Locale.current.languageCode != "ru" ? "Publication date" : "Дата публикации")
            .accessibilityValue(viewModel.foodItem?.common.publication_date ?? "")
            
            // Nutrients
            nutrientsView
                .padding(.top, 5)
            
            // Google Search Link
            googleSearchLink
                .padding(.vertical, 20)
        }
    }
    
    // MARK: - Nutrients View
    private var nutrientsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("contained in 100 grams")
                    .frame(width: 270, alignment: .leading)
                    .font(.body)
                    .foregroundColor(Color(UIColor.systemGray2))
                    .accessibilityLabel(Locale.current.languageCode != "ru" ? "Nutrients contained in 100 grams" : "Содержание питательных веществ в 100 граммах")
            }
            
            // Proximates
            nutrientSection(title: "Proximates", range: 0..<5200)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            
            // Minerals
            nutrientSection(title: "Minerals", range: 5200..<6250)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            
            // Vitamins
            nutrientSection(title: "Vitamins and Other Components", range: 6250..<9600)
                .transition(.opacity.combined(with: .move(edge: .leading)))
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showProgress)
    }
    
    // MARK: - Nutrient Section
    private func nutrientSection(title: String, range: Range<Int>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                .accessibilityLabel(title)
            
            if let nutrients = viewModel.foodItem?.nutrients {
                let filteredNutrients = nutrients.filter { nutrient in
                    guard let rank = nutrient.rank else { return false }
                    return range.contains(rank)
                }
                
                ForEach(filteredNutrients, id: \.id) { nutrient in
                    HStack {
                        Text("\(nutrient.name ?? "") (\(nutrient.unit_name ?? ""))")
                            .frame(width: 270, alignment: .leading)
                            .font(.body)
                        Text(formatNutrientAmount(nutrient.amount))
                            .font(.body)
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(nutrient.name ?? "")")
                    .accessibilityValue("\(formatNutrientAmount(nutrient.amount)) \(nutrient.unit_name ?? "")")
                }
            }
        }
    }
    
    private func formatNutrientAmount(_ amount: Float?) -> String {
        guard let amount = amount else { return "0.0" }
        if amount.isNaN || amount.isInfinite {
            return "0.0"
        }
        // Округляем до 1 знака после запятой и проверяем на отрицательные значения
        let formattedAmount = max(0, amount)
        return String(format: "%.1f", locale: Locale.current, formattedAmount)
    }
    
    // MARK: - Google Search Link
    private var googleSearchLink: some View {
        Link(NSLocalizedString("Search ", comment: "search with linebreak") + 
             " «\(Locale.current.languageCode != "ru" ? food.description : food.description)» " + 
             NSLocalizedString("in Google", comment: ""),
             destination: URL(string: "https://www.google.com/search?q=\(food.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
            .foregroundColor(.blue)
            .accessibilityLabel(Locale.current.languageCode != "ru" ? "Search in Google" : "Поиск в Google")
            .accessibilityHint(Locale.current.languageCode != "ru" ? "Opens Google search for this food item" : "Открывает поиск Google для этого продукта")
    }
}

