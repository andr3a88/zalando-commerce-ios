//
//   Copyright © 2016 Zalando SE. All rights reserved.
//

import XCTest
import Nimble
import AtlasSDK

@testable import AtlasUI

class URLRequestTests: UITestCase {

    func testLanguageHeader() {
        let language = "fr"
        let request = URLRequest(url: URL(validURL: "http://zalando.de"), language: language)

        guard let languageField = request.allHTTPHeaderFields?["Accept-Language"] else {
            fail("No Accept-Language header")
            return
        }

        expect(languageField).to(contain("\(language);q=1.0"))
    }

    func testSalesChannelLanguageHeader() {
        let client = try! AtlasUI.shared().client
        let language = client.salesChannelLanguage
        let request = URLRequest(url: URL(validURL: "http://zalando.de"), config: client.config)

        guard let languageField = request.allHTTPHeaderFields?["Accept-Language"] else {
            fail("No Accept-Language header")
            return
        }

        expect(languageField).to(contain("\(language);q=1.0"))
    }


}

