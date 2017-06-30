#import <UIKit/UIKit.h>
#import "HLProfileCellProtocol.h"

@interface HLProfileCell : UITableViewCell <HLProfileCellProtocol>

@property (nonatomic, strong) HLProfileTableItem *item;

@end
