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

    func testDecodeBinary8Min() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc4, 0x00]))
        XCTAssertEqual(result!, Data(count: 0))
    }

    func testEncodeBinary8Max() {
        let data = Data(count: 0xff)
        let result = Data(bytes: [0xc4, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeBinary8Max() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc4, 0xff]) + Data(count: 0xff))
        XCTAssertEqual(result!, Data(count: 0xff))
    }

    func testEncodeBinary16Min() {
        let data = Data(count: 0x100)
        let result = Data(bytes: [0xc5, 0x01, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeBinary16Min() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc5, 0x01, 0x00]) + Data(count: 0x100))
        XCTAssertEqual(result!, Data(count: 0x100))
    }

    func testEncodeBinary16Max() {
        let data = Data(count: 0xffff)
        let result = Data(bytes: [0xc5, 0xff, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeBinary16Max() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self, from: Data(bytes: [0xc5, 0xff, 0xff]) + Data(count: 0xffff))
        XCTAssertEqual(result!, Data(count: 0xffff))
    }

    func testEncodeBinary32Min() {
        let data = Data(count: 0x10000)
        let result = Data(bytes: [0xc6, 0x00, 0x01, 0x00, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testDecodeBinary32Min() {
        let decoder = MessagePackDecoder()
        let result = try! decoder.decode(Data.self,
                                         from: Data(bytes: [0xc6, 0x01, 0x00, 0x00, 0x00]) + Data(count: 0x10000))
        XCTAssertEqual(result!, Data(count: 0x10000))
    }

    func testEncodeBinary32Max() {
        let data = Data(count: 0xffff_ffff)
        let result = Data(bytes: [0xc6, 0xff, 0xff, 0xff, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

//    func testDecodeBinary32Max() {
//        let decoder = MessagePackDecoder()
//        let result = try! decoder.decode(Data.self,
//                                         from: Data(bytes: [0xc6, 0xff, 0xff, 0xff, 0xff])
//                                            + Data(count: 0xffffffff))
//        XCTAssertEqual(result!, Data(count: 0xffffffff))
//    }

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
        ("testDecodeBinary8Min", testDecodeBinary8Min),
        ("testEncodeBinary8Max", testEncodeBinary8Max),
        ("testDecodeBinary8Max", testDecodeBinary8Max),
        ("testEncodeBinary16Min", testEncodeBinary16Min),
        ("testDecodeBinary16Min", testDecodeBinary16Min),
        ("testEncodeBinary16Max", testEncodeBinary16Max),
        ("testDecodeBinary16Max", testDecodeBinary16Max),
        ("testEncodeBinary32Min", testEncodeBinary32Min),
        ("testDecodeBinary32Min", testDecodeBinary32Min),
        ("testEncodeBinary32Max", testEncodeBinary32Max),
        ("testEncodeBinaryOutOfRange", testEncodeBinaryOutOfRange),
    ]
}
