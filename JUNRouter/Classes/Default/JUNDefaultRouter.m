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
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    JUNRouterNextHandler wrappedNext = ^(id<JUNRouter> _Nullable dest) {
        [queue addOperationWithBlock:^{
            next(dest);
        }];
    };
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
        wrappedNext(nextRouter);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _handleTransitionFrom:prevRouter to:nextRouter nextHandler:wrappedNext];
    });
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
    if (nextRouter == nil || prevRouter == nil) return next(nil);
    if (![nextRouter isKindOfClass:[UIViewController class]]) return next(nil);
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
                        [self _handleVcTransitionFrom:navVc to:subVc nextHandler:next];
                    }];
                    return;
                }
            }
        }
        [self _handleVcTransitionFrom:tabVc.selectedViewController to:nextVc nextHandler:next];
    } else if ([prevVc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVc = (UINavigationController *)prevVc;
        UIViewController *topVc = ((UINavigationController *)prevVc).topViewController;
        if ([[topVc class] isEqual:[nextVc class]]) {
            next(topVc);
            return;
        }
        for (UIViewController *subVc in navVc.childViewControllers) {
            if (![[subVc class] isEqual:[nextVc class]]) continue;
            UIViewController *destVc = nil;
            long count = [navVc.childViewControllers count] - 1;
            while ((destVc = navVc.childViewControllers[count--]) != subVc) {
                if (![self _shouldPopVc:destVc whenTransitionToVc:nextVc]) break;
            }
            [navVc popToViewController:destVc animated:self.isAnimated];
            if (self.isAnimated) {
                NSParameterAssert([[NSOperationQueue currentQueue] isEqual:[NSOperationQueue mainQueue]]);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    next(subVc);
                });
            } else {
                next(subVc);
            }
            return;
        }
        [(UINavigationController *)prevVc jun_pushViewController:nextVc animated:self.isAnimated completion:^{
            next(nextVc);
        }];
    } else if (prevVc.navigationController) {
        [self _handleVcTransitionFrom:prevVc.navigationController to:nextVc nextHandler:next];
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

- (BOOL)_shouldDismissVc:(UIViewController *)presentedVc whenTransitionToVc:(UIViewController *)nextVc {
    NSURL *url = self.routeExpress.url;
    int cursor = self.routeExpress.cursor;
    return ![presentedVc respondsToSelector:@selector(jun_routeRequestDismissWhenTransitionToViewController:url:cursor:)] || [presentedVc jun_routeRequestDismissWhenTransitionToViewController:nextVc url:url cursor:cursor] == true;
}

- (BOOL)_shouldPopVc:(UIViewController *)vc whenTransitionToVc:(UIViewController *)nextVc {
    NSURL *url = self.routeExpress.url;
    int cursor = self.routeExpress.cursor;
    return ![vc respondsToSelector:@selector(jun_routeRequestPopWhenTransitionToViewController:url:cursor:)] || [vc jun_routeRequestPopWhenTransitionToViewController:nextVc url:url cursor:cursor];
}

@end
