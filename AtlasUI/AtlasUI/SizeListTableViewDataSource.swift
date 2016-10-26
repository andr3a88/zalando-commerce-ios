//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import AtlasSDK

class SizeListTableViewDataSource: NSObject {

    internal let article: Article

    init(article: Article) {
        self.article = article
    }

}

extension SizeListTableViewDataSource: UITableViewDataSource {

    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return article.availableUnits.count
    }

    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(UnitSizeTableViewCell.self, forIndexPath: indexPath) { cell in
            let unit = self.article.availableUnits[indexPath.item]
            cell.configureData(unit)
            cell.accessibilityIdentifier = "size-cell-\(indexPath.row)"
            return cell
        }
    }

}