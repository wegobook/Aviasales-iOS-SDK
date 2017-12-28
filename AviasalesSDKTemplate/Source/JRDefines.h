//
//  JRDefines.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#ifndef AviasalesSDKTemplate_Defines_h
#define AviasalesSDKTemplate_Defines_h

#if defined APPSTORE
#define MLOG(fmt, ...)
#else
#define MLOG(fmt, ...) NSLog((@"%s %d: " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#endif

#define AVIASALES_BUNDLE ([[NSBundle mainBundle] URLForResource:@"AviasalesSDKTemplateBundle" withExtension:@"bundle"] ? [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"AviasalesSDKTemplateBundle" withExtension:@"bundle"]] : [NSBundle mainBundle])

#define AVIASALES_(v) [AVIASALES_BUNDLE localizedStringForKey:(v) value:@"" table:(@"AviasalesTemplateLocalizable")]
#define AVIASALES__(k,v) [AVIASALES_BUNDLE localizedStringForKey:(k) value:(v) table:(@"AviasalesTemplateLocalizable")]

#define AVIASALES_VC_GRANDPA_IS_TABBAR [self.parentViewController.parentViewController respondsToSelector:@selector(tabBar)]

#define AVIASALES_CURRENCIES [NSArray arrayWithObjects:@"eur", @"usd", @"gbp", @"aud", @"cad", @"nzd", @"thb", @"pln", @"brl", @"cny", @"hkd", @"twd", @"sgd", @"krw", @"myr", @"vnd", @"jpy", @"try", @"rub", @"idr", @"dkk", @"nok", @"sek", @"mop", @"php", nil]


//------------------------
// MACRO
//------------------------

#define JR_ANY_AIRPORT @"ANY"
#define JR_OTHER_ALLIANCES @"OTHER_ALLIANCES"

#define AS_MARKER [[JRUserSettings sharedManager] marker]
#define LOAD_VIEW_FROM_NIB_NAMED(X) [[AVIASALES_BUNDLE loadNibNamed:X owner:self options:nil] objectAtIndex : 0]
#define LANDSCAPE_NAME(X) [NSString stringWithFormat : @"%@_landscape", X]
#define dispatch_main_sync_safe(block) \
if ([NSThread isMainThread]) \
{ \
block(); \
} \
else \
{ \
dispatch_sync(dispatch_get_main_queue(), block); \
}

#define IS_NON_EMPTY_STRING(object) (object && [object isKindOfClass:[NSString class]] && [object length] > 0)

#define HL_URL_SHORTENER_USERNAME @"sapato"
#define HL_URL_SHORTENER_PASSWORD @"EPhliOk7"

#define NAV_BAR_HEIGHT = 49.0

NS_ASSUME_NONNULL_BEGIN

//------------------------
// DEFINES
//------------------------

static const CGFloat kNavBarHeight = 49.0;

NSUserDefaults *JRUserDefaults();
CGFloat JRPixel();

#define HL_DEFAULTS_SEARCH_INFO_KEY @"hotelsSearchInfoKey"

//------------------------
// TARGETS & CONFIGURATIONS
//------------------------

BOOL Simulator();
BOOL iPhone();
BOOL iPhone4Inch();
BOOL iPhone35Inch();
BOOL iPhone47Inch();
BOOL iPhone55Inch();
BOOL iPhone58Inch();

BOOL iPad();

typedef NS_ENUM(NSInteger, DeviceSizeType) {
    DeviceSizeTypeIPhone58Inch, // iPhone X
    DeviceSizeTypeIPhone55Inch, // iPhone 6+
    DeviceSizeTypeIPhone47Inch, // iPhone 6
    DeviceSizeTypeIPhone4Inch,  // iPhone 5, 5c, 5s,
    DeviceSizeTypeIPhone35Inch, // iPhone 4s
    DeviceSizeTypeIPad          // For all iPads
};

DeviceSizeType CurrentDeviceSizeType() __attribute__((const));

BOOL iOSVersionEqualTo(NSString *version);
BOOL iOSVersionGreaterThan(NSString *version);
BOOL iOSVersionGreaterThanOrEqualTo(NSString *version);
BOOL iOSVersionLessThan(NSString *version);
BOOL iOSVersionLessThanOrEqualTo(NSString *version);

CGFloat iPhoneSizeValue(CGFloat defaultValue, CGFloat iPhone6Value, CGFloat iPhone6PlusValue);
CGFloat deviceSizeTypeValue(CGFloat deviceSizeTypeIPhone35Inch, CGFloat deviceSizeTypeIPhone4Inch, CGFloat deviceSizeTypeIPhone47Inch, CGFloat DeviceSizeTypeIPhone55Inch, CGFloat DeviceSizeTypeIPad);

CGFloat minScreenDimension(void);
CGFloat maxScreenDimension(void);

BOOL Debug();
BOOL AppStore();

UIView * _Nullable loadViewFromNibNamed(NSString * _Nonnull nibNamed);
UIView * _Nullable loadViewFromNib(NSString * _Nonnull nibNamed, id _Nullable owner);

NSString * platformName(void);

//------------------------
// LOCALIZATION
//------------------------

NSString *NSLS(NSString *key);
NSString *NSLSP(NSString *key, float pluralValue);

//------------------------
// DISPATCH
//------------------------

void hl_dispatch_main_sync_safe(dispatch_block_t block);
void hl_dispatch_main_async_safe(dispatch_block_t block);

NS_ASSUME_NONNULL_END

//------------------------
// Float comparison
//------------------------

#define FLOAT_COMPARISON_EPSILON 0.00001f
#define IS_FLOAT_EQUALS_WITH_ACCURACY(A, B, EPSILON) (ABS(A - B) < EPSILON)
#define IS_FLOAT_EQUALS(A, B) (IS_FLOAT_EQUALS_WITH_ACCURACY(A, B, FLOAT_COMPARISON_EPSILON))
#define ZERO_HEADER_HEIGHT 0.00001f

#endif
