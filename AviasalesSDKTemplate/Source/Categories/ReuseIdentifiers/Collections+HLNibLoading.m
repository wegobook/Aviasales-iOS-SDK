#import "Collections+HLNibLoading.h"

@implementation UITableView (HLNibLoading)

- (void)hl_registerNibWithName:(nonnull NSString *)name
{
    [self registerNib:[UINib nibWithNibName:name bundle:nil] forCellReuseIdentifier:name];
}

@end

@implementation UICollectionView (HLNibLoading)

- (void)hl_registerNibWithName:(nonnull NSString *)name
{
    [self registerNib:[UINib nibWithNibName:name bundle:nil] forCellWithReuseIdentifier:name];
}

@end
