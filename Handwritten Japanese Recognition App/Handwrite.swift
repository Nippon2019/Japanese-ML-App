//
//  Handwrite.swift
//  Handwritten Japanese Recognition App
//
//  Created by Aiyu Kamate on 2020/08/03.
//  Copyright © 2020 Aiyu Kamate. All rights reserved.
//

import UIKit

class Handwrite: UIView {

        var x = 0
        var path:UIBezierPath!
        var touchPoint:CGPoint!
        var startingPoint:CGPoint!
        
        override func layoutSubviews() {
            self.clipsToBounds = true
            self.isMultipleTouchEnabled = true
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            startingPoint = touch?.location(in: self)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            touchPoint = touch?.location(in: self)
            
            path = UIBezierPath()
            path.move(to: startingPoint)
            path.addLine(to: touchPoint)
            startingPoint = touchPoint
            
            x = 1
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.yellow.cgColor
            shapeLayer.lineWidth = 5
            shapeLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(shapeLayer)
            self.setNeedsDisplay()
        }
        
        func clear(){
            if x > 0{
                path.removeAllPoints()
            }
            self.layer.sublayers = nil
            self.setNeedsDisplay()
        }
    }

extension UIImage{
    convenience init (view:UIView){
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
