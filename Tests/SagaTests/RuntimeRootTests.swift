import Foundation
@testable import Saga
import SagaPathKit
import XCTest

final class RuntimeRootTests: XCTestCase {
  func testExplicitRootBypassesSourceDiscovery() throws {
    var io = FileIO.mock
    io.resolveSwiftPackageFolder = { _ in
      throw NSError(domain: "Unexpected source discovery", code: 1)
    }
    let saga = try Saga(input: "content", output: "deploy", fileIO: io,
                        originFilePath: "/missing/checkout/Sources/main.swift", root: "/site")
    XCTAssertEqual(saga.rootPath, "/site")
    XCTAssertEqual(saga.inputPath, "/site/content")
    XCTAssertEqual(saga.outputPath, "/site/deploy")
  }

  func testExplicitRootPreservesAbsolutePaths() throws {
    let saga = try Saga(input: "/content", output: "/output", fileIO: .mock, root: "/site")
    XCTAssertEqual(saga.inputPath, "/content")
    XCTAssertEqual(saga.outputPath, "/output")
  }

  func testDefaultStillDiscoversSourcePackage() throws {
    let saga = try Saga(input: "content", fileIO: .mock)
    XCTAssertEqual(saga.rootPath, "root")
    XCTAssertEqual(saga.inputPath, "root/content")
    XCTAssertEqual(saga.outputPath, "root/deploy")
  }
}
