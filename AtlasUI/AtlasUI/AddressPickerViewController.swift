//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

typealias AddressUpdatedHandler = (address: EquatableAddress) -> Void
typealias AddressDeletedHandler = (address: EquatableAddress) -> Void
typealias AddressSelectedHandler = (address: EquatableAddress) -> Void

final class AddressPickerViewController: UIViewController {

    internal var addressUpdatedHandler: AddressUpdatedHandler?
    internal var addressDeletedHandler: AddressDeletedHandler?
    internal var addressSelectedHandler: AddressSelectedHandler?
    internal var addressCreationStrategy: AddressCreationStrategy?

    internal lazy var tableviewDelegate: AddressListTableViewDelegate = {
        return AddressListTableViewDelegate(tableView: self.tableView,
                                            addresses: self.initialAddresses,
                                            selectedAddress: self.initialSelectedAddress,
                                            actionsHandler: self.actionsHandler)
    }()

    private let checkout: AtlasUI
    private let initialAddresses: [EquatableAddress]
    private let initialSelectedAddress: EquatableAddress?
    private lazy var actionsHandler: AddressActionsHandler = {
        return AddressActionsHandler(checkout: self.checkout, viewController: self)
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.registerReusableCell(AddressRowViewCell.self)
        tableView.registerReusableCell(AddAddressTableViewCell.self)
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()

    init(checkout: AtlasUI, initialAddresses: [EquatableAddress], initialSelectedAddress: EquatableAddress?) {
        self.checkout = checkout
        self.initialAddresses = initialAddresses
        self.initialSelectedAddress = initialSelectedAddress
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setEditing(false, animated: false)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

}

extension AddressPickerViewController: UIBuilder {

    func configureView() {
        view.addSubview(tableView)
        configureEditButton()
        configureTableView()

        navigationController?.navigationBar.accessibilityIdentifier = "address-picker-navigation-bar"
    }

    func configureConstraints() {
        tableView.fillInSuperView()
    }

    internal func configureEditButton() {
        if tableviewDelegate.addresses.isEmpty {
            setEditing(false, animated: false)
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = editButtonItem()
            navigationItem.rightBarButtonItem?.accessibilityIdentifier = "address-picker-right-button"
        }
    }

    private func configureTableView() {
        tableView.delegate = tableviewDelegate
        tableView.dataSource = tableviewDelegate
        tableView.reloadData()
    }

}
