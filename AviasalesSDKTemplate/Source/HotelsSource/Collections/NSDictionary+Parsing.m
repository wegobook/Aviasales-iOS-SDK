#import "NSDictionary+Parsing.h"
#import "NSArray+Functional.h"

@implementation NSDictionary (Parsing)

- (NSString *)tryParseNotEmptyStringForKeys:(NSArray <NSString *> *)keys
{
    for (NSString *key in keys) {
        NSString *result = [self stringForKey:key];
        if (result.length > 0) {
            return result;
        }
    }

    return nil;
}

- (NSString *)stringForKey:(id)key
{
    id obj = [self objectOrNilForKey:key];
    return [self castNumberOrStringToString:obj];
}

- (NSInteger)integerForKey:(id)key
{
    return [self integerForKey:key defaultValue:0];
}

- (NSInteger)integerForKey:(id)key defaultValue:(NSInteger)defaultValue
{
    id obj = [self objectOrNilForKey:key];
    return [obj respondsToSelector:@selector(integerValue)] ? [obj integerValue] : defaultValue;
}

- (BOOL)boolForKey:(id)key
{
    return [self boolForKey:key defaultValue:NO];
}

- (BOOL)boolForKey:(id)key defaultValue:(BOOL)defaultValue
{
    NSNumber *number = [self numberForKey:key];
    return number != nil ? [number boolValue] : defaultValue;
}

- (double)doubleForKey:(id)key
{
    return [[self numberForKey:key] doubleValue];
}

- (float)floatForKey:(id)key
{
    return [[self numberForKey:key] floatValue];
}

- (NSNumber *)numberForKey:(id)key
{
    id obj = [self objectOrNilForKey:key];
    return [obj isKindOfClass:[NSNumber class]] ? obj : nil;
}

- (NSDictionary *)dictForKey:(id)key
{
    id obj = [self objectOrNilForKey:key];
    return [obj isKindOfClass:[NSDictionary class]] ? obj : nil;
}

- (NSArray *)arrayForKey:(id)key
{
    id obj = [self objectOrNilForKey:key];
    return [obj isKindOfClass:[NSArray class]] ? obj : nil;
}

- (NSArray *)stringArrayForKey:(id)key
{
    NSArray *arr = [self arrayForKey:key];
    return [arr map:^id(id obj) {
        return [self castNumberOrStringToString:obj];
    }];
}

- (NSArray *)arrayForKey:(id)key withObjectsOfClass:(Class)klass
{
    id obj = [self objectOrNilForKey:key];
    NSArray *arr = [obj isKindOfClass:[NSArray class]] ? obj : nil;
    return [arr filter:^BOOL(id obj) {
        return [obj isKindOfClass:klass];
    }];
}

- (id)objectOrNilForKey:(id)key
{
    id value = [self objectForKey:key];
    return [value isKindOfClass:[NSNull class]] ? nil : value;
}

- (NSString *)castNumberOrStringToString:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    }

    return nil;
}

@end


@implementation NSMutableDictionary (StringForKey)

- (void)setObjectSafe:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!aKey) {
        return;
    }
    
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    } else {
        [self setObject:@"" forKey:aKey];
    }
}

@end
