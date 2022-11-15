//
//  UITabBarController+JUNex4RouteExpress.m
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/15.
//

#import "UITabBarController+JUNex4RouteExpress.h"

@implementation UITabBarController (JUNex4RouteExpress)

- (void)jun_setSelectedViewController:(UIViewController *)vc completion:(void (^)(void))completion {
    self.selectedViewController = vc;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion();
    });
}

@end
