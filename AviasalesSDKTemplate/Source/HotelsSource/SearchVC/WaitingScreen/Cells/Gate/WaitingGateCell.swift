class WaitingGateCell: WaitingCell {

    @IBOutlet weak var gateLogoView: GateLogoView!

    var gateItem: GateItem?

    func configureForGateItem(_ item: GateItem) {
        gateItem = item
        gateLogoView.configure(forGate: item.gate, maxImageSize: gateLogoView.bounds.size)
        gateLoaded(item.isLoaded)
    }

}
