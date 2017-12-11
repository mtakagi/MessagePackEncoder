//
//  SingleValueTests.swift
//  MsgPackEncoderPackageDescription
//
//  Created by mtakagi on 2017/12/02.
//

import XCTest
@testable import MsgPackEncoder

class SingleValueTests : XCTestCase {

    func testEncodeNil() {
        let value : Int? = nil
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(value)

        XCTAssertEqual(result, Data([0xc0]))
    }

    func testDecodeNil() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Sample?.self, from: Data([0xc0]))

        XCTAssertNil(result!)
    }

    func testEncodeTrue() {
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(true)

        XCTAssertEqual(result, Data([0xc3]))
    }

    func testDecodeTrue() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Bool.self, from: Data([0xc3]))

        XCTAssertEqual(result!, true)
    }

    func testEncodeFalse() {
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(false)

        XCTAssertEqual(result, Data([0xc2]))
    }

    func testDecodeFalse() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Bool.self, from: Data([0xc2]))

        XCTAssertEqual(result!, false)
    }

    func testEncodeTimestamp32Min() {
        let encoder = MessagePackEncoder()
        let date = Date(timeIntervalSince1970: 0.0)
        let result = try! encoder.encode(date)

        XCTAssertEqual(result, Data([0xd6, 0xff, 0x00, 0x00, 0x00, 0x00]))
    }

    func testDecodeTimestamp32Min() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Date.self, from: Data([0xd6, 0xff, 0x00, 0x00, 0x00, 0x00]))

        XCTAssertEqual(result!, Date(timeIntervalSince1970: 0.0))
    }

    func testEncodeTimestamp32Max() {
        let encoder = MessagePackEncoder()
        let date = Date(timeIntervalSince1970: Double(UInt32.max))
        let result = try! encoder.encode(date)

        XCTAssertEqual(result, Data([0xd6, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    func testDecodeTimestamp32Max() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Date.self, from: Data([0xd6, 0xff, 0xff, 0xff, 0xff, 0xff]))

        XCTAssertEqual(result!, Date(timeIntervalSince1970: TimeInterval(UInt32.max)))
    }

    static var allTests = [
        ("testEncodeNil", testEncodeNil),
        ("testDecodeNil", testDecodeNil),
        ("testEncodeTrue", testEncodeTrue),
        ("testDecodeTrue", testDecodeTrue),
        ("testEncodeFalse", testEncodeFalse),
        ("testDecodeFalse", testDecodeFalse),
        ("testEncodeTimestamp32Min", testEncodeTimestamp32Min),
        ("testDecodeTimestamp32Min", testDecodeTimestamp32Min),
        ("testEncodeTimestamp32Max", testEncodeTimestamp32Max),
        ("testDecodeTimestamp32Max", testDecodeTimestamp32Max),
    ]
}
