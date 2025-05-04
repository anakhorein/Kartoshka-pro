//
// Created by Alexander Knyazev on 27.11.2021.
// A SwiftUI view that displays a list of nutrients and allows multiple selection up to a defined limit.

import SwiftUI

struct MultipleSelectionList: View {
    /// Optional list of nutrients available for selection.
    @Binding var nutrients: [Nutrient]?
    /// Currently selected nutrients.
    @Binding var selectedNutrients: [Nutrient]
    /// Maximum number of items that can be selected.
    private let maxSelection = 4
    /// Color used to highlight selected items.
    private let highlightColor = Color(red: 246/255, green: 103/255, blue: 111/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: Header Section
            /// Title and subtitle showing the selection hint.
            VStack(alignment: .leading, spacing: 4) {
                Text("Nutrients")
                    .font(.largeTitle.bold())
                    .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                Text("Select up to \(maxSelection)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)

            Divider()

            // MARK: Nutrient List
            /// Displays nutrients in a scrollable list with selection support.
            List(nutrients ?? [], id: \.self) { item in
                HStack {
                    Text("\(item.name), \(item.unit_name)")
                        .foregroundColor(
                            selectedNutrients.contains(item)
                                ? highlightColor
                                : .primary
                        )
                        .font(.body)
                        .animation(.easeInOut(duration: 0.2), value: selectedNutrients.contains(item))
                    Spacer()
                    if selectedNutrients.contains(item) {
                        Image(systemName: "checkmark")
                            .foregroundColor(highlightColor)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .contentShape(Rectangle())   // Expand tap target to full row
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        toggle(item)
                    }
                }
            }
            .listStyle(.plain) // Apply modern plain list style
        }
    }

    // MARK: Selection Handling
    /// Toggles the selection state of the given nutrient.
    /// Ensures the number of selected items does not exceed the maximum.
    /// - Parameter item: The nutrient to be toggled in the selection list.
    private func toggle(_ item: Nutrient) {
        if let index = selectedNutrients.firstIndex(of: item) {
            selectedNutrients.remove(at: index)
        } else if selectedNutrients.count < maxSelection {
            selectedNutrients.append(item)
        }
    }
}
