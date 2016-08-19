//
//  AppDelegate.swift
//  MetalMac
//
//  Created by yly on 6/29/16.
//  Copyright © 2016 lyle. All rights reserved.
//

import Cocoa
import GLKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let names = ["Metal", "SoftRender"]

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.window.setContentSize(CGSizeMake(640, 480))
        self.window.setFrameTopLeftPoint(CGPointMake(100, 900))
        
        
//        let controller = SoftRenderViewController(nibName: "SoftRenderViewController", bundle: nil)
//        self.window.contentViewController = controller
        
//        let controller = MetalViewController(nibName: "MetalViewController", bundle: nil)
//        self.window.contentViewController = controller
        
//        testMatrix(GLKVector4Make(0.5,0.5,-0.96, 1.0))
//        testMatrix(GLKVector4Make(0.5,0.5,-0.02, 1.0))
//        testMatrix(GLKVector4Make(-1.0,1.0,-80.0, 0.0))
    }
    
    func testMatrix(v:GLKVector4) {
        let r:Float = 1.0
        let eyeX:Float = 0
        let eyeY:Float = 0
        let eyeZ:Float = 1.0
        
        let pm = GLKMatrix4MakePerspective(Float(M_PI)/180.0*80.0, r, 0, 1000.0)
        let vm = GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, 0, 0, -1.0, 0, 1.0, 0)
        let mm = GLKMatrix4Identity
        let pv = GLKMatrix4Multiply(pm, vm)
        let pvm = GLKMatrix4Multiply(pv, mm)
        let v1 = GLKMatrix4MultiplyVector4(pvm, v)
        print(v1.format())
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return names.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        if let cell = tableView.makeViewWithIdentifier("cell", owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = names[row]
            return cell
        }

        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object as! NSTableView
        print(table.selectedRow);
        
        if table.selectedRow == 0 {
            let controller = MetalViewController(nibName: "MetalViewController", bundle: nil)
            self.window.contentViewController = controller
        }else if table.selectedRow == 1 {
            let controller = SoftRenderViewController(nibName: "SoftRenderViewController", bundle: nil)
            self.window.contentViewController = controller
        }
    }
    
    

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

