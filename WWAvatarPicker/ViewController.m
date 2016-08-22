//
//  ViewController.m
//  WWAvatarPicker
//
//  Created by hewaiwai on 16/8/22.
//  Copyright © 2016年 waiwai. All rights reserved.
//

#import "ViewController.h"
#import "WWAvatarPicker.h"
@interface ViewController ()<WWAvatarPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
/** WWAvatarPicker */
@property(retain, nonatomic) WWAvatarPicker  *avatarPicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressSelect:(UIButton *)sender {
    [self.avatarPicker startPickWithImageSize:CGSizeMake(240, 128) shouldCrop:YES formVC:self];
}


#pragma mark - WWAvatarPicker delegate
- (void)didSelectedAvatar:(UIImage *)avatar
{
    self.avatarImage.image = avatar;
}


#pragma mark - getter and setter
- (WWAvatarPicker *)avatarPicker
{
    if (!_avatarPicker) {
        _avatarPicker = [[WWAvatarPicker alloc]init];
        _avatarPicker.delegate = self;
    }
    return _avatarPicker;
}
@end
