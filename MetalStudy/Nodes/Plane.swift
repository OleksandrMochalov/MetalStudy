//
//  Plane.swift
//  MetalStudy
//
//  Created by Oleksandr on 10.11.2023.
//

import Foundation
import simd
import MetalKit

class Plane: Node, Renderable {
    var vertices: [Vertex] = [
        Vertex(
            position: .init(-1, 1, 0),
            color: .init(x: 0.12, y: 0.5, z: 0.3, w: 1),
            texture: .init(x: 0, y: 1)
        ),
        Vertex(
            position: .init(1, 1, 0),
            color: .init(0.5, 0.3, 0.2, 1),
            texture: .init(x: 1, y: 1)
        ),
        Vertex(
            position: .init(-1, -1, 0),
            color: .init(0.123, 0.33, 0.12, 1),
            texture: .init(x: 0, y: 0)
        ),
        Vertex(
            position: .init(1, -1, 0),
            color: .init(0.4, 0.44, 0.66, 1),
            texture: .init(x: 1, y: 0)
        )
    ]
    
    var indices: [UInt16] = [
        0, 2, 3,
        0, 1, 3
    ]
    
    var constants: K.ShaderConstants = .init()
    var time: Float = 0
    
    var vertexBuffer: MTLBuffer?
    var indicesBuffer: MTLBuffer?
    
    var pipelineState: MTLRenderPipelineState!
    var vertexFunctionName: String = "vertex_shader"
    var fragmentFunctionName: String = "fragment_shader"
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        return vertexDescriptor
    }
    
    // Texturable
    var texture: MTLTexture?
    
    init(device: MTLDevice) {
        super.init()
        buildBuffers(device: device)
        buildPipeline(device: device)
    }
    
    init(device: MTLDevice, textureName: String) {
        super.init()
        if let texture = setTexture(device: device, imageName: textureName) {
            self.texture = texture
            self.fragmentFunctionName = "textured_fragment"
        }
        buildBuffers(device: device)
        buildPipeline(device: device)
    }
    
    func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
        indicesBuffer = device.makeBuffer(
            bytes: indices,
            length: indices.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }
    
    func buildPipeline(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: vertexFunctionName)
        let fragmentFunction = library?.makeFunction(name: fragmentFunctionName)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error when creating pipeline state: \(error)")
        }
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        super.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
        guard let indicesBuffer = indicesBuffer else { return }
        time += deltaTime
        let moveBy = abs(sin(time) / 2 + 0.5)
        constants.moveBy = moveBy
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBytes(&constants, length: MemoryLayout<K.ShaderConstants>.stride, index: 1)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indicesBuffer,
            indexBufferOffset: 0
        )
    }
}

extension Plane: Texturable { }
