//
// Created by Alexander Knyazev on 27.11.2021.
//

import Foundation

import SwiftUI

struct DetailView: View {
    var food: Food!
    @State var foodItem: FoodItemAnswer?
    @State var showProgress = false
    @State private var progressValue = 0.0
    var body: some View {
        
        GeometryReader { geometry in
            ScrollView {
                if (showProgress) {
                    VStack {
                        ProgressView("Loading info", value: progressValue, total: 100).progressViewStyle(CircularProgressViewStyle())
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                    
                } else {
                    VStack(alignment: .leading){
                        Text((foodItem?.common.description ?? ""))
                            .font(.title)
                        
                        HStack {
                            Text("FDC ID: ")
                            Text(String((foodItem?.common.fdc_id ?? 0)))
                        }.padding(.top,5)
                        
                        HStack {
                            Text("Publication date: ")
                            Text((foodItem?.common.publication_date ?? ""))
                        }
                        
                        VStack(alignment: .leading){
                            HStack {
                                Text( "contained in 100 grams")
                                    .frame(width: 270, alignment: .leading).font(Font.headline.weight(.light))
                                    .foregroundColor(Color(UIColor.systemGray2))
                            }
                            
                            Text("Proximates").font(.headline)
                            ForEach(foodItem?.nutrients ?? [], id: \.id) { nutrient in
                                if (nutrient.rank ?? 10000 < 5200){
                                    HStack {
                                        Text("\(nutrient.name ?? "") (\(nutrient.unit_name ?? ""))")
                                            .frame(width: 270, alignment: .leading)
                                        Text(String(format: "%.1f", locale: Locale.current, nutrient.amount ?? 0))
                                        //.frame(width: 120, alignment: .leading)
                                        //.padding(5)
                                    }
                                    
                                }
                            }
                            Text("Minerals").font(.headline)
                            ForEach(foodItem?.nutrients ?? [], id: \.id) { nutrient in
                                let rank = nutrient.rank ?? 10000
                                if (rank > 5199 && rank < 6250){
                                    HStack {
                                        Text("\(nutrient.name ?? "") (\(nutrient.unit_name ?? ""))")
                                            .frame(width: 270, alignment: .leading)
                                        Text(String(format: "%.1f", locale: Locale.current, nutrient.amount ?? 0))
                                        //.frame(width: 120, alignment: .leading)
                                        //.padding(5)
                                    }}
                            }
                            Text("Vitamins and Other Components").font(.headline)
                            ForEach(foodItem?.nutrients ?? [], id: \.id) { nutrient in
                                let rank = nutrient.rank ?? 10000
                                if (rank  > 6249 && rank < 9600){
                                    HStack {
                                        Text("\(nutrient.name ?? "") (\(nutrient.unit_name ?? ""))")
                                            .frame(width: 270, alignment: .leading)
                                        Text(String(format: "%.1f", locale: Locale.current, nutrient.amount ?? 0))
                                        //.frame(width: 120, alignment: .leading)
                                        //.padding(5)
                                    }
                                }
                            }
                            
                        }.padding(.top,5)
                        
                        
                        
                        Link(NSLocalizedString("Search ", comment: "search with linebreak") + " «\(Locale.current.languageCode != "ru" ? food.description : food.description)» " + NSLocalizedString("in Google", comment: ""),
                             destination: URL(string: "https://www.google.com/search?q=\(food.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
                            .foregroundColor(.blue).padding(.vertical,20)
                    }.padding(20)
                    
                }
            }
        }.onAppear(perform: loadData)
    }
    
    func loadData() {
        //jsonLocalLoad()
        self.showProgress = true
        
        let cache = URLCache.shared
        var request = URLRequest(url: URL(string: "https://api.knyazev.site/food/item")!/*,     cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10.0*/)
        //if let data = cache.cachedResponse(for: request)?.data {
        //    print("Загрузили из кэша")
        //     processData(data)
        //} else {
        
        let session = URLSession.shared
        
        let parameterDictionary = [
            "id": String(food.fdc_id)
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
                print(data)
                print(response)
                print("\(request.curlString)")
                processData(data)
                return
            }
        })
        task.resume()
        //}
    }
    
    func processData(_ data: Data) {
        
        do {
            let decodedResponse = try JSONDecoder().decode(FoodItemAnswer.self, from: data)
            //print("\(decodedResponse)")
            DispatchQueue.main.async {
                foodItem = decodedResponse
                //self.count = decodedResponse.count
                showProgress = false
                print(foodItem)
            }
        } catch {
            print(String(describing: error))
        }
    }
}
