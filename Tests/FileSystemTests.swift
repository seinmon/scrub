import XCTest
@testable import scrub

final class FileSystemTests: XCTestCase {


//    func testInit() throws {
//
//    }
//
//    func testCreateDirectory() throws {
//
//    }

    func testScrubDirectoryURL() throws {
        for dir in FileSystem.ScrubDirectory.allCases {
            XCTAssertEqual(
                dir.url,
                FileManager.default.homeDirectoryForCurrentUser.appending(path: dir.rawValue)
            )
        }
    }

    func testPath() throws {
        let testPath = "/Library"

        XCTAssertEqual(FileManager.default.homeDirectoryForCurrentUser.appending(path: testPath),
                       FileSystem.path(testPath, relativeToCurrentUserHome: true))

        XCTAssertEqual(URL(filePath: testPath),
                       FileSystem.path(testPath, relativeToCurrentUserHome: false))
    }
}
