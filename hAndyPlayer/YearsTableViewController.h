//
//  YearsTableViewController.h
//  hAndyPlayer
//
//  Created by andrew glew on 04/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface YearsTableViewController : UITableViewController
@property (strong, nonatomic) AVPlayer *audioPlayer;
@end
