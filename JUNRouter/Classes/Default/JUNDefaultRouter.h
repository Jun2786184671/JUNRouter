//
//  JUNDefaultRouter.h
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/8.
//

#import "JUNRouteExpress.h"

NS_ASSUME_NONNULL_BEGIN

@interface JUNDefaultRouter : NSObject <JUNRouter>

- (instancetype)initWithRouteMapper:(nullable NSDictionary<NSString *, NSString *> *)routeMapper animated:(Boolean)animated routeExpress:(JUNRouteExpress *)routeExpress;

@end

NS_ASSUME_NONNULL_END
