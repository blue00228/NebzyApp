//
//  AppDelegate.m
//  NebzyApp
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <AudioToolbox/AudioServices.h>

@interface AppDelegate ()
@property (nonatomic, assign) BOOL isLaunching;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Configure Parse.com
    //[Parse setApplicationId:@"jBoXmiSW57MwTjWrw86Ux5qTVlH02lPi9MQiKFUf" clientKey:@"fajBDK1PdVSLDOdvm8WUFVGBtmeTqT0sd6z1T9rf"];
    
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"28fd82ca-8ad3-4cfb-b9bb-99c8f7919f95";
        configuration.clientKey = @"";
        configuration.server = @"https://api.parse.buddy.com/parse/";
    }]];
    
    
    //Configure Facebook AppID
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    //
    [PFTwitterUtils initializeWithConsumerKey:@"iQNjqROAI38XrpxXUr0lvYOPX" consumerSecret:@"LMuxKCup2KaGmwe1GaWmvI21sFCXi0lM9RubqS5A1jRiMFbnYo"];
    
    //Register Notification
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [self runSplashScreen];
    _isLaunching = YES;
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application                                 didFinishLaunchingWithOptions:launchOptions];
}

-(void) runSplashScreen {
    
    CGFloat logoSize = 100.0f;
    
    UIImage *splashImage = [UIImage imageNamed:@"login_bg1.png"];
    UIImageView *splashImageView = [[UIImageView alloc] initWithImage:splashImage];
    [self.window.rootViewController.view addSubview:splashImageView];
    [self.window.rootViewController.view bringSubviewToFront:splashImageView];
    
    UIBlurEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView;
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.window.rootViewController.view.bounds;
    
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrantEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
    vibrantEffectView.frame = self.window.rootViewController.view.bounds;
    
    [splashImageView addSubview:blurEffectView];
    [splashImageView addSubview:vibrantEffectView];
    
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    [logoImageView setFrame:CGRectMake(0, 0, logoSize, logoSize)];
    [self.window.rootViewController.view addSubview:logoImageView];
    [self.window.rootViewController.view bringSubviewToFront:logoImageView];
    CGSize size = self.window.rootViewController.view.frame.size;
    [logoImageView setCenter:CGPointMake(size.width/2, size.height/2 - logoSize)];
    
    UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
    [yourLabel setTextColor:[UIColor colorWithRed:90.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f]];
    [yourLabel setBackgroundColor:[UIColor clearColor]];
    [yourLabel setFont:[UIFont fontWithName: @"System Light" size: 16.0f]];
    [yourLabel setText:@"You are here!"];
    [yourLabel setTextAlignment:NSTextAlignmentCenter];
    [self.window.rootViewController.view addSubview:yourLabel];
    [self.window.rootViewController.view bringSubviewToFront:yourLabel];
    [yourLabel setCenter:CGPointMake(size.width/2, size.height/2)];
    
//    CGRect frame = [yourLabel frame];
//    frame.origin = CGPointMake(size.width/2, size.height/2+100);
//    [splashLabel setFrame:frame];
    
    [UIView animateWithDuration:2.0f
                          delay:.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         splashImageView.alpha = .0f;
                         CGFloat x = 80.0f;
                         CGFloat y = 120.0f;
                         splashImageView.frame = CGRectMake(x,
                                                            y,
                                                            splashImageView.frame.size.width-2*x,
                                                            splashImageView.frame.size.height-2*y);
                         logoImageView.alpha = .0f;
                         yourLabel.alpha = .0f;
                     } completion:^(BOOL finished){
                         if (finished) {
                             [splashImageView removeFromSuperview];
                             [logoImageView removeFromSuperview];
                             [yourLabel removeFromSuperview];
                         }
                     }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _isLaunching = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _isLaunching = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dev..NebzyApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NebzyApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NebzyApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //return [PFFacebookUtils handleOpenURL:url];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//Register PushNotificationToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    Global *g_Data = [Global sharedInstance];
    if(g_Data.tokenFlag) {
        currentInstallation[@"user"] = [PFUser currentUser];
    }
    else {
        g_Data.tokenFlag = YES;
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(_isLaunching) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    else {
        [PFPush handlePush:userInfo];
    }
}

//Called when app come back from Facebook
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

@end
