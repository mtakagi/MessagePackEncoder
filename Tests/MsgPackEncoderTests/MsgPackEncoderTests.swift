import XCTest
@testable import MsgPackEncoder

struct Empty : Codable {
}

struct Sample : Codable {
    var foo : UInt8
    var bar : String
    var bazz : UInt32
}

class MsgPackEncoderTests: XCTestCase {
    func testEmptyStruct() {
        let empty = Empty()
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x80])

        XCTAssertEqual(data, result)
    }

    func testEmptyArray() {
        let empty : [Empty] = []
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(empty)
        let data = Data(bytes: [0x90])

        XCTAssertEqual(data, result)
    }

    func testBinary8Min() {
        let data = Data(count: 0)
        let result = Data(bytes: [0xc4, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testBinary8Max() {
        let data = Data(count: 0xff)
        let result = Data(bytes: [0xc4, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testBinary16Min() {
        let data = Data(count: 0x100)
        let result = Data(bytes: [0xc5, 0x01, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testBinary16Max() {
        let data = Data(count: 0xffff)
        let result = Data(bytes: [0xc5, 0xff, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testBinary32Min() {
        let data = Data(count: 0x10000)
        let result = Data(bytes: [0xc6, 0x00, 0x01, 0x00, 0x00]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testBinary32Max() {
        let data = Data(count: 0xffff_ffff)
        let result = Data(bytes: [0xc6, 0xff, 0xff, 0xff, 0xff]) + data
        let encoder = MessagePackEncoder()
        let encoded = try! encoder.encode(data)
        XCTAssertEqual(encoded, result)
    }

    func testBinaryOutOfRange() {
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

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let fuck = Sample(foo: 10, bar: "fuck", bazz: 10000)
        let encoder = MessagePackEncoder()
        let result = try! encoder.encode(fuck)
        print(result)
        try! result.write(to: URL(fileURLWithPath: "/Users/mtakagi/Desktop/fuck.msg"))
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
