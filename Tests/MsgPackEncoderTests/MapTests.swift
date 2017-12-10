//
//  MapTests.swift
//  MsgPackEncoderPackageDescription
//
//  Created by mtakagi on 2017/12/01.
//

import XCTest
@testable import MsgPackEncoder

class MapTests : XCTestCase {

    func testEncodeEmptyMap() {
        let encoder = MessagePackEncoder()
        let map : [String:String] = [:]
        let result = try! encoder.encode(map)

        XCTAssertEqual(result, Data([0x80]))
    }

    func testEncodeStringMap() {
        let encoder = MessagePackEncoder()
        let map = ["foo" : "hoge", "bar" : "fuga", "bazz" : "piyo"]
        let result = try! encoder.encode(map)

        XCTAssertEqual(result, Data([0x83, 0xa4, 0x62, 0x61, 0x7a, 0x7a, 0xa4, 0x70, 0x69, 0x79, 0x6f, 0xa3, 0x62, 0x61, 0x72, 0xa4, 0x66, 0x75, 0x67, 0x61, 0xa3, 0x66, 0x6f, 0x6f, 0xa4, 0x68, 0x6f, 0x67, 0x65]))
    }

    func testEncodeBoolMap() {
        let encoder = MessagePackEncoder()
        let map = ["true" : true, "false" : false]
        let result = try! encoder.encode(map)

        XCTAssertEqual(result, Data([0x82, 0xa4, 0x74, 0x72, 0x75, 0x65, 0xc3, 0xa5, 0x66, 0x61, 0x6c, 0x73, 0x65, 0xc2]))
    }

    static var allTests = [
        ("testEncodeEmptyMap", testEncodeEmptyMap),
        ("testEncodeStringMap", testEncodeStringMap),
        ("testEncodeBoolMap", testEncodeBoolMap),
    ]
}
