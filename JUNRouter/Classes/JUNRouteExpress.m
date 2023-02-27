//
//  JUNRouter.m
//  JUNRouter
//
//  Created by Jun Ma on 2022/11/4.
//

#import "JUNRouteExpress.h"
#import "NSURL+JUNex4RouteExpress.h"
#import "NSString+JUNex4RouteExpress.h"
#import "JUNDefaultRouter.h"

@interface JUNRouteModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) void (^handler)(NSDictionary *userInfo, void (^next)(id<JUNRouter> _Nullable));

@end

@implementation JUNRouteModel

@end


@interface JUNRouteBuilder ()

@property(nonatomic, strong) NSMutableArray<JUNRouteModel *> *routes;

@end

@implementation JUNRouteBuilder

- (NSMutableArray<JUNRouteModel *> *)routes {
    if (_routes == nil) {
        _routes = [NSMutableArray array];
    }
    return _routes;
}

- (void)name:(NSString *)name handle:(void (^)(NSDictionary * _Nullable, void (^ _Nonnull)(id<JUNRouter> _Nonnull)))handler {
    JUNRouteModel *route = [[JUNRouteModel alloc] init];
    route.name = name;
    route.handler = handler;
    [self.routes addObject:route];
}

@end


@interface JUNRouteExpress ()

@property(nonatomic, strong, readonly) id<JUNRouter> defaultRouter;
@property(nonatomic, copy, readonly) NSURL *url;
@property(nonatomic, assign, readonly) int cursor;

@end

@implementation JUNRouteExpress

- (instancetype)initWithRouteMapper:(NSDictionary<NSString *,NSString *> *)routeMapper animated:(Boolean)animated {
    if (self = [super init]) {
        _defaultRouter = [[JUNDefaultRouter alloc] initWithRouteMapper:routeMapper animated:animated routeExpress:self];
    }
    return self;
}

- (instancetype)initWithRouteMappingFile:(NSString *)fileName animated:(Boolean)animated {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSAssert(filePath != nil, @"mapping file not exist");
    NSDictionary *routeMapper = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [self initWithRouteMapper:routeMapper animated:animated];
}

- (void)deliver:(NSURL *)url toFirstRouter:(id<JUNRouter>)firstRouter {
    [self _checkValidURL:url];
    _url = url;
    _cursor = 1;
    __weak __block void (^weakHandler)(id<JUNRouter> next) = nil;
    
    JUNRouterNextHandler handler = ^(id<JUNRouter> router) {
        if (router == nil || [self _checkRecursiveBounds] == true) return;
        self->_currentRouter = router;
        [self _routeHandle:router handler:weakHandler];
    };
    weakHandler = handler;
    handler(firstRouter);
}

- (NSDictionary *)parseQueryString:(NSString *)queryString {
    if (queryString.length == 0) {
        return nil;
    }
    NSArray<NSString *> *entries = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithCapacity:entries.count];
    for (NSString *entry in entries) {
        NSArray<NSString *> *slices = [entry componentsSeparatedByString:@"="];
        NSAssert(slices.count == 2, @"Url parameter format is not valid.");
        NSString *key = slices.firstObject;
        NSObject *value = [slices.lastObject jun_stringByRemoveQuotes].jun_inferredValue;
        [res setValue:value forKey:key];
    }
    return res;
}

- (void)_checkValidURL:(NSURL *)url {
    [self _checkValidScheme:url];
    [self _checkValidHost:url];
}

- (void)_checkValidScheme:(NSURL *)url {
    NSAssert([url.scheme isEqualToString:self.scheme ?: @"page"],
             @"url must be customized or start with 'page://'");
}

- (void)_checkValidHost:(NSURL *)url {
    NSAssert(url.host.length == 0 ||
             [url.host isEqualToString:@"localhost"] ||
             [url.host isEqualToString:@"127.0.0.1"], @"url host must be local");
}

- (Boolean)_checkRecursiveBounds {
    return self.cursor == [self.url.pathComponents count];
}

- (void)_routeHandle:(id<JUNRouter>)router handler:(JUNRouterNextHandler)handler {
    int prevCursor = self.cursor;
    if ([router respondsToSelector:@selector(jun_routeBuild:)]) {
        [self _handleByRouteBuildMethod:router handler:handler];
    } else if ([router respondsToSelector:@selector(jun_routeHandle:cursor:nextHandler:)]) {
        [self _handleByRouteHandleMethod:router handler:handler];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.cursor == prevCursor && ![self _checkRecursiveBounds]) {
            NSAssert([self.defaultRouter respondsToSelector:@selector(jun_routeHandle:cursor:nextHandler:)],
                     @"default router must implement routeHandle method");
            [self.defaultRouter jun_routeHandle:self.url cursor:&self->_cursor nextHandler:handler];
        }
    });
}

- (void)_handleByRouteBuildMethod:(id<JUNRouter>)router handler:(JUNRouterNextHandler)handler {
    NSArray<JUNRouteModel *> *routes = [self _getRoutes:router];
    for (JUNRouteModel *route in routes) {
        if (![route.name isEqualToString:self.url.pathComponents[self.cursor]]) continue;
        _cursor++;
        if (route.handler != nil) {
            NSString *paramsStr = self.url.query;
            NSDictionary *params = self.cursor == self.url.pathComponents.count ? [self parseQueryString:paramsStr] : nil;
            route.handler(params, handler);
        }
        break;
    }
}

- (void)_handleByRouteHandleMethod:(id<JUNRouter>)router handler:(JUNRouterNextHandler)handler {
    [router jun_routeHandle:self.url cursor:&self->_cursor nextHandler:handler];
}

- (NSArray<JUNRouteModel *> *)_getRoutes:(id<JUNRouter>)router {
    NSParameterAssert([router respondsToSelector:@selector(jun_routeBuild:)]);
    JUNRouteBuilder *builder = [[JUNRouteBuilder alloc] init];
    [router jun_routeBuild:builder];
    JUNRouteBuilder *defaultBuilder = [[JUNRouteBuilder alloc] init];
//    if ([self.defaultRouter respondsToSelector:@selector(jun_routeBuild:)]) {
//        [self.defaultRouter jun_routeBuild:defaultBuilder];
//    }
    if ([defaultBuilder.routes count]) {
        [builder.routes addObjectsFromArray:defaultBuilder.routes];
    }
    return builder.routes;
}

@end
