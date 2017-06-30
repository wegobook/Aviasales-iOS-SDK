#import <UIKit/UIKit.h>

@protocol HLPlaceholderViewDelegate <NSObject>
@optional
- (void)dropFilters;
- (void)moveToNewSearch;
@end

@interface HLPlaceholderView : UIView

@property (nonatomic, weak) IBOutlet UILabel            *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel            *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton           *button;
@property (nonatomic, weak) IBOutlet UIImageView        *iconImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topImageConstraint;

@property (nonatomic, weak) id<HLPlaceholderViewDelegate> delegate;

- (IBAction) searchAction;
- (IBAction) dropFilters;

@end

