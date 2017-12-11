import XCTest
@testable import MsgPackEncoder

public struct Empty : Codable {

    public init() {}

    public init(from: Decoder) {
        
    }

}

extension Empty : Equatable {
    public static func ==(lhs: Empty, rhs: Empty) -> Bool {
        return true
    }
}

struct Sample : Codable {
    var foo : UInt8
    var bar : String
    var bazz : UInt32
}

extension Sample : Equatable {
    static func ==(lhs: Sample, rhs: Sample) -> Bool {
        return lhs.foo == rhs.foo && lhs.bar == rhs.bar && lhs.bazz == rhs.bazz
    }

    static func !=(lhs: Sample, rhs: Sample) -> Bool {
        return !(lhs == rhs)
    }
}

struct Nested : Codable {
    var nested : String
    var sample : Sample
}

extension Nested : Equatable {
    static func ==(lhs: Nested, rhs: Nested) -> Bool {
        return lhs.nested == rhs.nested && lhs.sample == rhs.sample
    }

    static func !=(lhs: Nested, rhs: Nested) -> Bool {
        return !(lhs == rhs)
    }
}

struct NestStruct : Codable {
    struct Nest : Codable {
        var nest : String
    }

    var nest : String
    var nested : Nest
}

struct Unkeyed : Codable {
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

    init(empty: Empty?, bool: Bool, uint: UInt, uint64: UInt64,
    uint32: UInt32, uint16: UInt16, uint8: UInt8,
    int: Int, int64: Int64, int32: Int32, int16: Int16,
    int8: Int8, float: Float, double: Double, string: String) {
        self.empty = empty
        self.bool = bool
        self.uint = uint
        self.uint64 = uint64
        self.uint32 = uint32
        self.uint16 = uint16
        self.uint8 = uint8
        self.int = int
        self.int64 = int64
        self.int32 = int32
        self.int16 = int16
        self.int8 = int8
        self.float = float
        self.double = double
        self.string = string
    }

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

    init(from decoder : Decoder) throws {
        var container = try decoder.unkeyedContainer()

        self.empty = try container.decode(Empty?.self)
        self.bool = false
        self.uint = try container.decode(UInt.self)
        self.uint64 = try container.decode(UInt64.self)
        self.uint32 = try container.decode(UInt32.self)
        self.uint16 = try container.decode(UInt16.self)
        self.uint8 = try container.decode(UInt8.self)
        self.int = try container.decode(Int.self)
        self.int64 = try container.decode(Int64.self)
        self.int32 = try container.decode(Int32.self)
        self.int16 = try container.decode(Int16.self)
        self.int8 = try container.decode(Int8.self)
        self.float = try container.decode(Float.self)
        self.double = try container.decode(Double.self)
        self.string = try container.decode(String.self)
    }
}

extension Unkeyed : Equatable {
    static func ==(lhs: Unkeyed, rhs: Unkeyed) -> Bool {
        if lhs.float.isNaN || lhs.double.isNaN || rhs.float.isNaN || rhs.double.isNaN {
            return lhs.empty == rhs.empty && lhs.bool == rhs.bool && lhs.uint == rhs.uint
                && lhs.uint64 == rhs.uint64 && lhs.uint32 == rhs.uint32 && lhs.uint16 == rhs.uint16
                && lhs.uint8 == rhs.uint8 && lhs.int == rhs.int && lhs.int64 == rhs.int64 && lhs.int32 == rhs.int32
                && lhs.int16 == rhs.int16 && lhs.int8 == rhs.int8
                && lhs.string == rhs.string
        } else {
            return lhs.empty == rhs.empty && lhs.bool == rhs.bool && lhs.uint == rhs.uint
                && lhs.uint64 == rhs.uint64 && lhs.uint32 == rhs.uint32 && lhs.uint16 == rhs.uint16
                && lhs.uint8 == rhs.uint8 && lhs.int == rhs.int && lhs.int64 == rhs.int64 && lhs.int32 == rhs.int32
                && lhs.int16 == rhs.int16 && lhs.int8 == rhs.int8 && lhs.float == rhs.float && lhs.double == rhs.double
                && lhs.string == rhs.string
        }
    }

    static func !=(lhs: Unkeyed, rhs: Unkeyed) -> Bool {
        return !(lhs == rhs)
    }
}

struct Keyed : Codable {
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
}

extension Keyed : Equatable {
    static func ==(lhs: Keyed, rhs: Keyed) -> Bool {
        if lhs.float.isNaN || lhs.double.isNaN || rhs.float.isNaN || rhs.double.isNaN {
            return lhs.empty == rhs.empty && lhs.bool == rhs.bool && lhs.uint == rhs.uint
                && lhs.uint64 == rhs.uint64 && lhs.uint32 == rhs.uint32 && lhs.uint16 == rhs.uint16
                && lhs.uint8 == rhs.uint8 && lhs.int == rhs.int && lhs.int64 == rhs.int64 && lhs.int32 == rhs.int32
                && lhs.int16 == rhs.int16 && lhs.int8 == rhs.int8
                && lhs.string == rhs.string
        } else {
            return lhs.empty == rhs.empty && lhs.bool == rhs.bool && lhs.uint == rhs.uint
                && lhs.uint64 == rhs.uint64 && lhs.uint32 == rhs.uint32 && lhs.uint16 == rhs.uint16
                && lhs.uint8 == rhs.uint8 && lhs.int == rhs.int && lhs.int64 == rhs.int64 && lhs.int32 == rhs.int32
                && lhs.int16 == rhs.int16 && lhs.int8 == rhs.int8 && lhs.float == rhs.float && lhs.double == rhs.double
                && lhs.string == rhs.string
        }
    }

    static func !=(lhs: Keyed, rhs: Keyed) -> Bool {
        return !(lhs == rhs)
    }
}

class MsgPackEncoderTests: XCTestCase {

    func testEncodeSample() {
        let encoder = MessagePackEncoder()
        let sample = Sample(foo: 127, bar: "Sample", bazz: UInt32.max)
        let result = try! encoder.encode(sample)
        
        XCTAssertEqual(result, Data([0x83, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xce, 0xff, 0xff, 0xff, 0xff, 0xa3, 0x66, 0x6f, 0x6f, 0x7f, 0xa3, 0x62, 0x61, 0x72, 0xa6, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65]))
    }

    func testDecodeSample() {
        let decoder = MessagePackDecoder()
        let sample = Sample(foo: 127, bar: "Sample", bazz: UInt32.max)
        let result = try! decoder.decode(Sample.self,
                                         from: Data([0x83, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xce, 0xff, 0xff, 0xff, 0xff, 0xa3, 0x66, 0x6f, 0x6f, 0x7f, 0xa3, 0x62, 0x61, 0x72, 0xa6, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65]))

        XCTAssertEqual(result!, sample)
    }

    func testEncodeNested() {
        let encoder = MessagePackEncoder()
        let sample = Sample(foo: 127, bar: "Sample", bazz: UInt32.max)
        let nested = Nested(nested: "Nested", sample: sample)
        let result = try! encoder.encode(nested)

        XCTAssertEqual(result, Data([0x82, 0xa6, 0x6e, 0x65, 0x73, 0x74, 0x65, 0x64, 0xa6, 0x4e, 0x65, 0x73, 0x74, 0x65, 0x64, 0xa6, 0x73, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x83, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xce, 0xff, 0xff, 0xff, 0xff, 0xa3, 0x66, 0x6f, 0x6f, 0x7f, 0xa3, 0x62, 0x61, 0x72, 0xa6, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65]))
    }

    func testDecodeNested() {
        let decoder = MessagePackDecoder()
        let sample = Sample(foo: 127, bar: "Sample", bazz: UInt32.max)
        let nested = Nested(nested: "Nested", sample: sample)
        let result = try! decoder.decode(Nested.self, from: Data([0x82, 0xa6, 0x6e, 0x65, 0x73, 0x74, 0x65, 0x64, 0xa6, 0x4e, 0x65, 0x73, 0x74, 0x65, 0x64, 0xa6, 0x73, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x83, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xce, 0xff, 0xff, 0xff, 0xff, 0xa3, 0x66, 0x6f, 0x6f, 0x7f, 0xa3, 0x62, 0x61, 0x72, 0xa6, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65]))

        XCTAssertEqual(result!, nested)
    }

    func testEncodeNestedStruct() {
        let encoder = MessagePackEncoder()
        let nested = NestStruct(nest: "Outer", nested: NestStruct.Nest(nest: "Inner"))
        let result = try! encoder.encode(nested)

        XCTAssertEqual(result, Data([0x82, 0xa4, 0x6e, 0x65, 0x73, 0x74, 0xa5, 0x4f, 0x75, 0x74, 0x65, 0x72, 0xa6, 0x6e, 0x65, 0x73, 0x74, 0x65, 0x64, 0x81, 0xa4, 0x6e, 0x65, 0x73, 0x74, 0xa5, 0x49, 0x6e, 0x6e, 0x65, 0x72]))
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

    func testDecodeUnkeyedStruct() {
        let decoder = MessagePackDecoder()
        let unkeyed = Unkeyed(empty: nil, bool: false, uint: UInt.max, uint64: UInt64.max,
                              uint32: UInt32.max, uint16: UInt16.max, uint8: UInt8.max,
                              int: Int.min, int64: Int64.min, int32: Int32.min, int16: Int16.min,
                              int8: Int8.min, float: Float.infinity, double: Double.nan, string: "Unkeyed")
        let result = try! decoder.decode(Unkeyed.self,
                                         from: Data([0x9e, 0xc0, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xce, 0xff, 0xff, 0xff, 0xff, 0xcd, 0xff, 0xff, 0xcc, 0xff, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xd1, 0x80, 0x00, 0xd0, 0x80, 0xca, 0x7f, 0x80, 0x00, 0x00, 0xcb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7, 0x55, 0x6e, 0x6b, 0x65, 0x79, 0x65, 0x64]))

        XCTAssertEqual(result!, unkeyed)
    }

    func testEncodeKeyedStruct() {
        let encoder = MessagePackEncoder()
        let keyed = Keyed(empty: nil, bool: false, uint: UInt.max, uint64: UInt64.max,
                              uint32: UInt32.max, uint16: UInt16.max, uint8: UInt8.max,
                              int: Int.min, int64: Int64.min, int32: Int32.min, int16: Int16.min,
                              int8: Int8.min, float: Float.infinity, double: Double.nan, string: "Unkeyed")
        let result = try! encoder.encode(keyed)

        XCTAssertEqual(result, Data([0x8e, 0xa6, 0x75, 0x69, 0x6e, 0x74, 0x36, 0x34, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xa6, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xa7, 0x55, 0x6e, 0x6b, 0x65, 0x79, 0x65, 0x64, 0xa4, 0x62, 0x6f, 0x6f, 0x6c, 0xc2, 0xa6, 0x75, 0x69, 0x6e, 0x74, 0x33, 0x32, 0xce, 0xff, 0xff, 0xff, 0xff, 0xa6, 0x64, 0x6f, 0x75, 0x62, 0x6c, 0x65, 0xcb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa5, 0x69, 0x6e, 0x74, 0x31, 0x36, 0xd1, 0x80, 0x00, 0xa5, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0xca, 0x7f, 0x80, 0x00, 0x00, 0xa3, 0x69, 0x6e, 0x74, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa5, 0x75, 0x69, 0x6e, 0x74, 0x38, 0xcc, 0xff, 0xa5, 0x69, 0x6e, 0x74, 0x33, 0x32, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xa4, 0x75, 0x69, 0x6e, 0x74, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xa5, 0x69, 0x6e, 0x74, 0x36, 0x34, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa6, 0x75, 0x69, 0x6e, 0x74, 0x31, 0x36, 0xcd, 0xff, 0xff, 0xa4, 0x69, 0x6e, 0x74, 0x38, 0xd0, 0x80]))
    }

    func testDecodeKeyedStruct() {
        let decoder = MessagePackDecoder()
        let keyed = Keyed(empty: nil, bool: false, uint: UInt.max, uint64: UInt64.max,
                          uint32: UInt32.max, uint16: UInt16.max, uint8: UInt8.max,
                          int: Int.min, int64: Int64.min, int32: Int32.min, int16: Int16.min,
                          int8: Int8.min, float: Float.infinity, double: Double.nan, string: "Unkeyed")
        let result = try! decoder.decode(Keyed.self,
                                         from: Data([0x8e, 0xa6, 0x75, 0x69, 0x6e, 0x74, 0x36, 0x34, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xa6, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xa7, 0x55, 0x6e, 0x6b, 0x65, 0x79, 0x65, 0x64, 0xa4, 0x62, 0x6f, 0x6f, 0x6c, 0xc2, 0xa6, 0x75, 0x69, 0x6e, 0x74, 0x33, 0x32, 0xce, 0xff, 0xff, 0xff, 0xff, 0xa6, 0x64, 0x6f, 0x75, 0x62, 0x6c, 0x65, 0xcb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa5, 0x69, 0x6e, 0x74, 0x31, 0x36, 0xd1, 0x80, 0x00, 0xa5, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0xca, 0x7f, 0x80, 0x00, 0x00, 0xa3, 0x69, 0x6e, 0x74, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa5, 0x75, 0x69, 0x6e, 0x74, 0x38, 0xcc, 0xff, 0xa5, 0x69, 0x6e, 0x74, 0x33, 0x32, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xa4, 0x75, 0x69, 0x6e, 0x74, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xa5, 0x69, 0x6e, 0x74, 0x36, 0x34, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa6, 0x75, 0x69, 0x6e, 0x74, 0x31, 0x36, 0xcd, 0xff, 0xff, 0xa4, 0x69, 0x6e, 0x74, 0x38, 0xd0, 0x80]))

        XCTAssertEqual(result!, keyed)
    }

    func testEmptyStruct() {
        let empty = Empty()
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x80])

        XCTAssertEqual(data, result)
    }

    func testDecodeEmptyStruct() {
        let empty = Empty()
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Empty.self, from: Data([0x80]))

        XCTAssertEqual(result!, empty)
    }

    static var allTests = [
        ("testEncodeSample", testEncodeSample),
        ("testEncodeNested", testEncodeNested),
        ("testEncodeNestedStruct", testEncodeNestedStruct),
        ("testEncodeUnkeyedStruct", testEncodeUnkeyedStruct),
        ("testEncodeKeyedStruct", testEncodeKeyedStruct),
        ("testEmptyStruct", testEmptyStruct),
    ]
}
