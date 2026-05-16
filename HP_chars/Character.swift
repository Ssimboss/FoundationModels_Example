//
//  Character.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Foundation
import FoundationModels

@Generable
enum Species: String, Decodable, CaseIterable {
    case human
    case halfGiant = "half-giant"
    case werewolf
    case cat
    case snake
    case phoenix
    case dog
    case goblin
    case owl
    case toad
    case ghost
    case poltergeist
    case threeHeadedDog = "three-headed dog"
    case dragon
    case centaur
    case cephalopod
    case selkie
    case houseElf = "house-elf"
    case serpent
    case acromantula
    case hippogriff
    case hat
    case giant
    case pygmyPuff = "pygmy puff"
    case vampire = "vampire"
    case halfHuman = "half-human"
}

@Generable
enum Ancestry: String, Decodable, CaseIterable {
    case halfBlood = "half-blood"
    case muggle = "muggleborn"
    case pureBlood = "pure-blood"
}

@Generable
enum Gender: String, Decodable, CaseIterable {
    case male
    case female
}

@Generable
enum House: String, Decodable, CaseIterable {
    case gryffindor = "Gryffindor"
    case slytherin = "Slytherin"
    case hufflepuff = "Hufflepuff"
    case ravenclaw = "Ravenclaw"
}

struct Character: Decodable {
    let id: String
    let name: String
    let species: Species
    let gender: Gender?
    let house: House?
    let isWizard: Bool
    let ancestry: Ancestry?
    let isHogwartsStudent: Bool
    let isHogwartsStaff: Bool
    let isAlive: Bool
    let imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case species
        case gender
        case house
        case wizard
        case ancestry
        case hogwartsStudent
        case hogwartsStaff
        case alive
        case image
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.species = try container.decode(Species.self, forKey: .species)
        self.gender = try? container.decode(Gender.self, forKey: .gender)
        self.house = try? container.decode(House.self, forKey: .house)
        self.isWizard = try container.decode(Bool.self, forKey: .wizard)
        self.ancestry = try? container.decode(Ancestry.self, forKey: .ancestry)
        self.isHogwartsStudent = try container.decode(Bool.self, forKey: .hogwartsStudent)
        self.isHogwartsStaff = try container.decode(Bool.self, forKey: .hogwartsStaff)
        self.isAlive = try container.decode(Bool.self, forKey: .alive)
        self.imageURL = {
            guard let urlString = try? container.decode(String.self, forKey: .image) else {
                return nil
            }
            return URL(string: urlString)
        }()
    }
}
