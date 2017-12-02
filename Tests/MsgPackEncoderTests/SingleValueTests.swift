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
        ("testEncodeNil", testEncodeNil),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTimestamp32Min", testEncodeTimestamp32Min),
        ("testEncodeTimestamp32Max", testEncodeTimestamp32Max),
    ]
}
