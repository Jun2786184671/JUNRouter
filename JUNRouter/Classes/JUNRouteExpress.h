//
//  JUNRouter.h
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/4.
//

#import <UIKit/UIKit.h>

@class JUNRouteBuilder;

NS_ASSUME_NONNULL_BEGIN

@protocol JUNRouter <NSObject>

typedef void (^JUNRouterNextHandler)(id<JUNRouter> _Nullable dest);

@optional
- (void)jun_routeBuild:(JUNRouteBuilder *)route;
- (void)jun_routeHandle:(NSURL *)url cursor:(int *)cursor nextHandler:(JUNRouterNextHandler)next;

@end

@interface UIViewController () <JUNRouter>

@end

@interface JUNRouteExpress : NSObject

- (instancetype)initWithRouteMappingFile:(NSString *)fileName animated:(Boolean)animated;
- (instancetype)initWithRouteMapper:(nullable NSDictionary<NSString *, NSString *> *)routeMapper animated:(Boolean)animated;
@property(nonatomic, readonly) id<JUNRouter> currentRouter;
- (void)deliver:(NSURL *)url toFirstRouter:(id<JUNRouter>)firstRouter;

@end

@interface JUNRouteBuilder : NSObject

- (void)name:(NSString *)name handle:(void (^)(NSDictionary * _Nullable userInfo, JUNRouterNextHandler next))handler;

@end

NS_ASSUME_NONNULL_END
