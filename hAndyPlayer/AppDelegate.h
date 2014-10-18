//
//  AppDelegate.h
//  hAndyPlayer
//
//  Created by andrew glew on 31/07/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    AVPlayer *audioPlayer;
    NSMutableArray *songList;
}


@property (nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) NSMutableArray *songList;
@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

