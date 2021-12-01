//
//  ContentView.swift
//  Kartoshka pro
//
//  Created by Alexander Knyazev on 06.11.2021.
//


import SwiftUI

struct ContentView: View {

    @State var foods = [Food]()
    @State var stashFoods = [Food]()

    @State var categories = [Category(id: "", title: "All food", title_en: "All food"),
                             Category(id: "branded_food", title: "Branded food", title_en: "Branded food"),
                             Category(id: "experimental_food", title: "Experimental food", title_en: "Experimental food"),
                             Category(id: "foundation_food", title: "Foundation food", title_en: "Foundation food"),
                             Category(id: "sr_legacy_food", title: "SR legacy food", title_en: "SR legacy food"),
                             Category(id: "survey_fndds_food", title: "Survey (FNDDS) food", title_en: "Survey (FNDDS) food")

    ]
    @State private var categoryCurrent = Category(id: "foundation_food", title: "Foundation food", title_en: "Foundation food")
    @State private var searchText = ""

    @State private var sortType = "id"
    @State private var sortDirection = "desc"

    @Environment(\.colorScheme) var colorScheme

    var normalColor = Color(UIColor.systemGray2)
    @State private var colHighlightColor: Color = Color(UIColor(red: 246 / 255, green: 103 / 255, blue: 111 / 255, alpha: 1))
    @State private var colDefaultColor: Color?
    @State private var rowBackgroundColor: Color = Color(UIColor.systemBackground)
    @State private var rowBackgroundColorHighlight: Color = Color(UIColor(red: 246 / 255, green: 140 / 255, blue: 150 / 255, alpha: 0.8))
    @State private var rowForegroundColor: Color?
    @State private var rowForegroundColorHighlight: Color = Color.white
    let linkColor = Color(UIColor(red: 245 / 255, green: 143 / 255, blue: 63 / 255, alpha: 0.9))

    @State private var selectedFoodId = 0

    @State private var textSearch = ""
    @State private var isEditing = false

    @State private var modalFood: Food?

    @State var apiJsonData = Data()

    @State var showProgress = false
    @State private var progressValue = 0.0
    @State private var observation: NSKeyValueObservation!

    @State private var selection = Set<String>()
    @State private var isEditMode: EditMode = .active
    let items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    @State private var sort: Int = 0

    @State private var showLanguageSheet = false
    @State private var x = 0

    @State private var nutrients: [Nutrient]?
    @State private var selectedNutrients = [Nutrient(id: "1008", name: "Energy", nutrient_nbr: "208", rank: "300", unit_name: "KCAL")]


    init() {
        rowForegroundColor = colorScheme == .dark ? Color.white : Color.black
        colDefaultColor = colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 5) {
                    TextField(Locale.current.languageCode != "ru" ? "Search" : "Поиск", text: $textSearch)
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: textSearch) { newValue in
                                if (newValue == "") {
                                    filterFood(categoryCurrent)
                                } else {
                                    filterFoodByTitle(newValue)
                                }
                                sortChange()
                            }
                            .overlay(
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                                .foregroundColor(.gray)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 8)

                                        if isEditing {
                                            Button(action: {
                                                self.textSearch = ""
                                                self.isEditing = false
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
                                self.isEditing = true
                            }


                }.padding(.horizontal, 15)


                GeometryReader { geometry in
                    ScrollView {
                        if (showProgress) {
                            VStack {
                                ProgressView("Loading products", value: progressValue, total: 100).progressViewStyle(CircularProgressViewStyle())
                            }
                                    .frame(width: geometry.size.width)
                                    .frame(minHeight: geometry.size.height)

                        } else {
                            HStack(alignment: .top, spacing: 0) {

                                LazyVStack(alignment: .leading, spacing: 3) {

                                    HStack(spacing: 1) {
                                        if (selectedNutrients != nil) {
                                            ForEach(selectedNutrients, id: \.id) { item in
                                                ColumnHeader(title: item.name, literal: item.id)
                                                        .foregroundColor(sortType == item.id ? colHighlightColor : linkColor)
                                                        .onTapGesture {
                                                            sortChange(item.id, sortDirection)
                                                        }
                                            }
                                        }
                                    }
                                            .frame(height: 100, alignment: .bottomLeading)


                                    ForEach(foods, id: \.id) { item in
                                        HStack(spacing: 1) {
                                            if (selectedNutrients != nil) {
                                                ForEach(selectedNutrients, id: \.id) { nutrient in
                                                    if (item.n1008 != nil) {
                                                        Text(String(format: "%.1f", locale: Locale.current, (item.n1008!)))
                                                                .frame(width: 49, alignment: .trailing)
                                                                .foregroundColor(selectedFoodId == item.id ? rowForegroundColorHighlight : sortType == "proteins" ? colHighlightColor : colDefaultColor)

                                                    }
                                                }
                                            }
                                        }.background(selectedFoodId == item.id ? rowBackgroundColorHighlight : rowBackgroundColor)
                                                .font(Font.headline.weight(.light).monospacedDigit())
                                                .onTapGesture {
                                                    self.selectedFoodId = item.id
                                                }
                                    }
                                }.frame(width: 159, alignment: .leading)

                                LazyVStack(alignment: .leading, spacing: 3) {
                                    VStack {
                                        Text("in 100 grams")
                                                .frame(height: 100, alignment: .bottomLeading)
                                                .font(Font.headline.weight(.light))
                                                .foregroundColor(Color(UIColor.systemGray2))
                                                .offset(x: 10, y: -3)
                                    }.frame(height: 100)

                                    ForEach(foods, id: \.id) { item in
                                        HStack() {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                Text(Locale.current.languageCode != "ru" ? item.description : item.description)
                                                        .lineLimit(1)
                                                        .onTapGesture {
                                                            self.selectedFoodId = item.id
                                                        }
                                                        .onLongPressGesture {
                                                            modalFood = item
                                                        }
                                            }
                                                    .foregroundColor(selectedFoodId == item.id ? rowForegroundColorHighlight : rowForegroundColor)
                                                    .sheet(item: $modalFood) {
                                                        DetailView(food: $0).onTapGesture {
                                                            modalFood = nil
                                                        }
                                                    }
                                        }.padding(.leading, 10.0)
                                                .background(selectedFoodId == item.id ? rowBackgroundColorHighlight : rowBackgroundColor)

                                    }
                                }
                            }
                        }
                    }.onAppear(perform: loadData).padding(10).edgesIgnoringSafeArea(.all)

                }
            }
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            Button(action: {
                                self.showLanguageSheet.toggle()
                            }) {
                                Text("Nutrients")
                                        .foregroundColor(linkColor)
                            }
                                    .sheet(isPresented: $showLanguageSheet) {
                                        MultipleSelectionList(nutrients: self.$nutrients, selectedNutrients: self.$selectedNutrients)
                                    }

                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            Picker(selection: $categoryCurrent, label: Text("Categories").foregroundColor(linkColor)) {
                                ForEach(categories, id: \.self) {
                                    Text(Locale.current.languageCode != "ru" ? $0.title_en : $0.title)
                                }
                            }
                                    .onChange(of: categoryCurrent, perform: { filterFood($0); sortChange(sortType, sortDirection) })
                                    .pickerStyle(MenuPickerStyle())

                        })
                    })
                    .navigationTitle(Locale.current.languageCode != "ru" ? categoryCurrent.title_en : categoryCurrent.title)

        }.navigationViewStyle(StackNavigationViewStyle())


    }


    func filterFoodByTitle(_ text: String) {
        self.searchText = text
        loadData()
    }

    func filterFood(_ category: Category = Category(id: "", title: "All food", title_en: "All food")) {
        self.categoryCurrent = category
        loadData()
    }

    func sortChange(_ sortType: String = "id", _ sortDirection: String = "desc") {

        self.sortType = sortType
        self.sortDirection = sortDirection

    }

    func loadData() {
        jsonLocalLoad()
        self.showProgress = true

        let cache = URLCache.shared
        var request = URLRequest(url: URL(string: "https://api.knyazev.site/food/")!/*,     cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10.0*/)
        if let data = cache.cachedResponse(for: request)?.data {
            print("Загрузили из кэша")
            processData(data)
        } else {

            let session = URLSession.shared

            let parameterDictionary = [
                "page": 1,
                "sort": sortType,
                "sortOrder": sortDirection,
                "types": [categoryCurrent.id],
                "search": searchText,
                "nutrients": selectedNutrients.map({ $0.id })
            ] as [String: Any]

            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
                return
            }

            request.httpBody = httpBody

            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    print(String(describing: error))
                    return
                }
                if let data = data, let response = response {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            let cachedData = CachedURLResponse(response: response, data: data)
                            cache.storeCachedResponse(cachedData, for: request)
                        }
                    }

                    print("\(request.curlString)")
                    processData(data)
                    return
                }
            })
            task.resume()
        }
    }

    func jsonLocalLoad() {
        let url = Bundle.main.url(forResource: "nutrients", withExtension: "json")!
        let data = try! Data(contentsOf: url)

        do {
            nutrients = try JSONDecoder().decode([Nutrient].self, from: data)

        } catch {
            print(String(describing: error))
        }
    }

    func processData(_ data: Data) {
        do {
            let decodedResponse = try JSONDecoder().decode(Answer.self, from: data)
            DispatchQueue.main.async {
                self.foods = decodedResponse.food
                showProgress = false
            }
        } catch {
            print(String(describing: error))
        }
    }
}

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
