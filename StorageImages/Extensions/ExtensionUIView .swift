import UIKit

extension UIView {
    
    func roundCorners(_ radius: CGFloat = 20) {
        self.layer.cornerRadius = radius
    }
    
    func dropshadow(_ radius: CGFloat = 20) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 15, height: 15)
        layer.shouldRasterize = true
    }
}
