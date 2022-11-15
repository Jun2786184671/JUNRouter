//
//  UINavigationController+JUNex4RouteExpress.m
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/15.
//

#import "UINavigationController+JUNex4RouteExpress.h"

@implementation UINavigationController (JUNex4RouteExpress)

- (void)jun_pushViewController:(UIViewController *)vc animated:(Boolean)isAnimated completion:(void (^)(void))completion {
    [self pushViewController:vc animated:isAnimated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion();
    });
}

@end
