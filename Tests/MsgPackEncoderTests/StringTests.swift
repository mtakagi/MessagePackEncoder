//
//  StringTests.swift
//  MsgPackEncoderTests
//
//  Created by mtakagi on 2017/11/27.
//
// Testing idea is derived from https://github.com/a2/MessagePack.swift

import XCTest
@testable import MsgPackEncoder

class StringTests : XCTestCase {

    func testEncodeFixStr() {
        let str = "🍎"
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(str)

        XCTAssertEqual(result, Data([UInt8(0b1010_0000 | 4)]) + str.data(using: .utf8)!)
    }

    func testEncodeStr8Min() {
        let str = String(repeating: "🍎", count: 0x20 / 4)
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(str)

        XCTAssertEqual(result, Data([0xd9, 0x20]) + str.data(using: .utf8)!)
    }

    func testEncodeStr8Max() {
        let str = String(repeating: "☃", count: 0xff / 3)
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(str)

        XCTAssertEqual(result, Data([0xd9, 0xff]) + str.data(using: .utf8)!)
    }

    func testEncodeStr16Min() {
        let str = String(repeating: "🍎", count: 0x100 / 4)
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(str)

        XCTAssertEqual(result, Data([0xda, 0x01, 0x00]) + str.data(using: .utf8)!)
    }

    func testEncodeStr16Max() {
        let str = String(repeating: "☃", count: 0xffff / 3)
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(str)

        XCTAssertEqual(result, Data([0xda, 0xff, 0xff]) + str.data(using: .utf8)!)
    }

    func testEncodeStr32Min() {
        let str = String(repeating: "🍎", count: 0x10000 / 4)
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(str)

        XCTAssertEqual(result, Data([0xdb, 0x00, 0x01, 0x00, 0x00]) + str.data(using: .utf8)!)
    }

    // FIXME: More efficient
//    func testEncodeStr32Max() {
//        let str = String(repeating: "☃", count: 0xffff_ffff / 3)
//        let encoder = MessagePackEncoder()
//        let result = try! encoder.encode(str)
//
//        XCTAssertEqual(result, Data([0xdb, 0xff, 0xff, 0xff, 0xff]) + str.data(using: .utf8)!)
//    }
//
//    func testEncodeStrOutOfRange() {
//        do {
//            let str = String(repeating: "🍎", count: 0x1_0000_0000 / 4)
//            let encoder = MessagePackEncoder()
//            _ = try encoder.encode(str)
//        } catch EncodingError.invalidValue(let value, let context) {
//            XCTAssertNotNil(value)
//            XCTAssertNotNil(context)
//        } catch let e {
//            XCTFail(e.localizedDescription)
//        }
//    }

    static var allTests = [
        ("testEncodeFixStr", testEncodeFixStr),
        ("testEncodeStr8Min", testEncodeStr8Min),
        ("testEncodeStr8Max", testEncodeStr8Max),
        ("testEncodeStr16Min", testEncodeStr16Min),
        ("testEncodeStr16Max", testEncodeStr16Max),
        ("testEncodeStr32Min", testEncodeStr32Min),
//        ("testEncodeStr32Max", testEncodeStr32Max),
//        ("testEncodeStrOutOfRange", testEncodeStrOutOfRange),
        ]
}
