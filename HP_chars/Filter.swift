//
//  Filter.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import FoundationModels

@Generable
enum FilterConstraint {
    case species(Species)
    case gender(Gender)
    case house(House)
    case ancestry(Ancestry)
    case isWizard(Bool)
    case isHogwartsStudent(Bool)
    case isHogwartsStaff(Bool)
    case isAlive(Bool)
}

@Generable
struct FilterRequest {
    @Guide(description: "One entry per dimension the user explicitly named in their request. Emit zero entries when the user named no constraints (e.g. 'show everyone'). Do NOT add a constraint for any dimension the user did not mention.")
    let constraints: [FilterConstraint]

    var filter: Filter {
        var result = Filter.noFilter
        for constraint in constraints {
            switch constraint {
            case .species(let value): result.species.append(value)
            case .gender(let value): result.genders.append(value)
            case .house(let value): result.houses.append(value)
            case .ancestry(let value): result.ancestries.append(value)
            case .isWizard(let value): result.isWizard = value
            case .isHogwartsStudent(let value): result.isHogwartsStudent = value
            case .isHogwartsStaff(let value): result.isHogwartsStaff = value
            case .isAlive(let value): result.isAlive = value
            }
        }
        return result
    }
}

struct Filter {
    var species: [Species]
    var genders: [Gender]
    var houses: [House]
    var isWizard: Bool?
    var ancestries: [Ancestry]
    var isHogwartsStudent: Bool?
    var isHogwartsStaff: Bool?
    var isAlive: Bool?
    
    static let noFilter = Filter(
        species: [],
        genders: [],
        houses: [],
        ancestries: []
    )

    func pass(character: Character) -> Bool {
        if !species.isEmpty, !species.contains(character.species) {
            return false
        }
        if !genders.isEmpty {
            if let gender = character.gender {
                if !genders.contains(gender) {
                    return false
                }
            } else {
                return false
            }
        }
        if !houses.isEmpty {
            if let house = character.house {
                if !houses.contains(house) {
                    return false
                }
            } else {
                return false
            }
        }
        if let isWizard {
            if character.isWizard != isWizard {
                return false
            }
        }
        if !ancestries.isEmpty {
            if let ancestry = character.ancestry {
                if !ancestries.contains(ancestry) {
                    return false
                }
            } else {
                return false
            }
        }
        if let isHogwartsStudent {
            if character.isHogwartsStudent != isHogwartsStudent {
                return false
            }
        }
        if let isHogwartsStaff {
            if character.isHogwartsStaff != isHogwartsStaff {
                return false
            }
        }
        if let isAlive {
            if character.isAlive != isAlive {
                return false
            }
        }        
        return true
    }
}
