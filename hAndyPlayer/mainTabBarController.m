//
//  mainTabBarController.m
//  Ears
//
//  Created by andrew glew on 13/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "mainTabBarController.h"
#import <AVFoundation/AVFoundation.h>
#import "YearsTableViewController.h"
#import "DecadesTableViewController.h"
#import "AppDelegate.h"

@interface mainTabBarController ()
@end

@implementation mainTabBarController
- (void)viewDidLoad {
    [super viewDidLoad];

}




-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.audioPlayer pause];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    
// UITableViewController* controller = segue.destinationViewController;
//    controller.audioplayer
 
 
}

@end
