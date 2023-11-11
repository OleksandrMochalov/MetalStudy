//
//  GameScene.swift
//  MetalStudy
//
//  Created by Oleksandr on 10.11.2023.
//

import MetalKit

class GameScene: AppScene {
    var plane: Plane
    
    override init(device: MTLDevice, size: CGSize) {
        plane = .init(device: device, textureName: "unnamed.png")
        super.init(device: device, size: size)
        add(child: plane)
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        super.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
        plane.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
    }
}
