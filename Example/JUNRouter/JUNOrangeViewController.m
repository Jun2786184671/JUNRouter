//
//  JUNOrangeViewController.m
//  JUNRouter_Example
//
//  Created by Jun Ma on 2022/11/15.
//  Copyright © 2022 Jun Ma. All rights reserved.
//

#import "JUNOrangeViewController.h"
#import "JUNYellowViewController.h"

@interface JUNOrangeViewController ()

@end

@implementation JUNOrangeViewController

- (void)jun_routeBuild:(JUNRouteBuilder *)route {
    [route name:@"yellow" handle:^(NSDictionary * _Nullable userInfo, JUNRouterNextHandler  _Nonnull next) {
        UIViewController *yellowVc = [[JUNYellowViewController alloc] init];
        [self presentViewController:yellowVc animated:true completion:^{
            next(yellowVc);
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
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
