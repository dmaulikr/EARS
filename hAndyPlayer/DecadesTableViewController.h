//
//  DecadesTableViewController.h
//  Ears
//
//  Created by andrew glew on 10/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface DecadesTableViewController : UITableViewController
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) NSMutableArray *songList;
@end
