//
//  ActiveArtistsTableViewController.h
//  Ears
//
//  Created by andrew glew on 16/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SelectDateViewController.h"


@interface ActiveArtistsTableViewController : UITableViewController
@property (nonatomic, assign) NSDate *userSelectedDate;
@end

