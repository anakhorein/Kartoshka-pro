//
// Created by Alexander Knyazev on 27.11.2021.
//

import Foundation

import SwiftUI

struct MultipleSelectionList: View {
    @Binding var nutrients:[Nutrient]?
    @Binding var selectedNutrients: [Nutrient]

    var body: some View {
        Text("Nutrients")
            .padding(.top, 10.0).font(Font.title)
        Text("choose maximum four").font(Font.headline.weight(.light))
        List {
            ForEach(self.nutrients!, id: \.self) { item in
                MultipleSelectionRow(title: "\(item.name), \(item.unit_name)", isSelected: self.selectedNutrients.contains(item)) {
                    if self.selectedNutrients.contains(item) {
                        self.selectedNutrients.removeAll(where: { $0 == item })
                    } else {
                        if(self.selectedNutrients.count<4){
                            self.selectedNutrients.append(item)}
                    }
                }
            }
        }.listStyle(PlainListStyle())
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    var rowForegroundColor : Color?
    var colHighlightColor: Color = Color(UIColor(red: 246 / 255, green: 103 / 255, blue: 111 / 255, alpha: 1))

    var body: some View {
        Button(action: self.action) {
            HStack {
                if self.isSelected {
                    Text(self.title).foregroundColor(colHighlightColor)
                    Spacer()
                    Image(systemName: "checkmark").foregroundColor(colHighlightColor)
                }else{
                    Text(self.title).foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
            }
        }
    }
}
