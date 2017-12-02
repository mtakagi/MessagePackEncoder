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

struct Unkeyed : Encodable {
    var empty : Empty?
    var bool : Bool
    var uint : UInt
    var uint64 : UInt64
    var uint32 : UInt32
    var uint16 : UInt16
    var uint8 : UInt8
    var int : Int
    var int64 : Int64
    var int32 : Int32
    var int16 : Int16
    var int8 : Int8
    var float : Float
    var double : Double
    var string : String

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        try container.encode(empty)
        try container.encode(uint)
        try container.encode(uint64)
        try container.encode(uint32)
        try container.encode(uint16)
        try container.encode(uint8)
        try container.encode(int)
        try container.encode(int64)
        try container.encode(int32)
        try container.encode(int16)
        try container.encode(int8)
        try container.encode(float)
        try container.encode(double)
        try container.encode(string)
    }
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

    func testEncodeUnkeyedStruct() {
        let encoder = MessagePackEncoder()
        let unkeyed = Unkeyed(empty: nil, bool: false, uint: UInt.max, uint64: UInt64.max,
                              uint32: UInt32.max, uint16: UInt16.max, uint8: UInt8.max,
                              int: Int.min, int64: Int64.min, int32: Int32.min, int16: Int16.min,
                              int8: Int8.min, float: Float.infinity, double: Double.nan, string: "Unkeyed")
        let result = try! encoder.encode(unkeyed)

        XCTAssertEqual(result, Data([0x9e, 0xc0, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xce, 0xff, 0xff, 0xff, 0xff, 0xcd, 0xff, 0xff, 0xcc, 0xff, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xd1, 0x80, 0x00, 0xd0, 0x80, 0xca, 0x7f, 0x80, 0x00, 0x00, 0xcb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7, 0x55, 0x6e, 0x6b, 0x65, 0x79, 0x65, 0x64]))
    }

    func testEmptyStruct() {
        let empty = Empty()
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x80])

        XCTAssertEqual(data, result)
    }

    static var allTests = [
        ("testEncodeSample", testEncodeSample),
        ("testEncodeNested", testEncodeNested),
        ("testEmptyStruct", testEmptyStruct),
    ]
}
