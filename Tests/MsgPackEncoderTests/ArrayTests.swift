//
//  ArrayTests.swift
//  MsgPackEncoderTests
//
//  Created by mtakagi on 2017/12/01.
//

import XCTest
@testable import MsgPackEncoder

internal enum UIntType {
    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
}

extension UIntType : Codable {
    func encode(to encoder: Encoder) throws {
        switch self {
        case .uint(let value):
            try value.encode(to: encoder)
        case .uint8(let value):
            try value.encode(to: encoder)
        case .uint16(let value):
            try value.encode(to: encoder)
        case .uint32(let value):
            try value.encode(to: encoder)
        case .uint64(let value):
            try value.encode(to: encoder)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try .uint(container.decode(UInt.self))
    }
}

extension UIntType {
    func rawValue() -> UInt64 {
        switch self {
        case .uint(let value):
            return UInt64(value)
        case .uint8(let value):
            return UInt64(value)
        case .uint16(let value):
            return UInt64(value)
        case .uint32(let value):
            return UInt64(value)
        case .uint64(let value):
            return value
        }
    }
}

extension UIntType : Equatable {
    static func ==(lhs: UIntType, rhs: UIntType) -> Bool {
        return lhs.rawValue() == rhs.rawValue()
    }
}

internal enum IntType {
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
}

extension IntType : Codable {
    func encode(to encoder: Encoder) throws {
        switch self {
        case .int(let value):
            try value.encode(to: encoder)
        case .int8(let value):
            try value.encode(to: encoder)
        case .int16(let value):
            try value.encode(to: encoder)
        case .int32(let value):
            try value.encode(to: encoder)
        case .int64(let value):
            try value.encode(to: encoder)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try .int(container.decode(Int.self))
    }
}

extension IntType {
    func rawValue() -> Int64 {
        switch self {
        case .int(let value):
            return Int64(value)
        case .int8(let value):
            return Int64(value)
        case .int16(let value):
            return Int64(value)
        case .int32(let value):
            return Int64(value)
        case .int64(let value):
            return value
        }
    }
}

extension IntType : Equatable {
    static func ==(lhs: IntType, rhs: IntType) -> Bool {
        return lhs.rawValue() == rhs.rawValue()
    }
}

class ArrayTests : XCTestCase {

    func testEmptyArray() {
        let empty : [Empty] = []
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x90])

        XCTAssertEqual(data, result)
    }

    func testDecodeEmptyArray() {
        let empty : [Empty] = []
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode([Empty].self, from: Data(bytes: [0x90]))

        XCTAssertEqual(result!, empty)
    }

    func testEncodeBoolArray() {
        let encoder = MessagePackEncoder()
        let array : [Bool] = [true, false]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x92, 0xc3, 0xc2]))
    }

    func testDecodeBoolArray() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode([Bool].self, from: Data([0x92, 0xc3, 0xc2]))

        XCTAssertEqual(result!, [true, false])
    }

    func testEncodeNilArray() {
        let encoder = MessagePackEncoder()
        let array : [Empty?] = [Empty?](repeating: nil, count: 0xffff)
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0xdc, 0xff, 0xff]) + Data([UInt8](repeating: 0xc0, count: 0xffff)))
    }

    func testDecodeNilArray() {
        let decoder = MessagePackDecoder()
        let array : [Empty?] = [Empty?](repeating: nil, count: 0xffff)
        let result = try! decoder.decode([Empty?].self,
                                         from: Data([0xdc, 0xff, 0xff]) + Data([UInt8](repeating: 0xc0, count: 0xffff)))

        XCTAssertTrue(result!.elementsEqual(array, by: {$0 == nil && $1 == nil}))
    }

    func testEncodePositiveArray() {
        let encoder = MessagePackEncoder()
        let array = [Int](repeating: 0x7f, count: 0x1_0000)
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0xdd, 0x00, 0x01, 0x00, 0x00]) + Data([UInt8](repeating: 0x7f, count: 0x1_0000)))
    }

    func testDecodePositiveArray() {
        let decoder = MessagePackDecoder()
        let array = [Int](repeating: 0x7f, count: 0x1_0000)
        let result = try! decoder.decode([Int].self,
                                         from: Data([0xdd, 0x00, 0x01, 0x00, 0x00])
                                            + Data([UInt8](repeating: 0x7f, count: 0x1_0000)))

        XCTAssertEqual(result!, array)
    }

    func testEncodeNegativeArray() {
        let encoder = MessagePackEncoder()
        let array = [Int](repeating: -1, count: 16)
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0xdc, 0x00, 0x10]) + Data([UInt8](repeating: 0xff, count: 16)))
    }

    func testDecodeNegativeArray() {
        let decoder = MessagePackDecoder()
        let array = [Int](repeating: -1, count: 16)
        let result = try! decoder.decode([Int].self,
                                         from: Data([0xdc, 0x00, 0x10])
                                            + Data([UInt8](repeating: 0xff, count: 16)))

        XCTAssertEqual(result!, array)
    }

    func testEncodeStringArray() {
        let encoder = MessagePackEncoder()
        let array = ["foo", "bar", "bazz"]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x93, 0xa3, 0x66, 0x6f, 0x6f, 0xa3, 0x62, 0x61, 0x72, 0xa4, 0x62, 0x61, 0x7a, 0x7a]))
    }

    func testDecodeStringArray() {
        let decoder = MessagePackDecoder()
        let array = ["foo", "bar", "bazz"]
        let result = try! decoder.decode([String].self,
                                         from: Data([0x93, 0xa3, 0x66, 0x6f, 0x6f, 0xa3, 0x62, 0x61, 0x72, 0xa4, 0x62, 0x61, 0x7a, 0x7a]))

        XCTAssertEqual(result!, array)
    }

    func testEncodeUIntArray() {
        let encoder = MessagePackEncoder()
        let array : [UIntType] = [.uint8(UInt8.max), .uint16(UInt16.max), .uint32(UInt32.max), .uint64(UInt64.max), .uint(UInt.max)]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x95, 0xcc, 0xff, 0xcd, 0xff, 0xff, 0xce, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    func testDecodeUIntArray() {
        let decoder = MessagePackDecoder()
        let array : [UIntType] = [.uint8(UInt8.max), .uint16(UInt16.max), .uint32(UInt32.max), .uint64(UInt64.max), .uint(UInt.max)]
        let result = try! decoder.decode([UIntType].self,
                                         from: Data([0x95, 0xcc, 0xff, 0xcd, 0xff, 0xff, 0xce, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))

        XCTAssertEqual(result!, array)
    }

    func testEncodeIntArray() {
        let encoder = MessagePackEncoder()
        let array : [IntType] = [.int8(Int8.min), .int16(Int16.min), .int32(Int32.min), .int64(Int64.min), .int(Int.min)]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x95, 0xd0, 0x80, 0xd1, 0x80, 0x00, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    }

    func testDecodeIntArray() {
        let decoder = MessagePackDecoder()
        let array : [IntType] = [.int8(Int8.min), .int16(Int16.min), .int32(Int32.min), .int64(Int64.min), .int(Int.min)]
        let result = try! decoder.decode([IntType].self,
                                         from: Data([0x95, 0xd0, 0x80, 0xd1, 0x80, 0x00, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))

        XCTAssertEqual(result!, array)
    }

    static var allTests = [
        ("testEmptyArray", testEmptyArray),
        ("testDecodeEmptyArray", testDecodeEmptyArray),
        ("testEncodeBoolArray", testEncodeBoolArray),
        ("testDecodeBoolArray", testDecodeBoolArray),
        ("testEncodeNilArray", testEncodeNilArray),
        ("testDecodeNilArray", testDecodeNilArray),
        ("testEncodePositiveArray", testEncodePositiveArray),
        ("testDecodePositiveArray", testDecodePositiveArray),
        ("testEncodeNegativeArray", testEncodeNegativeArray),
        ("testDecodeNegativeArray", testDecodeNegativeArray),
        ("testEncodeStringArray", testEncodeStringArray),
        ("testDecodeStringArray", testDecodeStringArray),
        ("testEncodeUIntArray", testEncodeUIntArray),
        ("testDecodeUIntArray", testDecodeUIntArray),
        ("testEncodeIntArray", testEncodeIntArray),
        ("testDecodeIntArray", testDecodeIntArray),
    ]
}


