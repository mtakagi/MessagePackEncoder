import XCTest
@testable import MsgPackEncoder

public struct Empty : Codable {
}

struct Sample : Codable {
    var foo : UInt8
    var bar : String
    var bazz : UInt32
}

class MsgPackEncoderTests: XCTestCase {
    func testEmptyStruct() {
        let empty = Empty()
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x80])

        XCTAssertEqual(data, result)
    }
    
    func testEncodeNil() {
        let value : Int? = nil
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(value)

        XCTAssertEqual(result, Data([0xc0]))
    }

    func testEncodeTrue() {
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(true)

        XCTAssertEqual(result, Data([0xc3]))
    }

    func testEncodeFalse() {
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(false)

        XCTAssertEqual(result, Data([0xc2]))
    }

    func testEncodeTimestamp32Min() {
        let encoder = MessagePackEncoder()
        let date = Date(timeIntervalSince1970: 0.0)
        let result = try! encoder.encode(date)

        XCTAssertEqual(result, Data([0xd6, 0xff, 0x00, 0x00, 0x00, 0x00]))
    }

    func testEncodeTimestamp32Max() {
        let encoder = MessagePackEncoder()
        let date = Date(timeIntervalSince1970: Double(UInt32.max))
        let result = try! encoder.encode(date)

        XCTAssertEqual(result, Data([0xd6, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    static var allTests = [
        ("testEmptyStruct", testEmptyStruct),
        ("testEncodeNil", testEncodeNil),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTimestamp32Min", testEncodeTimestamp32Min),
        ("testEncodeTimestamp32Max", testEncodeTimestamp32Max),
    ]
}
