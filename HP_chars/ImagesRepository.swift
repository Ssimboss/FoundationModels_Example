//
//  ImagesRepository.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 10/05/2026.
//

import Combine
import UIKit

protocol ImagesRepositoryProtocol {
    var images: CurrentValueSubject<[String : UIImage], Never> { get }
    func loadImageIfNeeded(id: String, url: URL?)
}

final class ImagesRepository: ImagesRepositoryProtocol {
    enum Error: Swift.Error {
        case invalidData
    }

    private(set) var images = CurrentValueSubject<[String : UIImage], Never>([:])

    func loadImageIfNeeded(id: String, url: URL?) {
        guard images.value[id] == nil, let url else { return }
        Task {
            do {
                let image = try await loadImage(id: id, url: url)
                addImage(image, for: id)
            } catch {
                
            }
        }
    }

    @concurrent
    private func loadImage(id: String, url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw Error.invalidData
        }
        return image
    }

    @MainActor
    private func addImage(_ image: UIImage, for id: String) {
        images.value[id] = image
    }
}
