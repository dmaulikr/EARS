//
//  SongDetailViewController.m
//  Ears
//
//  Created by andrew glew on 06/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "SongDetailViewController.h"
#import "SongsTableViewController.h"
#import "AppDelegate.h"

@interface SongDetailViewController () <SongDetailDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtwork;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;
//@property (weak, nonatomic) IBOutlet UILabel *songNumberOfPlays;
@property (weak, nonatomic) IBOutlet UIImageView *songArtwork;
@property (weak, nonatomic) IBOutlet UILabel *songAlbum;
@property (weak, nonatomic) IBOutlet UILabel *trackDuration;
@property (weak, nonatomic) IBOutlet UIImageView *pauseIcon;
@property (weak, nonatomic) IBOutlet UILabel *songIndex;
@property (strong, nonatomic) IBOutlet UIView *songDetailView;

@property (weak, nonatomic) IBOutlet UILabel *trackTimer;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign, getter=isInitial) BOOL initial;
@property (nonatomic, assign) int testTimer;
@property (nonatomic, assign) NSNumber *songDuration;
@property (nonatomic, strong) AVAudioSession *session;

@end



@implementation SongDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.audioPlayer = appDelegate.audioPlayer;
    self.songList = appDelegate.songList;
    
    self.session = [AVAudioSession sharedInstance];
    NSError *error;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting audio session category: %@", error);
    }
    [self.session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error activating audio session: %@", error);
    }

    

    
    
    NSDictionary *mediaInfo = @{MPMediaItemPropertyTitle: @"My Title",
                                MPMediaItemPropertyAlbumTitle: @"My Album Name",
                                MPMediaItemPropertyPlaybackDuration: [NSNumber numberWithFloat:0.30f]};
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    
    
    //Song Navigation
    UISwipeGestureRecognizer *gestureRight;
    UISwipeGestureRecognizer *gestureLeft;
    gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightPreviousSong:)];//direction is set by default.
    gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftNextSong:)];//need to set direction.
    [gestureLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [gestureRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    //[gesture setNumberOfTouchesRequired:1];//default is 1
    [[self view] addGestureRecognizer:gestureRight];//this gets things rolling.
    [[self view] addGestureRecognizer:gestureLeft];//this gets things rolling.
    
    
    //Volume Control
    UISwipeGestureRecognizer *gestureUp;
    UISwipeGestureRecognizer *gestureDown;
    gestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVolumeUp:)];//direction is set by default.
    gestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVolumeDown:)];//need to set direction.
    [gestureUp setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [gestureDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    
    //[gesture setNumberOfTouchesRequired:1];//default is 1
    [[self view] addGestureRecognizer:gestureUp];//this gets things rolling.
    [[self view] addGestureRecognizer:gestureDown];//this gets things rolling.
    

    UITapGestureRecognizer *doubleTapPlayPause = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(doubleTapPlayPause:)];
    doubleTapPlayPause.numberOfTapsRequired = 2;
    [[self view] addGestureRecognizer:doubleTapPlayPause];
    [self setPaused:NO];
    [self setInitial:YES];
    [self presentSongDetail:@"fromRight"];
    [self configureTimer];

    UIProgressView* prog = [[UIProgressView alloc] init];
    self.progressBar = prog;
    // self.progressBar.progressTintColor = [UIColor colorWithRed:1.000 green:0.869 blue:0.275 alpha:1.000];
    self.progressBar.progressTintColor = [UIColor orangeColor];
    self.progressBar.trackTintColor = [UIColor darkGrayColor];
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat w = 230;
    CGFloat h = 10;
    [self.progressBar addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:w]];
    [self.progressBar addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:h]];
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(100,100,w,h)];
    [v addSubview:self.progressBar];
    [v addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:v attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [v addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:v attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    v.clipsToBounds = YES;
    v.layer.cornerRadius = 4;
    self.navigationItem.titleView = v;
    
    
}




-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
}


//- (void)viewDidDisappear:(BOOL)animated
//{
    //[super viewWillDisappear:animated];
       //self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 44);
    
//}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }

}


-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    NSLog(@"viewDidDisappear");
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    // Resign as first responder
    [self resignFirstResponder];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    [super viewWillDisappear:animated];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    NSLog(@"Event remoteControlReceivedWithEvent called!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"Event called!");
                [self playPause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"Event called!");
                [self playPreviousSong];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"Event called!");
                [self playNextSong];
                break;
                
            default:
                break;
        }
    }
}



-(void)playerItemDidReachEnd {
    
    // validate this is not the last song.  if it is we stop playing!
    // validate this is not the last song.  if it is we stop playing!
    if (self.playingSong == self.songList.count - 1) {
        self.playingSong = 0;
    } else {
        self.playingSong ++;
    }
   
    
    NSLog(@"SONGDETAIL: PLAYERITEMDIDREACHEND, PLAYINGSONG:%d SONGLIST%@",self.playingSong,self.songList);
    
    MPMediaItem *song = [self.songList objectAtIndex:self.playingSong];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self playAudio];
    [self.delegate addItemViewController:self didChangeSong:self.playingSong];
    [self presentSongDetail:@"slideLeft"];
}



-(BOOL)canBecomeFirstResponder
{
    return YES;
}




-(void)doubleTapPlayPause:(UITapGestureRecognizer *)gesture
{
    [self playPause];
}


-(void) playPause {
    if ([self isPaused] == NO) {
        [self.audioPlayer pause];
        self.pauseIcon.hidden=NO;
        [self setPaused:YES];
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    } else {
        [self playAudio];
        self.pauseIcon.hidden=YES;
        [self setPaused:NO];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
}


- (void)swipeRightPreviousSong:(UISwipeGestureRecognizer *)gesture
{
    [self playPreviousSong];
}


-(void) playPreviousSong {
    //Change Song forward
    if (self.playingSong==0) {
        self.playingSong = self.songList.count - 1;
    } else {
        self.playingSong --;
    }
    
    NSLog(@"%lu",(unsigned long)self.songList.count);
    [self.audioPlayer pause];
    MPMediaItem *song = [self.songList objectAtIndex:self.playingSong];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    
    
    [self playAudio];
    
    
    [self setPaused:NO];
    [self setInitial:YES];
    [self.delegate addItemViewController:self didChangeSong:self.playingSong];
    [self presentSongDetail:@"fromLeft"];
    
}

-(void) playAudio {
    
    [self.audioPlayer play];
    //MPMediaItem *song = [self.songList objectAtIndex:self.playingSong];
    //[[MPMusicPlayerController systemMusicPlayer] setNowPlayingItem:song];
    //[[MPMusicPlayerController systemMusicPlayer]
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        //MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: [UIImage imageNamed:@"AlbumArt"]];
        
        [songInfo setObject:@"Audio Title" forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:@"Audio Author" forKey:MPMediaItemPropertyArtist];
        // [songInfo setObject:@"Audio Album" forKey:MPMediaItemPropertyAlbumTitle];
        //[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        
    }
    
    
}


- (void)swipeLeftNextSong:(UISwipeGestureRecognizer *)gesture
{
    [self playNextSong];
}

-(void) playNextSong {
    if (self.playingSong == (self.songList.count - 1 )) {
        self.playingSong=0;
    } else {
        self.playingSong ++;
    }
    NSLog(@"%lu",(unsigned long)self.songList.count);
    [self.audioPlayer pause];
    MPMediaItem *song = [self.songList objectAtIndex:self.playingSong];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self playAudio];
    [self setPaused:NO];
    [self setInitial:YES];
    [self.delegate addItemViewController:self didChangeSong:self.playingSong];
    [self presentSongDetail:@"fromRight"];
}




- (void)swipeVolumeDown:(UISwipeGestureRecognizer *)gesture
{
    if ([self.audioPlayer volume] > 0.0) {
        [self.audioPlayer setVolume:[self.audioPlayer volume] -0.1];
    }
}

- (void)swipeVolumeUp:(UISwipeGestureRecognizer *)gesture
{
    if ([self.audioPlayer volume] < 1.0) {
        [self.audioPlayer setVolume:[self.audioPlayer volume] +0.1];
    }
    
}



-(void) presentSongDetail:(NSString *)animationType {
   
    BOOL noItunesArtwork;
    [self.progressBar setProgress:0.0 animated:true];
    UIImageView *blurredImage = [[UIImageView alloc] init];
    //[self.progressBar progress:0.0];
    MPMediaItem *track = [self.songList objectAtIndex:self.playingSong];
    self.songTitle.text = [track valueForKey: MPMediaItemPropertyTitle];
    self.songArtist.text = [track valueForKey: MPMediaItemPropertyArtist];
    self.songAlbum.text = [track valueForKey: MPMediaItemPropertyAlbumTitle];
    self.songDuration = [track valueForProperty:MPMediaItemPropertyPlaybackDuration];
    int minutes = floor([self.songDuration floatValue] / 60);
    int seconds = trunc([self.songDuration floatValue] - minutes * 60);
    self.trackDuration.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    self.trackTimer.text = @"00:00";
    self.songIndex.text = [NSString stringWithFormat:@"%03d/%03lu",self.playingSong+1,(unsigned long)self.songList.count];
    self.pauseIcon.hidden=YES;
    
    /* Artwork plus blurred background */
    MPMediaItemArtwork *itemArtwork = [track valueForProperty:MPMediaItemPropertyArtwork];
    //self.songArtwork.image = [itemArtwork imageWithSize:CGSizeMake(220, 220)];
    self.songArtwork.image = [itemArtwork imageWithSize:CGSizeMake(150, 150)];
    //if (self.songArtwork.image.size.height==0) {
    //    noItunesArtwork = YES;
    //    self.songArtwork.image = [UIImage imageNamed:@"vinyl-red"];
        
    //}
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    if ([animationType isEqualToString:@"fromRight"]) {
        transition.type = kCATransitionFromLeft;
    } else if ([animationType isEqualToString:@"slideLeft"]) {
        transition.type = kCATransitionPush;
    } else
    {
        transition.type = kCATransitionFromRight;
    }
    
    if (noItunesArtwork) {
        CGRect rect = CGRectMake(0,0,320,600);
        UIGraphicsBeginImageContext( rect.size );
        [self.songArtwork.image drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(picture1);
        blurredImage.image = [UIImage imageWithData:imageData];
    } else {
        blurredImage.image = [itemArtwork imageWithSize:CGSizeMake(320, 600)];
    }
    [self.view addSubview:[[UIImageView alloc] initWithImage:blurredImage.image]];
    //self.backgroundImage is the image that the method above returns, it's a screenshot of the presenting view controller.
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    [self.view addSubview:blurEffectView];
    
    // lastly bring all controls to front.
    [self.view bringSubviewToFront:self.songArtwork];
    [self.songArtwork.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.pauseIcon];
//    [self.view bringSubviewToFront:self.songNumberOfPlays];
    [self.view bringSubviewToFront:self.songTitle];
    [self.songTitle.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.songArtist];
    [self.songArtist.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.songAlbum];
    [self.songAlbum.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.trackDuration];
    [self.trackDuration.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.trackTimer];
    [self.trackTimer.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.songIndex];
    [self.songIndex.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.progressBar];
}





-(void) configureTimer {
    __block SongDetailViewController * weakSelf = self;
    [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time) {
                                                  if(!time.value) {
                                                      return;
                                                  }
                                                  
                                                  int currentTime = (int)((weakSelf.audioPlayer.currentTime.value)/weakSelf.audioPlayer.currentTime.timescale);
                                                  int currentMins = (int)(currentTime/60);
                                                  int currentSec  = (int)(currentTime%60);
                                                  
                                                  [weakSelf.progressBar setProgress:(int)currentTime / (int)weakSelf.songDuration animated:YES];
                                                  NSString * timerLabel =
                                                  [NSString stringWithFormat:@"%02d:%02d",currentMins,currentSec];
                                                  weakSelf.trackTimer.text = timerLabel;

                                                  
                                                float totalTime = [weakSelf.songDuration floatValue];
                                                float fltTime=((weakSelf.audioPlayer.currentTime.value/weakSelf.audioPlayer.currentTime.timescale  )/totalTime);
                                                  [weakSelf.progressBar setProgress:fltTime animated:true];
                                                  
                                                  
                                              }];
    
}

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (void)addItemViewController:(SongDetailViewController *)controller didChangeSong:(int)item {
    
}


@end
