class WaitingCell: UICollectionViewCell {

    @IBOutlet var gateLoadedImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        gateLoadedImageView.image = UIImage(named: "gateLoaded")?.imageTinted(with: JRColorScheme.actionColor())
    }

    func gateLoaded(_ loaded: Bool) {
        activityIndicator.isHidden = loaded
        gateLoadedImageView.isHidden = !loaded

        if !loaded && !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
    }

}
