import BrightcovePlayerSDK
//import BrightcoveSSAI
import BrightcoveIMA
import GoogleInteractiveMediaAds

class PlayerViewController: UIViewController, BCOVPlaybackControllerDelegate, BCOVPUIPlayerViewDelegate {

    //MARK: Properties

    private var playbackService: BCOVPlaybackService?
    private var playbackController: BCOVPlaybackController?
    private var videoView: BCOVPUIPlayerView?
    private var kViewControllerPlaybackServicePolicyKey: String?
    private var kViewControllerAccountID: String?
    private var kViewControllerVideoID: String?
    private var kViewControllerAdConfigId: String?
    private var kViewControllerAdTagUrl: String?

    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createPlaybackController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupVideoView()
        self.requestContentFromPlaybackService()
    }

    override func viewWillDisappear(_ animated: Bool) {
        //Force switching to portrait mode to fix a UI bug
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    //MARK: Internal Methods

    internal func setAccountIds(_ policyKey: String, accountId: String) {
        self.kViewControllerPlaybackServicePolicyKey = policyKey
        self.kViewControllerAccountID = accountId
    }

    internal func setVideoId(_ videoId: String) {
        self.kViewControllerVideoID = videoId
    }

    internal func setAdConfigId(_ adConfigId: String?) {
        self.kViewControllerAdConfigId = adConfigId
    }

    internal func setAdTagUrl(_ adTagUrl: String?) {
        self.kViewControllerAdTagUrl = adTagUrl
    }

    internal func playFromExistingView() {
        self.createPlaybackController()
        self.setupVideoView()
        self.requestContentFromPlaybackService()
    }

    //MARK: Private Methods

    private func createPlaybackController() {
        let imaSettings = IMASettings()
        imaSettings.ppid = ""
        imaSettings.language = "en"
        
        let renderSettings = IMAAdsRenderingSettings()
        renderSettings.webOpenerPresentingController = self
        renderSettings.webOpenerDelegate = self
        
        let adsRequestPolicy = BCOVIMAAdsRequestPolicy.init(vmapAdTagUrl: self.kViewControllerAdTagUrl)
        
        let imaPlaybackSessionOptions = [kBCOVIMAOptionIMAPlaybackSessionDelegateKey: self]
        
        let sharedSDKManager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        self.playbackController = sharedSDKManager.createIMAPlaybackController(
            with: imaSettings,
            adsRenderingSettings: renderSettings,
            adsRequestPolicy: adsRequestPolicy,
            adContainer: self.videoView?.contentOverlayView,
            companionSlots: nil,
            viewStrategy: nil,
            options: imaPlaybackSessionOptions)
        self.playbackController?.delegate = self
        self.playbackController?.isAutoAdvance = true
        self.playbackController?.isAutoPlay = true
    }

    private func requestContentFromPlaybackService() {
        let queryParameters = [
            kBCOVPlaybackServiceParamaterKeyAdConfigId: self.kViewControllerAdConfigId
        ]
        self.playbackService?.findVideo(withVideoID: self.kViewControllerVideoID!, parameters: queryParameters) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in

            if let video = video {
                self.playbackController?.setVideos([video] as NSArray)
            }
        }
    }

    private func setupVideoView() {
        self.playbackService = BCOVPlaybackService(accountId: self.kViewControllerAccountID, policyKey: self.kViewControllerPlaybackServicePolicyKey)
        self.videoView = BCOVPUIPlayerView(playbackController: self.playbackController, options: nil, controlsView: BCOVPUIBasicControlView.withVODLayout())
        self.videoView?.delegate = self
        self.videoView?.frame = self.videoContainer.bounds
        self.videoView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.videoContainer.addSubview(videoView!)
        self.videoView?.playbackController = playbackController
        self.customizeUI()
    }

    private func customizeUI() {
        // Hide fullscreen button
        let fullscreenButton: BCOVPUIButton? = self.videoView?.controlsView.screenModeButton
        fullscreenButton?.isHidden = true
    }

    private func clear() {
        self.playbackController = nil
        self.playbackService = nil
        self.kViewControllerVideoID = nil
    }

    //MARK: Delegate Methods
    // Check to docs of BCOVPlaybackControllerDelegate to add other delegate methods

    internal func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        // Nothing to do
    }

    //MARK: Actions

    @IBAction func dismissPlayerView(_ sender: Any) {
        self.dismiss(animated: true, completion: {(_: Void) -> Void in
            self.playbackController?.pause()
            self.clear()
        })
    }
}

extension PlayerViewController: IMAWebOpenerDelegate {
    
    func webOpenerDidClose(inAppBrowser webOpener: NSObject!) {
        // Called when the in-app browser has closed.
        playbackController?.resumeAd()
    }
    
}
