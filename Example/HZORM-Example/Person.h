//
//  Person.h
//  HZORM-Example
//
//  Created by xzh on 2017/8/17.
//  Copyright © 2017年 GeniusBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(nonatomic, assign) NSInteger id;
@property(nonatomic, copy) NSString *pName;
@property(nonatomic, assign) NSInteger pAge;

@property(nonatomic, copy) NSArray *pBooks;

@end
