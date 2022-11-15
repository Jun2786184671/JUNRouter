//
//  UITabBarController+JUNex4RouteExpress.h
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarController (JUNex4RouteExpress)

- (void)jun_setSelectedViewController:(UIViewController *)vc completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
