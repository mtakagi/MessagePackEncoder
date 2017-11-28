//
//  IntTests.swift
//  MsgPackEncoderTests
//
//  Created by mtakagi on 2017/11/28.
//

import XCTest
@testable import MsgPackEncoder

class IntTests : XCTestCase {
    func testEncodePositiveFixInt() {
        let encoder = MessagePackEncoder()

        for i in 0x00...0x7f {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([UInt8(i)]))
        }
    }

    func testEncodeNegativeFixInt() {
        let encoder = MessagePackEncoder()
        let start = -32
        let end = -1

        for i in start...end {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([UInt8(truncatingIfNeeded: i)]))
        }
    }

    func testEncodeUInt8() {
        let encoder = MessagePackEncoder()
        let start : UInt8 = 0x80
        let end : UInt8 = 0xff

        for i in start...end {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xcc, i]))
        }
    }

    func testEncodeUInt16() {
        let encoder = MessagePackEncoder()
        let start : UInt16 = 0x100
        let end : UInt16 = 0xffff

        for i in start...end {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xcd, UInt8(truncatingIfNeeded: i >> 8), UInt8(truncatingIfNeeded: i)]))
        }
    }

    func testEncodeUInt32() {
        let encoder = MessagePackEncoder()
        let start : UInt32 = 0x10000
        let end : UInt32 = 0xffff_ffff
        var result = try! encoder.encode(start)
        XCTAssertEqual(result, Data([0xce,
                                     UInt8(truncatingIfNeeded: start >> 24), UInt8(truncatingIfNeeded: start >> 16),
                                     UInt8(truncatingIfNeeded: start >> 8), UInt8(truncatingIfNeeded: start)]))
        result = try! encoder.encode(end)
        XCTAssertEqual(result, Data([0xce,
                                     UInt8(truncatingIfNeeded: end >> 24), UInt8(truncatingIfNeeded: end >> 16),
                                     UInt8(truncatingIfNeeded: end >> 8), UInt8(truncatingIfNeeded: end)]))
    }

    func testEncodeUInt64() {
        let encoder = MessagePackEncoder()
        let start : UInt64 = 0x1_0000_0000
        let end : UInt64 = 0xffff_ffff_ffff_ffff
        var result = try! encoder.encode(start)
        XCTAssertEqual(result, Data([0xcf,
                                     UInt8(truncatingIfNeeded: start >> 56), UInt8(truncatingIfNeeded: start >> 48),
                                     UInt8(truncatingIfNeeded: start >> 40), UInt8(truncatingIfNeeded: start >> 32),
                                     UInt8(truncatingIfNeeded: start >> 24), UInt8(truncatingIfNeeded: start >> 16),
                                     UInt8(truncatingIfNeeded: start >> 8), UInt8(truncatingIfNeeded: start)]))
        result = try! encoder.encode(end)
        XCTAssertEqual(result, Data([0xcf,
                                     UInt8(truncatingIfNeeded: end >> 56), UInt8(truncatingIfNeeded: end >> 48),
                                     UInt8(truncatingIfNeeded: end >> 40), UInt8(truncatingIfNeeded: end >> 32),
                                     UInt8(truncatingIfNeeded: end >> 24), UInt8(truncatingIfNeeded: end >> 16),
                                     UInt8(truncatingIfNeeded: end >> 8), UInt8(truncatingIfNeeded: end)]))
    }

    func testEncodeInt8() {
        let encoder = MessagePackEncoder()

        for i in (-128)...(-33) {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xd0, UInt8(truncatingIfNeeded: i)]))
        }
    }

    func testEncodeInt16() {
        let encoder = MessagePackEncoder()

        for i in (Int16.min)..<Int16((Int8.min)) {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xd1, UInt8(truncatingIfNeeded: i >> 8), UInt8(truncatingIfNeeded: i)]))
        }

        for i in (Int16(Int8.max) + 1)...(Int16.max) {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xd1, UInt8(truncatingIfNeeded: i >> 8), UInt8(truncatingIfNeeded: i)]))
        }
    }

    func testEncodeInt32() {
        let encoder = MessagePackEncoder()
        let array = [Int32(Int16.min) - 1, Int32.min, Int32(Int16.max) + 1, Int32.max]

        for i in array {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xd2,
                                         UInt8(truncatingIfNeeded: i >> 24), UInt8(truncatingIfNeeded: i >> 16),
                                         UInt8(truncatingIfNeeded: i >> 8), UInt8(truncatingIfNeeded: i)]))
        }
    }

    func testEncodeInt64() {
        let encoder = MessagePackEncoder()
        let array = [Int64(Int32.min) - 1, Int64.min, Int64(Int32.max) + 1, Int64.max]

        for i in array {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([0xd3,
                                         UInt8(truncatingIfNeeded: i >> 56), UInt8(truncatingIfNeeded: i >> 48),
                                         UInt8(truncatingIfNeeded: i >> 40), UInt8(truncatingIfNeeded: i >> 32),
                                         UInt8(truncatingIfNeeded: i >> 24), UInt8(truncatingIfNeeded: i >> 16),
                                         UInt8(truncatingIfNeeded: i >> 8), UInt8(truncatingIfNeeded: i)]))
        }
    }

    static var allTests = [
        ("testEncodePositiveFixInt", testEncodePositiveFixInt),
        ("testEncodeNegativeFixInt", testEncodeNegativeFixInt),
        ("testEncodeUInt8", testEncodeUInt8),
        ("testEncodeUInt16", testEncodeUInt16),
        ("testEncodeUInt32", testEncodeUInt32),
        ("testEncodeUInt64", testEncodeUInt64),
        ("testEncodeInt8", testEncodeInt8),
        ("testEncodeInt16", testEncodeInt16),
        ("testEncodeInt32", testEncodeInt32),
        ("testEncodeInt64", testEncodeInt64),
    ]
}
