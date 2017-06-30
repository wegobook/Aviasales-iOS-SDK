#import "HLWebBrowser.h"

#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>
#import "AviasalesSDKTemplate-Swift.h"

#import "HLRestartableProgressView.h"

static CGFloat kAddressBarExpandedHeight = 64.0;
static CGFloat kAddressBarCollapsedHeight = 40.0;
static CGFloat kScrollActionLength = 24.0f;
static CGFloat kInitialFontSize = 19.0f;
static CGFloat kFinalFontSize = 12.0f;

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

@property (atomic, assign) CGFloat lastScrollViewOffset;
@property (atomic, assign) CGFloat initialScrollViewOffset;
@property (atomic, assign) CGFloat hidingProgress;
@property (atomic, assign) BOOL finishedInitialLoading;

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

    [self addBlurEffectForBars];
    [self setupProgressBar];
    [self toggleBackForwardButtons];

    [self layoutIfNeeded];

    UIEdgeInsets webViewInsets = self.webView.scrollView.contentInset;
    webViewInsets.bottom = self.navigationView.frame.size.height;
    self.webView.scrollView.contentInset = webViewInsets;
}

- (void)dealloc
{
    self.webView.scrollView.delegate = nil;
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
        self.webView.scrollView.delegate = self;
        [self updateWebViewScrollBehavour];
    });
}

- (void)stopProgress
{
    [self.progressView stop];
}

- (void)updateWebViewScrollBehavour
{
    BOOL canAnimateScrollView = [self canAnimateScrollView:self.webView.scrollView];
    self.webViewToSuperviewTop.active = canAnimateScrollView;
    self.webViewToNavViewTop.active = !canAnimateScrollView;
    if (iPhone()) {
        self.webViewToSuperviewBottom.active = canAnimateScrollView;
        self.webViewToBarViewBottom.active = !canAnimateScrollView;
    }
    [self layoutIfNeeded];
}

- (BOOL)canAnimateScrollView:(UIScrollView *)scrollView
{
    BOOL contentSizeIsEqualToBounds = CGSizeEqualToSize(scrollView.contentSize, scrollView.bounds.size);
    BOOL contentIsEmpty = CGSizeEqualToSize(scrollView.contentSize, CGSizeZero);

    return !(contentIsEmpty || contentSizeIsEqualToBounds);
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
    self.progressView.progressColor = [JRColorScheme mainButtonBackgroundColor];
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

- (void)expandControls
{
    [self animateBarsToHidingProgress:0.0];
}

- (void)collapseControls
{
    [self animateBarsToHidingProgress:1.0];
}

- (void)animateBarsToHidingProgress:(CGFloat)progress
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self setAddressBarHideProgress:progress];
                         [self setNavBarHideProgress:progress];
                         [self updateInsets];
                         [self layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)setAddressBarHideProgress:(CGFloat)progress
{
    if (!self.finishedInitialLoading) {
        return;
    }

    CGFloat alpha = 1 - progress;
    self.closeButton.alpha = alpha;
    self.reloadButton.alpha = alpha;
    self.textBackground.alpha = alpha;
    self.backwardButton.alpha = alpha;
    self.forwardButton.alpha = alpha;

    CGFloat newConstant = (1 - progress) * kAddressBarExpandedHeight + progress * kAddressBarCollapsedHeight;

    self.addressViewHeight.constant = newConstant;

    CGFloat textOriginY = progress * 11;
    self.textOrigin.constant = textOriginY;

    CGFloat ratio = 1 -  (1 - kFinalFontSize / kInitialFontSize) * progress;
    CGAffineTransform scale = CGAffineTransformMakeScale(ratio, ratio);
    self.textAndLockView.transform = scale;

    self.hidingProgress = progress;
}

- (void)setNavBarHideProgress:(CGFloat)progress
{
    CGFloat newConstant = - progress * self.navigationView.frame.size.height;
    self.navigationViewOrigin.constant = newConstant;
}

- (void)completeHidingWithScrollView:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    if (self.hidingProgress > 0.5 && offset > kScrollActionLength) {
        [self collapseControls];
    } else {
        [self expandControls];
    }
}

- (void)updateInsets
{
    BOOL canAnimateScrollView = [self canAnimateScrollView:self.webView.scrollView];
    BOOL previousValue = self.webViewToSuperviewTop.active;
    if (canAnimateScrollView != previousValue) {
        [self updateWebViewScrollBehavour];
    }

    UIEdgeInsets webViewInsets = self.webView.scrollView.contentInset;
    webViewInsets.top = canAnimateScrollView ? self.addressViewHeight.constant : 0;
    webViewInsets.bottom = canAnimateScrollView ? (self.navigationView.frame.size.height + self.navigationViewOrigin.constant) : 0;
    self.webView.scrollView.contentInset = webViewInsets;
    self.webView.scrollView.scrollIndicatorInsets = webViewInsets;

    if (canAnimateScrollView != previousValue) {
        self.webView.scrollView.contentOffset = CGPointMake(self.webView.scrollView.contentOffset.x, -webViewInsets.top);
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
    [self updateWebViewScrollBehavour];

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
    [self expandControls];

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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginScrolling:(CGFloat)offset
{
    self.lastScrollViewOffset = offset;
    self.initialScrollViewOffset = offset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    if (offset < (scrollView.contentSize.height - scrollView.bounds.size.height - (self.navigationView.bounds.size.height + self.navigationViewOrigin.constant))) {
        if (offset > 0) {
            CGFloat delta = (offset - self.lastScrollViewOffset) / kScrollActionLength;
            CGFloat progress = self.hidingProgress + delta;
            progress = MIN(1.0, progress);
            progress = MAX(progress, 0.0);
            [self setAddressBarHideProgress:progress];
            [self setNavBarHideProgress:progress];
            [self updateInsets];

            self.lastScrollViewOffset = offset;
        }
    } else {
        [self expandControls];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self completeHidingWithScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self completeHidingWithScrollView:scrollView];
    }
}

@end
