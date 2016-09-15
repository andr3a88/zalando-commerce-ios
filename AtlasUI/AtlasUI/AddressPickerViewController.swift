//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

enum AddressType {
    case shipping
    case billing
}

typealias AddressSelectionCompletion = (pickedAddress: EquatableAddress, pickedAddressType: AddressType) -> Void
typealias CreateAddressHandler = Void -> Void
typealias UpdateAddressHandler = (address: EquatableAddress) -> Void

final class AddressPickerViewController: UIViewController, CheckoutProviderType {

    internal var checkout: AtlasCheckout
    private let addressType: AddressType
    private let selectionCompletion: AddressSelectionCompletion

    private let tableView = UITableView()
    private var addresses: [UserAddress] = [] {
        didSet {
            tableviewDelegate?.addresses = addresses
            tableView.reloadData()
        }
    }
    let tableviewDelegate: AddressListTableViewDelegate?

    var selectedAddress: EquatableAddress? {
        didSet {
            tableviewDelegate?.selectedAddress = selectedAddress
        }
    }

    init(checkout: AtlasCheckout, addressType: AddressType,
        addressSelectionCompletion: AddressSelectionCompletion) {
            self.checkout = checkout
            self.addressType = addressType
            selectionCompletion = addressSelectionCompletion
            tableviewDelegate = AddressListTableViewDelegate(checkout: checkout,
                addressType: addressType, addressSelectionCompletion: selectionCompletion)

            super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        switch addressType {
        case .billing:
            self.title = "Billing Address"
        case .shipping:
            self.title = "Shipping Address"
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController?.navigationBar.accessibilityIdentifier = "address-picker-navigation-bar"
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "address-picker-right-button"

        setupTableView()
        fetchAddresses()
        configureTableviewDelegate()
    }

    private func configureTableviewDelegate() {
        configureCreateAddress()
        configureUpdateAddress()
    }

    private func fetchAddresses() {
        checkout.client.addresses { [weak self] result in
            guard let strongSelf = self else { return }
            Async.main {
                switch result {
                case .failure(let error):
                    strongSelf.userMessage.show(error: error)
                case .success(let addresses):
                    strongSelf.addresses = addresses
                }
            }
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    func setupTableView() {
        tableView.fillInSuperView()

        tableView.delegate = tableviewDelegate
        tableView.dataSource = tableviewDelegate
        tableView.registerReusableCell(AddressRowViewCell.self)
        tableView.registerReusableCell(AddAddressTableViewCell.self)
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()

    }

}

extension AddressPickerViewController {

    private func configureCreateAddress() {
        tableviewDelegate?.createAddressHandler = { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.addressType == .shipping else {
                strongSelf.showCreateAddress(.StandardAddress)
                return
            }

            let title = strongSelf.loc("Address.Add.type.title")
            let standardAction = ButtonAction(text: strongSelf.loc("Address.Add.type.standard"), style: .Default) { (UIAlertAction) in
                strongSelf.showCreateAddress(.StandardAddress)
            }
            let pickupPointAction = ButtonAction(text: strongSelf.loc("Address.Add.type.pickupPoint"), style: .Default) { (UIAlertAction) in
                strongSelf.showCreateAddress(.PickupPoint)
            }
            let cancelAction = ButtonAction(text: strongSelf.loc("Cancel"), style: .Cancel, handler: nil)

            strongSelf.userMessage.show(title: title,
                                        message: nil,
                                        actions: standardAction, pickupPointAction, cancelAction,
                                        preferredStyle: .ActionSheet)
        }
    }

    private func configureUpdateAddress() {
        tableviewDelegate?.updateAddressHandler = { [weak self] (address) in
            self?.showUpdateAddress(address)
        }
    }

    private func showCreateAddress(addressType: EditAddressType) {
        showEditAddressViewController(addressType, address: nil) { [weak self] editAddressViewModel in
            guard let request = CreateAddressRequest(addressViewModel: editAddressViewModel) else { return }
            self?.checkout.client.createAddress(request) { result in
                guard let strongSelf = self else { return }
                Async.main {
                    switch result {
                    case .failure(let error):
                        strongSelf.userMessage.show(error: error)
                    case .success(let address):
                        strongSelf.addresses.append(address)
                    }
                }
            }
        }
    }

    private func showUpdateAddress(address: EquatableAddress) {
        let addressType: EditAddressType = address.pickupPoint == nil ? .StandardAddress : .PickupPoint
        showEditAddressViewController(addressType, address: address) { [weak self] editAddressViewModel in
            guard let request = UpdateAddressRequest(addressViewModel: editAddressViewModel) else { return }
            self?.checkout.client.updateAddress(address.id, request: request) { result in
                guard let strongSelf = self else { return }
                Async.main {
                    switch result {
                    case .failure(let error):
                        strongSelf.userMessage.show(error: error)
                    case .success(let address):
                        let idx = strongSelf.addresses.indexOf { $0 == address }
                        if let addressIdx = idx {
                            strongSelf.addresses[addressIdx] = address
                        }
                    }
                }
            }
        }
    }

    private func showEditAddressViewController(type: EditAddressType, address: EquatableAddress?, completion: EditAddressCompletion) {
        let viewController = EditAddressViewController(addressType: type, checkout: checkout, address: address, completion: completion)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .OverCurrentContext
        self.navigationController?.showViewController(navigationController, sender: nil)
    }

}
