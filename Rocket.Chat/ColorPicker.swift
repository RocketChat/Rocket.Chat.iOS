//
//  ColorPicker.swift
//
//  Created by Dejan Atanasov on 12/25/15.
//
import UIKit
@objc protocol colorDelegate {
    @objc optional func pickedColor(color:UIColor)
}
class ColorPicker: UIView {
    var currentSelectionY: CGFloat = 0;
    var selectedColor: UIColor!
    weak var delegate: colorDelegate!
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        UIColor.black.set()
        var tempXPlace = self.currentSelectionY;
        if (tempXPlace < CGFloat (0.0)) {
            tempXPlace = CGFloat (0.0)
        } else if (tempXPlace >= self.frame.size.height) {
            tempXPlace = self.frame.size.height - 1.0
        }
        let temp = CGRect(origin:CGPoint(x:tempXPlace, y:0.0), size: CGSize(width:self.frame.size.width, height:1.0))
        UIRectFill(temp)
        //draw central bar over it
        let height = Int(self.frame.size.height)
        for i in 0 ..< height {
            UIColor(hue:CGFloat (i)/self.frame.size.height, saturation: 1.0,brightness: 1.0, alpha: 1.0).set()
            let temp = CGRect(origin:CGPoint( x:0, y:(i)),size:CGSize(width:self.frame.size.width,height:1.0))
            UIRectFill(temp)
        }
    }
    //Changes the selected color, updates the UI, and notifies the delegate.
    func selectedColor(sColor: UIColor) {
        if sColor != selectedColor {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            if sColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                currentSelectionY = CGFloat (hue * self.frame.size.width)
                self.setNeedsDisplay()
            }
            selectedColor = sColor
            self.delegate.pickedColor!(color: selectedColor)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        updateColor(touch: touch!)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        updateColor(touch: touch!)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        updateColor(touch: touch!)
    }
    func updateColor(touch: UITouch) {
        currentSelectionY = (touch.location(in: self).y)
        selectedColor = UIColor(hue: (currentSelectionY / self.frame.size.height), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        self.delegate.pickedColor!(color: selectedColor)
        self.setNeedsDisplay()
    }
}
