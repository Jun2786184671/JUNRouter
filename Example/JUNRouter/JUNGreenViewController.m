//
//  JUNGreenViewController.m
//  JUNRouter_Example
//
//  Created by Jun Ma on 2022/11/15.
//  Copyright © 2022 Jun Ma. All rights reserved.
//

#import "JUNGreenViewController.h"
#import "JUNBlueViewController.h"

@interface JUNGreenViewController ()

@end

@implementation JUNGreenViewController

- (void)jun_routeHandle:(NSURL *)url cursor:(int *)cursor nextHandler:(JUNRouterNextHandler)next {
    if ([url.pathComponents[*cursor] isEqualToString:@"blue"]) {
        *cursor += 1;
        UIViewController *blueVc = [[JUNBlueViewController alloc] init];
        [self.navigationController popToRootViewControllerAnimated:true];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:blueVc animated:true completion:^{
                next(blueVc);
            }];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
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
