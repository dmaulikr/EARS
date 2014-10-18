//
//  SongDetailViewController.h
//  Ears
//
//  Created by andrew glew on 06/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SongsTableViewController.h"

@class SongDetailViewController;

@protocol SongDetailDelegate <NSObject>
- (void)addItemViewController:(SongDetailViewController *)controller didChangeSong:(int)item;
@end

@interface SongDetailViewController : UIViewController

@property (strong, nonatomic) NSArray *songList;
//@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (nonatomic,retain)  AVPlayer *audioPlayer;
@property (assign) int playingSong;
@property (strong, nonatomic) NSString *selectionType;
@property (strong, nonatomic) MPMediaItem *song;
@property (nonatomic, weak) id <SongDetailDelegate> delegate;
-(void) presentSongDetail: (NSString *) animationType;
- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize;

@end

