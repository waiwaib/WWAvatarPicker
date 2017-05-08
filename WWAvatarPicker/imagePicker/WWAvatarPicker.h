//
//  imagePickerCenter.h
//  VenadaOA
//
//  Created by hejingzhi on 15/6/23.
//  Copyright (c) 2015年 waiwai. All rights reserved.
//
//
//  a class to manager image picker;

#import "RSKImageCropper.h"
#import <Foundation/Foundation.h>

@protocol WWAvatarPickerDelegate

/** complete image pick */
-(void) didSelectedAvatar:(UIImage *)avatar;
@end



@interface WWAvatarPicker : NSObject<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,WWAvatarPickerDelegate,RSKImageCropViewControllerDelegate>

/** pikcer delegate; */
@property (nonatomic , assign) id<WWAvatarPickerDelegate> delegate;

/** form view controller */
@property (nonatomic, weak) id formVC;

/**
 *  privide two way to get images,take photo or select at photo album; can set the picker style;
 *
 *  @param targetsize target size
 *  @param crop       should crop image
 *  @param weak_VC    from VC
 */
- (void)startPickWithImageSize:(CGSize)targetsize  shouldCrop:(BOOL)crop formVC:(id) weak_VC ;

/**
 *  provide method to get images by one way-->take photo;
 */
- (void)imageByTakePhoto;

/**
 *  provide method to get images by one way-->select at Album;
 */
- (void)imagesByAlbum;
@end
