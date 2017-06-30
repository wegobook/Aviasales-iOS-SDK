import UIKit

@objc protocol BookRoomDelegate: class, NSObjectProtocol {
    func bookRoom(_ room: HDKRoom)
}

class HotelPricesVC: HotelDetailsMoreTableVC, PeekVCProtocol, UIViewControllerPreviewingDelegate {

    weak var delegate: BookRoomDelegate?
    var commitBlock: (() -> Void)?

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLS("HL_HOTEL_DETAIL_SEGMENTED_ALLPRICES_SECTION")
        contentTable.allowsSelection = true
        contentTable.hl_registerNib(withName: HLHotelDetailsPriceTableCell.hl_reuseIdentifier())
        contentTable.hl_registerNib(withName: HLShowMorePricesCell.hl_reuseIdentifier())
        contentTable.contentInset.top += 5
        sections = createSections()
    }

    // MARK: - Private methods

    private func createSections() -> [TableSection] {
        var result: [TableSection] = []
        let collectedRooms = variant.roomsByType
        for rooms in collectedRooms {
            let room = rooms[0]
            let section = PriceSection(rooms: rooms, name: room.localizedType ?? "", variant: variant)
            result.append(section)
        }

        (result.last as? PriceSection)?.shouldShowSeparator = false

        return result
    }

    private func expandSection(_ section: PriceSection) {
        section.expanded = !section.expanded
        contentTable.reloadData()
    }

    // MARK: - UITableViewDelegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        if let roomItem = item as? RoomItem {
            delegate?.bookRoom(roomItem.room)
        } else if let expandItem = item as? ExpandPriceItem {
            expandSection(expandItem.section)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear

        if #available(iOS 9.0, *) {
            if let cell = cell as? HLHotelDetailsPriceTableCell, cell.forceTouchAdded != true {
                registerForPreviewing(with: self, sourceView: cell)
                cell.forceTouchAdded = true
            }
        }
    }

    // MARK: - UIViewControllerPreviewingDelegate
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let cell = previewingContext.sourceView as? HLHotelDetailsPriceTableCell {
            previewingContext.sourceRect = previewingContext.sourceView.bounds

            return createBookingPeekVC(variant, room: cell.room)
        }

        return nil
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let peekVC = viewControllerToCommit as? PeekVCProtocol {
            peekVC.commitBlock?()
        }
    }

    private func createBookingPeekVC(_ variant: HLResultVariant?, room: HDKRoom) -> BookingPeekVC {
        let peekVC = BookingPeekVC(nibName: "PeekTableVC", bundle: nil)
        peekVC.room = room
        peekVC.variant = variant
        peekVC.viewControllerToShowBrowser = self
        let width = UIScreen.main.bounds.width
        let height = peekVC.heightForVariant(variant, peekWidth: width)
        peekVC.preferredContentSize = CGSize(width: width, height: height)
        peekVC.commitBlock = {[weak self] in self?.delegate?.bookRoom(room) }

        return peekVC
    }

    func priceCellRect(_ cell: HLHotelDetailsPriceTableCell) -> CGRect? {
        if contentTable.visibleCells.contains(cell) {
            return view.convert(cell.highlightView.frame, from: cell)
        }

        return nil
    }
}
