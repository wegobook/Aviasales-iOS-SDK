#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ProfileItemAction)();
typedef BOOL(^ProfileItemActivateBlock)();

@interface HLProfileTableItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong, nullable) NSString *accessibilityIdentifier;
@property (nonatomic, copy, nullable) ProfileItemAction action;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithTitle:(NSString *)title action:(ProfileItemAction)action active:(BOOL)active;

@end

NS_ASSUME_NONNULL_END
