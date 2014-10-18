//
//  EarSongsTableViewController.h
//  Ears
//
//  Created by andrew glew on 05/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SongDetailViewController.h"


@interface SongsTableViewController : UITableViewController;
@property (strong, nonatomic) NSString *selectedYear;
@property (strong, nonatomic) NSString *selectedDecade;
@property (strong, nonatomic) NSString *selectedArtist;
@property (strong, nonatomic) NSString *decadeStartYear;
@property (strong, nonatomic) NSString *decadeEndYear;
@property (strong, nonatomic) NSString *selectionType;
@property (nonatomic,retain) AVPlayer *audioPlayer;
@property (nonatomic, assign) BOOL showCloud;
@end