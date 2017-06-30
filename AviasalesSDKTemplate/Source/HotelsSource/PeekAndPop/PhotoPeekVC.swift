class PhotoPeekVC: PeekTableVC {

    var photoIndex: Int = 0

    override func createItems() -> [PeekItem] {
        let item = PhotoPeekItem(variant)
        item.photoIndex = photoIndex

        return [item]
    }

    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return [createShowFullPhotoItem()]
    }

    @available(iOS 9.0, *)
    fileprivate func createShowFullPhotoItem() -> UIPreviewActionItem {
        let title = NSLS("HL_PHOTO_PEEK_BUTTON_TITLE")

        let bookAction = UIPreviewAction(title: title, style: .default) { [weak self]  (action, viewController) -> Void in
            self?.commitBlock?()
        }

        return bookAction
    }
}
