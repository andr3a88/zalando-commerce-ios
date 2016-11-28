//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

struct CheckoutSummaryViewModel {

    var dataModel: CheckoutSummaryDataModel {
        didSet {
            validate(against: oldValue)
        }
    }
    var layout: CheckoutSummaryLayout

}

extension CheckoutSummaryViewModel {

    fileprivate func validate(against oldDataModel: CheckoutSummaryDataModel) {
        checkPriceChange(oldDataModel: oldDataModel)
        checkPaymentMethod(oldDataModel: oldDataModel)
    }

    fileprivate func checkPriceChange(oldDataModel: CheckoutSummaryDataModel) {
        if oldDataModel.totalPrice != dataModel.totalPrice {
            UserMessage.displayError(AtlasCheckoutError.priceChanged(newPrice: dataModel.totalPrice))
        }
    }

    fileprivate func checkPaymentMethod(oldDataModel: CheckoutSummaryDataModel) {
        guard oldDataModel.paymentMethod != nil && dataModel.paymentMethod == nil else { return }
        UserMessage.displayError(AtlasCheckoutError.paymentMethodNotAvailable)
    }

}
