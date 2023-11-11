//
//  ContentView.swift
//  MetalStudy
//
//  Created by Oleksandr on 09.11.2023.
//

import SwiftUI
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var scene: AppScene? = nil
    
    var samplerState: MTLSamplerState?
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        metalView.device = device
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        super.init()
        buildSamplerState()
        scene = GameScene(device: Renderer.device, size: metalView.bounds.size)
        metalView.clearColor = Color.bgColor
        metalView.delegate = self
    }
    
    private func buildSamplerState() {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = Renderer.device.makeSamplerState(descriptor: descriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        let timeDelta = 1 / Float(view.preferredFramesPerSecond)
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        guard let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor) else { return }
        commandEncoder.setFragmentSamplerState(self.samplerState, index: 0)
        scene?.render(commandEncoder: commandEncoder, deltaTime: timeDelta)
        commandEncoder.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

extension Renderer {
    enum Color {
        static let bgColor = MTLClearColorMake(
            0.0,
            0.2,
            0.1,
            1.0
        )
    }
    
    struct Constants {
        var moveBy: Float = 0
    }
}

class MetalViewController: UIViewController {
    
    var metalView: MTKView {
        self.view as! MTKView
    }
    var renderer: Renderer!
    
    override func loadView() {
        self.view = MTKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.renderer = Renderer(metalView: self.metalView)
    }
}

struct ContentView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MetalViewController {
        return .init()
    }
    
    func updateUIViewController(_ uiViewController: MetalViewController, context: Context) {
        
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}
