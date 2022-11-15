//
//  JUNTabBarController.m
//  JUNRouter_Example
//
//  Created by Jun Ma on 2022/11/15.
//  Copyright © 2022 Jun Ma. All rights reserved.
//

#import "JUNTabBarController.h"

@interface JUNTabBarController ()

@end

@implementation JUNTabBarController

- (void)jun_routeBuild:(JUNRouteBuilder *)route {
    [route name:@"red" handle:^(NSDictionary * _Nullable userInfo, JUNRouterNextHandler  _Nonnull next) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.selectedIndex = 1;
            next(self.selectedViewController);
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
