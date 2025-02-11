import Interview

extension Contact {
    static func fixture(
        id: Int = 0,
        name: String = "Shakira",
        photoURL: String = "") -> Self {
            
        .init(
            id: id,
            name: name,
            photoURL: photoURL
        )
    }
}
