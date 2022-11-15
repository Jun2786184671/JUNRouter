//
//  NSURL+JUNex4RouteExpress.h
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (JUNex4RouteExpress)

@property(nonatomic, readonly) Boolean jun_isRoot;
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSObject *> *jun_params;

@end

NS_ASSUME_NONNULL_END
