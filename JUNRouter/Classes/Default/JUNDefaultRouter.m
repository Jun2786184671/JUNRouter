//
//  JUNDefaultRouter.m
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/8.
//

#import "JUNDefaultRouter.h"
#import "UINavigationController+JUNex4RouteExpress.h"
#import "UITabBarController+JUNex4RouteExpress.h"

@interface JUNDefaultRouter ()

@property(nonatomic, assign, readonly, getter=isAnimated) Boolean animated;
@property(nonatomic, strong, readonly) NSDictionary *routeMapper;
@property(nonatomic, weak, readonly) JUNRouteExpress *routeExpress;

@end

@implementation JUNDefaultRouter


- (instancetype)initWithRouteMapper:(NSDictionary<NSString *, NSString *> *)routeMapper animated:(Boolean)animated routeExpress:(JUNRouteExpress *)routeExpress {
    if (self = [super init]) {
        _animated = animated;
        _routeMapper = routeMapper;
        _routeExpress = routeExpress;
    }
    return self;
}

- (void)jun_routeHandle:(NSURL *)url cursor:(int *)cursor nextHandler:(JUNRouterNextHandler)next {
    NSString *routeName = url.pathComponents[*cursor];
    NSString *routerClsName = self.routeMapper[routeName];
    if (routerClsName == nil) {
        routerClsName = routeName;
    }
    NSAssert(routerClsName != nil, @"can not match a router");
    *cursor += 1;
    id<JUNRouter> prevRouter = self.routeExpress.currentRouter;
    id<JUNRouter> nextRouter = [[NSClassFromString(routerClsName) alloc] init];
    [self _handleTransitionFrom:prevRouter to:nextRouter completion:^{
        next(nextRouter);
    }];
}

//- (void)jun_routeBuild:(JUNRouteBuilder *)route {
//    [self.routeMapping enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull name, NSString *  _Nonnull routerClsName, BOOL * _Nonnull stop) {
//        [route name:name handle:^(NSDictionary * _Nullable userInfo, void (^ _Nonnull next)(id<JUNRouter> _Nonnull)) {
//            id<JUNRouter> prevRouter = [JUNRouteExpress defaultExpress].currentRouter;
//            id<JUNRouter> nextRouter = [[NSClassFromString(routerClsName) alloc] init];
//            [self _handleTransitionFrom:prevRouter to:nextRouter completion:^{
//                next(nextRouter);
//            }];
//        }];
//    }];
//}

- (void)_handleTransitionFrom:(id<JUNRouter>)prevRouter to:(id<JUNRouter>)nextRouter completion:(void (^)(void))completion {
    if (nextRouter == nil || prevRouter == nil) return;
    if (![nextRouter isKindOfClass:[UIViewController class]]) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([prevRouter isKindOfClass:[UIViewController class]]) {
            [self _handleVcTransitionFrom:(UIViewController *)prevRouter to:(UIViewController *)nextRouter completion:completion];
            return;
        }
        [self _presentVcToFront:(UIViewController *)nextRouter completion:completion];
    });
}

- (void)_handleVcTransitionFrom:(UIViewController *)prevVc to:(UIViewController *)nextVc completion:(void (^)(void))completion {
    if ([prevVc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVc = (UITabBarController *)prevVc;
        for (UIViewController *vc in tabVc.childViewControllers) {
            if (![[vc class] isEqual:[nextVc class]]) continue;
            [tabVc jun_setSelectedViewController:vc completion:completion];
            return;
        }
        [self _handleVcTransitionFrom:tabVc.selectedViewController to:nextVc completion:completion];
    } else if ([prevVc isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)prevVc jun_pushViewController:nextVc animated:self.isAnimated completion:completion];
    } else if (prevVc.navigationController != nil) {
        [prevVc.navigationController jun_pushViewController:nextVc animated:self.isAnimated completion:completion];
    } else if (prevVc.isBeingPresented || prevVc.presentingViewController != nil) {
        UIViewController *ancestor = prevVc.presentingViewController;
        [prevVc dismissViewControllerAnimated:self.isAnimated completion:^{
            [self _handleVcTransitionFrom:ancestor to:nextVc completion:completion];
        }];
    } else {
        [self _presentVcToFront:nextVc completion:completion];
    }
}

- (void)_presentVcToFront:(UIViewController *)vc completion:(void (^)(void))completion {
    UIViewController *rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc presentViewController:vc animated:self.isAnimated completion:completion];
}

@end
