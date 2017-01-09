//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import XCTest
import Nimble
import AtlasSDK

@testable import AtlasUI

class URLRequestTests: UITestCase {

    func testLanguageHeader() {
        let language = "fr"
        let request = URLRequest(url: URL(validURL: "http://zalando.de"), language: language)

        expect(request.allHTTPHeaderFields?["Accept-Language"]).to(contain("\(language);q=1.0"))
    }

    func testLanguageQueryString() {
        let language = "fr"
        let request = URLRequest(url: URL(validURL: "http://zalando.de"), language: language)

        let urlComponents = URLComponents(validURL: request.url!)
        expect(urlComponents.queryItems).to(contain(URLQueryItem(name: "lng", value: language)))
    }

    func testSalesChannelLanguageHeader() {
        let client = try! AtlasUI.shared().client
        let language = client.config.salesChannel.languageCode
        let request = URLRequest(url: URL(validURL: "http://zalando.de"), config: client.config)

        expect(request.allHTTPHeaderFields?["Accept-Language"]).to(contain("\(language);q=1.0"))
    }


}

