//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import XCTest
import Nimble

@testable import ZalandoCommerceAPI

class JSONJsonsTests: JSONTestCase {

    func testJsons() {
        let jsons = json["jsons", "jsons"]
        let notJsons = json["jsons", "notJsons"]

        expect(jsons.jsons).toNot(beEmpty())
        expect(notJsons.jsons).to(beEmpty())
    }

}
