#import "HLProfileCurrencyItem.h"
#import "UIViewCell+ReuseIdentifier.h"
#import "HLProfileCurrencyCell.h"
#import <HotellookSDK/HotellookSDK.h>

@implementation HLProfileCurrencyItem

- (instancetype)initWithTitle:(NSString *)title action:(nonnull ProfileItemAction)action active:(BOOL)active
{
    if (self = [super initWithTitle:title action:action active:active]) {
        self.cellIdentifier = [HLProfileCurrencyCell hl_reuseIdentifier];
    }
    
    return self;
}

@end
