//
//  UploadImageViewController.m
//  FBParse
//
//  Created by Toby Stephens on 29/05/2013.
//  Copyright (c) 2013 Toby Stephens. All rights reserved.
//

#import "UploadImageViewController.h"
#import "UIImage+Scaling.h"
#import "Define.h"
#import "ProgressHUD.h"

@interface UploadImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>
//@property (nonatomic, strong) IBOutlet UILabel *lblChooseAnImage;
//@property (nonatomic, strong) IBOutlet UIImageView *imgToUpload;
//@property (nonatomic, strong) IBOutlet UIButton *btnPhotoAlbum;
//@property (nonatomic, strong) IBOutlet UIButton *btnCamera;
//@property (nonatomic, strong) IBOutlet UITextField *txtComment;
//@property (nonatomic, strong) IBOutlet UIButton *btnUpload;
//@property (nonatomic, strong) IBOutlet UIView *vProgressUpload;
//@property (nonatomic, strong) IBOutlet UIProgressView *progressUpload;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@end

@implementation UploadImageViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [[self textView] setText:@""];
    [[self textView] becomeFirstResponder];
    
    _textView.layer.borderWidth = 1.0f;
    _textView.layer.borderColor = [UIColor blackColor].CGColor;
    
	// Check which types of Image Picker Source are available
	// For example, in the simulator, we won't be able to take a new photo with the camera
//	[_btnPhotoAlbum setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]];
//	[_btnCamera setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]];
//    CGFloat barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    CGRect frame = _textView.frame;
//    frame.origin.y = barHeight;
//    [_textView setFrame:frame];
}

- (IBAction) chooseImageFromPhotoAlbum
{
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
}

- (IBAction) createImageWithCamera
{
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
}

- (IBAction)postPost:(id)sender {
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [self.textView resignFirstResponder];
    
    PFObject *wallImageObject = [PFObject objectWithClassName:PF_WALL_POST_CLASSNAME];
    wallImageObject[@"text"] = self.textView.text;
    PFUser *curUser = [PFUser currentUser];
//    if(curUser[@"fbId"]) {
//        wallImageObject[@"userFBId"] = curUser[@"fbId"];
//    }
    wallImageObject[@"postObjectId"] = curUser.objectId;
    wallImageObject[@"imageURL"] = curUser[PF_USER_PICTURE];
    wallImageObject[@"user"] = curUser.username;
    
    [ProgressHUD show:@"Posting to wall..." Interaction:NO];
    
    [wallImageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [ProgressHUD dismiss];
        if (succeeded) {
            //[[NSNotificationCenter defaultCenter] postNotificationName:N_ImageUploaded object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Post failed" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alertview show];
        }
    }];
    
    
}

- (IBAction) uploadImage
{
	// Disable the Upload button to prevent multiple touches
//	[_btnUpload setEnabled:NO];
//
//	// Check that we have an image selected
//	if (!_imgToUpload.image) {
//		[[[UIAlertView alloc] initWithTitle:@"Upload Error"
//									message:@"Please choose an image before uploading"
//								   delegate:self
//						  cancelButtonTitle:@"Ok"
//						  otherButtonTitles:nil] show];
//		[_btnUpload setEnabled:YES];
//		return;
//	}
//
//	// Check that we have a comment to go with the image
//	if (_txtComment.text.length == 0) {
//		[[[UIAlertView alloc] initWithTitle:@"Upload Error"
//									message:@"Please provide a comment for the image before uploading"
//								   delegate:self
//						  cancelButtonTitle:@"Ok"
//						  otherButtonTitles:nil] show];
//		[_btnUpload setEnabled:YES];
//		return;
//	}
//	
//	// Show progress
//	[_vProgressUpload setHidden:NO];
//	
//	// Upload the image to Parse
//	[self uploadImage:self.imgToUpload.image withComment:_txtComment.text];
}

-(IBAction)cancelPost:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) uploadImage:(UIImage *)image withComment:(NSString *)comment
{
    // 1
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // 2
    PFFile *imageFile = [PFFile fileWithName:@"image" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // 3
            PFObject *wallImageObject = [PFObject objectWithClassName:PF_WALL_POST_CLASSNAME];
            wallImageObject[@"image"] = imageFile;
            wallImageObject[@"imageURL"] = [[PFUser currentUser] objectForKey:PF_USER_PICTURE];
            wallImageObject[@"user"] = [PFUser currentUser].username;
            
            [wallImageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // 4
                    PFObject *wallImageCommentObject = [PFObject objectWithClassName:PF_WALL_COMMENT_CLASSNAME];
                    wallImageCommentObject[@"comment"] = comment;
                    //wallImageCommentObject[@"userFBId"] = [[PFUser currentUser] objectForKey:@"fbId"];
                    wallImageCommentObject[@"imageURL"] = [[PFUser currentUser] objectForKey:PF_USER_PICTURE];
                    wallImageCommentObject[@"user"] = [PFUser currentUser].username;
                    wallImageCommentObject[@"imageObjectId"] = wallImageObject.objectId;
                    
                    [wallImageCommentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        // 5
                        if ([self respondsToSelector:@selector(commsUploadImageComplete:)]) {
                            [self commsUploadImageComplete:YES];
                        }
                    }];
                } else {
                    // 6
                    if ([self respondsToSelector:@selector(commsUploadImageComplete:)]) {
                        [self commsUploadImageComplete:NO];
                    }
                }
            }];
        } else {
            // 7
            if ([self respondsToSelector:@selector(commsUploadImageComplete:)]) {
                [self commsUploadImageComplete:NO];
            }
        }
    } progressBlock:^(int percentDone) {
        // 8
        if ([self respondsToSelector:@selector(commsUploadImageProgress:)]) {
            [self commsUploadImageProgress:percentDone];
        }
    }];
}

- (void) commsUploadImageComplete:(BOOL)success
{
	// Reset the UI
//	[_vProgressUpload setHidden:YES];
//	[_btnUpload setEnabled:YES];
//	[_lblChooseAnImage setHidden:NO];
//	[_imgToUpload setImage:nil];
//	
//	// Did the upload work ?
//	if (success) {
//		[self.navigationController popViewControllerAnimated:YES];
//		
//		// Notify that a new image has been uploaded
//        [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageUploaded object:nil];
//	} else {
//		[[[UIAlertView alloc] initWithTitle:@"Upload Error"
//									message:@"Error uploading image. Please try again."
//								   delegate:nil
//						  cancelButtonTitle:@"Ok"
//						  otherButtonTitles:nil] show];
//	}
}

- (void) commsUploadImageProgress:(short)progress
{
//	NSLog(@"Uploaded: %d%%", progress);
//	[_progressUpload setProgress:(progress/100.0f)];
}



#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//	// We've chosen an image, so hide the hint text.
//	[_lblChooseAnImage setHidden:YES];
//
//	// Close the image picker
//    [picker dismissViewControllerAnimated:YES completion:nil];
//	
//	// We're going to Scale the Image to fit the image view.
//	// This is just to keep traffic size down.
//	UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
//	[_imgToUpload setImage:[image imageScaledToFitSize:_imgToUpload.frame.size]];
}


#pragma mark - UITextViewDelegate

// Hide the keyboard when we return from the comment field.
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
    return YES;
}


@end
