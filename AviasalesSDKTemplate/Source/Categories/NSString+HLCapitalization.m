#import "NSString+HLCapitalization.h"

@implementation NSString (HLCapitalization)

- (NSString *)hl_firstLetterCapitalizedString
{
    return self.length > 0 ? [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]] : self;
}

@end
