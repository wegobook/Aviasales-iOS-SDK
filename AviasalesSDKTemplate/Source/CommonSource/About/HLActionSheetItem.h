#import <Foundation/Foundation.h>

@interface HLActionSheetItem : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, copy) void(^selectionBlock)(void);

- (id)initWithTitle:(NSString *)title selectionBlock:(void(^)(void))selectionBlock;

@end
