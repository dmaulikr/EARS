//
//  SelectDateViewController.h
//  Ears
//
//  Created by andrew glew on 19/08/14.
//  Copyright (c) 2014 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectDateViewController;

@protocol SelectDateDelegate <NSObject>
- (void)addItemViewController:(SelectDateViewController *)controller didPickDateWithSelectedDate:(NSDate *)selectedDate;
@end

@interface SelectDateViewController : UIViewController
@property (nonatomic, weak) id <SelectDateDelegate> delegate;
@end




