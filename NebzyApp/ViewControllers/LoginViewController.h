//
//  LoginViewController.h
//  NebzyApp
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyViewController.h"

@interface LoginViewController : MyViewController <UIActionSheetDelegate>

{
    
}

@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIView *gradientView;

- (IBAction) onFacebookLogin:(id)sender;
- (IBAction) viewTouched:(id)sender;

@end

