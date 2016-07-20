//
//  File.metal
//  MetalMac
//
//  Created by yly on 6/29/16.
//  Copyright © 2016 lyle. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexIn{
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
};

struct Uniforms{
    float4x4 modelMatrix;
//    float4x4 viewMatrix;
    float4x4 projectMatrix;
};

vertex VertexOut basic_vertex(
                           const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[buffer(1)]],
                           unsigned int vid [[ vertex_id ]]) {
    VertexIn vi = vertex_array[vid];
    
    VertexOut vo;
    vo.position = uniforms.projectMatrix * uniforms.modelMatrix * float4(vi.position, 1.0);
    vo.color = vi.color;
    return vo;
}

fragment half4 basic_fragment(VertexOut vo[[stage_in]]) {
    return half4(vo.color[0], vo.color[1], vo.color[2], vo.color[3]);
}
