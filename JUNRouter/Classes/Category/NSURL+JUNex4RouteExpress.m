//
//  NSURL+JUNex4RouteExpress.m
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/4.
//

#import "NSURL+JUNex4RouteExpress.h"
#import "NSString+JUNex4RouteExpress.h"

@implementation NSURL (JUNex4RouteExpress)

- (Boolean)jun_isRoot {
    return self.pathComponents.count == 1 && [self.pathComponents.firstObject isEqualToString:@"/"];
}

@end
