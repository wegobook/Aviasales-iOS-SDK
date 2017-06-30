#import <Foundation/Foundation.h>

@interface NSDictionary (Parsing)

- (NSString *)tryParseNotEmptyStringForKeys:(NSArray <NSString *> *)keys;
- (NSString *)stringForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (NSInteger)integerForKey:(id)key defaultValue:(NSInteger)defaultValue;
- (BOOL)boolForKey:(id)key;
- (BOOL)boolForKey:(id)key defaultValue:(BOOL)defaultValue;
- (double)doubleForKey:(id)key;
- (float)floatForKey:(id)key;
- (NSNumber *)numberForKey:(id)key;
- (NSDictionary *)dictForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSArray *)arrayForKey:(id)key withObjectsOfClass:(Class)klass;
- (NSArray *)stringArrayForKey:(id)key;

@end

@interface NSMutableDictionary (StringForKey)

- (void)setObjectSafe:(id)anObject forKey:(id<NSCopying>)aKey;

@end
