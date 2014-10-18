//
//  DecadesTableViewController.m
//  Ears
//
//  Created by andrew glew on 10/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "DecadesTableViewController.h"
#import "SongsTableViewController.h"
#import "AppDelegate.h"

@interface DecadesTableViewController ()
@property (strong, nonatomic) NSMutableArray *selectedSongs;
@property (strong, nonatomic) NSMutableArray *decadesListing;
@property (nonatomic, assign) BOOL showCloud;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonShowCloud;
@end

@implementation DecadesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setShowCloud: NO];
    self.tableView.dataSource =self;
    self.tableView.delegate = self;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.audioPlayer = appDelegate.audioPlayer;
    
    [self loadDecadesView];
}

-(void)loadDecadesView {
   
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate.songList removeAllObjects];
    
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    if (!self.showCloud) {
        [everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    }
    
    NSArray *itemsFromGenericQuery = [everything items];
    self.selectedSongs = [NSMutableArray arrayWithArray:itemsFromGenericQuery];
    
    // create new NSArray object yearList that picks out the year and turns it into a string value
    NSArray *stringYears = [[self.selectedSongs valueForKey:@"year"] valueForKey:@"stringValue"];
    NSCountedSet *countedList = [[NSCountedSet alloc] initWithArray:stringYears];
    NSMutableArray *yearListingUnsorted = [[NSMutableArray alloc] init];
    
    for (NSString *myYearList in countedList) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:myYearList forKey:@"year"];
        [dict setValue:[NSString stringWithFormat:@"%lu",(long)[countedList countForObject:myYearList]] forKey:@"count"];
        [yearListingUnsorted addObject:dict];
    }
    
    /* TODO
     Appears yearListingUnsorted is used in both this view and the other.  It would be faster and more efficient if this was shared.
     */
    
    
    /*create a new dictionary;  check first 3 chars of year e.g. 1954 '195' and collect the count until first 3 digits change. add new object to array so array might be;
     
     (  {   id          =   0;
     sumOfSongs  =   1154;
     decade      =   "00's";
     },
     {      id          =   199
     sumOfSongs  =   1582;
     decade      =   "1990's"
     },
     {      id          =   200
     sumOfSongs  =   3488;
     decade      =   "2000's"
     */
    
    
    NSArray *decades = @[@"190", @"191", @"192",@"193", @"194", @"195", @"196", @"197", @"198", @"199", @"200", @"201", @"202", @"203", @"204", @"205", @"0" ];
    
    NSString *fullDecadeRef;
    NSPredicate *p;
    NSArray *decadeArray;
    self.decadesListing = [[NSMutableArray alloc] init];
    
    for (NSString *decade in decades) {
        /* manage the predicate, to handle the 0/unknown year songs in collection were released */
        if ([decade  isEqual: @"0"]) {
            p = [NSPredicate predicateWithFormat:
                 @"year == '0'", decade];
        } else {
            p = [NSPredicate predicateWithFormat:
                 @"year CONTAINS %@", decade];
        }
        decadeArray = [yearListingUnsorted filteredArrayUsingPredicate:p];
        
        /* next use a nifty enumerateObjectsUsingBlock to get the sum of key 'count' for
         filtered selection */
        __block int sumOfSongs = 0;
        [decadeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            sumOfSongs += [[obj objectForKey:@"count"] integerValue];
        }];
        
        /* if items found in current decade, add to our mutable array the dictionary described above before the for loop */
        if (sumOfSongs!=0) {
            fullDecadeRef = [NSString stringWithFormat:@"%@0's",decade];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:decade forKey:@"id"];
            [dict setValue:fullDecadeRef forKey:@"decade"];
            [dict setValue:[NSString stringWithFormat:@"%d Songs",sumOfSongs] forKey:@"sumOfSongs"];
            [dict setValue:[NSString stringWithFormat:@"%@0",decade] forKey:@"startYear"];
            [dict setValue:[NSString stringWithFormat:@"%@9",decade] forKey:@"endYear"];
            [self.decadesListing addObject:dict];
        }
        
    }
    [self.tableView reloadData];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:76.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
   [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]}];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:76.0/255.0 alpha:1.0];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    
    NSLog(@"viewWillDisappear");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.decadesListing.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DecadeCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"DecadeCell"]; //
    }
    
    // Set up the cell...
    if (![[[self.decadesListing objectAtIndex:indexPath.row]valueForKey:@"decade"] isEqualToString:@"00's"]) {
        cell.textLabel.text = [[self.decadesListing objectAtIndex:indexPath.row]valueForKey:@"decade"];
    } else {
        cell.textLabel.text = @"Unknown";
    }
    cell.detailTextLabel.text = [[self.decadesListing objectAtIndex:indexPath.row]valueForKey:@"sumOfSongs"];
    
    cell.textLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:76.0/255.0 alpha:1.0];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // stops the runtime error where we are forcing output to close
    [self.audioPlayer pause];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
 
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender   {
 
 if([segue.identifier isEqualToString:@"showDecadeSongs"]){
 NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
 SongsTableViewController *controller = (SongsTableViewController *)segue.destinationViewController;
 controller.selectedDecade = [[self.decadesListing objectAtIndex:indexPath.row]valueForKey:@"decade"];
 controller.decadeStartYear = [[self.decadesListing objectAtIndex:indexPath.row]valueForKey:@"startYear"];
controller.decadeEndYear = [[self.decadesListing objectAtIndex:indexPath.row]valueForKey:@"endYear"];
 //controller.audioPlayer = self.audioPlayer;
controller.selectedYear = nil;
  controller.selectionType = @"decades";
controller.showCloud = self.showCloud;
     controller.hidesBottomBarWhenPushed = YES;
 }
}


- (IBAction)showCloudPressed:(id)sender {
    [self setShowCloud: ![self showCloud]];
    if (self.showCloud==NO) {
        self.buttonShowCloud.tintColor = [UIColor blackColor];
    } else {
        self.buttonShowCloud.tintColor = [UIColor whiteColor];
    }
    [self loadDecadesView];
}

@end
