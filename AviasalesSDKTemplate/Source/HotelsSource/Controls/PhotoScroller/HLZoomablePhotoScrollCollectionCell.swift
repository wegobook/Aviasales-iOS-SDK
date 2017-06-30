import UIKit

class HLZoomablePhotoScrollCollectionCell: HLPhotoScrollCollectionCell {

    fileprivate var zoomablePhotoView: HLZoomablePhotoView {
        return self.photoView as! HLZoomablePhotoView
    }

    var editingChangedHandler: ((_ nowEditing: Bool) -> Void)? {
        didSet {
            self.zoomablePhotoView.editingChangedHandler = self.editingChangedHandler
        }
    }

    var zoomEnabled: Bool = false {
        didSet {
            self.zoomablePhotoView.zoomEnabled = self.zoomEnabled
        }
    }

    var isZoomed: Bool {
        return self.zoomablePhotoView.isZoomed
    }

    // MARK: - Override methods

    override var reuseIdentifier: String? {
        return "ZoomablePhotoScrollCollectionCell"
    }

    override func createPhotoView () -> HLPhotoView {
        let photoView = HLZoomablePhotoView()
        photoView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        return photoView
    }

}
