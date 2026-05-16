//
//  FilterView.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import SwiftUI

struct FilterRowData {
    let id: Int
    let title: String
    let isSelected: Bool
}

struct FilterSectionData {
    let id: Int
    let title: String
    let rows: [FilterRowData]
}

protocol FilterViewModelProtocol: ObservableObject {
    var title: String { get }
    var sections: [FilterSectionData] { get }
    var applyButtonTitle: String { get }

    func filterDidTap(section: Int, row: Int)
    func applyButtonDidTap()
}

private enum FilterListElement: Identifiable {
    case sectionHeader(id: Int, title: String)
    case row(sectionId: Int, data: FilterRowData)
    
    var id: String {
        switch self {
        case .sectionHeader(let id,_):
            return "section_\(id)"
        case .row(let sectionId, let data):
            return "row_\(sectionId)_\(data.id)"
        }
    }
}

struct FilterView<
    ViewModel: FilterViewModelProtocol
>: View {
    @ObservedObject
    private var viewModel: ViewModel
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List(viewModel.sections.listElements) { element in
                switch element {
                case .sectionHeader(_, let title):
                    sectionHeader(title: title)
                case .row(let sectionId, let data):
                    row(sectionId: sectionId, data: data)
                }
            }
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    applyButton
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .bold()
    }
    
    @ViewBuilder
    private func row(
        sectionId: Int,
        data: FilterRowData
    ) -> some View {
        Button {
            viewModel.filterDidTap(
                section: sectionId,
                row: data.id
            )
        } label: {
            HStack {
                Text(data.title)
                    .foregroundStyle(.gray)
                if data.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    @ViewBuilder
    private var applyButton: some View {
        Button {
            viewModel.applyButtonDidTap()
        } label: {
            Text(viewModel.applyButtonTitle)
        }
        .tint(Color.blue)
    }
}

private extension Array where Element == FilterSectionData {
    var listElements: [FilterListElement] {
        return flatMap { section in
            return [.sectionHeader(id: section.id, title: section.title)] + section.rows.map { row in
                    .row(sectionId: section.id, data: row)
            }
        }
    }
}
