//
//  UserListViewController.m
//  NebzyApp
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserListViewController.h"
#import "UserProfileCollectionViewCell.h"
#import "DataStore.h"

#define leftRightInset 5
#define cellspacing 4
#define columnCount 3

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Logout button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Log out"
                                   style: UIBarButtonItemStylePlain
                                   target: self action: @selector(logOut:)];
    self.navigationItem.leftBarButtonItem = backButton;

    self.collectionView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    //self.collectionView.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    //[doubleTapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:doubleTapGesture];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    //lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    [self getMyCurrentLocation];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        PFUser *userObject = (PFUser *)[[super objects] objectAtIndex:indexPath.row];
        Global *g_Data = [Global sharedInstance];
        g_Data.selectedUser = userObject;
        [self performSegueWithIdentifier:@"Segue_Profile" sender:nil];
    }
}

- (void) processDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath)
        {
            //NSLog(@"Image was double tapped");
            PFUser *userObject = (PFUser *)[[super objects] objectAtIndex:indexPath.row];       //Receiving user
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
            [pushQuery whereKey:@"user" equalTo:userObject];
            /*NSDictionary *data = @{
             @"alert" : @"Hello! How are you?",
             @"badge" : @"Increment",
             @"sounds" : @""
             };
             PFPush *push = [[PFPush alloc] init];
             [push setQuery:pushQuery];
             [push setData:data];
             [push sendPushInBackground];*/
            [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:@"\ue32b"];
            //[PFPush sendPushMessageToChannelInBackground:@"global" withMessage:@"Hello World!"];
            UserProfileCollectionViewCell *curCell = (UserProfileCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            [curCell.heartImage.superview bringSubviewToFront:curCell.heartImage];
            
            
            curCell.heartImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            
//            [self.view addSubview:popUp];
            [curCell.heartImage setHidden:NO];
            [UIView animateWithDuration:0.3/1.5 animations:^{
                curCell.heartImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    curCell.heartImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        curCell.heartImage.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
        else
        {
            
        }
    }
}

- (void) setBlurBackground {
    UIBlurEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView;
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrantEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
    vibrantEffectView.frame = self.view.bounds;
    
    [self.view addSubview:blurEffectView];
    [self.view addSubview:vibrantEffectView];
}

- (void)logOut:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        return;
    }
    else
    {
        //[PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        [Global logOut];
        [self dismissViewControllerAnimated:YES completion:NULL];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        //}];
        
    }
}

-(void) getMyCurrentLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded)
                {
                    self.myGeoPoint = geoPoint;
                    [self loadObjects];                 //Refresh CollectionView
                }
            }];
        }
    }];
}

-(void) getNearbyFriends {
    
    PFGeoPoint *myGeoPoint = (PFGeoPoint *)[[PFUser currentUser] valueForKey:@"currentLocation"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"currentLocation" nearGeoPoint:myGeoPoint withinKilometers:kUserRadius];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            PFGeoPoint * geoPoint1 = [PFUser currentUser][@"currentLocation"];
            for (PFObject *object in objects) {
                
                // DISTANCE
                
                PFGeoPoint * geoPoint2 = object[@"currentLocation"];
                
                CLLocation *location1 = [[CLLocation alloc]
                                         initWithLatitude:geoPoint1.latitude
                                         longitude:geoPoint1.longitude];
                
                CLLocation *location2 = [[CLLocation alloc]
                                         initWithLatitude:geoPoint2.latitude
                                         longitude:geoPoint2.longitude];
                
                
                CLLocationDistance distance = [location1 distanceFromLocation:location2];
                
                // Print out the distance
                NSLog(@"There's %f km between you and this user", distance);
            }
            
        } else {
            // Details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

#pragma mark -
#pragma mark Query

- (PFQuery *)queryForCollection {
    
    if(![[PFUser currentUser] objectForKey:@"currentLocation"])
        return nil;
    //PFQuery *query = [super queryForCollection];
    PFGeoPoint *myGeoPoint = (PFGeoPoint *)[[PFUser currentUser] objectForKey:@"currentLocation"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"currentLocation" nearGeoPoint:myGeoPoint withinMiles:kUserRadius];
    [query whereKey:@"login" equalTo:@"YES"];
    query.limit = 300;
    return query;
}

#pragma mark -
#pragma mark CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [[super objects] count];
    return count;
}

- (PFCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
                                  object:(PFObject *)object {
    
    UserProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserProfileCollectionViewCell" forIndexPath:indexPath];
    PFUser *selUser = (PFUser *) object;
    NSString *url = selUser[PF_USER_PICTURE];
    if(url)
        [cell setPictureWithURL:url];
    
    DataStore *dataStore = [DataStore instance];
    if([dataStore.fbFriends objectForKey:selUser.objectId] == nil)
        [dataStore.fbFriends setObject:selUser forKey:selUser.objectId];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat picDimension = (self.view.frame.size.width- (leftRightInset*2) - (cellspacing*(columnCount-1))) / columnCount;
    return CGSizeMake(picDimension, picDimension);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //(self.view.frame.size.width-15) / 14.0f;
    return UIEdgeInsetsMake(leftRightInset,leftRightInset,leftRightInset,leftRightInset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
