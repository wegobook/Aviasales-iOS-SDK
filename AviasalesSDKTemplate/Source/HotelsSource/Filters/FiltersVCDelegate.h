#import "HLFilterDelegate.h"
#import "PointSelectionDelegate.h"
#import "ChooseSelectionDelegate.h"

@protocol FiltersVCDelegate <NSObject, HLFilterDelegate, PointSelectionDelegate, ChooseSelectionDelegate>
@end
