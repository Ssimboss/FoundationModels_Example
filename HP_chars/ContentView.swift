//
//  ContentView.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import SwiftUI

struct ContentElement: Identifiable {
    let id: String
    let image: Image?
    let title: String
    let subtitle: String
}

protocol ContentViewModelProtocol: ObservableObject {
    var title: String { get }
    var elements: [ContentElement] { get }

    func filterButtonDidTap()
    func inputButtonDidTap()
    func elementDidAppear(id: String)
}

struct ContentView<
    ViewModel: ContentViewModelProtocol
>: View {
    @ObservedObject
    private var viewModel: ViewModel
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List(viewModel.elements) { element in
                HStack {
                    image(for: element)
                    VStack(alignment: .leading) {
                        title(for: element)
                        subtitle(for: element)
                    }
                }
                .onAppear {
                    viewModel.elementDidAppear(id: element.id)
                }
            }
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    inputButton
                }
            }
        }
    }

    @ViewBuilder
    private func image(for element: ContentElement) -> some View {
        ZStack {
            if let image = element.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray
            }
        }
        .frame(
            width: 100,
            height: 100
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func title(for element: ContentElement) -> some View {
        Text(element.title)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color.black)
    }

    @ViewBuilder
    private func subtitle(for element: ContentElement) -> some View {
        Text(element.subtitle)
            .font(.system(size: 14))
            .foregroundStyle(Color.gray)
    }
    
    @ViewBuilder
    private var filterButton: some View {
        Button {
            viewModel.filterButtonDidTap()
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }

    @ViewBuilder
    private var inputButton: some View {
        Button {
            viewModel.inputButtonDidTap()
        } label: {
            Image(systemName: "text.bubble")
        }
    }
}
