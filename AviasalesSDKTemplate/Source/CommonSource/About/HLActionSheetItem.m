#import "HLActionSheetItem.h"

@implementation HLActionSheetItem

- (id) initWithTitle:(NSString *)title selectionBlock:(void(^)(void))selectionBlock
{
    self = [super init];
    if (self) {
        self.title = title;
        self.selectionBlock = selectionBlock;
    }
    return self;
}
@end
