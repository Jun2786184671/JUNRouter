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

@property(nonatomic, strong) id<JUNRouter> defaultRouter;
@property(nonatomic, strong) id<JUNRouter> currentRouter;
@property(nonatomic, copy) NSURL *url;
@property(nonatomic, assign) int cursor;
@property(nonatomic, strong) NSMutableArray *stashedDeliverBlocks;
@property(nonatomic, assign) bool isIdle;

@end

@implementation JUNRouteExpress

- (NSMutableArray *)stashedDeliverBlocks {
    if (!_stashedDeliverBlocks) {
        _stashedDeliverBlocks = [NSMutableArray array];
    }
    return _stashedDeliverBlocks;
}

- (instancetype)init {
    if (self = [super init]) {
        self.isIdle = true;
    }
    return self;
}

- (instancetype)initWithRouteMapper:(NSDictionary<NSString *,NSString *> *)routeMapper animated:(Boolean)animated {
    if (self = [self init]) {
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
    [self deliver:url toFirstRouter:firstRouter completion:nil];
}

- (void)deliver:(NSURL *)url toFirstRouter:(id<JUNRouter>)firstRouter completion:(void (^)(id<JUNRouter> _Nonnull))completionHandler {
    
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    
    __weak typeof(self) weakSelf = self;
    void (^deliverBlock)(void) = ^{
        [weakSelf _checkValidURL:url];
        weakSelf.url = url;
        weakSelf.cursor = 1;
        
         __block JUNRouterNextHandler handler = ^(id<JUNRouter> router) {
            [currentQueue addOperationWithBlock:^{
                if (router == nil || [weakSelf _checkRecursiveBounds] == true) {
                    if (!handler) return;
                    handler = nil;
                    if (completionHandler) {
                        [currentQueue addOperationWithBlock:^{
                            completionHandler(weakSelf.currentRouter);
                        }];
                    }
                    if ([self.stashedDeliverBlocks count]) {
                        void (^stashedDeliverBlock)(void) = self.stashedDeliverBlocks[0];
                        [self.stashedDeliverBlocks removeObjectAtIndex:0];
                        [currentQueue addOperationWithBlock:stashedDeliverBlock];
                    } else {
                        weakSelf.isIdle = true;
                    }
                    return;
                }
                weakSelf.currentRouter = router;
                [weakSelf _routeHandle:router handler:handler queue:currentQueue];
            }];
        };
        handler(firstRouter);
    };
    
    @synchronized (self) {
        if (self.isIdle) {
            self.isIdle = false;
            deliverBlock();
        } else {
            [self.stashedDeliverBlocks addObject:deliverBlock];
        }
    }
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

- (void)_routeHandle:(id<JUNRouter>)router handler:(JUNRouterNextHandler)handler queue:(NSOperationQueue *)queue {
    int prevCursor = self.cursor;
    if ([router respondsToSelector:@selector(jun_routeBuild:)]) {
        [self _handleByRouteBuildMethod:router handler:handler];
    } else if ([router respondsToSelector:@selector(jun_routeHandle:cursor:nextHandler:)]) {
        [self _handleByRouteHandleMethod:router handler:handler];
    }
    [queue addOperationWithBlock:^{
        if (self.cursor == prevCursor && ![self _checkRecursiveBounds]) {
            NSAssert([self.defaultRouter respondsToSelector:@selector(jun_routeHandle:cursor:nextHandler:)],
                     @"default router must implement routeHandle method");
            [self.defaultRouter jun_routeHandle:self.url cursor:&self->_cursor nextHandler:handler];
        } else if ([self _checkRecursiveBounds]) {
            handler(nil);
        }
    }];
}

- (void)_handleByRouteBuildMethod:(id<JUNRouter>)router handler:(JUNRouterNextHandler)handler {
    NSArray<JUNRouteModel *> *routes = [self _getRoutes:router];
    for (JUNRouteModel *route in routes) {
        if (![[route.name lowercaseString] isEqualToString:[self.url.pathComponents[self.cursor] lowercaseString]]) continue;
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
