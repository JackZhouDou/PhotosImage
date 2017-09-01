//
//  PhotosSaveImage.h
//  绿色家园
//
//  Created by 周都 on 2017/8/30.
//  Copyright © 2017年 周都. All rights reserved.
//

//切记iOS10以后访问相册需要设置info.plist中的Privacy - Photo Library Usage Description 不然会闪退


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PhotosSaveImageMode) {
    PhotosSaveImageModeDelegate = 0,/**< 是通过协议去调的**/
    
    PhotosSaveImageModeBlock  = 1,/**< 是通过Block协议去调的**/
    
    
};

//失败的提示码
typedef NS_ENUM(NSUInteger, PhotosSaveImageTypeMsge){
   
    PhotosSaveImageTypeMsgePermission = 0,//没有访问相册的权限
    
    PhotosSaveImageTypeMsgeSaveNot ,//保存失败
    
    PhotosSaveImageTypeMsgeNotNetwork,//没有网络
    
    PhotosSaveImageTypeMsgePartSaveNot, /**<一部分保存失败*/
    
    PhotosSaveImageTypeMsgeCreatedCollectionNot, /**<创建相册失败*/
    
    PhotosSaveImageTypeMsgeSucceed /**<保存成功*/
};

/**
 保存图片的进度

 @param receivedSize 当前保存的张数
 @param expectedSize 预计要保存的个数
 */
typedef void(^SaveImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void(^PhotosSaveImageBlock)( PhotosSaveImageTypeMsge saveType);


@protocol PhotosSaveImageDelegate <NSObject>

@optional
//失败的回调
- (void)SaveImageComeToPhotosLabraryResult:(PhotosSaveImageTypeMsge)SaveType;

/**
 保存图片

 @param receivedSize 当前保存到哪张图
 @param expectedSize <#expectedSize description#>
 */
- (void)SaveImageProgressReceivedSize:(NSInteger )receivedSize ExpectedSize:(NSInteger)expectedSize;


@end

@interface PhotosSaveImage : NSObject

/**
 快速保存本地图片

 @param images 图片数组必须是图片
 @param photosName 创建相册 ，如果穿nil保存到系统相册
 @param progressBlock 保存的进度
 @param saveImageBlock 保存的结果回调
 */
+(void)saveImages:(NSArray <UIImage *>*)images withPhotosName:(NSString *)photosName saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock;


/**
 快速保存网络图片

 @param urlImages 图片的url
 @param photosNmae 相册名字
 @param progressBlock 进度的回调
 @param saveImageBlock 完成的状态判断
 */
+(void)SaveImageUrls:(NSArray <NSString *>*)urlImages withPhotosName:(NSString *)photosNmae saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock;





//保存的协议
@property (weak, nonatomic) id<PhotosSaveImageDelegate> delegateSave;


/**
 相册的名字
 */
@property (nonatomic, strong) NSString *photosName;

/**
 本地图数组
 */
@property (nonatomic, strong) NSArray <UIImage *> *imageArray;

/**
 网络图数组
 */
@property (nonatomic, strong) NSArray  <NSString *> *imageUrlArray;


/**
 开始保存网络图片
 */
- (void)startSaveUrlImage;

/**
 保存本地图
 */
- (void)startSaveLoadImage;
@end

//错误信息
//@interface PhotsSaveImageEorr : NSObject
//
//@property (nonatomic, strong) NSString *eorrName;
//
//
//
//@end
