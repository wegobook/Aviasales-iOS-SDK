import UIKit

protocol ReviewsVCDelegate: class {
    func reviewLogoClicked(review: HDKReview, fromViewController viewController: UIViewController)
}

class ReviewsVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate, ReviewCellDelegate, PeekVCProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet weak var agencyButton: UIButton!
    var commitBlock: (() -> Void)?

    weak var delegate: ReviewsVCDelegate?

    var sections: [TableSection] = []

    let gates: [HDKGate]
    let reviews: [HDKReview]
    let variant: HLResultVariant
    var selectedGate: HDKGate?

    init(reviews: [HDKReview], variant: HLResultVariant) {
        self.reviews = reviews
        self.variant = variant
        gates = ReviewsVC.reviewGates(reviews: reviews)
        super.init(nibName: "ReviewsVC", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSections() -> [TableSection] {
        let filteredReviews = selectedGate == nil
            ? reviews
            : reviews.filter { $0.gate.gateId == selectedGate!.gateId }

        let items = filteredReviews.map { ReviewItem(model: $0, delegate: self) }
        TableItem.setFirstAndLast(items: items)

        var sections = [TableSection(name: nil, items: items)]
        sections = addPoweredByBookingSectionIfNeeded(to: sections)

        return sections
    }

    private func addPoweredByBookingSectionIfNeeded(to sections: [TableSection]) -> [TableSection] {
        guard HDKGate.isBooking(gateId: selectedGate?.gateId ?? "") else {
            return sections
        }

        var result = sections
        result.insert(createPoweredByBookingSection(), at: 0)
        return result
    }

    private func createPoweredByBookingSection() -> TableSection {
        return TableSection(name: nil, items: [PoweredByBookingItem()])
    }

    private static func reviewGates(reviews: [HDKReview]) -> [HDKGate] {
        return reviews.reduce([], { (result, review) -> [HDKGate] in
            let gateId = review.gate.gateId

            if !result.contains(where: { $0.gateId == gateId }) {
                return result + [review.gate]
            }

            return result
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        sections = createSections()
        agencyButton.setTitleColor(JRColorScheme.actionColor(), for: .normal)
        agencyButton.setTitle(NSLS("HL_REVIEWS_ALL_AGENCIES_FILTER_TITLE"), for: .normal)
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.hl_reuseIdentifier())
        tableView.register(PoweredByBookingCell.self, forCellReuseIdentifier: PoweredByBookingCell.hl_reuseIdentifier())
        tableView.estimatedRowHeight = 200

        var inset = tableView.contentInset
        inset.bottom += kNavBarHeight + 20
        tableView.contentInset = inset
    }

    private func titleForGate(gate: HDKGate?) -> String {
        if gate == nil {
            return NSLS("HL_REVIEWS_ALL_AGENCIES_FILTER_TITLE")
        } else {
            return gate?.name?.hl_firstLetterCapitalized() ?? ""
        }
    }

    @IBAction func changeAgencyClicked(_ sender: Any) {
        let allGatesPopoverItem = PopoverItem(title: titleForGate(gate: nil), selected: selectedGate == nil, action: {
            self.applyFilter(gate: nil)
        })

        let gatesPopoverItems: [PopoverItem] = gates.compactMap { gate -> PopoverItem? in
            guard gate.name != nil else { return nil }
            return PopoverItem(title: titleForGate(gate: gate), selected: gate == selectedGate, action: {
                self.applyFilter(gate: gate)
            })
        }

        let popoverItems = [allGatesPopoverItem] + gatesPopoverItems
        let pickerVC = PopoverItemPickerVC(items: popoverItems)
        let contentSize = PopoverItemPickerVC.prefferedSizeForPopoverPresentation(itemsCount: popoverItems.count)
        presentPopover(pickerVC,
                       under: agencyButton,
                       contentSize: contentSize)
    }

    private func applyFilter(gate: HDKGate?) {
        if selectedGate != gate {
            selectedGate = gate
            agencyButton.setTitle(titleForGate(gate: selectedGate), for: .normal)
            sections = createSections()
            tableView.reloadData()

            if sections.count > 0 && sections[0].items.count > 0 {
                tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }
    }

    func gateLogoClicked(review: HDKReview) {
        delegate?.reviewLogoClicked(review: review, fromViewController: self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].items[indexPath.row].cell(tableView: tableView, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].items[indexPath.row].cellHeight(tableWidth: tableView.bounds.width)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(ZERO_HEADER_HEIGHT)
    }
}
