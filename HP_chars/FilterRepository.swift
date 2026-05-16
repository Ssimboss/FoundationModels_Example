//
//  FilterRepository.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Combine

protocol FilterRepositoryProtocol {
    var filter: CurrentValueSubject<Filter, Never> { get }
}

final class FilterRepository: FilterRepositoryProtocol {
    private(set) var filter = CurrentValueSubject<Filter, Never>(.noFilter)
}
