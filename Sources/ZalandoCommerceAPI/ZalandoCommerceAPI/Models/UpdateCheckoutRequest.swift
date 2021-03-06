//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation

// TODO: document it, please...

public struct UpdateCheckoutRequest {

    public let billingAddressId: AddressId?
    public let shippingAddressId: AddressId?
    public let coupons: [String]?

    public init(billingAddressId: AddressId? = nil, shippingAddressId: AddressId? = nil, coupons: [String]? = nil) {
        self.shippingAddressId = shippingAddressId
        self.billingAddressId = billingAddressId
        self.coupons = coupons
    }

}

extension UpdateCheckoutRequest: JSONRepresentable {

    private struct Keys {
        static let billingAddressId = "billing_address_id"
        static let shippingAddressId = "shipping_address_id"
        static let coupons = "coupons"
    }

    func toJSON() -> JSONDictionary {
        var result = [String: Any]()

        if let billingAddressId = billingAddressId, !billingAddressId.isEmpty {
            result[Keys.billingAddressId] = billingAddressId
        }

        if let shippingAddressId = shippingAddressId, !shippingAddressId.isEmpty {
            result[Keys.shippingAddressId] = shippingAddressId
        }

        if let coupons = coupons {
            result[Keys.coupons] = coupons
        }

        return result
    }
}
