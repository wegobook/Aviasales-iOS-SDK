#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)map:(id (^)(id obj))block
{
    NSParameterAssert(block != nil);

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        if (value) {
            [result addObject:value];
        }
    }];

    return [result copy];
}

- (NSArray *)flattenMap:(id (^)(id obj))block
{
    NSParameterAssert(block != nil);

    NSMutableArray *result = [NSMutableArray array];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        if ([value isKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray:value];
        }
    }];

    return [result copy];
}

- (NSArray *)filter:(BOOL (^)(id obj))block
{
    NSParameterAssert(block != nil);
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
}

- (NSArray *)arrayWithoutDuplicates
{
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self];
    return [orderedSet array];
}

- (BOOL)atLeastOneConfirms:(BOOL (^)(id obj))pred
{
    for (id x in self) {
        if (pred(x)) {
            return true;
        }
    }
    return false;
}

- (BOOL)allObjectsConfirm:(BOOL (^)(id obj))pred
{
    for (id x in self) {
        if (!pred(x)) {
            return false;
        }
    }
    return true;
}

- (NSInteger)lastIndexOfObjectPassingTest:(BOOL (^)(id obj, NSInteger index))pred
{
    NSInteger currentIndex = self.count - 1;
    for (id x in [self reverseObjectEnumerator]) {
        if (pred(x, currentIndex)) {
            return currentIndex;
        }
        currentIndex = currentIndex - 1;
    }
    return NSNotFound;
}

- (id)hl_firstMatch:(BOOL (^)(id obj))block
{
    NSParameterAssert(block != nil);
    
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (index == NSNotFound)
        return nil;
    
    return self[index];
}

@end
