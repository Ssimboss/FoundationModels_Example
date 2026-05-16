//
//  FilterViewModel.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Combine
import Foundation

protocol FilterRouterProtocol {
    func dismissFilters()
}

final class FilterViewModel: FilterViewModelProtocol {
    private enum Section: Int {
        case species
        case gender
        case house
        case isWizard
        case ancestry
        case isHogwartsStudent
        case isHogwartsStaff
        case isAlive
    }
    
    let title: String = "Filters"

    private var filter: Filter
    private let filterRepository: FilterRepositoryProtocol
    private let router: FilterRouterProtocol

    @Published
    private(set) var sections: [FilterSectionData] = []
    private var cancellables: Set<AnyCancellable> = []

    init(
        filterRepository: FilterRepositoryProtocol,
        router: FilterRouterProtocol
    ) {
        self.filter = filterRepository.filter.value
        self.filterRepository = filterRepository
        self.router = router
        updateState()
    }

    let applyButtonTitle: String = "Apply"

    func filterDidTap(section: Int, row: Int) {
        guard let section = Section(rawValue: section) else {
            assertionFailure("Unknown section")
            return
        }
        switch section {
        case .species:
            let allSpecies = Species.allCases
            guard allSpecies.indices.contains(row) else {
                assertionFailure("Unknown species")
                return
            }
            let species = allSpecies[row]
            if filter.species.contains(species) {
                filter.species.removeAll { $0 == species }
            } else {
                filter.species.append(species)
            }
        case .gender:
            let allGenders = Gender.allCases
            guard allGenders.indices.contains(row) else {
                assertionFailure("Unknown gender")
                return
            }
            let gender = allGenders[row]
            if filter.genders.contains(gender) {
                filter.genders.removeAll { $0 == gender }
            } else {
                filter.genders.append(gender)
            }
        case .house:
            let allHouses = House.allCases
            guard allHouses.indices.contains(row) else {
                assertionFailure("Unknown house")
                return
            }
            let house = allHouses[row]
            if filter.houses.contains(house) {
                filter.houses.removeAll { $0 == house }
            } else {
                filter.houses.append(house)
            }
        case .isWizard:
            switch row {
            case 0:
                switch filter.isWizard {
                case true: filter.isWizard = nil
                case false, .none: filter.isWizard = true
                }
            case 1:
                switch filter.isWizard {
                case true, .none: filter.isWizard = false
                case false: filter.isWizard = nil
                }
            default:
                assertionFailure("unknown state")
                return
            }
        case .ancestry:
            let allAncestries = Ancestry.allCases
            guard allAncestries.indices.contains(row) else {
                assertionFailure("Unknown house")
                return
            }
            let ancestry = allAncestries[row]
            if filter.ancestries.contains(ancestry) {
                filter.ancestries.removeAll { $0 == ancestry }
            } else {
                filter.ancestries.append(ancestry)
            }
        case .isHogwartsStudent:
            switch row {
            case 0:
                switch filter.isHogwartsStudent {
                case true: filter.isHogwartsStudent = nil
                case false, .none: filter.isHogwartsStudent = true
                }
            case 1:
                switch filter.isHogwartsStudent {
                case true, .none: filter.isHogwartsStudent = false
                case false: filter.isHogwartsStudent = nil
                }
            default:
                assertionFailure("unknown state")
                return
            }
        case .isHogwartsStaff:
            switch row {
            case 0:
                switch filter.isHogwartsStaff {
                case true: filter.isHogwartsStaff = nil
                case false, .none: filter.isHogwartsStaff = true
                }
            case 1:
                switch filter.isHogwartsStaff {
                case true, .none: filter.isHogwartsStaff = false
                case false: filter.isHogwartsStaff = nil
                }
            default:
                assertionFailure("unknown state")
                return
            }
        case .isAlive:
            switch row {
            case 0:
                switch filter.isAlive {
                case true: filter.isAlive = nil
                case false, .none: filter.isAlive = true
                }
            case 1:
                switch filter.isAlive {
                case true, .none: filter.isAlive = false
                case false: filter.isAlive = nil
                }
            default:
                assertionFailure("unknown state")
                return
            }
        }
        updateState()
    }

    func applyButtonDidTap() {
        filterRepository.filter.send(filter)
        router.dismissFilters()
    }

    private func updateState() {
        self.sections = [
            FilterSectionData(
                id: Section.species.rawValue, title: "Species", rows: Species.allCases.enumerated().map { index, species in
                    FilterRowData(id: index, title: species.rawValue, isSelected: filter.species.contains(species))
                }),
            FilterSectionData(
                id: Section.gender.rawValue, title: "Gender", rows: Gender.allCases.enumerated().map { index, gender in
                    FilterRowData(id: index, title: gender.rawValue, isSelected: filter.genders.contains(gender))
                }),
            FilterSectionData(
                id: Section.house.rawValue, title: "House", rows: House.allCases.enumerated().map { index, house in
                    FilterRowData(id: index, title: house.rawValue, isSelected: filter.houses.contains(house))
                }),
            FilterSectionData(
                id: Section.isWizard.rawValue, title: "Wizard?", rows: [
                    FilterRowData(id: 0, title: "Character is a wizard", isSelected: filter.isWizard == true),
                    FilterRowData(id: 1, title: "Character is NOT a wizard", isSelected: filter.isWizard == false),
                ]),
            FilterSectionData(
                id: Section.ancestry.rawValue, title: "Ancestry", rows: Ancestry.allCases.enumerated().map { index, ancestry in
                    FilterRowData(id: index, title: ancestry.rawValue, isSelected: filter.ancestries.contains(ancestry))
                }),
            FilterSectionData(
                id: Section.isHogwartsStudent.rawValue, title: "Hogwarts Student?", rows: [
                    FilterRowData(id: 0, title: "Character is a Hogwarts student", isSelected: filter.isHogwartsStudent == true),
                    FilterRowData(id: 1, title: "Character is NOT a Hogwarts student", isSelected: filter.isHogwartsStudent == false)
                ]),
            FilterSectionData(
                id: Section.isHogwartsStaff.rawValue, title: "Hogwarts Staff?", rows: [
                    FilterRowData(id: 0, title: "Character is a Hogwarts staff", isSelected: filter.isHogwartsStaff == true),
                    FilterRowData(id: 1, title: "Character is NOT a Hogwarts staff", isSelected: filter.isHogwartsStaff == false)
                ]),
            FilterSectionData(
                id: Section.isAlive.rawValue, title: "Alive?", rows: [
                    FilterRowData(id: 0, title: "Character is alive", isSelected: filter.isAlive == true),
                    FilterRowData(id: 1, title: "Character is dead", isSelected: filter.isAlive == false),
                ]),
        ]
    }
}
