# JUNRouter

[![Version](https://img.shields.io/cocoapods/v/JUNRouter.svg?style=flat)](https://cocoapods.org/pods/JUNRouter)
[![License](https://img.shields.io/cocoapods/l/JUNRouter.svg?style=flat)](https://cocoapods.org/pods/JUNRouter)
[![Platform](https://img.shields.io/cocoapods/p/JUNRouter.svg?style=flat)](https://cocoapods.org/pods/JUNRouter)

## Demo

To run the demo project, clone the repo, and run `pod install` from the Example directory first.

## Installation

JUNRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JUNRouter'
```

## Guide
1. ```#import <JUNRouter/JUNRouteExpress.h>``` into your project's pch file, otherwise you will need to import this header in every class that you want to be a router.
2. If any class wants to be a router, it needs to implement the ```<JUNRouter>``` protocol. The view controller class has implemented the protocol by default, and subclasses only need to override methods.
3. Two callback methods are provided to register routes. You can implement either or both, with the default 'routeBuild' method taking precedence. If neither of the two is implemented, the next router is first found in the registered route mapping dictionary or .plist file. If the path is not registered, the path name is used as the class name to create a router. If the class does not exist, the route chain will be interrupted.
```objc
- (void)jun_routeBuild:(JUNRouteBuilder *)route;
- (void)jun_routeHandle:(NSURL *)url cursor:(int *)cursor nextHandler:(JUNRouterNextHandler)next;
```
5. Example for routeBuild：
```objc
@Override
- (void)jun_routeBuild:(JUNRouteBuilder *)route {
    [route name:@"pathA" handle:^(NSDictionary * _Nullable userInfo, void (^ _Nonnull next)(id<JUNRouter> _Nullable)) {
        YourNextRouter *aRouter = [[YourNextRouter alloc] init];
        next(aRouter);
    }];
    [route name:@"pathB" handle:^(NSDictionary * _Nullable userInfo, void (^ _Nonnull next)(id<JUNRouter> _Nonnull)) {
        UIViewController *aVc = [[YourViewController alloc] init];
        [self presentViewController:aVc animated:true completion:^{
            next(aVc);
        }];
    }];
    // Code other path conditions...
}
```
6. Example for routeHandle：
```objc
@Override
- (void)jun_routeHandle:(NSURL *)url cursor:(int *)cursor nextHandler:(JUNRouterNextHandler)next {
    NSString *pathComponent = url.pathComponents[*cursor];
    *cursor += 1;
    if ([pathComponent isEqualToString:@"pathA"]) {
        YourNextRouter *aRouter = [[YourNextRouter alloc] init];
        next(aRouter);
    } else if ([pathComponent isEqualToString:@"pathB"]) {
        UIViewController *aVc = [[YourViewController alloc] init];   
        [self presentViewController:redVc animated:true completion:^{
            next(aVc);
        }];
    } else {
        // Fall on other path conditions...
    }
}

```
7. Finally, pass url to the first router, and it is ready to use.
```objc
JUNRouteExpress *routeExpress = [[JUNRouteExpress alloc] initWithRouteMappingFile:@"route_mapping.plist" animated:true];
[routeExpress deliver:aUrl toFirstRouter:aRouter];
```
8. Note that the header of the url protocol must be ```page://``` and host can be omitted, as shown in the examples:
```
page://localhost/path/to/dest
page:///path/to/dest?id=1&name='Jun'&age="20"
page:///path/to/anObjcClass
```
9. You can configure route mapping by a .plist file. The path that is not registered by the code will be resolved through the file.

## Author

Jun Ma, maxinchun5@gmail.com

## License

JUNRouter is available under the MIT license. See the LICENSE file for more info.
