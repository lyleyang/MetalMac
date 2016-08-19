//
//  SoftRenderViewController.swift
//  MetalMac
//
//  Created by yly on 7/25/16.
//  Copyright © 2016 lyle. All rights reserved.
//

import Cocoa
import GLKit

extension Float {
    var f:CGFloat {
        return CGFloat(self)
    }
}

class SoftRenderViewController: NSViewController {
    
    var context:CGContext?

    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        loadImage()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            self.drawTriangle(10, y1: 200, x2: 10, y2: 0, x3: 300, y3: 200, u1:0, v1:1, u2: 0,v2: 0,u3: 1,v3: 1)
//            self.drawTriangle(10, y1: 0, x2: 300, y2: 0, x3: 300, y3: 200, u1:0, v1:0, u2: 1,v2: 0,u3: 1,v3: 1)
            
            self.drawCube()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1.0/30.0, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
    }
    
    func loop(){
        drawCube()
        rotateY += Float(M_PI/180.0)
    }
    
    //MARK: Draw Cube
    
    func drawCube(){

        let p1 = testMatrix(GLKVector4Make(-10, 10, -10, 1))
        let p2 = testMatrix(GLKVector4Make(-10, 10, 10, 1))
        let p3 = testMatrix(GLKVector4Make(10, 10, 10, 1))
        let p4 = testMatrix(GLKVector4Make(10, 10, -10, 1))
        
        let p5 = testMatrix(GLKVector4Make(-10, -10, -10, 1))
        let p6 = testMatrix(GLKVector4Make(-10, -10, 10, 1))
        let p7 = testMatrix(GLKVector4Make(10, -10, 10, 1))
        let p8 = testMatrix(GLKVector4Make(10, -10, -10, 1))
        
        clear()
        
        drawLine(p1, v2: p2)
        drawLine(p2, v2: p3)
        drawLine(p3, v2: p4)
        drawLine(p4, v2: p1)
        
        drawLine(p5, v2: p6)
        drawLine(p6, v2: p7)
        drawLine(p7, v2: p8)
        drawLine(p8, v2: p5)
        
        drawLine(p1, v2: p5)
        drawLine(p2, v2: p6)
        drawLine(p3, v2: p7)
        drawLine(p4, v2: p8)
        
        updateImage()
    }
    
    func drawLine(v1:GLKVector4, v2:GLKVector4) {
        drawLine(v1.x.f, y1: v1.y.f, x2: v2.x.f, y2: v2.y.f)
    }
    
    var rotateY:Float = 0.0
    
    func testMatrix(v:GLKVector4) -> GLKVector4{
        let r:Float = 1.0
        let eyeX:Float = 0
        let eyeY:Float = 0
        let eyeZ:Float = 20.0
        
        let pm = GLKMatrix4MakePerspective(Float(M_PI)/180.0*80.0, r, 0, 100.0)
        let vm = GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, 0, 0, 0.0, 0, 1.0, 0)
        let mm = GLKMatrix4MakeYRotation(rotateY)
        let pv = GLKMatrix4Multiply(pm, vm)
        let pvm = GLKMatrix4Multiply(pv, mm)
        let v1 = GLKMatrix4MultiplyVector4(pvm, v)
        let v2 = GLKVector4Make(v1.x/v1.w * 100, v1.y/v1.w * 100, v1.z/v1.w, v1.w)
        print(v1.format(),v2.format())
        return v2
    }
    
    
    //MARK: Draw Triangle
    func drawTriangle(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat, x3:CGFloat, y3:CGFloat,u1:CGFloat, v1:CGFloat, u2:CGFloat, v2:CGFloat, u3:CGFloat, v3:CGFloat) {
        let size = self.view.bounds.size;
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        while x < size.width {
            while y < size.height {
                
                let c = ((y1-y2)*x+(x2-x1)*y+x1*y2-x2*y1)/((y1-y2)*x3+(x2-x1)*y3+x1*y2-x2*y1);
                let b = ((y1-y3)*x+(x3-x1)*y+x1*y3-x3*y1)/((y1-y3)*x2+(x3-x1)*y2+x1*y3-x3*y1);
                let a = 1-b-c;
                if (a >= 0 && a <= 1 && b >= 0 && b <= 1 && c >= 0 && c <= 1)
                {
                    let u = u1 * a + u2 * b + u3 * c
                    let v = 1.0 - (v1 * a + v2 * b + v3 * c)
                    var p = pixel(u, y: v)
                    
                    let cx = size.width/2.0
                    let cy = size.height/2.0
                    var f = (100.0 - sqrtf(Float((x-cx)*(x-cx) + (y-cy)*(y-cy)))) / 55

                    f = f < 0.0 ? 0.1 : f
                    
                    p[0] = p[0] * f
                    p[1] = p[1] * f
                    p[2] = p[2] * f
                    
                    let c = NSColor(colorLiteralRed: p[0], green: p[1], blue: p[2], alpha: 1.0)
                    drawPoint(x, y: y, color: c.CGColor)
                }
                y += 1.0
            }
            x += 1.0
            y = 0.0
        }
        
        updateImage()
    }
    
    func pixel(x:CGFloat, y:CGFloat) -> [Float]{
        var pixel:[Float] = [1.0, 1.0, 1.0]
        
        let offset = width * 4 * Int(CGFloat(height) * y) + Int(CGFloat(width) * x) * 4
        if offset >= buffer.count {
            return pixel
        }
        pixel[0] = Float(buffer[offset]) / 255.0
        pixel[1] = Float(buffer[offset + 1]) / 255.0
        pixel[2] = Float(buffer[offset + 2]) / 255.0
        return pixel
    }
    
    var buffer:[UInt8] = []
    var width = 0
    var height = 0
    
    func loadImage(){
        guard let path = NSBundle.mainBundle().pathForResource("297", ofType: "jpg") else{
            return
        }
        guard let image = NSImage(contentsOfFile: path) else{
            return
        }
        width = Int(image.size.width)
        height = Int(image.size.height)
        
        guard let data = image.TIFFRepresentation else{
            return
        }
        guard let bitmap = NSBitmapImageRep(data: data) else{
            return
        }
        
        let pixel = bitmap.bitmapData
        var offset = 0
        
        buffer = [UInt8](count:width * height * 4, repeatedValue:255)
        
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
    }
    
    func drawUpTriangle(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat, x3:CGFloat, y3:CGFloat){
        let kl = (y2 - y1)/(x2 - x1)
        let bl = y1 - x1 * kl
        
        let kr = (y2 - y3)/(x2 - x3)
        let br = y3 - x3 * kr
        
        for xi in Int(x1)..<Int(x2) {
            let xl = CGFloat(xi)
            let y = xl * kl + bl
            let xr = (y - br)/kr
            
            drawLine(xl, y1: y, x2: xr, y2: y)
            
            usleep(1000 * 5)
        }
        
    }
    
    //MARK: Draw Context
    func drawPoint(x:CGFloat, y:CGFloat, color:CGColor=NSColor.whiteColor().CGColor) {
        createContext()
        
        CGContextSetStrokeColorWithColor(context, color)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, x, y)
        CGContextAddLineToPoint(context, x+1.0, y)
        CGContextClosePath(context)
        CGContextStrokePath(context)
    }
    
    func drawLine(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat) {
        createContext()
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, x1, y1)
        CGContextAddLineToPoint(context, x2, y2)
        CGContextClosePath(context)
        CGContextStrokePath(context)
    }
    
    func updateImage(){
        guard let image = CGBitmapContextCreateImage(context) else{
            return
        }
        
        let size = CGSizeMake(CGFloat(CGImageGetWidth(image)), CGFloat(CGImageGetHeight(image)))
        imageView.image = NSImage(CGImage: image, size: size)
    }
    
    func createContext(){
        if context == nil {
            let size = self.view.bounds.size
            let w = Int(size.width)
            let h = Int(size.height)
            
            let space = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue
            context = CGBitmapContextCreate(nil, w, h, 8, w * 4, space, bitmapInfo)
            
            CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0)
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
            CGContextSetLineWidth(context, 1.0)
            
            CGContextStrokeRect(context, CGRectMake(0, 0, size.width, size.height))
            
            CGContextTranslateCTM(context, size.width/2.0, size.height/2.0)
            
            drawLine(-size.width/2.0, y1: 0, x2:size.width/2.0, y2: 0)
            drawLine(0, y1: size.height/2, x2: 0, y2: -size.height/2)
            
            CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0)
        }
    }
    
    func clear(){
        let size = self.view.bounds.size
        CGContextClearRect(context, CGRectMake(-size.width/2, -size.height/2, size.width, size.height))
    }
    
}
