// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/**
 * @author Yuvraj Singh
 */
enum JsonException: Error, LocalizedError {
    case encodingError(Error)
    case decodingError(Error)
    case conversionError(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingError(let error):
            return "Could not encode: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Could not decode: \(error.localizedDescription)"
        case .conversionError(let error):
            return "Could not convert: \(error.localizedDescription)"
        }
    }
}

/**
 * @author Yuvraj Singh
 */
protocol Json {
    func encode(_ object: Any) throws -> String
    func decode<T: Decodable>(_ json: String, as type: T.Type) throws -> T
    func convert<T: Decodable>(_ object: Any, to type: T.Type) throws -> T
    static func create() -> Json
}

/**
 * @author Yuvraj Singh
 */
class DefaultJson: Json {
    private let encoder = JSONEncoder()
    private let decoder: JSONDecoder
    
    init() {
        let decoder = JSONDecoder()
        // Swift's JSONDecoder ignores unknown properties by default
        self.decoder = decoder
    }
    
    func encode(_ object: Any) throws -> String {
        guard let encodable = object as? Encodable else {
            throw JsonException.encodingError(NSError(domain: "Not Encodable", code: 0))
        }
        do {
            let data = try encoder.encode(AnyEncodable(encodable))
            guard let json = String(data: data, encoding: .utf8) else {
                throw JsonException.encodingError(NSError(domain: "Encoding to String failed", code: 0))
            }
            return json
        } catch {
            throw JsonException.encodingError(error)
        }
    }
    
    func decode<T: Decodable>(_ json: String, as type: T.Type) throws -> T {
        guard let data = json.data(using: .utf8) else {
            throw JsonException.decodingError(NSError(domain: "Invalid UTF-8", code: 0))
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JsonException.decodingError(error)
        }
    }
    
    func convert<T: Decodable>(_ object: Any, to type: T.Type) throws -> T {
        do {
            let json = try encode(object)
            return try decode(json, as: type)
        } catch {
            throw JsonException.conversionError(error)
        }
    }
    
    static func create() -> Json {
        return DefaultJson()
    }
}

// Helper to allow encoding of Any Encodable
struct AnyEncodable: Encodable {
    private let encodable: Encodable
    
    init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
