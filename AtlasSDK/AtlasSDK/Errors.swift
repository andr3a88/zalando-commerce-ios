//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

public protocol AtlasErrorType: ErrorType {

    var localizedDescriptionKey: String { get }

}

public extension AtlasErrorType {

    var localizedDescriptionKey: String { return "\(self.dynamicType).message.\(self)" }

}

public enum AtlasConfigurationError: AtlasErrorType {

    case incorrectConfigServiceResponse
    case missingClientId
    @available( *, deprecated, message = "Sales channel should be taken from config service, when ready")
    case missingSalesChannel
    case missingCountryCode

}

public enum AtlasAPIError: AtlasErrorType {

    case noData
    case invalidResponseFormat
    case unauthorized

    case nsURLError(code: Int, details: String?)
    case http(status: HTTPStatus, details: String?)
    case backend(status: Int?, title: String?, details: String?)

    case checkoutFailed(addresses: [UserAddress]?, cartId: String?, error: ErrorType)

}
