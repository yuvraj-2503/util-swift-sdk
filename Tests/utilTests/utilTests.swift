import XCTest
@testable import util  // 'util' must match your Swift module/package name exactly

/**
 * @author Yuvraj Singh
 */
final class JsonTests: XCTestCase {
    struct User: Codable, Equatable {
        let name: String
        let age: Int
    }

    func testEncodingAndDecoding() {
        let jsonUtil = DefaultJson()
            let user = User(name: "Yuvraj", age: 30)

            do {
                let encoded = try jsonUtil.encode(user)
                print("Encoded JSON:", encoded)
                XCTAssertFalse(encoded.isEmpty, "Encoded string should not be empty")

                let decoded: User = try jsonUtil.decode(encoded, as: User.self)
                print("Decoded:", decoded)
                XCTAssertEqual(decoded, user, "Decoded user should match the original")
            } catch {
                XCTFail("Test failed with error: \(error)")
            }
    }
}

