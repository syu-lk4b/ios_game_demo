import XCTest
@testable import AIDungeon

final class ResponseParserTests: XCTestCase {
    func testParseTradeTag() {
        let text = "当然可以交易！[TRADE: 生命药水, 50金币] 你要来一瓶吗？"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "当然可以交易！ 你要来一瓶吗？")
        XCTAssertEqual(result.actions.count, 1)
        if case .trade(let itemName, let cost) = result.actions[0] {
            XCTAssertEqual(itemName, "生命药水")
            XCTAssertEqual(cost, 50)
        } else {
            XCTFail("Expected trade action")
        }
    }

    func testParseHintTag() {
        let text = "我听说...[HINT: Boss弱火属性]...你可要小心。"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "我听说......你可要小心。")
        if case .hint(let hint) = result.actions[0] {
            XCTAssertEqual(hint, "Boss弱火属性")
        } else {
            XCTFail("Expected hint action")
        }
    }

    func testParseGiftTag() {
        let text = "拿着这个吧。[GIFT: 神秘钥匙]"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "拿着这个吧。")
        if case .gift(let itemName) = result.actions[0] {
            XCTAssertEqual(itemName, "神秘钥匙")
        } else {
            XCTFail("Expected gift action")
        }
    }

    func testParseMultipleTags() {
        let text = "[HINT: 小心陷阱] 来做个交易吧 [TRADE: 火焰卷轴, 30金币]"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.actions.count, 2)
    }

    func testParseNoTags() {
        let text = "你好，冒险者。这里很危险。"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "你好，冒险者。这里很危险。")
        XCTAssertTrue(result.actions.isEmpty)
    }
}
