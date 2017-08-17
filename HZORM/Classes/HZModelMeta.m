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
    _tableName = [cla getTabelName]; NSAssert(_tableName.length > 0, @"You should implemnt getTabelName method in NSObject + HZORMModel");
    
    _primaryKeys = [cla getPrimaryKeys];NSAssert(_primaryKeys.count > 0, @"You should implemnt getPrimaryKeys method in NSObject + HZORMModel");
    
    _incrementing = [cla isIncrementing];
    
    _casts = [cla getCasts];
    
    NSDictionary *maps = [cla getColumnMap];NSAssert(maps.count > 0, @"You should implemnt getColumnMap method in NSObject + HZORMModel");
    
    NSArray *allPropertyNames = [self allPropertyNamesWithClass:cla];
    NSMutableDictionary *validMaps = [NSMutableDictionary dictionaryWithCapacity:maps.count];
    [maps enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull column, NSString  *_Nonnull property, BOOL * _Nonnull stop) {
        if ([allPropertyNames containsObject:property]) {
            [validMaps setObject:property forKey:column];
        }else {
            NSAssert1(NO, @"property:%@ not exists", property);
        }
    }];
    
    _columnMap = validMaps;
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
