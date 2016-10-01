//
//  AppDelegate.m
//  Hachidori Toshokan
//
//  Created by 桐間紗路 on 2016/09/28.
//  Copyright © 2016年 Atelier Shiori. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.window.titleVisibility = NSWindowTitleHidden;
    // Sort data
    //sort table
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [_tb setSortDescriptors:[NSArray arrayWithObject:sd]];
    [_apopoverdetailsout setDrawsBackground:NO];
    [_apopoverdetails setBackgroundColor:[NSColor clearColor]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(void)windowWillClose:(NSNotification *)notification{
    //Temrminate Application
    [[NSApplication sharedApplication] terminate:nil];
    
}


#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "moe.ateliershiori.Hachidori_Toshokan" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"moe.ateliershiori.Hachidori_Toshokan"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Hachidori_Toshokan" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


-(IBAction)refreshlist:(id)sender{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://hummingbird.me/api/v1/users/chikorita157/library" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            // Clean Core Data
            [_list removeObjects:[_list arrangedObjects]];
            
            //commit
            [_managedObjectContext save:nil];
        // populate list
            
        NSArray * anilist = (NSArray *)responseObject;
        for (NSDictionary * aentry in anilist){
            NSDictionary * ainfo = aentry[@"anime"];
            NSDictionary * rating = aentry[@"rating"];
            NSManagedObject *newEntry = [NSEntityDescription
                                         insertNewObjectForEntityForName :@"AnimeList"
                                         inManagedObjectContext: _managedObjectContext];
            [newEntry setValue:aentry[@"episodes_watched"] forKey:@"current_episode"];
            [newEntry setValue:[NSString stringWithFormat:@"%@/%@",aentry[@"episodes_watched"], ainfo[@"episode_count"]] forKey:@"progress"];
            [newEntry setValue:aentry[@"id"] forKey:@"id"];
            [newEntry setValue:[NSString stringWithFormat:@"%@",ainfo[@"cover_image"]] forKey:@"image"];
            [newEntry setValue:aentry[@"last_watched"] forKey:@"last_watched"];
            [newEntry setValue:[NSString stringWithFormat:@"%@",aentry[@"notes"]] forKey:@"notes"];
            [newEntry setValue:aentry[@"private"] forKey:@"private"];
            [newEntry setValue:aentry[@"rewatching"] forKey:@"rewatching"];
            if(rating[@"value"] != [NSNull null]){
                [newEntry setValue:[[[NSNumberFormatter alloc]init] numberFromString:[NSString stringWithFormat:@"%@",rating[@"value"]]] forKey:@"score"];
            }
            [newEntry setValue:aentry[@"status"] forKey:@"status"];
            [newEntry setValue:ainfo[@"title"] forKey:@"title"];
            [newEntry setValue:ainfo[@"episode_count"] forKey:@"total_episodes"];
            [newEntry setValue:aentry[@"updated_at"] forKey:@"updated_at"];
            [newEntry setValue:ainfo[@"slug"] forKey:@"aniid"];
            [_list addObject:newEntry];
        }
        //commit
        [_managedObjectContext save:nil];
        //sort table
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
            [_tb setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
#pragma Anime List popover
-(IBAction)alistdoubleclcick:(id)sender{
    NSArray * selected = [_list selectedObjects];
    NSManagedObject * entry = [selected objectAtIndex:0];
    NSString* aniid = (NSString *)[entry valueForKey:@"aniid"];
    selectedaniid = aniid;
    int current_episode = (int)[entry valueForKey:@"current_episode"];
    bool rewatching = (bool)[entry valueForKey:@"rewatching"];
    NSString * status = (NSString *)[entry valueForKey:@"status"];
    float rating = (int)[entry valueForKey:@"score"];
    NSString * notes = (NSString *)[entry valueForKey:@"notes"];
    [self loadinfo:aniid watchedepisodes:current_episode rating:rating status:status notes:notes rewatching:rewatching];
}
-(void)loadinfo:(NSString *)aniid watchedepisodes:(int)epi rating:(float)rating status:(NSString *)status notes:(NSString *)notes rewatching:(BOOL)rewatching{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@",@"https://hummingbird.me/api/v1/anime/",aniid] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        // populate popup window
        NSDictionary * anientry = (NSDictionary *)responseObject;
        [_apopovertitle setStringValue:anientry[@"title"]];
        //Empty
        [_apopoverdetails setString:@""];
        //Title
        if (anientry[@"alternate_title"] != [NSNull null] && [[NSString stringWithFormat:@"%@", anientry[@"alternate_title"]] length] >0) {
            [self appendToAnimeInfo:[NSString stringWithFormat:@"Also known as %@", anientry[@"alternate_title"]]];
        }
        [self appendToAnimeInfo:@""];
        //Description
        [self appendToAnimeInfo:@"Description"];
        [self appendToAnimeInfo:anientry[@"synopsis"]];
        //Meta Information
        [self appendToAnimeInfo:@""];
        [self appendToAnimeInfo:@"Other Information"];
        [self appendToAnimeInfo:[NSString stringWithFormat:@"Start Date: %@", anientry[@"started_airing"]]];
        [self appendToAnimeInfo:[NSString stringWithFormat:@"Airing Status: %@", anientry[@"status"]]];
        if (anientry[@"finished_airing"] != [NSNull null]) {
            [self appendToAnimeInfo:[NSString stringWithFormat:@"Finished Airing: %@", anientry[@"finished_airing"]]];
        }
        if (anientry[@"episode_count"] != [NSNull null]){
            [self appendToAnimeInfo:[NSString stringWithFormat:@"Episodes: %@", anientry[@"episode_count"]]];
        }
        else{
            [self appendToAnimeInfo:@"Episodes: Unknown"];
        }
         [self appendToAnimeInfo:[NSString stringWithFormat:@"Episode Length: %@ minutes", anientry[@"episode_length"]]];
        [self appendToAnimeInfo:[NSString stringWithFormat:@"Show Type: %@", anientry[@"show_type"]]];
        if (anientry[@"age_rating"] != [NSNull null]) {
            [self appendToAnimeInfo:[NSString stringWithFormat:@"Age Rating: %@", anientry[@"age_rating"]]];
        }
        [self appendToAnimeInfo:[NSString stringWithFormat:@"Community Rating: %@/5", anientry[@"community_rating"]]];
        NSImage * dimg = [[NSImage alloc]initByReferencingURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", anientry[@"cover_image"]]]]; //Downloads Image
        [_apopoverposterimage setImage:dimg]; //Get the Image for the title
        // Scroll the vertical scroller to top
        [_apopoverdetails scrollToBeginningOfDocument:self];
        [_ainfopopover showRelativeToRect:[_tb frameOfCellAtColumn:0 row:[_tb selectedRow]] ofView:_tb preferredEdge:0];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void)appendToAnimeInfo:(NSString*)text
{
    NSAttributedString* attr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n", text]];
    
    [[_apopoverdetails textStorage] appendAttributedString:attr];
}
-(IBAction)popovershare:(id)sender{
    //Generate Items to Share
    NSArray *shareItems = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Check this show out! %@ ", [_apopovertitle stringValue] ], [NSURL URLWithString:[NSString stringWithFormat:@"http://hummingbird.me/anime/%@", selectedaniid]] ,nil];
    //Get Share Picker
    NSSharingServicePicker *sharePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];
    sharePicker.delegate = nil;
    // Show Share Box
    [sharePicker showRelativeToRect:[sender bounds] ofView:_sharebutton preferredEdge:NSMinYEdge];
}

-(IBAction)filterByStatus:(id)sender{
    NSPredicate *predicate;
    NSLog(@"%@",[_statusfilter titleOfSelectedItem]);
    if([[_statusfilter titleOfSelectedItem]  isEqual: @"All"] && [_filtersearchfield stringValue] > 0){
        predicate = [NSPredicate predicateWithFormat:@"title CONTAINS %@", [_statusfilter titleOfSelectedItem], [_filtersearchfield stringValue]];
    }
    else if([[_statusfilter titleOfSelectedItem]  isEqual: @"All"] && [_filtersearchfield stringValue] == 0){
    }
    else if([_filtersearchfield stringValue] > 0){
     predicate = [NSPredicate predicateWithFormat:@"status == %@ and title CONTAINS %@", [_statusfilter titleOfSelectedItem], [_filtersearchfield stringValue]];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"status == %@", [_statusfilter titleOfSelectedItem]];
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"AnimeList" inManagedObjectContext:_managedObjectContext]];
    
    if(predicate){
        [request setPredicate:predicate];
    }
    [_list fetch:request];
    [_list prepareContent];
}

@end
