//
//  AppDelegate.swift
//  MetalMac
//
//  Created by yly on 6/29/16.
//  Copyright © 2016 lyle. All rights reserved.
//

import Cocoa
import Metal
import GLKit
import CoreVideo
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var renderView: NSView!

    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var layer: CAMetalLayer!
    var queue: MTLCommandQueue!
    var displayLink: CVDisplayLink?
    var triangle: Node!
    var cube: Cube!
    var lastTime: Double = 0.0

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        self.window.setContentSize(CGSizeMake(640, 480))
        
        if device == nil {
            setupMetal()
        }
        loadImage()
        
        let did = CGMainDisplayID()
        CVDisplayLinkCreateWithCGDisplay(did, &displayLink)
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        if let displayLink = displayLink {
            CVDisplayLinkSetOutputCallback(displayLink, { (displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn in
                
                unsafeBitCast(displayLinkContext, AppDelegate.self).render()
                
                return 0
                }, UnsafeMutablePointer<Void>(unsafeAddressOf(self)))
            CVDisplayLinkStart(displayLink)
        }
        
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { (event:NSEvent) -> NSEvent? in
            self.keyEvent(event)
            return event
        }
    }
    
    let LeftArrowKeycode:UInt16 = 123
    let RightArrowKeycode:UInt16 = 124
    let BottomArrowKeycode:UInt16 = 125
    let UpArrowKeycode:UInt16 = 126
    
    let UpPgKeycode:UInt16 = 116
    let DnPgKeycode:UInt16 = 121
    
    var eyeX:Float = 0.0
    var eyeY:Float = 0.0
    var eyeZ:Float = 0.0
    
    func keyEvent(event:NSEvent){
        print("\(event.keyCode)")
        
        let code = event.keyCode
        let char = event.characters
        if code == LeftArrowKeycode {
            cube.x -= 0.1
        }else if code == RightArrowKeycode {
            cube.x += 0.1
        }else if code == BottomArrowKeycode {
            cube.y -= 0.1
        }else if code == UpArrowKeycode {
            cube.y += 0.1
        }else if code == UpPgKeycode {
            cube.z += 0.1
        }else if code == DnPgKeycode {
            cube.z -= 0.1
        }else if char == "a" {
            eyeX -= 0.1
        }else if char == "d" {
            eyeX += 0.1
        }else if char == "w" {
            eyeY += 0.1
        }else if char == "s" {
            eyeY -= 0.1
        }else if char == "q" {
            eyeZ -= 0.1
        }else if char == "e" {
            eyeZ += 0.1
        }
    }
    
    func setupMetal(){
        
        if device != nil {
            return
        }
        
        guard let d = MTLCreateSystemDefaultDevice() else{
            print("no metal device")
            return
        }
        device = d
        
        layer = CAMetalLayer()
        layer.device = device
        layer.pixelFormat = .BGRA8Unorm
        layer.framebufferOnly = true
        layer.frame = renderView.frame
        renderView.layer?.insertSublayer(layer, atIndex: 0)
        
        guard let library = device.newDefaultLibrary() else{
            return
        }
        let vertex = library.newFunctionWithName("basic_vertex")
        let fragment = library.newFunctionWithName("basic_fragment")
        
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.fragmentFunction = fragment
        pipeline.vertexFunction = vertex
        pipeline.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        pipelineState = try? device.newRenderPipelineStateWithDescriptor(pipeline)
        
        queue = device.newCommandQueue()
        
//        let a = Vertex(x: -1.0, y: -1.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
//        let b = Vertex(x: 0.0, y: 1.0, z: 0.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
//        let c = Vertex(x: 1.0, y: -1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
//        triangle = Node(name: "Triangle", vertexs: [a,b,c], device: device)
        
        cube = Cube(device:device)
//        cube.s = 0.5
        cube.z = -5.0
//        cube.rz = Float(M_PI_2/2)
//        cube.ry = Float(M_PI_2/2)
        
        lastTime = CACurrentMediaTime()
    }
    
    func updateInfo(){
        var info = ""
        info += "x = \(cube.x) \n"
        info += "y = \(cube.y) \n"
        info += "z = \(cube.z) \n"
        
        info += "eye x = \(eyeX) \n"
        info += "eye y = \(eyeY) \n"
        info += "eye z = \(eyeZ) \n"
        
        self.textView.string = info
    }
    
    var texture:MTLTexture?
    
    func loadImage(){
        guard let path = NSBundle.mainBundle().pathForResource("297", ofType: "jpg") else{
            return
        }
//        guard let path = NSBundle.mainBundle().pathForResource("171", ofType: "png") else{
//            return
//        }
        guard let image = NSImage(contentsOfFile: path) else{
            return
        }
        let width = Int(image.size.width)
        let height = Int(image.size.height)

        guard let data = image.TIFFRepresentation else{
            return
        }
        guard let bitmap = NSBitmapImageRep(data: data) else{
            return
        }
        
        let pixel = bitmap.bitmapData
        var offset = 0
        
        var buffer = [UInt8](count:width * height * 4, repeatedValue:255)
        for l in 0..<height {
            for r in 0..<width{
                buffer[l * width * 4 + r * 4 ] = pixel[offset]
                offset += 1
                buffer[l * width * 4 + r * 4 + 1] = pixel[offset]
                offset += 1
                buffer[l * width * 4 + r * 4 + 2] = pixel[offset]
                offset += 1
                if bitmap.bitsPerPixel == 32 {
                    buffer[l * width * 4 + r * 4 + 3] = pixel[offset]
                    offset += 1
                }
            }
        }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: width, height: height, mipmapped: true)
        texture = self.device.newTextureWithDescriptor(descriptor)
        if let tex = texture{
            tex.replaceRegion(MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: buffer, bytesPerRow: width * 4)
        }
    }
    
    
    func render(){
        autoreleasepool { 
        
            guard let drawable = layer.nextDrawable() else{
                return
            }
            
            let delay = CACurrentMediaTime() - lastTime
            lastTime = CACurrentMediaTime()
            
            let command = queue.commandBuffer()
            
            let r = Float(self.window.frame.width/self.window.frame.height)
            
            let pm = GLKMatrix4MakePerspective(Float(M_PI)/180.0*85.0, r, 0.0, 100.0)
            let vm = GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, 0, 0, -5.0, 0, 1.0, 0)
            let vp = GLKMatrix4Multiply(pm, vm)
            
            cube.update(delay)
            cube.render(drawable.texture, skin: texture!, command: command, pipelineState: pipelineState, projectionMatrix: vp)
            
            command.presentDrawable(drawable)
            command.commit()
        }
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.updateInfo()
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

