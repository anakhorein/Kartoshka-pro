//
// Created by Alexander Knyazev on 27.11.2021.
//

import Foundation

import SwiftUI

struct DetailView: View {
    var food: Food!
    var body: some View {

        VStack() {

            Text(Locale.current.languageCode != "ru" ? food.description : food.description)
                    .font(.title)
                    .padding(50)

            HStack {
                Text("in 100 grams")
                        .font(Font.headline.weight(.light))
                        .foregroundColor(Color(UIColor.systemGray2))
                        .frame(width: 240, alignment: .leading)
                //.padding(5)
            }
            HStack {
                Text("Proteins:")
                        .frame(width: 120, alignment: .leading)
                        .padding(5)
                /*Text(String(format: "%.1f", locale: Locale.current, (food.proteins as NSString).floatValue) + NSLocalizedString(" g", comment: ""))
                 .frame(width: 120, alignment: .leading)
                 .padding(5)*/
            }
            HStack {
                Text("Fats:")
                        .frame(width: 120, alignment: .leading)
                        .padding(5)
                /*Text(String(format: "%.1f", locale: Locale.current, (food.fats as NSString).floatValue) + NSLocalizedString(" g", comment: ""))
                 .frame(width: 120, alignment: .leading)
                 .padding(5)*/
            }
            HStack {
                Text("Carbohydrates:")
                        .frame(width: 120, alignment: .leading)
                        .padding(5)
                /*Text(String(format: "%.1f", locale: Locale.current, (food.carbohydrates as NSString).floatValue) + NSLocalizedString(" g", comment: ""))
                 .frame(width: 120, alignment: .leading)
                 .padding(5)*/
            }
            HStack {
                Text("Kcal:")
                        .frame(width: 120, alignment: .leading)
                        .padding(5)
                /*Text(String(format: "%.2f", locale: Locale.current, (food.kcal as NSString).floatValue) + " " + NSLocalizedString("kcal",comment:"kilocallories"))
                 .frame(width: 120, alignment: .leading)
                 .padding(5)*/
            }
            Link(NSLocalizedString("Search\n", comment: "search with linebreak") + " «\(Locale.current.languageCode != "ru" ? food.description : food.description)»\n " + NSLocalizedString("in Google", comment: ""),
                    destination: URL(string: "https://www.google.com/search?q=\(food.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
                    .foregroundColor(.blue).padding(50)

        }

    }
}