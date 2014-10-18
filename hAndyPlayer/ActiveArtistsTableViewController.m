//
//  ActiveArtistsTableViewController.m
//  Ears
//
//  Created by andrew glew on 16/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "ActiveArtistsTableViewController.h"
#import "SongsTableViewController.h"


@interface ActiveArtistsTableViewController () <SelectDateDelegate>

@property (strong, nonatomic) NSMutableArray *artistList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonShowCloud;
@property (nonatomic, assign) BOOL showCloud;
@end



@implementation ActiveArtistsTableViewController



- (void)viewDidLoad {
    NSLog(@"ViewDidLoad called");
    
    [super viewDidLoad];
    
    self.tableView.dataSource =self;
    self.tableView.delegate = self;

    
    [self setShowCloud: NO];
    if (self.userSelectedDate==nil) {
        NSLog(@"empty");
    } else {
        NSLog(@"we got a value! %@", self.userSelectedDate);
        [self loadData];
        self.userSelectedDate = nil;
    }
    
 }



- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31.0/255.0 green:66.0/255.0 blue:115.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]}];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:31.0/255.0 green:66.0/255.0 blue:115.0/255.0 alpha:1.0];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.artistList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistActive" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.artistList objectAtIndex:indexPath.row]valueForKey:@"artist"];
    NSString *cellConcat = [[NSString alloc] initWithFormat:@"%@, %@", [[self.artistList objectAtIndex:indexPath.row]valueForKey:@"collectionName"], [[self.artistList objectAtIndex:indexPath.row]valueForKey:@"releaseDate"]];
    cell.detailTextLabel.text = cellConcat;
    cell.textLabel.textColor = [UIColor colorWithRed:31.0/255.0 green:66.0/255.0 blue:115.0/255.0 alpha:1.0];

    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[self.artistList objectAtIndex:indexPath.row]valueForKey:@"artworkUrl60"]]];
    UIImage *image = [UIImage imageWithData:imageData];
    cell.imageView.image = image;
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


- (IBAction)refreshPressed:(id)sender {
  
    // [self loadData];
}




-(void) loadData {
    
    self.artistList = [[NSMutableArray alloc] init];
    
    MPMediaQuery *query=[MPMediaQuery artistsQuery];
    
    if (!self.showCloud) {
        [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    }
    
    
    NSArray *artists=[query collections];
    
    NSString *artist;
    NSString *collectionName;
    NSString *releaseDate;
    NSString *artworkUrl60;
    NSString *niceReleaseDate;
    NSDate *dateOfRelease;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *niceDateFormatter = [[NSDateFormatter alloc] init];
    [niceDateFormatter setDateFormat:@"MMMM d yyyy"];
    
    NSString *formattedArtist;
    
    
    for(MPMediaItemCollection *collection in artists)
    {
        NSString *artistTitle = [[collection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        unichar firstCharacter = [artistTitle characterAtIndex:0];
        unichar lastCharacter = [artistTitle characterAtIndex:[artistTitle length] - 1];
        
        
        
        if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:firstCharacter] ||
            [[NSCharacterSet whitespaceCharacterSet] characterIsMember:lastCharacter]) {
            artistTitle = [artistTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        NSData *temp = [artistTitle dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *formatted = [[NSString alloc] initWithData:temp encoding:NSASCIIStringEncoding];
        formattedArtist = [formatted stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (CFStringRef)formattedArtist,
                                                                                                        NULL,
                                                                                                        CFSTR("!*'();:@&=$,/?%#[]\" "),
                                                                                                        kCFStringEncodingUTF8));
        
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/search?country=gb&entity=album&&attribute=allArtistTerm&term=%@",escapedString];
        
        // [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // https://itunes.apple.com/search?country=gb&entity=album&attribute=allArtistTerm&term=
        // https://itunes.apple.com/lookup?id=435800519&entity=album&sort=recent  start 06:59
        
        NSError *e = nil;
        NSData *jsonFeed = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if (!jsonFeed) {
            NSLog(@"Error obtaining JSON");
        } else {
        
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:jsonFeed options:NSJSONReadingMutableContainers error: &e];
        
            NSLog(@"START5: %@",formattedArtist);
        
            if (!jsonData) {
                NSLog(@"Error parsing JSON: %@", e);
            } else {
            
                for(NSDictionary *item in [jsonData objectForKey:@"results"]) {
                    artist = [item valueForKey:@"artistName"];

                    if (![artist isEqualToString:artistTitle]) {
                        continue;
                    }
                    collectionName = [item valueForKey:@"collectionName"];
                    releaseDate = [item valueForKey:@"releaseDate"];
                    artworkUrl60 = [item valueForKey:@"artworkUrl60"];
                
                    dateOfRelease = [dateFormatter dateFromString:releaseDate];
                
                    NSComparisonResult compareResult = [self.userSelectedDate compare : dateOfRelease];
                
                    if (compareResult == NSOrderedAscending)
                    {
                        NSLog(@"ARTIST=%@",artist);
                    
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setValue:artist forKey:@"artist"];
                        [dict setValue:collectionName forKey:@"collectionName"];
                    
                        niceReleaseDate = [niceDateFormatter stringFromDate:dateOfRelease];
                    
                        [dict setValue:niceReleaseDate forKey:@"releaseDate"];
                        [dict setValue:artworkUrl60 forKey:@"artworkUrl60"];
                    
                        [self.artistList addObject:dict];
                        NSLog(@"%lu",(unsigned long)self.artistList.count);
                        break;
                    }
                    else if (compareResult == NSOrderedDescending)
                    {
                        // Release date before today.
                    }
                    else
                    {
                        // Actually release date of today!
                    }
                }
            }
            
        }
    }
    NSLog(@"%@",self.artistList);
    [self.tableView reloadData];
}




// Version 2! Is this optimazed verson of original or is it slower due to twice as many network requests?
-(void) TestloadData {
    
    self.artistList = [[NSMutableArray alloc] init];
    
    MPMediaQuery *query=[MPMediaQuery artistsQuery];
    
    if (!self.showCloud) {
        [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    }
    
    
    NSArray *artists=[query collections];
    
    NSString *artist;
    NSString *collectionName;
    NSString *releaseDate;
    NSString *artworkUrl60;
    NSString *niceReleaseDate;
    NSDate *dateOfRelease;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *niceDateFormatter = [[NSDateFormatter alloc] init];
    [niceDateFormatter setDateFormat:@"MMMM d yyyy"];
    
    NSString *formattedArtist;
    
    
    for(MPMediaItemCollection *collection in artists)
    {
        NSString *artistTitle = [[collection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        unichar firstCharacter = [artistTitle characterAtIndex:0];
        unichar lastCharacter = [artistTitle characterAtIndex:[artistTitle length] - 1];
        
        
        
        if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:firstCharacter] ||
            [[NSCharacterSet whitespaceCharacterSet] characterIsMember:lastCharacter]) {
            artistTitle = [artistTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        NSData *temp = [artistTitle dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *formatted = [[NSString alloc] initWithData:temp encoding:NSASCIIStringEncoding];
        formattedArtist = [formatted stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (CFStringRef)formattedArtist,
                                                                                                        NULL,
                                                                                                        CFSTR("!*'();:@&=$,/?%#[]\" "),
                                                                                                        kCFStringEncodingUTF8));
        
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/search?country=gb&entity=album&limit=1&attribute=allArtistTerm&term=%@",escapedString];
        
        // [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // https://itunes.apple.com/search?country=gb&entity=album&attribute=allArtistTerm&term=
        // https://itunes.apple.com/lookup?id=435800519&entity=album&sort=recent  start 06:59
        
        NSError *e = nil;
        NSData *jsonFeed = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if (!jsonFeed) {
            NSLog(@"Error obtaining JSON");
        } else {
            
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:jsonFeed options:NSJSONReadingMutableContainers error: &e];
            
            if (!jsonData) {
                NSLog(@"Error parsing JSON: %@", e);
            } else {
                
                for(NSDictionary *result in [jsonData objectForKey:@"results"]) {

                
                    NSString *urlString = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/lookup?country=gb&entity=album&sort=recent&limit=1&id=%@",[result valueForKey:@"artistId"]];

                    NSError *e = nil;
                    NSData *jsonLookupFeed = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                
                    if (!jsonLookupFeed) {
                        NSLog(@"Error obtaining lookup JSON");
                    } else {
                
                        NSDictionary *jsonLookupData = [NSJSONSerialization JSONObjectWithData:jsonLookupFeed options:NSJSONReadingMutableContainers error: &e];
                    
                        if (!jsonLookupData) {
                            NSLog(@"Error parsing lookup JSON: %@", e);
                        } else {
                            
                            for(NSDictionary *lookupresult in [jsonLookupData objectForKey:@"results"]) {
                                if([[lookupresult valueForKey:@"wrapperType"] isEqualToString:@"collection"]) {

                            
                                artist = [lookupresult valueForKey:@"artistName"];
                        
                                if (![artist isEqualToString:artistTitle]) {
                                    continue;
                                }
                                collectionName = [lookupresult valueForKey:@"collectionName"];
                                releaseDate = [lookupresult valueForKey:@"releaseDate"];
                                artworkUrl60 = [lookupresult valueForKey:@"artworkUrl60"];
                        
                                dateOfRelease = [dateFormatter dateFromString:releaseDate];
                        
                                NSComparisonResult compareResult = [self.userSelectedDate compare : dateOfRelease];
                        
                                if (compareResult == NSOrderedAscending)
                                {
                                    NSLog(@"ARTIST=%@",artist);
                            
                                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                    [dict setValue:artist forKey:@"artist"];
                                    [dict setValue:collectionName forKey:@"collectionName"];
                            
                                    niceReleaseDate = [niceDateFormatter stringFromDate:dateOfRelease];
                            
                                    [dict setValue:niceReleaseDate forKey:@"releaseDate"];
                                    [dict setValue:artworkUrl60 forKey:@"artworkUrl60"];
                            
                                    [self.artistList addObject:dict];
                                    NSLog(@"%lu",(unsigned long)self.artistList.count);
                                    break;
                                }
                                else if (compareResult == NSOrderedDescending)
                                {
                                    // Release date before today.
                                }
                                else
                                {
                                    // Actually release date of today!
                                }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    NSLog(@"%@",self.artistList);
    [self.tableView reloadData];
}












- (IBAction)showCloudPressed:(id)sender {
    [self setShowCloud: ![self showCloud]];

    if (self.showCloud==NO) {
        self.buttonShowCloud.tintColor = [UIColor blackColor];
    } else {
        self.buttonShowCloud.tintColor = [UIColor whiteColor];
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showActivitySongs"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SongsTableViewController *controller = (SongsTableViewController *)segue.destinationViewController;
        controller.selectedArtist = [[self.artistList objectAtIndex:indexPath.row]valueForKey:@"artist"];
        controller.selectionType = @"activities";
        controller.showCloud = self.showCloud;
        controller.hidesBottomBarWhenPushed = YES;        
    } else if([segue.identifier isEqualToString:@"ShowDatePicker"]){
        SelectDateViewController *controller = (SelectDateViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
        
        
}

- (void)addItemViewController:(SelectDateViewController *)controller didPickDateWithSelectedDate:(NSDate *)selectedDate {
    NSLog(@"Triggered delegate!!!  :-)");
    self.userSelectedDate = selectedDate;
    
    NSDateFormatter *titleDateFormatter = [[NSDateFormatter alloc] init];
    [titleDateFormatter setDateFormat:@"d MMM yyyy"];
    
    self.title = [titleDateFormatter stringFromDate:selectedDate];
    
    [self loadData];
}



@end
