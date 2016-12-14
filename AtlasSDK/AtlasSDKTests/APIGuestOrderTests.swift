//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import Nimble

@testable import AtlasSDK

class APIGuestOrderTests: AtlasAPIClientBaseTests {

    func testCreateGuestOrder() {
        waitUntilAtlasAPIClientIsConfigured { done, client in
            let request = GuestOrderRequest(checkoutId: "CHECKOUT_ID", token: "TOKEN")
            client.createGuestOrder(request: request) { result in
                switch result {
                case .failure(let error):
                    fail(String(describing: error))
                case .success(let order):
                    expect(order.orderNumber).to(equal("10105083300694"))
                    expect(order.billingAddress.gender).to(equal(Gender.male))
                    expect(order.billingAddress.firstName).to(equal("John"))
                    expect(order.billingAddress.lastName).to(equal("Doe"))
                    expect(order.billingAddress.street).to(equal("Mollstr. 1"))
                    expect(order.billingAddress.zip).to(equal("10178"))
                    expect(order.billingAddress.city).to(equal("Berlin"))
                    expect(order.billingAddress.countryCode).to(equal("DE"))
                    expect(order.shippingAddress.gender).to(equal(Gender.male))
                    expect(order.shippingAddress.firstName).to(equal("John"))
                    expect(order.shippingAddress.lastName).to(equal("Doe"))
                    expect(order.shippingAddress.street).to(equal("Mollstr. 1"))
                    expect(order.shippingAddress.zip).to(equal("10178"))
                    expect(order.shippingAddress.city).to(equal("Berlin"))
                    expect(order.shippingAddress.countryCode).to(equal("DE"))
                    expect(order.grossTotal.amount).to(equal(10.45))
                    expect(order.grossTotal.currency).to(equal("EUR"))
                    expect(order.taxTotal.amount).to(equal(2.34))
                    expect(order.taxTotal.currency).to(equal("EUR"))
                }
                done()
            }
        }
    }

    func testGuestChecoutPaymentSelectionURL() {
        waitUntilAtlasAPIClientIsConfigured { done, client in
            let request = GuestPaymentSelectionRequest(customer: self.customerRequest, shippingAddress: self.addressRequest, billingAddress: self.addressRequest, cart: self.cartRequest)
            client.guestCheckoutPaymentSelectionURL(request: request) { result in
                switch result {
                case .failure(let error):
                    fail(String(describing: error))
                case .success(let url):
                    expect(url.absoluteString).to(equal("https://payment-gateway.kohle-integration.zalan.do/payment-method-selection-session/TOKEN/selection"))
                }
                done()
            }
        }
    }

}

extension APIGuestOrderTests {

    fileprivate var customerRequest: GuestCustomerRequest {
        return GuestCustomerRequest(email: "john.doe@zalando.de", subscribeNewsletter: false)
    }

    fileprivate var addressRequest: GuestAddressRequest {
        let address = OrderAddress(gender: .male,
                                   firstName: "John",
                                   lastName: "Doe",
                                   street: "Mollstr. 1",
                                   additional: nil,
                                   zip: "10178",
                                   city: "Berlin",
                                   countryCode: "DE",
                                   pickupPoint: nil)
        return GuestAddressRequest(address: address)
    }

    fileprivate var cartRequest: GuestCartRequest {
        let cartItemRequest = CartItemRequest(sku: "AD541L009-G11", quantity: 1)
        return GuestCartRequest(items: [cartItemRequest])
    }

    fileprivate var paymentRequest: GuestPaymentRequest {
        return GuestPaymentRequest(method: "PREPAYMENT", metadata: nil)
    }

}