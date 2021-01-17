import UIKit

class EditorViewController: UIViewController {
    
    // MARK: - outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        Manager.shared.loadPhotoAlbum()
    }
    
    // MARK: - IBActions
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        self.performImagePicker()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goViewButtonPressed(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ViewerViewController") as? ViewerViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - flow funcs
    private func performImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK: - extension
extension EditorViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var  chosenImage = UIImage()

        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        
        self.savePickedImage(chosenImage)
        
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func savePickedImage(_ image: UIImage) {
        guard let name = self.saveImage(image: image) else {
            return
        }
        let picture = Picture(name)
        let indexPath = IndexPath(item: Manager.shared.photoAlbum.count, section: 0)
        
        Manager.shared.addPictureToPhotoAlbum(picture)
        
        self.collectionView.insertItems(at: [indexPath])
    }
}

extension EditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Manager.shared.photoAlbum.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let image = self.loadSave(fileName: Manager.shared.photoAlbum[indexPath.item].name) {
            cell.configure(with: image)
        } else {
            cell.configure(with: UIImage())
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ViewerViewController") as? ViewerViewController else {
            return
        }
        controller.indexPicture = indexPath.item
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.size.width / 2 - 5
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

