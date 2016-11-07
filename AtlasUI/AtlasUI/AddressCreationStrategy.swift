//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

protocol AddressCreationStrategy {

    var addressFormCompletion: AddressFormCompletion? { get set }
    var availableTypes: [AddressCreationType] { get }

    func execute(checkout: AtlasCheckout)

}

extension AddressCreationStrategy {

    func execute(checkout: AtlasCheckout) {
        showActionSheet(availableTypes, checkout: checkout)
    }

    func showActionSheet(types: [AddressCreationType], checkout: AtlasCheckout) {
        let title = Localizer.string("addressListView.add.type.title")
        let countryCode = checkout.client.config.salesChannel.countryCode
        let emptyAddressViewModel = AddressFormViewModel(countryCode: countryCode)

        var buttonActions = types.map { type in
            ButtonAction(text: type.localizedTitleKey) { (UIAlertAction) in
                switch type {
                case .standard:
                    self.showAddressForm(.standardAddress, addressViewModel: emptyAddressViewModel, checkout: checkout)

                case .pickupPoint:
                    self.showAddressForm(.pickupPoint, addressViewModel: emptyAddressViewModel, checkout: checkout)

                case .addressBookImport(let strategy):
                    strategy.completion = { contactProperty in
                        if let addressViewModel = AddressFormViewModel(contactProperty: contactProperty, countryCode: countryCode) {
                            self.showAddressForm(.standardAddress, addressViewModel: addressViewModel, checkout: checkout)
                        } else {
                            UserMessage.displayError(AtlasCheckoutError.unclassified)
                        }
                    }
                    strategy.execute()
                }
            }
        }

        let cancelAction = ButtonAction(text: Localizer.string("button.general.cancel"), style: .Cancel, handler: nil)
        buttonActions.append(cancelAction)

        UserMessage.showActionSheet(title: title, actions: buttonActions)
    }

    func showAddressForm(addressType: AddressFormType, addressViewModel: AddressFormViewModel, checkout: AtlasCheckout) {
        let viewController = AddressFormViewController(addressType: addressType,
                                                       addressMode: .createAddress(addressViewModel: addressViewModel),
                                                       checkout: checkout,
                                                       completion: addressFormCompletion)

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .OverCurrentContext
        AtlasUIViewController.instance?.showViewController(navigationController, sender: nil)
    }

}
