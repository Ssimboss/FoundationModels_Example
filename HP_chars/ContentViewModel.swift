//
//  ContentViewModel.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Combine
import SwiftUI
import UIKit

protocol ContentRouterProtocol {
    func showFilters()
    func showInput()
}

final class ContentViewModel: ContentViewModelProtocol {
    let title = "Characters"
    private let charactersRepository: CharactersRepositoryProtocol
    private let filterRepository: FilterRepositoryProtocol
    private let imagesRepository: ImagesRepositoryProtocol
    private let router: ContentRouterProtocol
    @Published
    private(set) var elements: [ContentElement] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        charactersRepository: CharactersRepositoryProtocol,
        filterRepository: FilterRepositoryProtocol,
        imagesRepository: ImagesRepositoryProtocol,
        router: ContentRouterProtocol
    ) {
        self.charactersRepository = charactersRepository
        self.filterRepository = filterRepository
        self.imagesRepository = imagesRepository
        self.router = router
        charactersRepository.characters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                guard let self else { return }
                self.setElements(
                    characters: characters,
                    filter: self.filterRepository.filter.value,
                    images: self.imagesRepository.images.value
                )
        }.store(in: &cancellables)
        filterRepository.filter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                guard let self else { return }
                self.setElements(
                    characters: self.charactersRepository.characters.value,
                    filter: filter,
                    images: self.imagesRepository.images.value
                )
            }.store(in: &cancellables)
        imagesRepository.images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                guard let self else { return }
                self.setElements(
                    characters: self.charactersRepository.characters.value,
                    filter: self.filterRepository.filter.value,
                    images: images
                )
        }.store(in: &cancellables)
    }
    
    func elementDidAppear(id: String) {
        guard let character = charactersRepository
            .characters
            .value
            .first(where: { $0.id == id }) else { return }
        imagesRepository.loadImageIfNeeded(
            id: character.id,
            url: character.imageURL
        )
    }
    
    func filterButtonDidTap() {
        router.showFilters()
    }

    func inputButtonDidTap() {
        router.showInput()
    }

    private func setElements(
        characters: [Character],
        filter: Filter,
        images: [String: UIImage]
    ) {
        elements = characters.compactMap { character in
            guard filter.pass(character: character) else {
                return nil
            }
            return ContentElement(
                id: character.id,
                image: images[character.id].map { Image(uiImage: $0) },
                title: character.name,
                subtitle: character.generalInfo
            )
        }
    }
}

private extension Character {
    var generalInfo: String {
        let infoParts: [String?] = [
            species.rawValue,
            gender?.rawValue,
            house?.rawValue,
            { return isWizard ? "Wizard" : nil }(),
            ancestry?.rawValue,
            { return isHogwartsStudent ? "Hogwarts Student" : nil }(),
            { return isHogwartsStaff ? "Hogwarts Staff" : nil }(),
            isAlive ? "alive" : "dead",
        ]
        return infoParts
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
