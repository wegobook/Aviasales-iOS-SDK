#import "NSArray+HLContentComparison.h"

@implementation NSArray (HLContentComparison)

- (BOOL)hl_isContentEqualToArray:(NSArray *)array
{
    NSCountedSet *selfSet = [NSCountedSet setWithArray:self];
    NSCountedSet *otherSet = [NSCountedSet setWithArray:array];
    
    return [selfSet isEqualToSet:otherSet];
}

@end
