//
//  AppDelegate.m
//  HZORM-Example
//
//  Created by xzh on 2017/8/9.
//  Copyright © 2017年 GeniusBrother. All rights reserved.
//

#import "AppDelegate.h"
#import <HZORM/HZORM.h>
#import "Person.h"
#import <FMDB/FMDB.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *dbPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HZDatabase.db"];
    HZDBManager.dbPath = dbPath;
    NSLog(@"%@",dbPath);

//    Person *p = [[[Person search:@[@"*"]] where:@{@"id":@"2"}] first];
//    
//    NSLog(@"%@",p);
//    Person *p = [[Person alloc] init];
//    p.pAge = 28;
//    p.pName = @"xzh";
//    p.pBooks = @[@"1",];

//    Person *p2 = [[Person alloc] init];
//    p2.pAge = 29;
//    p2.pName = @"xzh2";
//    p2.pBooks = @[@"1",@"2"];
//    BOOL result = [Person insert:@[p,p2]];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from person"];
        while ([resultSet next]) {
            NSLog(@"%@",resultSet.resultDictionary);
        }
        [resultSet close];
    }];
    NSLog(@"aaaaa");
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from person"];
        while ([resultSet next]) {
            NSLog(@"%@",resultSet.resultDictionary);
        }
        [resultSet close];
    }];
    
    NSLog(@"hhhhhhhhh");
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
