#import "HLProfileCell.h"
#import "HLProfileTableItem.h"

@interface HLProfileCell()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation HLProfileCell

- (void)setupWithItem:(HLProfileTableItem *)item
{
    self.item = item;
    self.titleLabel.text = item.title;
    self.accessibilityIdentifier = item.accessibilityIdentifier;
}

@end
