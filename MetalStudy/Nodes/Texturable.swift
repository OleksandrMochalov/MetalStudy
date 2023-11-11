//
//  Texturable.swift
//  MetalStudy
//
//  Created by Oleksandr on 11.11.2023.
//

import MetalKit

protocol Texturable {
    var texture: MTLTexture? { get set }
}

extension Texturable {
    func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions = [MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.bottomLeft]
        guard let imageUrl = Bundle.main.url(forResource: imageName, withExtension: nil) else { return nil }
        do {
            let texture = try textureLoader.newTexture(URL: imageUrl, options: textureLoaderOptions)
            return texture
        } catch {
            print("Error when loading texture: \(error)")
            return nil
        }
    }
}
