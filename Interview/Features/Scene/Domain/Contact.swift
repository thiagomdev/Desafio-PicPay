import Foundation

public struct Contact: Equatable, Hashable, Decodable {
    public var id: Int
    public var name: String
    public var photoURL: String
    
    public init(
        id: Int,
        name: String,
        photoURL: String) {
            
        self.id = id
        self.name = name
        self.photoURL = photoURL
    }
}
