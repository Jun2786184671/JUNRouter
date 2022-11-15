//
//  UINavigationController+JUNex4RouteExpress.h
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (JUNex4RouteExpress)

- (void)jun_pushViewController:(UIViewController *)vc animated:(Boolean)isAnimated completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
