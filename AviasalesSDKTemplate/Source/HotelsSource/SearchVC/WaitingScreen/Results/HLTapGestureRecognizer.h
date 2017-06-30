#import <UIKit/UIKit.h>

@protocol HLGestureRecognizerDelegate <NSObject>

- (void)recognizerCancelled;
- (void)recognizerStarted;
- (void)recognizerFinished;

@end

@interface HLTapGestureRecognizer : UILongPressGestureRecognizer

@property (nonatomic, weak) id<HLGestureRecognizerDelegate> stateDelegate;

@end
