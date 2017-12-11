//
//  UInt8ArrayTests.swift
//  MsgPackEncoderPackageDescription
//
//  Created by mtakagi on 2017/12/02.
//

import XCTest
@testable import MsgPackEncoder

class UInt8ArrayTests : XCTestCase {

    func testEncodeUInt8Array8() {
        let data = [UInt8](repeating: 0, count: 0)
        let result = Data(bytes: [0xc4, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array8() {
        let data = [UInt8](repeating: 0, count: 0)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc4, 0x00]) + data)

        XCTAssertEqual(result!, Data(data))
    }

    func testEncodeUInt8Array8ToArray() {
        let data = [UInt8](repeating: 0, count: 0)
        let result = Data(bytes: [0b10010000]) + data
        let encoder = MessagePackEncoder()
        encoder.uint8ArrayEncodingStrategy = .array
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array8ToArray() {
        let data = [UInt8](repeating: 0, count: 0)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode([UInt8].self, from: Data(bytes: [0b10010000]) + data)

        XCTAssertEqual(result!, data)
    }

    func testEncodeUInt8Array8Max() {
        let data = [UInt8](repeating: 0, count: 0xff)
        let result = Data(bytes: [0xc4, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array8Max() {
        let data = [UInt8](repeating: 0, count: 0xff)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc4, 0xff]) + data)

        XCTAssertEqual(result!, Data(data))
    }

    func testEncodeUInt8Array16() {
        let data = [UInt8](repeating: 0, count: 0x100)
        let result = Data(bytes: [0xc5, 0x01, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array16() {
        let data = [UInt8](repeating: 0, count: 0x100)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc5, 0x01, 0x00]) + data)

        XCTAssertEqual(result!, Data(data))
    }

    func testEncodeUInt8Array16ToArray() {
        let data = [UInt8](repeating: 0, count: 0x100)
        let result = Data(bytes: [0xdc, 0x01, 0x00]) + data
        let encoder = MessagePackEncoder()
        encoder.uint8ArrayEncodingStrategy = .array
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array16ToArray() {
        let data = [UInt8](repeating: 0, count: 0x100)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode([UInt8].self, from: Data(bytes: [0xdc, 0x01, 0x00]) + data)

        XCTAssertEqual(result!, data)
    }

    func testEncodeUInt8Array32() {
        let data = [UInt8](repeating: 0, count: 0x10000)
        let result = Data(bytes: [0xc6, 0x00, 0x01, 0x00, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array32() {
        let data = [UInt8](repeating: 0, count: 0x10000)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc6, 0x00, 0x01, 0x00, 0x00]) + data)

        XCTAssertEqual(result!, Data(data))
    }

    func testEncodeUInt8Array32ToArray() {
        let data = [UInt8](repeating: 0, count: 0x10000)
        let result = Data(bytes: [0xdd, 0x00, 0x01, 0x00, 0x00]) + data
        let encoder = MessagePackEncoder()
        encoder.uint8ArrayEncodingStrategy = .array
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeUInt8Array32ToArray() {
        let data = [UInt8](repeating: 0, count: 0x10000)
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode([UInt8].self, from: Data(bytes: [0xdd, 0x00, 0x01, 0x00, 0x00]) + data)

        XCTAssertEqual(result!, data)
    }

    static var allTests = [
        ("testEncodeUInt8Array8", testEncodeUInt8Array8),
        ("testDecodeUInt8Array8", testDecodeUInt8Array8),
        ("testEncodeUInt8Array8ToArray", testEncodeUInt8Array8ToArray),
        ("testDecodeUInt8Array8ToArray", testDecodeUInt8Array8ToArray),
        ("testEncodeUInt8Array8Max", testEncodeUInt8Array8Max),
        ("testDecodeUInt8Array8Max", testDecodeUInt8Array8Max),
        ("testEncodeUInt8Array16", testEncodeUInt8Array16),
        ("testDecodeUInt8Array16", testDecodeUInt8Array16),
        ("testEncodeUInt8Array16ToArray", testEncodeUInt8Array16ToArray),
        ("testEncodeUInt8Array32", testEncodeUInt8Array32),
        ("testDecodeUInt8Array32", testDecodeUInt8Array32),
        ("testEncodeUInt8Array32ToArray", testEncodeUInt8Array32ToArray),
        ("testDecodeUInt8Array32ToArray", testDecodeUInt8Array32ToArray),
    ]
}
