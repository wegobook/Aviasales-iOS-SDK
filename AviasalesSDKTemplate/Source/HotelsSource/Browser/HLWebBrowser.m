#import "HLWebBrowser.h"

#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>

#import "HLRestartableProgressView.h"

static CGFloat kAddressBarExpandedHeight = 64.0;

@interface HLWebBrowser () <WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) HLRestartableProgressView *progressView;

@property (nonatomic, weak) IBOutlet UIView *addressView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addressViewHeight;

@property (nonatomic, weak) IBOutlet UIView *navigationView;
@property (nonatomic, weak) IBOutlet UIButton *buttonGoBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonGoForward;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *navigationViewOrigin;

@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *reloadButton;
@property (nonatomic, weak) IBOutlet UIButton *backwardButton;
@property (nonatomic, weak) IBOutlet UIButton *forwardButton;
@property (nonatomic, weak) IBOutlet UIImageView *lockIcon;
@property (nonatomic, weak) IBOutlet UIView *textBackground;
@property (nonatomic, weak) IBOutlet UILabel *pageTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *textAndLockView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textOrigin;

@property (atomic, assign) CGFloat hidingProgress;
@property (atomic, assign) BOOL finishedInitialLoading;
@property (atomic, assign) BOOL didRetryLoadingAfterNilUrl;

@property (nonatomic, strong) NSLayoutConstraint *webViewToSuperviewTop;
@property (nonatomic, strong) NSLayoutConstraint *webViewToSuperviewBottom;
@property (nonatomic, strong) NSLayoutConstraint *webViewToNavViewTop;
@property (nonatomic, strong) NSLayoutConstraint *webViewToBarViewBottom;

@end

@implementation HLWebBrowser

#pragma mark - Public

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    self.addressViewHeight.constant = 44.0 + statusBarHeight;

    [self addBlurEffectForBars];
    [self setupProgressBar];
    [self toggleBackForwardButtons];

    [self layoutIfNeeded];
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"URL"];
}

- (void)setPageTitle:(NSString *)pageTitle
{
    _pageTitle = pageTitle;
    self.pageTitleLabel.text = pageTitle;
}

- (void)loadUrlString:(NSString *)urlString scripts:(NSArray *)scripts
{
    self.urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];

    WKUserContentController *userContentController = [WKUserContentController new];

    for (NSString *script in scripts) {
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [userContentController addUserScript:userScript];
    }

    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContentController;

    @weakify(self);
    hl_dispatch_main_async_safe(^{
        @strongify(self);
        self.webView = [self webViewWithConfiguration:configuration];
        self.webView.navigationDelegate = self;
        [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        self.webView.UIDelegate = self;
        [self insertSubview:self.webView atIndex:0];
        [self.webView loadRequest:self.urlRequest];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        self.webViewToSuperviewTop = [self.webView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        self.webViewToSuperviewBottom = [self.webView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        self.webViewToNavViewTop = [self.webView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.addressView];
        if (iPhone()) {
            self.webViewToBarViewBottom = [self.webView autoPinEdge:ALEdgeBottom toEdge: ALEdgeTop ofView:self.navigationView];
            self.webViewToBarViewBottom.active = NO;
        }
        self.webViewToNavViewTop.active = NO;
        [self updateInsets:self.webView];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (self.webView.URL == nil) {
        if (self.didRetryLoadingAfterNilUrl) {
            [self.delegate navigationFailed:[NSError new]];
        } else {
            [self.webView loadRequest:self.urlRequest];
            self.didRetryLoadingAfterNilUrl = YES;
        }
    }
}

- (void)updateInsets:(WKWebView *)webView
{
    UIEdgeInsets webViewInsets = webView.scrollView.contentInset;
    webViewInsets.top = self.addressView.frame.size.height;
    webViewInsets.bottom = self.navigationView.frame.size.height;
    webView.scrollView.contentInset = webViewInsets;
    webView.scrollView.scrollIndicatorInsets = webViewInsets;
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)stopProgress
{
    [self.progressView stop];
}

#pragma mark - IBAction methods

- (IBAction)goBackward
{
    [self.webView stopLoading];
    [self.webView goBack];
    [self toggleBackForwardButtons];
}

- (IBAction)goForward
{
    [self.webView stopLoading];
    [self.webView goForward];
    [self toggleBackForwardButtons];
}

- (IBAction)close
{
    [self.webView evaluateJavaScript:@"window.alert=null;" completionHandler:nil];;
    [self.webView stopLoading];
    [self.delegate close];
}

- (IBAction)reload
{
    if (self.webView.URL) {
        [self.webView reload];
    } else {
        [self.delegate reload];
    }
}

#pragma mark - Private

- (void)setupProgressBar
{
    self.progressView = LOAD_VIEW_FROM_NIB_NAMED(@"HLRestartableProgressView");

    [self.addressView addSubview:self.progressView];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.progressColor = [JRColorScheme actionColor];
    self.progressView.shouldHideOnCompletion = YES;
    [self.progressView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.progressView autoSetDimension:ALDimensionHeight toSize:2.0];
}

- (void)startShowProgress
{
    @weakify(self);
    [self.progressView startWithProgressBlock:^CGFloat{
        @strongify(self);

        return self.webView.estimatedProgress;
    }];
}

- (void)toggleBackForwardButtons
{
    BOOL canGoForward = self.webView.canGoForward;
    BOOL canGoBackward = self.webView.canGoBack;

    self.buttonGoBack.enabled = canGoBackward;
    self.buttonGoForward.enabled = canGoForward;
}

- (void)addBlurEffectForBars
{
    for (UIView *barView in [[NSArray alloc] initWithObjects:self.addressView, self.navigationView, nil]) {
        [barView addBlurEffectWith:UIBlurEffectStyleExtraLight];
    }
}

#pragma mark - HLWebView delegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.progressView stop];
    [self toggleBackForwardButtons];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.lockIcon.hidden = !self.webView.hasOnlySecureContent;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (WKUserScript* script in webView.configuration.userContentController.userScripts) {
            [webView evaluateJavaScript:script.source completionHandler:nil];
        }
    });

    self.finishedInitialLoading = YES;

    [self.delegate navigationFinished];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.progressView stop];
    self.finishedInitialLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self toggleBackForwardButtons];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self startShowProgress];
}

#pragma mark - Deeplink

- (WKWebView *)webViewWithConfiguration:(WKWebViewConfiguration *)configuration
{
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    UIEdgeInsets webViewInsets = UIEdgeInsetsMake(kAddressBarExpandedHeight, 0.0, self.navigationView.frame.size.height, 0.0);
    webView.scrollView.contentInset = webViewInsets;
    webView.scrollView.scrollIndicatorInsets = webViewInsets;
    webView.scrollView.contentOffset = CGPointMake(0.0, webViewInsets.top);

    return webView;
}

@end
