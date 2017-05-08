//
//  imagePickerCenter.m
//  VenadaOA
//
//  Created by hejingzhi on 15/6/23.
//  Copyright (c) 2015年 waiwai. All rights reserved.
//

#import "WWAvatarPicker.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
@interface WWAvatarPicker()<UIAlertViewDelegate>

/** record image Picker */
@property (nonatomic , weak) id  currentPicker;

/** target Size */
@property (nonatomic , assign) CGSize targetSize;

/** set yes to crop selected image; */
@property (nonatomic , assign) BOOL shouldCrop;

/** set to -1 means no limmit; */
@property (nonatomic , assign) NSInteger selectNumLimmit;


@end

@implementation WWAvatarPicker


#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSURL *appsettings = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appsettings];
    }
}

#pragma mark - uiaction delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self imageByTakePhoto];
            break;
        }
        case 1:
        {
            [self imagesByAlbum];
            break;
        }
        default:
            break;
    }
}

#pragma mark -  image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    UIImage * image;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"])
    {
        //set image size to 160*160 and update image data
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // 裁剪
        if (_shouldCrop) {
            
            RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
            imageCropVC.delegate = self;
            [_currentPicker presentViewController:imageCropVC animated:YES completion:nil];
            return;
        }
        
        if (!__CGSizeEqualToSize(CGSizeZero,_targetSize)&&!_shouldCrop) {
            image = [self imageWithImageSimple:image scaledToSize:_targetSize];
        }
    }
    
    
    if (image) {
        [_delegate didSelectedAvatar:image];
    }
    else
    {
        NSLog(@"选择到的图片为空");
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark -  imagePickerCenterDelegate
- (void)didCompleteWithPickImage:(NSArray *)pickedArr
{
    NSLog(@"error -- delegate 方法被错误的响应了");
}

#pragma mark - RSKImageCropViewControllerDelegate
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if ([_currentPicker isMemberOfClass:[UIImagePickerController class]]) {
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.currentPicker dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (!__CGSizeEqualToSize(CGSizeZero,_targetSize)) {
        croppedImage = [self imageWithImageSimple:croppedImage scaledToSize:_targetSize];
    }
    [_delegate didSelectedAvatar:croppedImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.currentPicker dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - private method
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

#pragma mark - get images action
- (void)startPickWithImageSize:(CGSize)targetsize  shouldCrop:(BOOL)crop formVC:(id) weak_VC
{
    _targetSize = targetsize;
    _formVC = weak_VC;
    _shouldCrop = crop;
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [actionSheet showInView:[[UIApplication sharedApplication].delegate window]];
}

- (void)imageByTakePhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self checkAVAuthorizationStatus];
        //init image piker
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        _currentPicker = picker;
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [_formVC presentViewController:picker animated:YES completion:^{}];
    }
    else
    {
        MBProgressHUD * progressSuccess = [MBProgressHUD  showHUDAddedTo:[[UIApplication sharedApplication].delegate window]  animated:YES];
        progressSuccess.mode = MBProgressHUDModeText;
        progressSuccess.labelFont = [UIFont systemFontOfSize:13];
        progressSuccess.labelText = @"相机不能使用";
        [progressSuccess hide:YES afterDelay:1];
    }
}

- (void)imagesByAlbum
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        //init image piker
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        _currentPicker = picker;
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [_formVC presentViewController:picker animated:YES completion:^{}];
    }
    else
    {
        MBProgressHUD * progressSuccess = [MBProgressHUD  showHUDAddedTo:[[UIApplication sharedApplication].delegate window]  animated:YES];
        progressSuccess.mode = MBProgressHUDModeText;
        progressSuccess.labelFont = [UIFont systemFontOfSize:13];
        progressSuccess.labelText = @"相机不能使用";
        [progressSuccess hide:YES afterDelay:1];
    }
}

- (BOOL)checkAVAuthorizationStatus
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"请开启相机权限" message:@"应用需要访问相机" delegate:self cancelButtonTitle:@"暂时不" otherButtonTitles:@"去开启", nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (BOOL)checkAssetsLibraryAuthorizationStatus
{
    int author = [ALAssetsLibrary authorizationStatus];
    if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"请开启相册权限" message:@"格格快递需要访问相册" delegate:self cancelButtonTitle:@"暂时不" otherButtonTitles:@"去开启", nil];
        [alert show];
        return NO;
    }
    return YES;
}
@end
