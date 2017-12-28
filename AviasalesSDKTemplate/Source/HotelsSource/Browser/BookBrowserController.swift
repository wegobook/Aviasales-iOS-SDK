import HotellookSDK

class BookBrowserController: BrowserController {

    var room: HDKRoom?
    var loadDeeplinkToken: CancelToken?
    var showTime = Date()
    var canRotate = iPad()
    var isPresented = false
    var deferredError: NSError?

    let maxWaitingViewLifetime = 30.0
    let waitingViewAnimationDuration: TimeInterval = 0.4
    let logBrowserPredictedActionTimeout = 300.0

    @IBOutlet weak var waitingView: UIView?
    @IBOutlet weak var gateImageView: UIImageView?
    @IBOutlet weak var waitingViewTitleLabel: UILabel?

    @IBOutlet weak var waitingViewTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        waitingViewTopConstraint.constant = UIApplication.shared.statusBarFrame.height + 44

        waitingViewTitleLabel?.text = NSLS("HL_LOC_BROWSER_WAITING_VIEW_TITLE")
        loadGateImage()
        createBrowser(title: room?.gate.name)
        loadUrl()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        canRotate = true
        isPresented = true
        if let error = deferredError {
            showErrorView(error: error)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        canRotate = iPad()
        isPresented = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return canRotate ? .all : .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    private func loadUrl() {
        if let url = self.room?.deeplink {

            loadDeeplinkToken = CancelToken()
            ServiceLocator.shared.api.deeplinkInfo(url: url).promise(cancelToken: loadDeeplinkToken).then { [weak self] deeplinkInfo in
                self?.deeplinkLoaderSuccess(withUrl: deeplinkInfo.url, scripts: deeplinkInfo.scripts)
            }.always { [weak self] in
                self?.loadDeeplinkToken = nil
            }.catch { [weak self] error in
                self?.deeplinkLoaderFailedWithError(error)
            }

            showWaitingViewAnimated(animated: false)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + maxWaitingViewLifetime, execute: { [weak self] in
                self?.hideWaitingViewAnimated(animated: true)
            })

            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        } else {
            hideWaitingViewAnimated(animated: true)
            showErrorView(error: NSError())
        }
    }

    private func showWaitingViewAnimated(animated: Bool) {
        let duration = animated ? waitingViewAnimationDuration : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.waitingView?.alpha = 1.0
            }, completion: nil)
    }

    private func hideWaitingViewAnimated(animated: Bool) {

        let duration = animated ? waitingViewAnimationDuration : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.waitingView?.alpha = 0.0
            }, completion: nil)
    }

    private func showErrorView(error: NSError) {

        if !isPresented {
            deferredError = error

            return
        }

        deferredError = nil
        HLAlertsFabric.showSearchAlertViewWithError(error, handler: nil)
    }

    private func loadGateImage() {
        waitingView?.setNeedsLayout()
        waitingView?.layoutIfNeeded()

        guard gateImageView != nil else { return }
        guard room != nil else { return }
        guard let gateId = Int(room!.gate.gateId) else { return }
        let gateImageURL = HLUrlUtils.gateIconURL(gateId, size: gateImageView!.frame.size, alignment: .center)
        gateImageView!.sd_setImage(with: gateImageURL)
    }

    // MARK: - Deeplink

    func deeplinkLoaderSuccess(withUrl urlStr: String!, scripts: [String]!) {
        webBrowser?.loadUrlString(urlStr, scripts: scripts)
    }

    func deeplinkLoaderFailedWithError(_ error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        hideWaitingViewAnimated(animated: true)
        showErrorView(error: error as NSError)
        webBrowser?.stopProgress()
    }

    // MARK: - HLWebBrowserDelegate

    override func navigationFinished() {
        hideWaitingViewAnimated(animated: true)

        super.navigationFinished()
    }

    override func navigationFailed(_ error: Error!) {
        hideWaitingViewAnimated(animated: true)

        super.navigationFailed(error)
    }

    override func reload() {
        if loadDeeplinkToken == nil {
            loadUrl()
        }
    }
}
