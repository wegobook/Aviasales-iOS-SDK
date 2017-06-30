#import "HLProfileTableItem.h"

@implementation HLProfileTableItem

- (instancetype)initWithTitle:(NSString *)title action:(ProfileItemAction)action active:(BOOL)active
{
    if (self = [super init]) {
        self.title = title;
        self.action = action;
        self.active = active;
        self.height = 44.0;
    }
    
    return self;
}

@end
