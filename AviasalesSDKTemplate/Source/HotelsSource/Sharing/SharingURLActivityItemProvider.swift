class SharingURLActivityItemProvider: UIActivityItemProvider {
    let url: URL

    init(url: URL) {
        self.url = url
        super.init(placeholderItem: url)
    }

    override open var item: Any {
        return url
    }

    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        return item as AnyObject?
    }

    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return item
    }
}
