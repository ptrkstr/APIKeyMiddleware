import Vapor

public struct APIKey: Equatable {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
}

extension APIKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

public extension HTTPHeaders.Name {
    static let apiKey = HTTPHeaders.Name("api-key")
}

public extension HTTPHeaders {
    var apiKey: APIKey? {
        get {
            guard let string = self.first(name: .apiKey) else {
                return nil
            }
            
            return .init(value: string)
        }
        set {
            if let apiKey = newValue {
                replaceOrAdd(name: .apiKey, value: apiKey.value)
            } else {
                remove(name: .apiKey)
            }
        }
    }
}
