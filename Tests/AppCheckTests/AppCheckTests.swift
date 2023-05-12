//
//  AppCheckTests.swift
//  
//
//  Created by Norikazu Muramoto on 2023/05/12.
//

import XCTest
import AsyncHTTPClient
import NIO
import NIOFoundationCompat
@testable import AppCheck

final class AppCheckTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppCheck() async throws {
        let token = ""
        let appCheck = AppCheck()
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let client = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
//        try await appCheck.validate(token: "", client: <#T##HTTPClient#>)

        try await client.shutdown()
        try await eventLoopGroup.shutdownGracefully()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
