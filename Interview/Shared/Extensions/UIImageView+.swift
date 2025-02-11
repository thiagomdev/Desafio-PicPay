import UIKit

let imageToCahe = NSCache<NSString, UIImage>()

extension UIImageView {
    func load(urlImage: URL, mode: ContentMode) {
        self.image = nil
        if let cachedImage = imageToCahe.object(
            forKey: urlImage.absoluteString as NSString) {
            self.image = cachedImage
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let data = try? Data(contentsOf: urlImage) {
                if let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = img
                        imageToCahe.setObject(
                            img,
                            forKey: urlImage.absoluteString as NSString
                        )
                    }
                }
            }
        }
    }
}
