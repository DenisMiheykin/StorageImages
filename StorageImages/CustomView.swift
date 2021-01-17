import UIKit

class CustomView: UIView {
    
    @IBOutlet var squareView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var button: UIButton!
    
    var blurEffectView = UIVisualEffectView()
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurEffectView.effect = nil
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    class func instanceFromNib() -> CustomView {
        let xib = UINib(nibName: "CustomView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomView
        xib.squareView.roundCorners()
        xib.squareView.dropshadow()
        
        xib.blurEffectView.frame = xib.bounds
        xib.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        xib.insertSubview(xib.blurEffectView, at: 0)
        UIView.animate(withDuration: 0.3) {
            xib.blurEffectView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        
        return xib
    }
}

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
