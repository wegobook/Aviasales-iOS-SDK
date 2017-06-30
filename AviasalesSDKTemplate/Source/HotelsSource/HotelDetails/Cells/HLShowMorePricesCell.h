#import <UIKit/UIKit.h>

@interface HLShowMorePricesCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

- (void)setShouldShowSeparator:(BOOL)shouldShowSeparator;

@end
