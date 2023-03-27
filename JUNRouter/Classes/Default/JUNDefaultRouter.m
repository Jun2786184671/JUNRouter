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
    if ([[prevRouter class] isEqual:[nextRouter class]]) {
        next(nextRouter);
        return;
    }
    [self _handleTransitionFrom:prevRouter to:nextRouter nextHandler:next];
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

- (void)_handleTransitionFrom:(id<JUNRouter>)prevRouter to:(id<JUNRouter>)nextRouter nextHandler:(JUNRouterNextHandler)next {
    if (nextRouter == nil || prevRouter == nil) return;
    if (![nextRouter isKindOfClass:[UIViewController class]]) return;
    UIViewController *nextVc = (UIViewController *)nextRouter;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([prevRouter isKindOfClass:[UIViewController class]]) {
            UIViewController *prevVc = (UIViewController *)prevRouter;
            [self _handleVcTransitionFrom:prevVc to:nextVc nextHandler:next];
            return;
        }
        UIViewController *rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self _vc:rootVc presentVcToFront:nextVc nextHandler:next];
    });
}

- (void)_handleVcTransitionFrom:(UIViewController *)prevVc to:(UIViewController *)nextVc nextHandler:(JUNRouterNextHandler)next {
    if (prevVc.presentedViewController) {
        UIViewController *presentedVc = prevVc.presentedViewController;
        if ([self _shouldDismissVc:presentedVc whenTransitionToVc:nextVc]) {
            [presentedVc dismissViewControllerAnimated:self.isAnimated completion:^{
                [self _handleVcTransitionFrom:prevVc to:nextVc nextHandler:next];
            }];
        } else {
            [self _handleVcTransitionFrom:presentedVc to:nextVc nextHandler:next];
        }
        return;
    }
    if ([prevVc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVc = (UITabBarController *)prevVc;
        for (UIViewController *vc in tabVc.childViewControllers) {
            if ([[vc class] isEqual:[nextVc class]]) {
                [tabVc jun_setSelectedViewController:vc completion:^{
                    next(vc);
                }];
                return;
            } else if ([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVc = (UINavigationController *)vc;
                for (UIViewController *subVc in navVc.childViewControllers) {
                    if (![[subVc class] isEqual:[nextVc class]]) continue;
                    [tabVc jun_setSelectedViewController:navVc completion:^{
                        if (![navVc.visibleViewController isEqual:subVc]) {
                            [navVc popToViewController:subVc animated:true];
                        }
                        next(subVc);
                    }];
                    return;
                }
            }
        }
        [self _handleVcTransitionFrom:tabVc.selectedViewController to:nextVc nextHandler:next];
    } else if ([prevVc isKindOfClass:[UINavigationController class]]) {
        UIViewController *visibleVc = ((UINavigationController *)prevVc).visibleViewController;
        if ([[visibleVc class] isEqual:[nextVc class]]) {
            next(nextVc);
            return;
        }
        [(UINavigationController *)prevVc jun_pushViewController:nextVc animated:self.isAnimated completion:^{
            next(nextVc);
        }];
    } else if (prevVc.navigationController) {
        [prevVc.navigationController jun_pushViewController:nextVc animated:self.isAnimated completion:^{
            next(nextVc);
        }];
    } else if (prevVc.isBeingPresented || prevVc.presentingViewController) {
        UIViewController *ancestor = prevVc.presentingViewController;
        if ([self _shouldDismissVc:prevVc whenTransitionToVc:nextVc]) {
            [prevVc dismissViewControllerAnimated:self.isAnimated completion:^{
                [self _handleVcTransitionFrom:ancestor to:nextVc nextHandler:next];
            }];
        } else {
            [self _vc:prevVc presentVcToFront:nextVc nextHandler:next];
        }
    } else {
        [self _vc:prevVc presentVcToFront:nextVc nextHandler:next];
    }
}

- (void)_vc:(UIViewController *)vc presentVcToFront:(UIViewController *)targetVc nextHandler:(JUNRouterNextHandler)next {
    [vc presentViewController:targetVc animated:self.isAnimated completion:^{
        next(targetVc);
    }];
}

- (BOOL)_shouldDismissVc:(UIViewController *)presentedVC whenTransitionToVc:(UIViewController *)nextVc {
    return ![presentedVC respondsToSelector:@selector(jun_routeRequestDismissWhenTransitionToViewController:)] || [presentedVC jun_routeRequestDismissWhenTransitionToViewController:nextVc] == true;
}

@end
