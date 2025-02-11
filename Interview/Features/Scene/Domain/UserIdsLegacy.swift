public enum UserIdsLegacy {
    case legacyIds([Int])
    
    var value: [Int] {
        switch self {
        case let .legacyIds(value):
            return value
        }
    }
}
