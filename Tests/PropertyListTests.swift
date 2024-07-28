import XCTest
@testable import scrub

final class PropertyListTests: XCTestCase {
    private var testDir: URL {
        FileManager.default.temporaryDirectory.appending(path: "scrubTests")
    }

    private var testPlist: URL {
        testDir.appending(path: "test.plist")
    }

    override func setUp() {
        do {
            try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: false)
        } catch {
            print(error.localizedDescription)
        }
    }

    func testWrite() throws {
        let testData = ["Test 1", "Test 2"]

        XCTAssertThrowsError(try PropertyList.handler.write(
            testData,
            to: testDir.appending(path: "invalidDir/test.plist"))
        )

        try PropertyList.handler.write(testData, to: testPlist)
    }

    func testRead() throws {
        try testWrite()
        _ = try PropertyList.handler.read([String].self, from: testPlist)
    }

    override func tearDown() {
        do {
            try FileManager.default.removeItem(atPath: testDir.path())
        } catch {
            print(error.localizedDescription)
        }
    }
}
