#import <Foundation/Foundation.h>

@interface UITableView (HLNibLoading)
- (void)hl_registerNibWithName:(nonnull NSString *)name;
@end

@interface UICollectionView (HLNibLoading)
- (void)hl_registerNibWithName:(nonnull NSString *)name;
@end