//
//  CharactersRepository.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Foundation
import Combine

protocol CharactersRepositoryProtocol {
    var characters: CurrentValueSubject<[Character], Never> { get }
}

final class CharactersRepository: CharactersRepositoryProtocol {
    private(set) var characters = CurrentValueSubject<[Character], Never>([])
    
    init() {
        Task {
            await loadCharacters()
        }
    }
    
    @concurrent
    private func loadCharacters() async {
        let bundle = Bundle.main
        guard let fileURL = bundle.url(forResource: "hp_characters", withExtension: "json"),
              let data = try? Data.init(contentsOf: fileURL),
              let characters = try? JSONDecoder().decode([Character].self, from: data) else {
            return
        }
        await self.characters.send(characters)
    }
}
