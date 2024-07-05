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
    private var cachedImages = NSCache<NSURL, UIImage>()
    private var imageTasks: [URL: Task<Void, Never>] = [:]
    private var loadingResponses: [URL: [(UIImage?) -> Void]] = [:]
    
    private func getImage(for url: URL) async throws -> UIImage? {
        if let cachedImage = cachedImages.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            return nil
        }
        cachedImages.setObject(image, forKey: url as NSURL)
        
        return image
    }
    
    func getImage(for url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        if let cachedImage = cachedImages.object(forKey: url as NSURL) {
            completionHandler(cachedImage)
            return
        }
        
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completionHandler)
            return
        } else {
            loadingResponses[url] = [completionHandler]
        }
        
        imageTasks[url] = Task {
            guard let image = try? await getImage(for: url) else {
                completionHandler(nil)
                return
            }
            
            if Task.isCancelled {
                return
            }
            
            guard let blocks = loadingResponses[url] else {
                completionHandler(nil)
                return
            }
            
            for block in blocks {
                block(image)
            }
            
            imageTasks[url] = nil
            loadingResponses[url] = nil
        }
    }
    
    func cancel(for url: URL) {
        if let task = imageTasks[url] {
            task.cancel()
        }
        imageTasks[url] = nil
        loadingResponses[url] = nil
    }
}
