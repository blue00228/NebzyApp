//
//  LoginViewController.m
//  NebzyApp
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ProgressHUD.h"

#import <AVFoundation/AVFoundation.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import "PF_Twitter.h"
#import "NTRTwitterClient.h"
#import "FHSTwitterEngine.h"
#import "UserListViewController.h"
#import "CustomSegue.h"
#import "CustomUnwindSegue.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LoginViewController ()

@property (nonatomic , strong) AVPlayer *avPlayer;

@end

@implementation LoginViewController

- (void)initializeAudioSession {
    
    //Not affecting background music playing
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"intro" ofType:@"mov"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];
    [self.movieView.layer addSublayer:avPlayerLayer];
    
    //Config player
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer setVolume:0.0f];
    [self.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //Config dark gradient view
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [[UIScreen mainScreen] bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x030303) CGColor], (id)[[UIColor clearColor] CGColor], (id)[UIColorFromRGB(0x030303) CGColor],nil];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem.title = @"";
    [super setBlurBackground];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view, typically from a nib.
    [self initializeAudioSession];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.avPlayer play];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"Segue_Login" sender:nil];
        //[Global logOut];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.avPlayer pause];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerStartPlaying
{
    [self.avPlayer play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (IBAction)onFacebookLogin:(id)sender {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [super showSpinner:NO];
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        else {
//            NSDictionary *authDic = (NSDictionary *)[user valueForKey:@"authData"];
//            NSString *fbId = authDic[@"facebook"][@"id"];
            
            if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        // result is a dictionary with the user's Facebook data
                        NSDictionary *userData = (NSDictionary *)result;
                        
                        NSString *fbId = userData[@"id"];
                        NSString *name = userData[@"name"];
                        [user setObject:fbId forKey:PF_USER_FACEBOOKID];
                        [user setObject:name forKey:PF_USER_FULLNAME];
                        [user setObject:@"Facebook" forKey:PF_USER_SOCIAL];
                        NSString *picURLStr = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fbId];
                        [user setObject:picURLStr forKey:PF_USER_PICTURE];
                        [user saveInBackground];
                    }
                }];
            } else {
                NSLog(@"User logged in through Facebook!");
            }
            [self userLoggedIn:user];
            
        }
    }];
    
    [super showSpinner:YES]; // Show loading indicator until login is finished
}

-(IBAction)onTwitterLogin:(id)sender
{
    [PFTwitterUtils getTwitterAccounts:^(BOOL accountsWereFound, NSArray *twitterAccounts) {
        [self handleTwitterAccounts:twitterAccounts];
    }];
    [super showSpinner:YES];
}

- (void)handleTwitterAccounts:(NSArray *)twitterAccounts
{
    switch ([twitterAccounts count]) {
        case 0:
        {
            [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:NTR_TWITTER_CONSUMER_KEY andSecret:NTR_TWITTER_CONSUMER_SECRET];
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [self loginUserWithTwitterEngine];
                }
            }];
            [self presentViewController:loginController animated:YES completion:nil];
        }
            break;
        case 1:
            [self onUserTwitterAccountSelection:twitterAccounts[0]];
            break;
        default:
            self.twitterAccounts = twitterAccounts;
            [self displayTwitterAccounts:twitterAccounts];
            break;
    }
    
}

- (void)displayTwitterAccounts:(NSArray *)twitterAccounts
{
    __block UIActionSheet *selectTwitterAccountsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account"
                                                                                          delegate:self
                                                                                 cancelButtonTitle:nil
                                                                            destructiveButtonTitle:nil
                                                                                 otherButtonTitles:nil];
    
    [twitterAccounts enumerateObjectsUsingBlock:^(id twitterAccount, NSUInteger idx, BOOL *stop) {
        [selectTwitterAccountsActionSheet addButtonWithTitle:[twitterAccount username]];
    }];
    selectTwitterAccountsActionSheet.cancelButtonIndex = [selectTwitterAccountsActionSheet addButtonWithTitle:@"Cancel"];
    
    [selectTwitterAccountsActionSheet showInView:self.view];
}

- (void)onUserTwitterAccountSelection:(ACAccount *)twitterAccount
{
    [self loginUserWithAccount:twitterAccount];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self onUserTwitterAccountSelection:self.twitterAccounts[buttonIndex]];
    }
}

- (void)userLoggedIn:(PFUser *)user
{
    [user setObject:@"YES" forKey:@"login"];
    [user saveInBackground];
    [super showSpinner:NO];
    
    //Register token
    Global *g_Data = [Global sharedInstance];
    if(g_Data.tokenFlag) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation[@"user"] = user;
        [currentInstallation saveInBackground];
    }
    else {
        g_Data.tokenFlag = YES;
    }
    [self performSegueWithIdentifier:@"Segue_Login" sender:nil];
}

- (void)loginUserWithAccount:(ACAccount *)twitterAccount
{
    [PFTwitterUtils initializeWithConsumerKey:NTR_TWITTER_CONSUMER_KEY consumerSecret:NTR_TWITTER_CONSUMER_SECRET];
    
    [PFTwitterUtils setNativeLogInSuccessBlock:^(PFUser *parseUser, NSString *userTwitterId, NSError *error) {
        [self userLoggedIn:parseUser];
    }];
    
    [PFTwitterUtils setNativeLogInErrorBlock:^(TwitterLogInError logInError) {
        NSError *error = [[NSError alloc] initWithDomain:nil code:logInError userInfo:@{@"logInErrorCode" : @(logInError)}];
        NSLog(@"%@", error);
        //[self onLoginFailure:error];
    }];
    
    [PFTwitterUtils logInWithAccount:twitterAccount];
}

- (void)loginUserWithTwitterEngine
{
    [PFTwitterUtils initializeWithConsumerKey:NTR_TWITTER_CONSUMER_KEY consumerSecret:NTR_TWITTER_CONSUMER_SECRET];
    
    FHSTwitterEngine *twitterEngine = [FHSTwitterEngine sharedEngine];
    FHSToken *token = [FHSTwitterEngine sharedEngine].accessToken;
    
    [PFTwitterUtils logInWithTwitterId:twitterEngine.authenticatedID
                            screenName:twitterEngine.authenticatedUsername
                             authToken:token.key
                       authTokenSecret:token.secret
                                 block:^(PFUser *user, NSError *error) {
                                     if (user) {
                                         [self fetchDataForUser:user username:twitterEngine.authenticatedUsername];
                                         [self userLoggedIn:user];
                                         
                                     } else {
                                         //[self onLoginFailure:error];
                                         [super showSpinner:NO];
                                     }
                                 }];
}

- (void)fetchDataForUser:(PFUser *)user username:(NSString *)twitterUsername
{
    NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", twitterUsername];
    
    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            user.username = result[@"screen_name"];
            user[PF_USER_FULLNAME]= result[@"name"];
            //user[@"profileDescription"] = result[@"description"];
            user[PF_USER_SOCIAL] = @"Twitter";
            user[PF_USER_PICTURE] = [result[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
            [user saveEventually];
        }
    }];
    
}


-(void) getMyCurrentLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                NSInteger errCode = [error code];
//                if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
//                    [[PFUser currentUser] saveEventually];
                if(succeeded)
                    [self performSegueWithIdentifier:@"Segue_Login" sender:nil];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewTouched:(id)sender
{
    [self dismissKeyboard];
}

- (void) dismissKeyboard {
//    [self.txt_username resignFirstResponder];
//    [self.txt_password resignFirstResponder];
}

// Prepare for the segue going forward
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue isKindOfClass:[CustomSegue class]]) {
        // Set the start point for the animation to center of the button for the animation
        ((CustomSegue *)segue).originatingPoint = self.view.center;
    }
}

// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // Instantiate a new CustomUnwindSegue
    CustomUnwindSegue *segue = [[CustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    // Set the target point for the animation to the center of the button in this VC
    segue.targetPoint = self.view.center;
    return segue;
}

@end
