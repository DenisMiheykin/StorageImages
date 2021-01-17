import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with image: UIImage) {
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.image = image
        self.contentView.roundCorners()
    }
    
}
