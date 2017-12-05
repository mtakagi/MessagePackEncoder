//
//  FloatTests.swift
//  MsgPackEncoderTests
//
//  Created by mtakagi on 2017/11/30.
//

import XCTest
@testable import MsgPackEncoder

class FloatTests : XCTestCase {
    func testEncodeFloat() {
        let encoder = MessagePackEncoder()
        let floatArray : [Float] = [1.175e-38, -1.175e-38, 3.403e38, -3.403e38,
                                    Float.nan, Float.infinity, -Float.infinity,
                                    0.0, -0.0]

        for f in floatArray {
            let result = try! encoder.encode(f)
            let bitPattern = f.bitPattern

            XCTAssertEqual(result, Data([0xca,
                                         UInt8(truncatingIfNeeded: bitPattern >> 24), UInt8(truncatingIfNeeded: bitPattern >> 16),
                                         UInt8(truncatingIfNeeded: bitPattern >> 8), UInt8(truncatingIfNeeded: bitPattern)]))
        }
    }

    func testDecodeFloat() {
        let decoder = MessagePackDecoder()
        let floatArray : [Float] = [1.175e-38, -1.175e-38, 3.403e38, -3.403e38,
                                    Float.nan, Float.infinity, -Float.infinity,
                                    0.0, -0.0]

        for f in floatArray {
            let bitPattern = f.bitPattern
            let result = try! decoder.decode(Float.self, from: Data([0xca,
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 24),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 16),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 8),
                                                                     UInt8(truncatingIfNeeded: bitPattern)]))
            if f.isNaN {
                XCTAssertNotEqual(result!, f)
            } else {
                XCTAssertEqual(result!, f)
            }
        }
    }

    func testEncodeDouble() {
        let encoder = MessagePackEncoder()
        let floatArray : [Double] = [2.23e-308, -2.23e-308, 1.8e308, -1.8e308,
                                     Double.nan, Double.infinity, -Double.infinity,
                                     0.0, -0.0]
        for f in floatArray {
            let result = try! encoder.encode(f)
            let bitPattern = f.bitPattern

            XCTAssertEqual(result, Data([0xcb,
                                         UInt8(truncatingIfNeeded: bitPattern >> 56), UInt8(truncatingIfNeeded: bitPattern >> 48),
                                         UInt8(truncatingIfNeeded: bitPattern >> 40), UInt8(truncatingIfNeeded: bitPattern >> 32),
                                         UInt8(truncatingIfNeeded: bitPattern >> 24), UInt8(truncatingIfNeeded: bitPattern >> 16),
                                         UInt8(truncatingIfNeeded: bitPattern >> 8), UInt8(truncatingIfNeeded: bitPattern)]))
        }
    }

    func testDecodeDouble() {
        let decoder = MessagePackDecoder()
        let floatArray : [Double] = [2.23e-308, -2.23e-308, 1.8e308, -1.8e308,
                                     Double.nan, Double.infinity, -Double.infinity,
                                     0.0, -0.0]

        for f in floatArray {
            let bitPattern = f.bitPattern
            let result = try! decoder.decode(Double.self, from: Data([0xcb,
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 56),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 48),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 40),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 32),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 24),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 16),
                                                                     UInt8(truncatingIfNeeded: bitPattern >> 8),
                                                                     UInt8(truncatingIfNeeded: bitPattern)]))
            if f.isNaN {
                XCTAssertNotEqual(result!, f)
            } else {
                XCTAssertEqual(result!, f)
            }
        }
    }

    static var allTests = [
        ("testEncodeFloat", testEncodeFloat),
        ("testDecodeFloat", testDecodeFloat),
        ("testEncodeDouble", testEncodeDouble),
        ("testDecodeDouble", testDecodeDouble),
    ]
}
