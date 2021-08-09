    import XCTest
    @testable import BlePipe

    final class BlePipeTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            var found = 0
            let bps = BPScanner()
            bps.discoverClosure = { discovery in
                print(discovery.displayName)
                found += 1
            }
            
            bps.filterClosure = nil
            
            bps.startWith(duration: 10)
            
            waitForExpectations(timeout: 20) { error in
                print(error)
            }
//            XCTAssertEqual(BlePipe().text, "Hello, World!")
        }
    }
