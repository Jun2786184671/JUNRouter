//
//  NSURL+JUNex4RouteExpress.m
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/4.
//

#import "NSURL+JUNex4RouteExpress.h"
#import "NSString+JUNex4RouteExpress.h"

@implementation NSURL (JUNex4RouteExpress)

- (Boolean)jun_isRoot {
    return self.pathComponents.count == 1 && [self.pathComponents.firstObject isEqualToString:@"/"];
}

- (nullable NSDictionary<NSString *,NSObject *> *)jun_params {
    NSString *paramStr = self.query;
    if (paramStr.length == 0) {
        return nil;
    }
    NSArray<NSString *> *entries = [paramStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithCapacity:entries.count];
    for (NSString *entry in entries) {
        NSArray<NSString *> *slices = [entry componentsSeparatedByString:@"="];
        NSAssert(slices.count == 2, @"Url parameter format is not valid.");
        NSString *key = slices.firstObject;
        NSObject *value = [self _extractValueFromQuotes:slices.lastObject].jun_inferredValue;
        [res setValue:value forKey:key];
    }
    return res;
}

- (NSString *)_extractValueFromQuotes:(NSString *)value {
    NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"[\\w]+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [nameExpression matchesInString:value options:0 range:NSMakeRange(0, [value length])];
    NSParameterAssert([matches count] == 1);
    NSRange matchRange = [matches.lastObject range];
    return [value substringWithRange:matchRange];
}

@end
