import Foundation

class Manager {
    
    static let shared = Manager()
    var photoAlbum: [Picture] = []
    
    private init() {}
    
    func addPictureToPhotoAlbum(_ picture: Picture) {
        self.photoAlbum.append(picture)
        UserDefaults.standard.set(encodable: Manager.shared.photoAlbum, forKey: UserDefaultsKeys.photoAlbum)
    }
    
    func loadPhotoAlbum() {
        if let photoAlbum = UserDefaults.standard.value([Picture].self, forKey: UserDefaultsKeys.photoAlbum) {
            self.photoAlbum = photoAlbum
        }
    }
    
    func savePhotoAlbum() {
        UserDefaults.standard.set(encodable: self.photoAlbum, forKey: UserDefaultsKeys.photoAlbum)
    }
}
