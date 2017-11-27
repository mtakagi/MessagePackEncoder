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

    func testEncodePositiveFixInt() {
        let encoder = MessagePackEncoder()

        for i in 0x00...0x0f {
            let result = try! encoder.encode(i)
            XCTAssertEqual(result, Data([UInt8(i)]))
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
