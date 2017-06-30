#import "UIViewCell+ReuseIdentifier.h"

@implementation UITableViewCell (ReuseIdentifier)

+ (NSString *)hl_reuseIdentifier
{
    return [[NSStringFromClass(self.class) componentsSeparatedByString:@"."] lastObject];
}

@end

@implementation UICollectionViewCell (ReuseIdentifier)

+ (NSString *)hl_reuseIdentifier
{
    return [[NSStringFromClass(self.class) componentsSeparatedByString:@"."] lastObject];
}

@end

@implementation UICollectionReusableView (ReuseIdentifier)

+ (NSString *)hl_reuseIdentifier
{
    return [[NSStringFromClass(self.class) componentsSeparatedByString:@"."] lastObject];
}

@end
