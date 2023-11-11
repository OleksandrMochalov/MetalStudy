//
//  Renderable.swift
//  MetalStudy
//
//  Created by Oleksandr on 10.11.2023.
//

import Foundation
import MetalKit

public protocol Renderable {
    var pipelineState: MTLRenderPipelineState! { get }
    var fragmentFunctionName: String { get }
    var vertexDescriptor: MTLVertexDescriptor { get }
}
