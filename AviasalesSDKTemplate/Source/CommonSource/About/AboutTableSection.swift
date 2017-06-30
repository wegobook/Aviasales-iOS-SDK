@objc class AboutTableSection: NSObject {
    let items: [HLProfileTableItem]
    var descriptionTitle: String?

    init(items: [HLProfileTableItem]) {
        self.items = items

        super.init()
    }
}
