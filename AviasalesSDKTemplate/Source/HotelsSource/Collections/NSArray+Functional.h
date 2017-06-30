#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray *)map:(id (^)(id obj))block;
- (NSArray *)flattenMap:(id (^)(id obj))block;
- (NSArray *)filter:(BOOL (^)(id obj))block;
- (NSArray *)arrayWithoutDuplicates;
- (BOOL)atLeastOneConfirms:(BOOL (^)(id obj))pred;
- (BOOL)allObjectsConfirm:(BOOL (^)(id obj))pred;
- (id)hl_firstMatch:(BOOL (^)(id obj))block;

- (NSInteger)lastIndexOfObjectPassingTest:(BOOL (^)(id obj, NSInteger index))pred;

@end
