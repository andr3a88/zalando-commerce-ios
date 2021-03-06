//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import UIKit
import ZalandoCommerceAPI

protocol CheckoutSummaryEditProductDataSource: class {

    var checkoutContainer: CheckoutContainerView { get }
    var selectedArticle: SelectedArticle { get }

}

protocol CheckoutSummaryEditProductDelegate: class {

    func updated(selectedArticle: SelectedArticle)

}

class CheckoutSummaryEditProductStackView: UIStackView {

    let sizeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: 0x848484), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: UIFontWeightLight)
        button.setImage(UIImage(named: "selection_arrow", bundledWith: CheckoutSummaryEditProductStackView.self), for: .normal)
        return button
    }()

    let sizeQuantitySeparatorView: BorderView = {
        let view = BorderView()
        view.rightBorder = true
        view.borderColor = UIColor(hex: 0xE5E5E5)
        return view
    }()

    let quantityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: 0x848484), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: UIFontWeightLight)
        button.setImage(UIImage(named: "selection_arrow", bundledWith: CheckoutSummaryEditProductStackView.self), for: .normal)
        return button
    }()

    weak var dataSource: CheckoutSummaryEditProductDataSource?
    weak var delegate: CheckoutSummaryEditProductDelegate?

    func displayInitialSizes() {
        guard let selectedArticle = dataSource?.selectedArticle, let checkoutContainer = dataSource?.checkoutContainer else { return }
        checkoutContainer.displaySizes(selectedArticle: selectedArticle,
                                       animated: false,
                                       arrowHandler: updateArrow,
                                       completion: sizeSelected)
    }

    dynamic fileprivate func sizeButtonTapped() {
        guard let selectedArticle = dataSource?.selectedArticle, let checkoutContainer = dataSource?.checkoutContainer else { return }
        checkoutContainer.displaySizes(selectedArticle: selectedArticle,
                                       animated: true,
                                       arrowHandler: updateArrow,
                                       completion: sizeSelected)
    }

    dynamic fileprivate func quantityButtonTapped() {
        guard let selectedArticle = dataSource?.selectedArticle, let checkoutContainer = dataSource?.checkoutContainer else { return }
        checkoutContainer.displayQuantites(selectedArticle: selectedArticle,
                                           animated: true,
                                           arrowHandler: updateArrow,
                                           completion: quantitySelected)
    }

    private func sizeSelected(at idx: Int) {
        guard let selectedArticle = dataSource?.selectedArticle else { return }
        let updatedArticle = SelectedArticle(changeSelectedIndex: idx, from: selectedArticle)

        guard dataSource?.checkoutContainer.collectionView.type == .size, updatedArticle != selectedArticle else { return }
        delegate?.updated(selectedArticle: updatedArticle)
    }

    private func quantitySelected(at idx: Int) {
        guard let selectedArticle = dataSource?.selectedArticle else { return }
        let updatedArticle = SelectedArticle(changeQuantity: idx + 1, from: selectedArticle)

        guard dataSource?.checkoutContainer.collectionView.type == .quantity, updatedArticle != selectedArticle else { return }
        delegate?.updated(selectedArticle: updatedArticle)
    }

    private func updateArrow(for displayedType: CheckoutSummaryArticleRefineType?, animated: Bool) {
        var imageViewsToClose = [sizeButton.imageView, quantityButton.imageView].flatMap { $0 }
        var imageViewToOpen: UIImageView?

        if let type = displayedType {
            switch type {
            case .size: imageViewToOpen = sizeButton.imageView
            case .quantity: imageViewToOpen = quantityButton.imageView
            }
        }

        if let imageView = imageViewToOpen {
            updateArrow(arrowImageView: imageView, opened: true, animated: animated)
            imageViewsToClose.remove(item: imageView)
        }

        imageViewsToClose.forEach { updateArrow(arrowImageView: $0, opened: false, animated: animated) }
    }

    private func updateArrow(arrowImageView: UIImageView, opened: Bool, animated: Bool) {
        let transform = opened ? CGAffineTransform(rotationAngle: CGFloat.pi) : CGAffineTransform.identity
        UIView.animate(duration: animated ? .fast : .noAnimation) {
            arrowImageView.transform = transform
        }
    }

}

extension CheckoutSummaryEditProductStackView: UIBuilder {

    func configureView() {
        addArrangedSubview(sizeButton)
        addArrangedSubview(sizeQuantitySeparatorView)
        addArrangedSubview(quantityButton)
    }

    func configureConstraints() {
        sizeButton.setWidth(equalToView: quantityButton)
        sizeQuantitySeparatorView.setWidth(equalToConstant: UIView.onePixel)
    }

}

extension CheckoutSummaryEditProductStackView: UIDataBuilder {

    typealias T = CheckoutSummaryViewModel

    func configure(viewModel: T) {
        let selectedArticle = viewModel.dataModel.selectedArticle
        if selectedArticle.isSelected {
            let sizeLabel = Localizer.format(string: "summaryView.button.size")
            let size = selectedArticle.unit.size
            sizeButton.setTitle("\(sizeLabel): \(size)", for: .normal)
        } else {
            sizeButton.setTitle(Localizer.format(string: "summaryView.title.selectSize"), for: .normal)
        }

        let quantityLabel = Localizer.format(string: "summaryView.button.quantity")
        quantityButton.setTitle("\(quantityLabel): \(selectedArticle.quantity)", for: .normal)

        sizeButton.removeTarget(self, action: nil, for: .touchUpInside)
        quantityButton.removeTarget(self, action: nil, for: .touchUpInside)
        if viewModel.layout.allowsArticleRefine {
            sizeButton.addTarget(self, action: #selector(sizeButtonTapped), for: .touchUpInside)
            quantityButton.addTarget(self, action: #selector(quantityButtonTapped), for: .touchUpInside)
        }
    }

}
