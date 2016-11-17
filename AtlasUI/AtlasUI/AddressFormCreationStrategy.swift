//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

typealias AddressFormCreationStrategyCompletion = (AddressFormDataModel) -> Void

protocol AddressFormCreationStrategy {

    var localizedTitleKey: String { get }

    init(completion: AddressFormCreationStrategyCompletion)
    func execute()

}

extension AddressFormCreationStrategy {

    var localizedTitleKey: String {
        return "addressListView.add.type.\(self.dynamicType)"
    }

}
