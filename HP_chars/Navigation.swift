//
//  Navigation.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Combine

final class Navigation: ContentRouterProtocol,
                        FilterRouterProtocol,
                        InputRouterProtocol,
                        ObservableObject {
    @Published
    var isPresentingFilter: Bool = false
    @Published
    var isInputPresented: Bool = false

    func showFilters() {
        isPresentingFilter = true
    }

    func dismissFilters() {
        isPresentingFilter = false
    }

    func showInput() {
        isInputPresented = true
    }

    func dismissInput() {
        isInputPresented = false
    }
}
