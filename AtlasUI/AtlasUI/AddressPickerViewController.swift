//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

enum AddressType {
    case shipping
    case billing
}

typealias AddressSelectionCompletion = (pickedAddress: Addressable, pickedAddressType: AddressType) -> Void

final class AddressPickerViewController: UIViewController, CheckoutProviderType {

    internal var checkout: AtlasCheckout
    private let addressType: AddressType
    private let selectionCompletion: AddressSelectionCompletion

    private let tableView = UITableView()
    private var addresses: [Address] = []
    let tableviewDelegate: AddressListTableViewDelegate?

    var selectedAddress: Addressable? {
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
        self.setupTableView()
        fetchAddresses()
    }

    private func fetchAddresses() {
        checkout.client.fetchAddressList { [weak self] result in
            guard let strongSelf = self else { return }
            Async.main {
                switch result {
                case .failure(let error):
                    strongSelf.userMessage.show(error: error)
                case .success(let addressList):
                    strongSelf.addresses = addressList.addresses
                    strongSelf.tableviewDelegate?.addresses = addressList.addresses
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    func setupTableView() {

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.fillInSuperView()

        tableView.delegate = tableviewDelegate
        tableView.dataSource = tableviewDelegate
        tableView.registerReusableCell(AddressRowViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()

    }

}
