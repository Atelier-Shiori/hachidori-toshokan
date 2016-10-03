//
//  AppDelegate.h
//  Hachidori Toshokan
//
//  Created by 桐間紗路 on 2016/09/28.
//  Copyright © 2016年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AFNetworking.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSString * selectedaniid;
}

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) IBOutlet NSArrayController *list;
@property (strong) IBOutlet NSTableView *tb;
@property (weak) IBOutlet NSSearchFieldCell *filtersearchfield;
@property (weak) IBOutlet NSPopUpButton *statusfilter;

@property (strong) IBOutlet NSPopover *ainfopopover;

// Anime List Status Popover
@property (weak) IBOutlet NSTextField *apopovertitle;

@property (weak) IBOutlet NSPopUpButton *apopoverustatus;
@property (weak) IBOutlet NSTextField *apopoverurating;
@property (weak) IBOutlet NSTextField *apopoverwatchedepi;
@property (weak) IBOutlet NSButton *apopoverurewatch;
@property (weak) IBOutlet NSTextField *apopoverunotes;
@property (weak) IBOutlet NSImageView *apopoverposterimage;
@property (unsafe_unretained) IBOutlet NSTextView *apopoverdetails;

@property (weak) IBOutlet NSButton *sharebutton;
@property (weak) IBOutlet NSScrollView *apopoverdetailsout;
@property (weak) IBOutlet NSTextField *apopoverurewatchedtimes;



@end

