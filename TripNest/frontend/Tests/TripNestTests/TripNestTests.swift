import XCTest
@testable import TripNest

final class TripNestTests: XCTestCase {
    func testDashboardViewInitialization() throws {
        let dashboardView = DashboardView()
        XCTAssertNotNil(dashboardView)
    }
}
