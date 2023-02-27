//
//  NSString+JUNex4RouteExpress.h
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JUNex4RouteExpress)

@property(nonatomic, readonly) NSObject *jun_inferredValue;
- (NSString *)jun_stringByURLEncode;
- (NSString *)jun_stringByURLDecode;
- (NSString *)jun_stringByRemoveQuotes;

@end

NS_ASSUME_NONNULL_END
