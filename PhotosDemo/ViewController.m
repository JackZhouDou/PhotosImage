//
//  ViewController.m
//  PhotosDemo
//
//  Created by 周都 on 2017/9/1.
//  Copyright © 2017年 周都. All rights reserved.
//

#import "ViewController.h"
#import "PhotosSaveImage.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 保存本地图

 @param sender <#sender description#>
 */
- (IBAction)saveImageToPhotos:(id)sender {
    UIImage *image = self.imageView.image;
    
    if (image) {
        //可以有顺序的保存多张图
        NSArray *array = @[image];
        
        /**
         用要保存image

         @param receivedSize 当前保存到第几张图
         @param expectedSize 总共的图
         @return
         */
        [PhotosSaveImage saveImages:array withPhotosName:@"相册名字" saveingProgress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            NSLog(@"-->保存到第%ld张", receivedSize);
        } compeleteSave:^(PhotosSaveImageTypeMsge saveType) {
            
            switch (saveType) {
                case PhotosSaveImageTypeMsgeSaveNot:
                {
                    NSLog(@"-->全部保存失败");
                }
                    break;
                case PhotosSaveImageTypeMsgeSucceed:
                {
                    NSLog(@"-->全部保存成功");
                }
                    break;
                case PhotosSaveImageTypeMsgeNotNetwork:
                {
                    NSLog(@"-->没有网络");
                }
                    break;
                case PhotosSaveImageTypeMsgePermission:
                {
                    NSLog(@"-->提示没有访问相册的权限");
                }
                    break;
                    
                case PhotosSaveImageTypeMsgeCreatedCollectionNot:
                {
                   NSLog(@"-->创建相册失败");
                }
                    break;
                default:
                    break;
            }
            
            
        }];
    }
    
    
}

/**
 保存网络图， 由于我下载图用的SD如果要使用自己的方式下载可在PhotosSaveImage.m中的@method(webImageSaveArray)中修改

 @param sender <#sender description#>
 */
- (IBAction)saveWebImageToPhotos:(id)sender {
    
    NSArray *array = @[@"http://wx3.sinaimg.cn/mw690/006p5ID7gy1fj412fz1elj30cz08ca9z.jpg", @"http://wx3.sinaimg.cn/mw690/006p5ID7gy1fj412ltqnaj30rs0hbdgz.jpg"];
    
    [PhotosSaveImage SaveImageUrls:array withPhotosName:@"相册名字" saveingProgress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
         NSLog(@"-->保存到第%ld张", receivedSize);
        
    } compeleteSave:^(PhotosSaveImageTypeMsge saveType) {
        switch (saveType) {
            case PhotosSaveImageTypeMsgeSaveNot:
            {
                NSLog(@"-->全部保存失败");
            }
                break;
            case PhotosSaveImageTypeMsgeSucceed:
            {
                NSLog(@"-->全部保存成功");
            }
                break;
            case PhotosSaveImageTypeMsgeNotNetwork:
            {
                NSLog(@"-->没有网络");
            }
                break;
            case PhotosSaveImageTypeMsgePermission:
            {
                NSLog(@"-->提示没有访问相册的权限");
            }
                break;
                
            case PhotosSaveImageTypeMsgeCreatedCollectionNot:
            {
                NSLog(@"-->创建相册失败");
            }
                break;
            default:
                break;
        }
        
    
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
