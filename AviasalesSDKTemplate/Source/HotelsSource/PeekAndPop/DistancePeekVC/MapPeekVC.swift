class MapPeekVC: SingleHotelMapVC, PeekVCProtocol {

    var commitBlock: (() -> Void)?

    static func preferredHeight() -> CGFloat {
        return 500.0
    }

    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return [showFullMapItem()]
    }

    @available(iOS 9.0, *)
    private func showFullMapItem() -> UIPreviewActionItem {
        let showDetailsTitle = NSLS("HL_DISTANCE_PEEK_SHOW_FULL_MAP")
        let showDetailsAction = UIPreviewAction(title: showDetailsTitle, style: .default) { [weak self]  (action, viewController) -> Void in
            self?.commitBlock?()
        }

        return showDetailsAction
    }
}
