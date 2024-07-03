//
//  ImageCacheManager.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import Foundation
import UIKit

@MainActor
final class ImageCacheManager {
    private var cachedImages: [URL: UIImage] = [:]
    private var imageTasks: [URL: Task<Void, Never>] = [:]
    
    private func getImage(for url: URL) async throws -> UIImage? {
        if let cachedImage = cachedImages[url] {
            return cachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            return nil
        }
        cachedImages[url] = image
        
        return image
    }
    
    func getImage(for url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        imageTasks[url] = Task {
            do {
                let image = try await getImage(for: url)
                completionHandler(image)
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    func cancel(for url: URL) {
        if let task = imageTasks[url] {
            task.cancel()
        }
    }
}
