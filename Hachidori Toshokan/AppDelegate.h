//
//  AppDelegate.h
//  Hachidori Toshokan
//
//  Created by 桐間紗路 on 2016/09/28.
//  Copyright © 2016年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AFNetworking.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) IBOutlet NSArrayController *list;
@property (strong) IBOutlet NSTableView *tb;

@end

