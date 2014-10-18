//
//  EarSongsTableViewController.m
//  Ears
//
//  Created by andrew glew on 05/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "SongsTableViewController.h"
#import "AppDelegate.h"
#import "SongDetailViewController.h"

@interface SongsTableViewController () <SongDetailDelegate>
@property (strong, nonatomic) NSArray *selectedYearSongs;
@property (strong, nonatomic) NSMutableArray *songList;
@property (assign) int playingSong;
@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property (nonatomic, assign, getter=isPushedSong) BOOL pushedSong;
@property (strong,nonatomic) NSMetadataQuery* fileDownloadMonitorQuery;
@property (nonatomic, strong) AVAudioSession *session;

//@property (nonatomic) [[UIApplication sharedApplication] delegate] *audioPlayer
@end

@implementation SongsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.audioPlayer = appDelegate.audioPlayer;
    appDelegate.songList = nil;
    appDelegate.songList = [NSMutableArray array];
    self.songList = appDelegate.songList;
    
    [self setPushedSong:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    
    MPMediaQuery *searchQuery = [[MPMediaQuery alloc] init];

    if (!self.showCloud) {
        [searchQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    }
    
    NSPredicate *test;
    if ([self.selectionType isEqualToString:@"decades"]) {
        if ([self.selectedDecade isEqualToString:@"00's"]) {
            self.title = @"?";
        } else {
            self.title = self.selectedDecade;
        }
        test = [NSPredicate predicateWithFormat:@"(year >= %lu) AND (year <= %lu)", strtoul([self.decadeStartYear UTF8String], NULL, 0), strtoul([self.decadeEndYear UTF8String], NULL, 0)];
        
    } else if ([self.selectionType isEqualToString:@"years"]) {
        if ([self.selectedYear isEqualToString :@"0"]) {
            self.title = @"?";
        } else {
            self.title = self.selectedYear;
        }
        test = [NSPredicate predicateWithFormat:@"year == %lu", strtoul([self.selectedYear UTF8String], NULL, 0)];
    } else {
        self.title = self.selectedArtist;
        test = [NSPredicate predicateWithFormat:@"artist == %@", self.selectedArtist];
    }
    
    NSArray *tempSongs = [[searchQuery items] filteredArrayUsingPredicate:test];
    [self.songList addObjectsFromArray:randomize(tempSongs)];
    
    [self.tableView reloadData];
    
    /* play the first track */
    MPMediaItem *song = [self.songList objectAtIndex:0];
    AVPlayerItem * currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self playAudio];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    if ([self.selectionType isEqualToString:@"decades"]) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:76.0/255.0 alpha:1.0];
    } else if ([self.selectionType isEqualToString:@"years"]) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:133.0/255.0 blue:51.0/255.0 alpha:1.0];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31.0/255.0 green:66.0/255.0 blue:115.0/255.0 alpha:1.0];
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
   
   // self.tabBarController.tabBar.hidden = YES;
    
    [self.songTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.playingSong inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

-(void)playerItemDidReachEnd {

    // validate this is not the last song.  if it is we stop playing!
    if (self.playingSong == self.songList.count - 1) {
        self.playingSong = 0;
    } else {
        self.playingSong ++;
    }
    [self setPushedSong:YES];
    [self.songTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.playingSong  inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self setPushedSong:NO];
    
    NSLog(@"SONGTABLE: PLAYERITEMDIDREACHEND, PLAYINGSONG:%d SONGLIST%@",self.playingSong,self.songList);
    
   
    
    MPMediaItem *song = [self.songList objectAtIndex:self.playingSong];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self playAudio];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.songList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YearSongs" forIndexPath:indexPath];
    
    MPMediaItem *song = [self.songList objectAtIndex:indexPath.row];
    
    if ([self.selectionType isEqualToString:@"activities"]) {
        cell.detailTextLabel.text = [song valueForKey: MPMediaItemPropertyAlbumTitle];
    } else {
        cell.detailTextLabel.text = [song valueForKey: MPMediaItemPropertyArtist];
    }
    
    cell.textLabel.text = [song valueForProperty: MPMediaItemPropertyTitle];
    
    if ([self.selectionType isEqualToString:@"decades"]) {
        cell.textLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:76.0/255.0 alpha:1.0];
    } else  if ([self.selectionType isEqualToString:@"years"]) {
        cell.textLabel.textColor = [UIColor colorWithRed:37.0/255.0 green:133.0/255.0 blue:51.0/255.0 alpha:1.0];
    } else {
        cell.textLabel.textColor = [UIColor colorWithRed:31.0/255.0 green:66.0/255.0 blue:115.0/255.0 alpha:1.0];
    }
    
    
    if (self.showCloud==YES) {
        NSNumber *isCloudNumber = [song valueForProperty:MPMediaItemPropertyIsCloudItem];
        bool isCloud = [isCloudNumber boolValue];
    
        if (isCloud) {
            cell.imageView.hidden = NO;
        } else {
            cell.imageView.hidden = YES;
        }
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isPushedSong] == YES) {
            // Do nothing
    } else {
        /* only modify the song if the user changes the track */
        if (self.playingSong != indexPath.row) {
            self.playingSong = (int)indexPath.row;
            [self.audioPlayer pause];
            MPMediaItem *song = [self.songList objectAtIndex:self.playingSong];
            AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
            [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
            [self playAudio];
        }
    }
}


-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void) playAudio {
    
    [self.audioPlayer play];

    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

    if (playingInfoCenter) {
    
        
    
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    
        [songInfo setObject:@"Audio Title" forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:@"Audio Author" forKey:MPMediaItemPropertyArtist];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
    
    }
   
 
}


#pragma mark - Navigation



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender   {
    
    if([segue.identifier isEqualToString:@"showSongDetail"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SongDetailViewController *controller = (SongDetailViewController *)segue.destinationViewController;
        controller.songList = self.songList;
        controller.playingSong = (int)indexPath.row;
        //controller.audioPlayer = self.audioPlayer;
        controller.selectionType = self.selectionType;
        controller.delegate = self;
    }
}



NSArray *randomize(NSArray *arr)
{
    /* Version 2: A better randomizer method */
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arr];
    NSUInteger count = [mutableArray count];
    // See http://en.wikipedia.org/wiki/Fisher–Yates_shuffle
    if (count > 1) {
        for (NSUInteger i = count - 1; i > 0; --i) {
            [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))];
        }
    }
    
    NSArray *randomArray = [NSArray arrayWithArray:mutableArray];
    return randomArray;
}


- (void)addItemViewController:(SongDetailViewController *)controller didChangeSong:(int)item
{
    // required to pass data from songs detail back to this table view controller
    self.playingSong = item;
     NSLog(@"updated from songdetail swipe/end of song: self.playingSong = %d", self.playingSong);
}


//interface
void audioRouteChangeListenerCallback ( void     *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue );
//implementation
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue ) {
    
    // ensure that this callback was invoked for a route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    // Determines the reason for the route change,
    // to ensure that it is not because of a category change.
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue ( routeChangeDictionary,
                                                             CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    // "Old device unavailable"
    // headset was unplugged, or device was removed from a dock connector
    // that supports audio output. A test for when audio is paused
   // YOURPLAYERINSTANCE *playerInstance = (YOURPLAYERINSTANCE*) inUserData;
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        // player might respond appropriately - pause
    } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable){
        //audio plugged back in, player might respond appropriately - play }
    }
}
@end
