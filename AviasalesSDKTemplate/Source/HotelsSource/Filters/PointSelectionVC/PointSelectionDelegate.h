#import <HotellookSDK/HotellookSDK.h>

@protocol PointSelectionDelegate <NSObject>
- (void)openPointSelectionScreen;
@optional
- (void)locationPointSelected:(HDKLocationPoint *)point;
@end
