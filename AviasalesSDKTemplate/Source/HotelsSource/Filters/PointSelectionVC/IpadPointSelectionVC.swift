import UIKit

class IpadPointSelectionVC: PointSelectionVC {

    func contentHeight() -> CGFloat {
        resetTableContent()
        let navBarHeight: CGFloat = 48.0
        let searchBarHeight: CGFloat = 44.0
        let footerHeight: CGFloat = 20.0
        let rowHeight: CGFloat = 53.0
        let contentInset: CGFloat = 15.0

        var contentHeight: CGFloat = navBarHeight + searchBarHeight + contentInset
        for section in sections {
            contentHeight += section.title == nil ? 15.0 : 44.0
            contentHeight += CGFloat(section.items.count) * rowHeight
        }
        contentHeight += CGFloat(sections.count - 1) * footerHeight

        return contentHeight
    }
}
