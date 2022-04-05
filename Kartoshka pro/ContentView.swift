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
    @State private var selectedNutrients = [Nutrient(id: "1008", name: "Energy", nutrient_nbr: "208", rank: "300", unit_name: "KCAL"),
                                            Nutrient(id: "1003", name: "Protein", nutrient_nbr: "203", rank: "600", unit_name: "G"),
                                            Nutrient(id: "1004", name: "Total lipid (fat)", nutrient_nbr: "204", rank: "800", unit_name: "G"),
                                            Nutrient(id: "1005", name: "Carbohydrate, by difference", nutrient_nbr: "205", rank: "1110", unit_name: "G")
    ]

    @State private var page = 1
    @State private var count = 0


    init() {
        rowForegroundColor = colorScheme == .dark ? Color.white : Color.black
        colDefaultColor = colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 5) {
                    TextField(Locale.current.languageCode != "ru" ? "Search (min 3 symbols)" : "Поиск (минимум 3 буквы)", text: $textSearch)
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: textSearch) { newValue in
                                if (newValue == "") {
                                    filterFoodByTitle("")
                                } else {
                                    if(newValue.count>2){
                                        filterFoodByTitle(newValue)
                                    }
                                }
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


                }
                        .padding(.horizontal, 15)


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

                                VStack(alignment: .leading, spacing: 3) {

                                    HStack(spacing: 1) {
                                        ForEach(selectedNutrients, id: \.id) { nutrient in
                                            ColumnHeader(title: nutrient.name, literal: nutrient.id)
                                                    .foregroundColor(sortType == "n\(nutrient.id)" ? colHighlightColor : linkColor)
                                                    .onTapGesture {
                                                        sortChange("n\(nutrient.id)")
                                                    }
                                                    .frame(
                                                            minWidth: 0,
                                                            maxWidth: 49,
                                                            minHeight: 0,
                                                            maxHeight: .infinity,
                                                            alignment: .topLeading
                                                    )
                                                    //.border(.red)
                                        }
                                    }


                                    ForEach(foods, id: \.id) { item in
                                        HStack(spacing: 1) {
                                            ForEach(selectedNutrients, id: \.id) { nutrient in
                                                let val = item["n\(nutrient.id)"]
                                                if let temp = val as? Float {
                                                    Text(String(format: temp>100 ? "%.0f" : "%.1f", locale: Locale.current, temp))
                                                            //.frame(width: 49, alignment: .trailing)
                                                            .foregroundColor(selectedFoodId == item.id ? rowForegroundColorHighlight : sortType == "n\(nutrient.id)" ? colHighlightColor : colDefaultColor).frame(
                                                                minWidth: 0,
                                                                maxWidth: 49,
                                                                minHeight: 0,
                                                                // maxHeight: .infinity,
                                                                alignment: .trailing
                                                        )
                                                        //.border(.green)
                                                } else {
                                                    Text(String(format: "%.1f", locale: Locale.current, ""))
                                                            //.frame(width: 49, alignment: .trailing)
                                                            .foregroundColor(selectedFoodId == item.id ? rowForegroundColorHighlight : sortType == "n\(nutrient.id)" ? colHighlightColor : colDefaultColor).frame(
                                                                minWidth: 0,
                                                                maxWidth: 49,
                                                                minHeight: 0,
                                                               // maxHeight: .infinity,
                                                                alignment: .trailing
                                                        )
                                                        //.border(.green)
                                                }
                                            }
                                        }
                                                .background(selectedFoodId == item.id ? rowBackgroundColorHighlight : rowBackgroundColor)
                                                .font(Font.headline.weight(.light).monospacedDigit())
                                                .onTapGesture {
                                                    self.selectedFoodId = item.id
                                                }
                                        
                                    }
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    VStack {
                                        Text("in 100 grams")
                                                .frame(height: 100, alignment: .bottomLeading)
                                                .font(Font.headline.weight(.light))
                                                .foregroundColor(Color(UIColor.systemGray2))
                                                .offset(x: 10, y: -3)
                                    }
                                            .frame(height: 100)

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
                                        }
                                                .padding(.leading, 10.0)
                                                .background(selectedFoodId == item.id ? rowBackgroundColorHighlight : rowBackgroundColor)

                                    }

                                }
                                        .frame(
                                                minWidth: 0,
                                                maxWidth: .infinity,
                                                minHeight: 0,
                                                maxHeight: .infinity,
                                                alignment: .topLeading
                                        )

                            }
                            VStack() {
                                let pages: Int = Int(ceil(Double(count) / Double(100)))
                                Text("Results: \(count), page \(page) of \(pages)").padding(.top,15).foregroundColor(.gray).font(Font.headline.weight(.light))
                                HStack() {
                                    if (page > 1) {
                                        Button(String("Previous page")) {
                                            page = page - 1
                                            loadData()
                                        }
                                    }
                                    if (Double(count) / Double(100) > Double(page)) {
                                        Button(String("Next page")) {
                                            page = page + 1
                                            loadData()
                                        }
                                    }
                                }
                                        .padding(.bottom, 20)
                            }
                        }
                    }
                            .onAppear(perform: loadData).padding(10).edgesIgnoringSafeArea(.all)

                }
            }
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            Button(action: {
                                self.showLanguageSheet.toggle()
                            }) {
                                Text("Nutrients").foregroundColor(linkColor)
                            }
                                    .sheet(isPresented: $showLanguageSheet) {
                                        MultipleSelectionList(nutrients: self.$nutrients, selectedNutrients: self.$selectedNutrients).onDisappear(perform: loadData)
                                    }

                        })
                       
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            Menu{
                                ForEach(categories, id: \.self){ index in
                                    Button(action : {
                                        filterFood(index)
                                    }) {
                                        if categoryCurrent == index{
                                            if(index.id == "branded_food"){
                                                Label("\(index.title) \n(may contain wrong data)", systemImage: "checkmark")
                                                         .lineLimit(2)
                                            }else{
                                                Label("\(index.title)", systemImage: "checkmark")
                                            }
                                           
                                        }else {
                                            if(index.id == "branded_food"){
                                                Text("\(index.title) \n(may contain wrong data)")
                                                         .lineLimit(2)
                                            }else{
                                                Text("\(index.title)")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("Categories").foregroundColor(linkColor)
                            }
                        })
                    })
                    .navigationTitle(Locale.current.languageCode != "ru" ? categoryCurrent.title_en : categoryCurrent.title)

        }
                .navigationViewStyle(StackNavigationViewStyle())


    }


    func filterFoodByTitle(_ text: String) {
        self.searchText = text
        page = 1
        loadData()
    }

    func filterFood(_ category: Category = Category(id: "", title: "All food", title_en: "All food")) {
        self.categoryCurrent = category
        loadData()
    }

    func sortChange(_ sortType: String = "id") {
        if (self.sortType == sortType) {
            if (sortDirection == "desc") {
                sortDirection = "asc"
            } else {
                sortDirection = "desc"
            }
        }
        self.sortType = sortType

        loadData()
    }

    func loadData() {
        jsonLocalLoad()
        self.showProgress = true

        let cache = URLCache.shared
        var request = URLRequest(url: URL(string: "https://api.knyazev.site/food/")!/*,     cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10.0*/)
        //if let data = cache.cachedResponse(for: request)?.data {
        //    print("Загрузили из кэша")
        //     processData(data)
        //} else {

        let session = URLSession.shared
        
        var types = [categoryCurrent.id]
        if(categoryCurrent.id==""){
            types = ["branded_food", "experimental_food", "foundation_food", "sr_legacy_food", "survey_fndds_food"]
        }

        let parameterDictionary = [
            "page": page,
            "sort": sortType,
            "sortOrder": sortDirection,
            "types": types,
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
        //}
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
            //print("\(decodedResponse)")
            DispatchQueue.main.async {
                self.foods = decodedResponse.food
                self.count = decodedResponse.count
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

protocol PropertyReflectable {
}

extension PropertyReflectable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        return m.children.first {
                    $0.label == key
                }?
                .value
    }
}

extension Food: PropertyReflectable {
}
