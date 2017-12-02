import XCTest
@testable import MsgPackEncoder

public struct Empty : Codable {
}

struct Sample : Codable {
    var foo : UInt8
    var bar : String
    var bazz : UInt32
}

struct Nested : Codable {
    var nested : String
    var sample : Sample
}

class MsgPackEncoderTests: XCTestCase {

    func testEncodeSample() {
        let encoder = MessagePackEncoder()
        let sample = Sample(foo: 127, bar: "Sample", bazz: UInt32.max)
        let result = try! encoder.encode(sample)

        XCTAssertEqual(result, Data([0x83, 0xa3, 0x66, 0x6f, 0x6f, 0x7f, 0xa3, 0x62, 0x61, 0x72, 0xa6, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xce, 0xff, 0xff, 0xff, 0xff]))
    }

    func testEncodeNested() {
        let encoder = MessagePackEncoder()
        let sample = Sample(foo: 127, bar: "Sample", bazz: UInt32.max)
        let nested = Nested(nested: "Nested", sample: sample)
        let result = try! encoder.encode(nested)

        XCTAssertEqual(result, Data([0x82, 0xa6, 0x6e, 0x65, 0x73, 0x74, 0x65, 0x64, 0xa6, 0x4e, 0x65, 0x73, 0x74, 0x65, 0x64, 0xa6, 0x73, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x83, 0xa3, 0x66, 0x6f, 0x6f, 0x7f, 0xa3, 0x62, 0x61, 0x72, 0xa6, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xce, 0xff, 0xff, 0xff, 0xff]))
    }

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
        ("testEncodeSample", testEncodeSample),
        ("testEncodeNested", testEncodeNested),
        ("testEmptyStruct", testEmptyStruct),
        ("testEncodeNil", testEncodeNil),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTimestamp32Min", testEncodeTimestamp32Min),
        ("testEncodeTimestamp32Max", testEncodeTimestamp32Max),
    ]
}
