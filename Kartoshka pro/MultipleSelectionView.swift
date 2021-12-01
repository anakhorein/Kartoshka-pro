//
// Created by Alexander Knyazev on 27.11.2021.
//

import Foundation

import SwiftUI

struct MultipleSelectionList: View {
    @Binding var nutrients:[Nutrient]?
    @Binding var selectedNutrients: [Nutrient]

    var body: some View {
        List {
            ForEach(self.nutrients!, id: \.self) { item in
                MultipleSelectionRow(title: item.name, isSelected: self.selectedNutrients.contains(item)) {
                    if self.selectedNutrients.contains(item) {
                        self.selectedNutrients.removeAll(where: { $0 == item })
                    } else {
                        self.selectedNutrients.append(item)
                    }
                }
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}