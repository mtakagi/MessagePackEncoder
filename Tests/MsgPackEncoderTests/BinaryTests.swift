//
//  BinaryTests.swift
//  MsgPackEncoderTests
//
//  Created by mtakagi on 2017/11/27.
//
// Testing idea is derived from https://github.com/a2/MessagePack.swift

import XCTest
@testable import MsgPackEncoder

class BinaryTests: XCTestCase {

    func testEncodeBinary8Min() {
        let data = Data(count: 0)
        let result = Data(bytes: [0xc4, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testEncodeBinary8Max() {
        let data = Data(count: 0xff)
        let result = Data(bytes: [0xc4, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testEncodeBinary16Min() {
        let data = Data(count: 0x100)
        let result = Data(bytes: [0xc5, 0x01, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testEncodeBinary16Max() {
        let data = Data(count: 0xffff)
        let result = Data(bytes: [0xc5, 0xff, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testEncodeBinary32Min() {
        let data = Data(count: 0x10000)
        let result = Data(bytes: [0xc6, 0x00, 0x01, 0x00, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testEncodeBinary32Max() {
        let data = Data(count: 0xffff_ffff)
        let result = Data(bytes: [0xc6, 0xff, 0xff, 0xff, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testEncodeBinaryOutOfRange() {
        do {
            let data = Data(count: 0x1_0000_0000)
            let encoder = MessagePackEncoder()
            _ = try encoder.encode(data)
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertNotNil(value)
            XCTAssertNotNil(context)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    static var allTests = [
        ("testEncodeBinary8Min", testEncodeBinary8Min),
        ("testEncodeBinary8Max", testEncodeBinary8Max),
        ("testEncodeBinary16Min", testEncodeBinary16Min),
        ("testEncodeBinary16Max", testEncodeBinary16Max),
        ("testEncodeBinary32Min", testEncodeBinary32Min),
        ("testEncodeBinary32Max", testEncodeBinary32Max),
        ("testEncodeBinaryOutOfRange", testEncodeBinaryOutOfRange),
        ]
}
