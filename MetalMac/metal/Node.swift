//
//  Node.swift
//  MetalMac
//
//  Created by yly on 6/30/16.
//  Copyright © 2016 lyle. All rights reserved.
//

import Foundation
import Metal
import GLKit

struct Vertex {
    var x,y,z: Float
    var r,g,b,a: Float
    
    var u,v : Float
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a,u,v]
    }
}

class Node{
    let name: String
    let vertexCount: Int
    let buffer: MTLBuffer
    let uniformBuffer: MTLBuffer
    let uvBuffer: MTLBuffer
    
    var x:Float = 0.0
    var y:Float = 0.0
    var z:Float = 0.0
    var rx:Float = 0.0
    var ry:Float = 0.0
    var rz:Float = 0.0
    var s:Float = 1.0
    
    
    init(name:String, vertexs:[Vertex], device:MTLDevice){
        self.name = name
        self.vertexCount = vertexs.count
        
        var vf = [Float]()
        for v in vertexs {
            vf += v.floatBuffer()
        }
        let length = vertexs.count * sizeofValue(vertexs[0])
        self.buffer = device.newBufferWithBytes(vf, length: length, options: .OptionCPUCacheModeDefault)
        
        let lengthMatrix = sizeof(GLKMatrix4) * 2
        self.uniformBuffer = device.newBufferWithLength(lengthMatrix, options: .OptionCPUCacheModeDefault)
        
        let uvp:[Float] = [1,2,3]
        self.uvBuffer = device.newBufferWithBytes(uvp, length:uvp.count * sizeofValue(uvp[0]), options: .OptionCPUCacheModeDefault)
    }
    
    func modelMatrix() -> GLKMatrix4 {
        var matrix = GLKMatrix4Identity
        matrix = GLKMatrix4Translate(matrix, x, y, z)
        matrix = GLKMatrix4RotateX(matrix, rx)
        matrix = GLKMatrix4RotateY(matrix, ry)
        matrix = GLKMatrix4RotateZ(matrix, rz)
        matrix = GLKMatrix4Scale(matrix, s, s, s)
        return matrix
    }
    
    func update(delta: Double){
        ry += Float(delta * M_PI * 2.0 / 10.0)
    }
    
    func render(texture: MTLTexture, skin:MTLTexture, command: MTLCommandBuffer, pipelineState: MTLRenderPipelineState, projectionMatrix:GLKMatrix4){
        
        let lengthMatrix = sizeof(GLKMatrix4)
        let contents = self.uniformBuffer.contents()
        var matrix = modelMatrix()
        memcpy(contents, withUnsafePointer(&matrix, { (UnsafePointer<Void>)($0)}), lengthMatrix)
        var pm = projectionMatrix
        memcpy(contents + lengthMatrix, withUnsafePointer(&pm, { (UnsafePointer<Void>)($0)}),lengthMatrix)
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        descriptor.colorAttachments[0].loadAction = .Clear
        descriptor.colorAttachments[0].texture = texture
        
        let encoder = command.renderCommandEncoderWithDescriptor(descriptor)
        encoder.setCullMode(.Front)
        encoder.setVertexBuffer(buffer, offset: 0, atIndex: 0)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
        encoder.setFragmentTexture(skin, atIndex: 1)
        encoder.setRenderPipelineState(pipelineState)

        encoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        encoder.endEncoding()
    }
}

class Cube: Node {
    
    class func changuv(inout v1:Vertex,inout v2:Vertex,inout v3:Vertex,inout v4:Vertex) -> [Vertex]{
        v1.u = 0.0
        v1.v = 0.0
        
        v2.u = 0.0
        v2.v = 1.0
        
        v3.u = 1.0
        v3.v = 1.0
        
        v4.u = 1.0
        v4.v = 0.0
        
        return [v1,v2,v3, v3,v4,v1]
    }
    
    init(device: MTLDevice){
        
//        let v1 = Vertex(x: -1.0, y: 1.0, z: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:0.0, v:0.0)
//        let v2 = Vertex(x: -1.0, y: -1.0, z: 1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, u:0.0, v:1.0)
//        let v3 = Vertex(x: 1.0, y: -1.0, z: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, u:1.0, v:1.0)
//        let v4 = Vertex(x: 1.0, y: 1.0, z: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:1.0, v:0.0)
//        
//        let v5 = Vertex(x: -1.0, y: 1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:0.0, v:0.0)
//        let v6 = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, u:1.0, v:0.0)
//        let v7 = Vertex(x: 1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, u:1.0, v:1.0)
//        let v8 = Vertex(x: 1.0, y: 1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:0.0, v:1.0)
//        
//        let vs = [v1,v2,v3, v3,v4,v1, //font
//                  v6,v5,v7, v8,v7,v5,//back
//                  v2,v1,v5,  v5,v6,v2,//left
//                  v4,v3,v8,  v7,v8,v3,//right
//                  v1,v4,v5,  v5,v4,v8,//top
//                  v2,v6,v3,  v6,v7,v3,//bottom
//                  ];
        
        
        var v1 = Vertex(x: -1.0, y: 1.0, z: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:0.0, v:0.0)
        var v2 = Vertex(x: -1.0, y: -1.0, z: 1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, u:0.0, v:1.0)
        var v3 = Vertex(x: 1.0, y: -1.0, z: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, u:1.0, v:1.0)
        var v4 = Vertex(x: 1.0, y: 1.0, z: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:1.0, v:0.0)
        
        var v5 = Vertex(x: -1.0, y: 1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:0.0, v:0.0)
        var v6 = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, u:1.0, v:0.0)
        var v7 = Vertex(x: 1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, u:1.0, v:1.0)
        var v8 = Vertex(x: 1.0, y: 1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, u:0.0, v:1.0)
        
        var vs = [Vertex]()
        vs += Cube.changuv(&v1, v2: &v2, v3: &v3, v4: &v4)//font
        vs += Cube.changuv(&v8, v2: &v7, v3: &v6, v4: &v5)//back
        vs += Cube.changuv(&v5, v2: &v6, v3: &v2, v4: &v1)//left
        vs += Cube.changuv(&v4, v2: &v3, v3: &v7, v4: &v8)//right
        vs += Cube.changuv(&v5, v2: &v1, v3: &v4, v4: &v8)//top
        vs += Cube.changuv(&v2, v2: &v6, v3: &v7, v4: &v3)//bottom
        

        
        super.init(name: "Cube", vertexs: vs, device: device)
    }
    
   
}





















