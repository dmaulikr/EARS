//
//  YearsTableViewController.m
//  hAndyPlayer
//
//  Created by andrew glew on 04/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "YearsTableViewController.h"
#import "SongsTableViewController.h"
#import "AppDelegate.h"

@interface YearsTableViewController ()
@property (strong, nonatomic) NSMutableArray *songsList;
@property (strong, nonatomic) NSArray *uniqueYearList;
@property (nonatomic, assign) BOOL showCloud;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonShowCloud;
@end

@implementation YearsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.audioPlayer = appDelegate.audioPlayer;
    
    [self setShowCloud: NO];
    [self loadYearView];
   
}

-(void)loadYearView {
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    if (!self.showCloud) {
        [everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    }
    NSArray *itemsFromGenericQuery = [everything items];
    self.songsList = [NSMutableArray arrayWithArray:itemsFromGenericQuery];
    
    // create new NSArray object yearList that picks out the year and turns it into a string value
    NSArray *stringYears = [[self.songsList valueForKey:@"year"] valueForKey:@"stringValue"];
    NSCountedSet *countedList = [[NSCountedSet alloc] initWithArray:stringYears];
    NSMutableArray *yearListingUnsorted = [[NSMutableArray alloc] init];
    
    for (NSString *myYearList in countedList) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:myYearList forKey:@"year"];
        [dict setValue:[NSString stringWithFormat:@"%lu songs",(long)[countedList countForObject:myYearList]] forKey:@"count"];
        [yearListingUnsorted addObject:dict];
    }
    
    // next sort array by key 'year'
    NSSortDescriptor * yearDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"year"
                                ascending:YES];
    NSMutableArray * descriptors = [NSMutableArray arrayWithObjects:yearDescriptor, nil];
    self.uniqueYearList = [yearListingUnsorted sortedArrayUsingDescriptors:descriptors];
    [self.tableView reloadData];
  
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:133.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
   [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]}];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:133.0/255.0 blue:51.0/255.0 alpha:1.0];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.uniqueYearList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YearCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"YearCell"]; //
    }
    
    // Set up the cell...
    if (![[[self.uniqueYearList objectAtIndex:indexPath.row]valueForKey:@"year"] isEqualToString:@"0"]) {
        cell.textLabel.text = [[self.uniqueYearList objectAtIndex:indexPath.row]valueForKey:@"year"];
    } else {
        cell.textLabel.text = @"Unknown";
    }
    cell.detailTextLabel.text = [[self.uniqueYearList objectAtIndex:indexPath.row]valueForKey:@"count"];
    
    
    cell.textLabel.textColor = [UIColor colorWithRed:37.0/255.0 green:133.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // stops the runtime error where we are forcing output to close
    [self.audioPlayer pause];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender   {
    
    if([segue.identifier isEqualToString:@"showYearSongs"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SongsTableViewController *controller = (SongsTableViewController *)segue.destinationViewController;
        
        controller.selectedYear = [[self.uniqueYearList objectAtIndex:indexPath.row]valueForKey:@"year"];
        //controller.audioPlayer = self.audioPlayer;
        controller.selectionType = @"years";
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
    [self loadYearView];
}



@end
