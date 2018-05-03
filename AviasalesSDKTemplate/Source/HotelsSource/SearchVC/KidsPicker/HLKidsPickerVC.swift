import UIKit

@objc protocol KidsPickerDelegate: class {
    func kidsSelected()
}

@objcMembers
class HLKidsPickerVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate, HLKidAgePickerViewDelegate {

    var searchInfo: HLSearchInfo? {
        didSet {
            self.updateControls()
        }
    }

    weak var delegate: KidsPickerDelegate?
    @IBOutlet private weak var tableView: UITableView!
    var cleanButton: UIBarButtonItem?

    private var kidAgePickerView: HLKidAgePickerView?
    private var lockerView: HLLockerView?
    private var rowsCount: Int = 4

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLS("HL_KIDS_PICKER_TITLE")
        view.backgroundColor = JRColorScheme.mainBackgroundColor()

        tableView.scrollsToTop = false
        tableView.allowsSelectionDuringEditing = false
        tableView.hl_registerNib(withName: HLKidsPickerTableCell.hl_reuseIdentifier())

        let sel = #selector(HLKidsPickerVC.clean)
        cleanButton = UIBarButtonItem(title: NSLS("HL_CLEAN_BUTTON_TITLE"), style: .plain, target: self, action: sel)
        navigationItem.rightBarButtonItem = cleanButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateControls()
    }

    override func goBack() {
        delegate?.kidsSelected()

        super.goBack()
    }

    // MARK: - Private metods

    @objc @IBAction func clean() {
        searchInfo?.kidAgesArray = []
        updateControls()
    }

    func updateControls() {
        let count = searchInfo?.kidAgesArray.count ?? 0
        cleanButton?.isEnabled = (count > 0)
        tableView?.reloadData()
    }

    private func cellState(_ indexPath: IndexPath) -> HLKidsPickerTableCellState {
        let kidsCount = searchInfo?.kidAgesArray.count ?? 0
        var state = HLKidsPickerTableCellState.disabled

        if kidsCount == indexPath.row {
            state = HLKidsPickerTableCellState.ready
        } else if kidsCount > indexPath.row {
            state = HLKidsPickerTableCellState.selected
        }

        return state
    }

    private func showAgePicker() {
        kidAgePickerView = loadViewFromNibNamed("HLKidAgePickerView") as! HLKidAgePickerView?
        kidAgePickerView?.delegate = self
        kidAgePickerView?.frame = view.bounds

        if let index = tableView.indexPathForSelectedRow?.row, let kidAges = searchInfo?.kidAgesArray, kidAges.count > index {
            kidAgePickerView?.kidAge = kidAges[index]
        }
        kidAgePickerView?.show(view, animated: true, bottomOffset: bottomLayoutGuide.length)
    }

    // MARK: - Needed for cell editing mode!!

    private func lockScreenWithTouchTransparent(_ forCell: HLKidsPickerTableCell?) {
        lockerView = HLLockerView(frame: view.bounds)
        let deleteButtonFrame = forCell?.deleteButton.frame ?? CGRect.zero
        lockerView!.touchTransparentRect = (forCell?.convert(deleteButtonFrame, to: tableView))!
        lockerView!.translatesAutoresizingMaskIntoConstraints = false
        lockerView!.backgroundColor = UIColor.clear
        lockerView!.touchAction = {
            if let cell = forCell {
                cell.hideDeleteButton(true)
            }
        }

        view.addSubview(lockerView!)

        let constraintWidth = NSLayoutConstraint.constraints(withVisualFormat: "H:|[selfView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selfView": lockerView!])
        view.addConstraints(constraintWidth)
    }

    private func unlockScreen() {
        lockerView?.removeFromSuperview()
    }

    // MARK: - UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / 4.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLKidsPickerTableCell.hl_reuseIdentifier()) as! HLKidsPickerTableCell
        cell.kidNumber = indexPath.row + 1
        cell.state = cellState(indexPath)
        cell.hideDeleteButton(false)
        cell.willBeginEditingCellHandler = { [weak self] (cell: HLKidsPickerTableCell) -> Void in
            self?.lockScreenWithTouchTransparent(cell)
            self?.tableView.isEditing = true
        }
        cell.didEndEditingCellHandler = { [weak self] (cell: HLKidsPickerTableCell) -> Void in
            self?.unlockScreen()
            self?.tableView.isEditing = false
        }
        cell.deleteCellHandler = { [weak self] (cell: HLKidsPickerTableCell) -> Void in
            guard let `self` = self else { return }
            guard let searchInfo = self.searchInfo else { return }
            if searchInfo.kidAgesArray.count > indexPath.row {
                searchInfo.kidAgesArray.remove(at: indexPath.row)

                self.view.isUserInteractionEnabled = false

                CATransaction.begin()
                CATransaction.setCompletionBlock({ () -> Void in
                    self.view.isUserInteractionEnabled = true
                    self.updateControls()
                })

                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .bottom)
                let lastIndexPath = IndexPath(row: self.rowsCount - 1, section: 0)
                tableView.insertRows(at: [lastIndexPath], with: .bottom)
                tableView.endUpdates()

                CATransaction.commit()
            }
        }

        if let kidAges = searchInfo?.kidAgesArray {
            if kidAges.count > indexPath.row {
                cell.kidAge = kidAges[indexPath.row]
            }
        }

        return cell
    }

    // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchInfo = searchInfo, indexPath.row <= searchInfo.kidAgesArray.count {
            showAgePicker()
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - HLKidAgePickerViewDelegate methods

    func didSelectAge(_ age: Int) {
        if let ip = tableView.indexPathForSelectedRow, let searchInfo = searchInfo {
            if searchInfo.kidAgesArray.count > ip.row {
                searchInfo.kidAgesArray[ip.row] = age
            } else {
                searchInfo.kidAgesArray.append(age)
            }
            updateControls()
        }
    }

    func didCloseAgeSelector() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: - HLLockerView class

    fileprivate class HLLockerView: UIView {

        var touchTransparentRect: CGRect = CGRect.zero
        var touchAction:(() -> Void)?

        fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            if touchTransparentRect.contains(point) {
                return false
            }
            touchAction?()

            return super.point(inside: point, with: event)
        }
    }

}
