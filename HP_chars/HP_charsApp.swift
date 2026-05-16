//
//  HP_charsApp.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import SwiftUI

@main
struct HP_charsApp: App {
    @ObservedObject
    private var navigation: Navigation
    private var filterRepository: FilterRepositoryProtocol
    private let contentViewModel: ContentViewModel
    private let inputViewModel: InputViewModel
    init() {
        let navigation = Navigation()
        let filterRepository = FilterRepository()
        self.navigation = navigation
        self.filterRepository = filterRepository
        self.contentViewModel = ContentViewModel(
            charactersRepository: CharactersRepository(),
            filterRepository: filterRepository,
            imagesRepository: ImagesRepository(),
            router: navigation
        )
        self.inputViewModel = InputViewModel(
            filterRepository: filterRepository,
            router: navigation
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: contentViewModel)
                .sheet(isPresented: $navigation.isPresentingFilter) {
                    FilterView(
                        viewModel: FilterViewModel(
                            filterRepository: filterRepository,
                            router: navigation
                        )
                    )
                    .interactiveDismissDisabled()
                }
                .sheet(isPresented: $navigation.isInputPresented) {
                    InputView(
                        viewModel: inputViewModel
                    ).presentationDetents([.medium])
                }
        }
    }
}
