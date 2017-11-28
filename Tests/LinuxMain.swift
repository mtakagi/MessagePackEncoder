import XCTest
@testable import MsgPackEncoderTests

XCTMain([
    testCase(MsgPackEncoderTests.allTests),
	testCase(BinaryTests.allTests),
	testCase(StringTests.allTests),
	testCase(IntTests.allTests),
])
