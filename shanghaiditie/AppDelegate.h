//
//  AppDelegate.h
//  shanghaiditie
//
//  Created by 21k on 15/4/1.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString * strForDeviceToken;
    NSString * strForUserId;
    int tokenNumber;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

