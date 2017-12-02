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

extension UIntType : Encodable {
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
}

internal enum IntType {
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
}

extension IntType : Encodable {
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
}

class ArrayTests : XCTestCase {

    func testEmptyArray() {
        let empty : [Empty] = []
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x90])

        XCTAssertEqual(data, result)
    }

    func testEncodeBoolArray() {
        let encoder = MessagePackEncoder()
        let array : [Bool] = [true, false]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x92, 0xc3, 0xc2]))
    }

    func testEncodeNilArray() {
        let encoder = MessagePackEncoder()
        let array : [Empty?] = [Empty?](repeating: nil, count: 0xffff)
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0xdc, 0xff, 0xff]) + Data([UInt8](repeating: 0xc0, count: 0xffff)))
    }

    func testEncodePositiveArray() {
        let encoder = MessagePackEncoder()
        let array = [Int](repeating: 0x7f, count: 0x1_0000)
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0xdd, 0x00, 0x01, 0x00, 0x00]) + Data([UInt8](repeating: 0x7f, count: 0x1_0000)))
    }

    func testEncodeNegativeArray() {
        let encoder = MessagePackEncoder()
        let array = [Int](repeating: -1, count: 16)
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0xdc, 0x00, 0x10]) + Data([UInt8](repeating: 0xff, count: 16)))
    }

    func testEncodeStringArray() {
        let encoder = MessagePackEncoder()
        let array = ["foo", "bar", "bazz"]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x93, 0xa3, 0x66, 0x6f, 0x6f, 0xa3, 0x62, 0x61, 0x72, 0xa4, 0x62, 0x61, 0x7a, 0x7a]))
    }

    func testEncodeUIntArray() {
        let encoder = MessagePackEncoder()
        let array : [UIntType] = [.uint8(UInt8.max), .uint16(UInt16.max), .uint32(UInt32.max), .uint64(UInt64.max), .uint(UInt.max)]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x95, 0xcc, 0xff, 0xcd, 0xff, 0xff, 0xce, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    func testEncodeIntArray() {
        let encoder = MessagePackEncoder()
        let array : [IntType] = [.int8(Int8.min), .int16(Int16.min), .int32(Int32.min), .int64(Int64.min), .int(Int.min)]
        let result = try! encoder.encode(array)

        XCTAssertEqual(result, Data([0x95, 0xd0, 0x80, 0xd1, 0x80, 0x00, 0xd2, 0x80, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    }

    static var allTests = [
        ("testEmptyArray", testEmptyArray),
        ("testEncodeBoolArray", testEncodeBoolArray),
        ("testEncodeNilArray", testEncodeNilArray),
        ("testEncodePositiveArray", testEncodePositiveArray),
        ("testEncodeNegativeArray", testEncodeNegativeArray),
        ("testEncodeStringArray", testEncodeStringArray),
        ("testEncodeUIntArray", testEncodeUIntArray),
        ("testEncodeIntArray", testEncodeIntArray),
    ]
}


