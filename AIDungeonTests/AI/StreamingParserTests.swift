import XCTest
@testable import AIDungeon

final class StreamingParserTests: XCTestCase {
    func testParseSingleSSELine() {
        let line = "data: {\"choices\":[{\"delta\":{\"content\":\"Hello\"}}]}"
        let result = StreamingParser.parseSSELine(line)
        XCTAssertEqual(result, "Hello")
    }

    func testParseDoneSignal() {
        let line = "data: [DONE]"
        let result = StreamingParser.parseSSELine(line)
        XCTAssertNil(result)
    }

    func testParseEmptyLine() {
        let result = StreamingParser.parseSSELine("")
        XCTAssertNil(result)
    }

    func testParseNonDataLine() {
        let result = StreamingParser.parseSSELine("event: message")
        XCTAssertNil(result)
    }

    func testParseLineWithNoContent() {
        let line = "data: {\"choices\":[{\"delta\":{}}]}"
        let result = StreamingParser.parseSSELine(line)
        XCTAssertNil(result)
    }
}
