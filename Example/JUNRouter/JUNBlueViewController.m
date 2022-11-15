//
//  JUNBlueViewController.m
//  JUNRouter_Example
//
//  Created by Jun Ma on 2022/11/15.
//  Copyright © 2022 Jun Ma. All rights reserved.
//

#import "JUNBlueViewController.h"
#import "JUNPurpleViewController.h"

@interface JUNBlueViewController ()

@end

@implementation JUNBlueViewController

- (void)jun_routeBuild:(JUNRouteBuilder *)route {
    [route name:@"purple" handle:^(NSDictionary * _Nullable userInfo, JUNRouterNextHandler  _Nonnull next) {
        UIViewController *purpleVc = [[JUNPurpleViewController alloc] init];
        [self presentViewController:purpleVc animated:true completion:^{
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:userInfo[@"alert"] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertC addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                next(purpleVc);
            }]];
            [purpleVc presentViewController:alertC animated:true completion:nil];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
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
