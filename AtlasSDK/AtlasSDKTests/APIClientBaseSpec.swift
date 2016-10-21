//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

import Foundation
import Quick
import Nimble
import AtlasMockAPI

@testable import AtlasSDK

class APIClientBaseSpec: QuickSpec {

    let cartId = "CART_ID"
    let checkoutId = "CHECKOUT_ID"

    override class func setUp() {
        super.setUp()
        try! AtlasMockAPI.startServer()
    }

    override class func tearDown() {
        super.tearDown()
        try! AtlasMockAPI.stopServer()
    }

    private var clientOptions: Options {
        return Options(clientId: "atlas_Y2M1MzA",
                       salesChannel: "82fe2e7f-8c4f-4aa1-9019-b6bde5594456",
                       useSandbox: true,
                       interfaceLanguage: "de",
                       configurationURL: AtlasMockAPI.endpointURL(forPath: "/config"),
                       authorizationHandler: MockAuthorizationHandler())
    }

    func waitUntilAPIClientIsConfigured(actions: (done: () -> Void, client: APIClient) -> Void) {
        waitUntil(timeout: 10) { done in
            Atlas.configure(self.clientOptions) { result in
                switch result {
                case .failure(let error):
                    fail(String(error))
                    done()
                case .success(let client):
                    actions(done: done, client: client)
                }
            }
        }
    }

    func dataWithJSONObject(object: AnyObject) -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(object, options: [])
    }

    func mockedAPIClient(forURL url: NSURL, options: Options? = nil, data: NSData?,
                         status: HTTPStatus, errorCode: Int? = nil) -> APIClient {
        let apiURL = AtlasMockAPI.endpointURL(forPath: "/")
        let loginURL = AtlasMockAPI.endpointURL(forPath: "/oauth2/authorize")
        let callback = "http://de.zalando.atlas.AtlasCheckoutDemo/redirect"

        let dict: [String: AnyObject] = ["sales-channels": [["locale": "de_DE",
            "sales-channel": "82fe2e7f-8c4f-4aa1-9019-b6bde5594456", "toc_url": "https://www.zalando.de/agb/"]],
            "atlas-catalog-api": ["url": apiURL.absoluteString!],
            "atlas-checkout-api": [ "url": apiURL.absoluteString!,
                "payment": [ "selection-callback": callback, "third-party-callback": callback]],
            "oauth2-provider": ["url": loginURL.absoluteString!]]
        let json = JSON(dict)

        let config = Config(json: json, options: options ?? clientOptions)!
        var client = APIClient(config: config)

        var error: NSError? = nil
        if let errorCode = errorCode {
            error = NSError(domain: "NSURLErrorDomain", code: errorCode, userInfo: nil)
        }

        client.urlSession = URLSessionMock(data: data,
                                           response: NSHTTPURLResponse(URL: url, statusCode: status.rawValue),
                                           error: error)

        return client
    }

}
