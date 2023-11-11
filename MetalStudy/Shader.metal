//
//  Shader.metal
//  MetalStudy
//
//  Created by Oleksandr on 10.11.2023.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
    float moveBy;
};

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 texture [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 texture;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn[[stage_in]],
                            constant Constants &constants [[ buffer(1) ]]) {
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.position.x += constants.moveBy;
    vertexOut.color = vertexIn.color;
    vertexOut.texture = vertexIn.texture;
    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn[[stage_in]]) {
    half3 gray = (vertexIn.color.r + vertexIn.color.g + vertexIn.color.b) / 3.0;
    return half4(gray, 1.0);
}

fragment half4 textured_fragment(VertexOut vertexIn[[stage_in]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler defaultSampler;
    float4 color = texture.sample(defaultSampler, vertexIn.texture);
    return half4(color.r, color.b, color.g, 1.0);
}
