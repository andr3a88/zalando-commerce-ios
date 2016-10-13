//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

public protocol AtlasErrorType: ErrorType {

    var localizedTitleKey: String { get }
    var localizedMessageKey: String { get }

}

public extension AtlasErrorType {

    var localizedTitleKey: String { return "\(self.dynamicType).title.\(self)" }
    var localizedMessageKey: String { return "\(self.dynamicType).message.\(self)" }

}

public enum AtlasConfigurationError: AtlasErrorType {

    case incorrectConfigServiceResponse
    case missingClientId
    case missingSalesChannel

}

public enum AtlasAPIError: AtlasErrorType {

    case noData
    case noInternet
    case invalidResponseFormat
    case unauthorized

    case nsURLError(code: Int, details: String?)
    case http(status: HTTPStatus, details: String?)
    case backend(status: Int?, type: String?, title: String?, details: String?)

    case checkoutFailed(addresses: [UserAddress]?, cart: Cart?, error: ErrorType)

}

public enum AtlasCheckoutError: AtlasErrorType {

    case unclassified
    case outOfStock
    case missingAddress
    case priceChanged(newPrice: MoneyAmount)
    case paymentMethodNotAvailable
    case addressInvalid

}
