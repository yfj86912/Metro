//
//  AppDelegate.m
//  shanghaiditie
//
//  Created by 21k on 15/4/1.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import "AppDelegate.h"
#import "BPush.h"
#import "NetworkHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@interface AppDelegate ()<BPushDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    [BPush registerChannel:launchOptions apiKey:@"EqhIidTf4U67OPEOaOs9SUAK" pushMode:BPushModeProduction isDebug:YES];
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldSendDeviceToken) name:@"shouldSendDeviceToken" object:nil];
    tokenNumber = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldLogOutDeviceToken) name:@"shouldLogOutDeviceToken" object:nil];
    
    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
    [application registerForRemoteNotifications];
    
    
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BPush registerDeviceToken:deviceToken]; // 必须
    
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败， 原因：%@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App 收到推送的通知
    [BPush handleNotification:userInfo]; // 可选
    NSDictionary * dicForInfo = [userInfo objectForKey:@"aps"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushAction" object:dicForInfo];
}

#pragma mark Push Delegate
- (void)onMethod:(NSString*)method response:(NSDictionary*)data
{
    NSLog(@"method-----%@,     data-----%@", method, data);
    strForDeviceToken = [NSString stringWithString:[data objectForKey:@"channel_id"]];
    strForUserId = [NSString stringWithString:[data objectForKey:@"user_id"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSendDeviceToken" object:nil];
}

///向服务器发送devicetoken
- (void)shouldSendDeviceToken {
    if (tokenNumber==0) {
        tokenNumber++;
        return;
    }
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 8888;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_BaiduyunPush_LoginBind\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"user_id\":\"%@\",",strForUserId];
    NSString *str4 = [NSString stringWithFormat:@"\"channel_id\":\"%@\",", strForDeviceToken];
    NSString *str5 = [NSString stringWithFormat:@"\"APPType\":\"IOS\"}"];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}

///向服务器发送解绑devicetoken
- (void)shouldLogOutDeviceToken {
    tokenNumber =0;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@", server_address, gen];
    NSURL *url=[NSURL URLWithString:baseURL];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:dict];
    [request setAllowCompressedResponse:YES];
    request.tag = 7777;
    NSMutableData *bodyData=[NSMutableData data];
    NSString *str1 = [NSString stringWithFormat:@"{\"action\":\"TY_BaiduyunPush_LogoutBind\","];
    NSString *str2 = [NSString stringWithFormat:@"\"LoginId\":\"%@\",", [d objectForKey:@"LoginId"]];
    NSString *str3 = [NSString stringWithFormat:@"\"user_id\":\"%@\",",strForUserId];
    NSString *str4 = [NSString stringWithFormat:@"\"channel_id\":\"%@\",", strForDeviceToken];
    NSString *str5 = [NSString stringWithFormat:@"\"APPType\":\"IOS\"}"];
    
    [bodyData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str4 dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[str5 dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request startAsynchronous];
}


#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//请求成功
- (void)requestFinished:(ASIHTTPRequest *)_request {
    NSString *str = [[NSString alloc] initWithData:_request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *result = (NSDictionary *)[str JSONValue];
    if(_request.tag == 8888)
    {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            NSLog(@"deviceToken 绑定成功");
        }
        else if ([[result objectForKey:@"State"] isEqualToString:@"Error"]) {

        }
    }
    if (_request.tag == 7777) {
        if([[result objectForKey:@"State"] isEqualToString:@"Sucess"]){
            NSLog(@"deviceToken 解除绑定成功");
        }
        else if ([[result objectForKey:@"State"] isEqualToString:@"Error"]) {

        }
    }
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)_request {
}




#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.caredear.shanghaiditie" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"shanghaiditie" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"shanghaiditie.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
