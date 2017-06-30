@protocol HLWebBrowserDelegate <NSObject>

- (void)navigationFinished;
- (void)navigationFailed:(NSError *)error;
- (void)close;
- (void)reload;

@end

@interface HLWebBrowser : UIView

@property (nonatomic, weak) id <HLWebBrowserDelegate> delegate;
@property (nonatomic, strong) NSString *pageTitle;

- (void)loadUrlString:(NSString *)urlString scripts:(NSArray *)scripts;
- (void)stopProgress;

@end
