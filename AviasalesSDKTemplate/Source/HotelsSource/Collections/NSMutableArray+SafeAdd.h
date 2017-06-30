#import <Foundation/Foundation.h>

@interface NSMutableArray<ObjectType> (SafeAdd)

- (void)addIfNotNil:(ObjectType)object;

@end
