//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import Nimble
import AtlasMockAPI

@testable import AtlasSDK

class AtlasAPIClientErrorsTests: AtlasAPIClientBaseTests {

    let clientURL = URL(validURL: "https://atlas-sdk.api/api/any_endpoint")

    func testNoDataResponse() {
        let status = HTTPStatus.ok
        let api = mockedAtlasAPI(forURL: clientURL, data: nil, status: status)

        waitUntil(timeout: 10) { done in
            api.customer { result in
                defer { done() }
                guard case let .failure(error, _) = result else {
                    return fail("Should emit \(APIError.noData)")
                }

                expect("\(error)") == "\(APIError.noData)"
            }
        }
    }

    func testUnauthenticatedRequest() {
        let status = HTTPStatus.unauthorized
        let json: [String: Any] = ["type": "http://httpstatus.es/401",
                                   "title": "unauthorized",
                                   "status": status.rawValue,
                                   "detail": "Full authentication is required to access this resource"]

        let errorResponse = data(withJSONObject: json)
        let api = mockedAtlasAPI(forURL: clientURL, options: Options.forTests(), data: errorResponse, status: status)

        waitUntil(timeout: 10) { done in
            api.customer { result in
                defer { done() }
                switch result {
                case .failure(let error, _):
                    switch error {
                    case APIError.unauthorized: break
                    default: fail("\(error) should be unauthorized")
                    }
                default: fail("\(result) should be failure")
                }
            }
        }
    }

    func testBackendError() {
        let status = HTTPStatus.forbidden
        let json: [String: Any] = ["type": "http://httpstatus.es/401", "title": "unauthorized",
                                   "status": status.rawValue, "detail": ""]

        let errorResponse = data(withJSONObject: json)
        let api = mockedAtlasAPI(forURL: clientURL, data: errorResponse, status: status)

        waitUntil(timeout: 10) { done in
            api.customer { result in
                defer { done() }
                guard case let .failure(error, _) = result,
                    case let APIError.backend(errorStatus, type, title, details) = error else {
                        return fail("Should emit APIError.backend")
                }

                expect(errorStatus) == status.rawValue
                expect(type) == json["type"] as? String
                expect(title) == json["title"] as? String
                expect(details) == json["detail"] as? String
            }
        }
    }

    func testNSURLDomainError() {
        let api = mockedAtlasAPI(forURL: clientURL,
                                          data: nil,
                                          status: .unauthorized,
                                          errorCode: NSURLErrorBadURL)

        waitUntil(timeout: 10) { done in
            api.customer { result in
                defer { done() }
                guard case let .failure(error, _) = result,
                    case let APIError.nsURLError(code, details) = error else {
                        return fail("Should emit APIError.nsURLError")
                }

                expect(code) == NSURLErrorBadURL
                expect(details).to(contain("The operation couldn’t be completed"))
            }
        }
    }

    func testMangledJSON() {
        let errorStatus = HTTPStatus.serviceUnavailable
        let errorResponse = "Some text error".data(using: String.Encoding.utf8)
        let api = mockedAtlasAPI(forURL: clientURL, data: errorResponse, status: errorStatus)

        waitUntil(timeout: 10) { done in
            api.customer { result in
                defer { done() }
                guard case let .failure(error, _) = result,
                    case let APIError.http(status, _) = error else {
                        return fail("Should emit APIError.http")
                }

                expect(status) == errorStatus.rawValue
            }
        }
    }

}
