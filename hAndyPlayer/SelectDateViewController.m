//
//  SelectDateViewController.m
//  Ears
//
//  Created by andrew glew on 19/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import "SelectDateViewController.h"
#import "AppDelegate.h"


@interface SelectDateViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation SelectDateViewController

//@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)threadStartAnimating:(id)data
{
    [self.indicatorView startAnimating];
}

- (IBAction)selectButtonPressed:(id)sender {
    
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.audioPlayer pause];
    [self.delegate addItemViewController:self didPickDateWithSelectedDate:self.datePicker.date];
    [self.indicatorView stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)addItemViewController:(SelectDateViewController *)controller didPickDateWithSelectedDate:(NSDate *)selectedDate {
    
}

@end
