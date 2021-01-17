import UIKit

class ViewerViewController: UIViewController {

    // MARK: - outlets
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subView1: UIView!
    
    // MARK: - var
    var indexPicture = 0
    var pictureModified = false
    
    // MARK: - lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setup()
    }
    
    // MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.savePhotoAlbum()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func heartButtonPressed(_ sender: UIButton) {
        Manager.shared.photoAlbum[indexPicture].like = !Manager.shared.photoAlbum[indexPicture].like
        self.setHeartButton()
        self.pictureModified = true
    }
    
    @IBAction func commentTFEditingChanged(_ sender: UITextField) {
        Manager.shared.photoAlbum[indexPicture].comment = sender.text ?? ""
        self.pictureModified = true
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        self.moveSlideRight()
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        self.moveSlideLeft()
    }
    
    @IBAction func leftSwipeDetected(_ sender: UISwipeGestureRecognizer) {
        self.moveSlideRight()
    }
    
    @IBAction func rightSwipeDetected(_ sender: UISwipeGestureRecognizer) {
        self.moveSlideLeft()
    }
    
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.zoomImage()
    }
    
    @IBAction func removeZoomedImageView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            sender.view?.frame = self.imageView.frame
        }) { (_) in
            sender.view?.removeFromSuperview()
        }
    }
    
    // MARK: - flow funcs
    func savePhotoAlbum() {
        if self.pictureModified {
            Manager.shared.savePhotoAlbum()
        }
    }
    
    func zoomImage() {
        let zoomedImageView = UIImageView()
        zoomedImageView.frame = self.imageView.frame
        zoomedImageView.contentMode = self.imageView.contentMode
        zoomedImageView.clipsToBounds = true
        zoomedImageView.image = self.imageView.image
        zoomedImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeZoomedImageView(_:)))
        zoomedImageView.addGestureRecognizer(tap)
        self.subView1.addSubview(zoomedImageView)
        
        UIView.animate(withDuration: 0.3) {
            zoomedImageView.frame = self.view.bounds
        }
    }
    
    //
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            self.bottomConstraint.constant = 0
        } else {
            self.bottomConstraint.constant = keyboardScreenEndFrame.height
        }
        
        view.needsUpdateConstraints()
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - extension
extension ViewerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

private extension ViewerViewController {
    
    func setup() {
        if Manager.shared.photoAlbum.count == 0 {
            self.heartButton.isHidden = true
            self.leftButton.isHidden = true
            self.rightButton.isHidden = true
            self.commentTF.isHidden = true
            return
        }
        
        self.setupPicture()
        self.setupSwipeSettings()
    }
    
    func setupPicture() {
        self.loadImage(self.imageView)
        self.loadDataPicture()
    }
    
    func loadDataPicture() {
        self.commentTF.text = Manager.shared.photoAlbum[self.indexPicture].comment
        self.setHeartButton()
    }
    
    func setHeartButton() {
        if Manager.shared.photoAlbum[indexPicture].like {
            self.heartButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            self.heartButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func setupSwipeSettings() {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeDetected(_:)))
        leftSwipe.direction = .left
        self.imageView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeDetected(_:)))
        rightSwipe.direction = .right
        self.imageView.addGestureRecognizer(rightSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
        self.imageView.addGestureRecognizer(tap)
        
    }
    
    func loadImage(_ imageView: UIImageView) {
        imageView.contentMode = .scaleAspectFill
        if let image = self.loadSave(fileName: Manager.shared.photoAlbum[self.indexPicture].name) {
            imageView.image = image
        }
    }
    
    func moveSlideLeft() {
        self.upIndexPicture()
        let newImageView = self.createImageView(x: -2 * self.imageView.frame.size.width)
        self.runAnimate(newImageView, finish: 2 * self.imageView.frame.size.width)
    }
    
    func moveSlideRight() {
        self.downIndexPicture()
        let newImageView = self.createImageView(x: 2 * self.imageView.frame.size.width)
        self.runAnimate(newImageView, finish: -2 * self.imageView.frame.size.width)
    }
    
    func createImageView(x: CGFloat) -> UIImageView {
        let newImageView = UIImageView()
        
        newImageView.frame = CGRect(x: x,
                                    y: 0,
                                    width: self.imageView.frame.size.width,
                                    height: self.imageView.frame.size.height)
        newImageView.contentMode = .scaleAspectFit
        self.loadImage(newImageView)
        self.imageView.addSubview(newImageView)
        
        return newImageView
    }
    
    func runAnimate(_ newImageView: UIImageView, finish: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            newImageView.frame.origin.x += finish
        }) { (_) in
            self.imageView.image = newImageView.image
            newImageView.removeFromSuperview()
            self.loadDataPicture()
        }
    }
    
    func upIndexPicture() {
        if self.indexPicture == Manager.shared.photoAlbum.count - 1 {
            self.indexPicture = 0
        } else {
            self.indexPicture += 1
        }
    }
    
    func downIndexPicture() {
        if self.indexPicture == 0 {
            self.indexPicture = Manager.shared.photoAlbum.count - 1
        } else {
            self.indexPicture -= 1
        }
    }
}
