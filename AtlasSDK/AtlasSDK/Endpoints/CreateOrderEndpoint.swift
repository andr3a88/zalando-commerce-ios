//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

struct CreateOrderEndpoint: ConfigurableEndpoint {

    let serviceURL: NSURL
    let method: HTTPMethod = .POST
    let path = "orders"
    let contentType = "application/x.zalando.customer.order.create+json"
    let acceptedContentType = "application/x.zalando.customer.order.create.response+json"
    let parameters: [String: AnyObject]?

    let checkoutId: String

}