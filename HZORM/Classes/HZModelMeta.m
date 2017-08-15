//
//  HZModelMeta.m
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import "HZModelMeta.h"
#import <objc/runtime.h>

@implementation HZModelMeta

- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName
{
    unsigned int outCount, i;
    
    // 获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance
                                                           class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //  属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    
    return NO;
}

+ (NSString *)getTabelName { return @"";}

+ (NSDictionary *)getColumnNames { return nil; }

+ (id)getNewValueForProperty:(NSString *)name withOriginValue:(id)originValue { return originValue; }

+ (NSArray *)getUniqueKeys { return nil; }

@end
