//
//  HZModelMeta.m
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import "HZModelMeta.h"
#import "NSObject+HZORMModel.h"
#import <objc/runtime.h>

@interface HZModelMeta ()

@property(nonatomic, strong) Class cla;

@property(nonatomic, copy) NSString *tableName;

@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *columnMap;

@property(nonatomic, copy) NSDictionary *casts;

@property(nonatomic, copy) NSArray<NSString *> *primaryKeys;

@property(nonatomic, assign) BOOL incrementing;

@end

@implementation HZModelMeta

#pragma mark - Initialization
- (instancetype)initWithClass:(Class)cla
{
    self = [super init];
    if (self) {
        self.cla = cla;
        [self setup];
    }
    return self;
}

- (void)setup
{
    Class cla = self.cla;
    _tableName = [cla getTabelName];
    _primaryKeys = [cla getPrimaryKeys];
    _incrementing = [cla isIncrementing];
    _casts = [cla getCasts];
    
    NSDictionary *maps = [cla getColumnMap];
    NSArray *allPropertyNames = [self allPropertyNamesWithClass:cla];
    NSMutableDictionary *validMaps = [NSMutableDictionary dictionaryWithCapacity:maps.count];
    [maps enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull key, NSString  *_Nonnull obj, BOOL * _Nonnull stop) {
        if ([allPropertyNames containsObject:key]) {
            [validMaps setObject:obj forKey:key];
        }else {
            NSAssert1(NO, @"property:%@ not exists", key);
        }
    }];
}

#pragma mark - Private Method
- (NSArray<NSString *> *)allPropertyNamesWithClass:(Class)cla
{
    unsigned int outCount, i;
    objc_property_t * properties = class_copyPropertyList(cla, &outCount);
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:outCount];
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //  属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if (propertyName) [names addObject:propertyName];
    }
    free(properties);
    
    return names;
}



@end
