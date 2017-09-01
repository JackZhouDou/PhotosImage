//
//  PhotosSaveImage.m
//  绿色家园
//
//  Created by 周都 on 2017/8/30.
//  Copyright © 2017年 周都. All rights reserved.
//

#import "PhotosSaveImage.h"
//iOS8以后使用
#import <Photos/Photos.h>

#import "SDWebImageManager.h"

//内部使用的枚举
typedef NS_ENUM(NSUInteger,  SaveIMageModel) {
    SaveIMageModelLoading = 0,
    
    SaveIMageModelUrl
};

@interface PhotosSaveImage ()

@property (nonatomic, copy) SaveImageProgressBlock progressBlock;

@property (nonatomic, copy) PhotosSaveImageBlock saveImageBlock;

/**
 总图片数
 */
@property (nonatomic, assign) NSUInteger toatlNumber;

/**
 当前添加成功的数量
 */
@property (nonatomic, assign) NSUInteger currentSucceedNumber;


/**
 当前添加失败的数量
 */
@property (nonatomic, assign) NSUInteger currentDefeatNumber;


@property (nonatomic, assign) PhotosSaveImageMode  saveImageModel;


@property (nonatomic, strong) PHAssetCollection *createdCollection;

/**
 保存图片的模式
 */
@property (nonatomic, assign) SaveIMageModel saveModel;

/**
 用来计数
 */
@property (nonatomic, assign) NSUInteger  countNumber;

@end

@implementation PhotosSaveImage


+(void)saveImages:(NSArray <UIImage *>*)images withPhotosName:(NSString *)photosName saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock{
    
    PhotosSaveImage *photos = [PhotosSaveImage new];
    
    photos.progressBlock = progressBlock;
    
    photos.saveImageBlock = saveImageBlock;
    
    photos.photosName = photosName;
    
    photos.imageArray = images;
    
    photos.saveImageModel = PhotosSaveImageModeBlock;
    
    [photos startSaveLoadImage];
    
    
    
}



+(void)SaveImageUrls:(NSArray <NSString *>*)urlImages withPhotosName:(NSString *)photosNmae saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock{
    
    PhotosSaveImage *photos = [PhotosSaveImage new];
    
    photos.progressBlock = progressBlock;
    
    photos.saveImageBlock = saveImageBlock;
    
    photos.photosName = photosNmae;
    
    photos.imageUrlArray = urlImages;
    
    photos.saveImageModel = PhotosSaveImageModeBlock;
    
    [photos startSaveUrlImage];
    
    
}


/**
需要使用协议

 @param delegateSave 协议
 */
- (void)setDelegateSave:(id<PhotosSaveImageDelegate>)delegateSave{
    if (_delegateSave != delegateSave) {
        
        _delegateSave = delegateSave;
    }
    self.saveImageModel = PhotosSaveImageModeDelegate;
    
    
    
}
// 保存网络图
- (void)startSaveUrlImage{

    self.saveModel = SaveIMageModelUrl;
    self.countNumber = 0;
    [self contextPhotosPermission];
    
}


//保存本地图
- (void)startSaveLoadImage{
    
    
    self.saveModel = SaveIMageModelLoading;
    [self contextPhotosPermission];
    
}

//判断权限之后的处理
- (void)contextPhotosPermission{
    
    if ([self judgePhotosPermission]) {
        
        self.createdCollection = [self createdCollectionAction];
        
        if (self.createdCollection) {
            //创建建相册成功；
            self.currentSucceedNumber = 0;
            
            self.currentDefeatNumber = 0;
            
            self.toatlNumber = self.imageArray.count;
            //本地图开始保存
            if (self.saveModel == SaveIMageModelLoading) {
                [self loadingImageSaveArray];
                
            }else{
                
                [self webImageSaveArray];
                
            }
            
            
            
        }else{
            //创建相册失败
            [self resultCompelteType:PhotosSaveImageTypeMsgeCreatedCollectionNot];
        }
        
    }else{
        //没有权限
        [self resultCompelteType:PhotosSaveImageTypeMsgePermission];
        
    }
    
}
//处理结果
- (void)resultCompelteType:(PhotosSaveImageTypeMsge)resultType{
    
    switch (self.saveImageModel) {
            //使用的协议
        case PhotosSaveImageModeDelegate:
        {
            if (self.delegateSave && [self.delegateSave respondsToSelector:@selector(SaveImageComeToPhotosLabraryResult:)]) {
                
                [self.delegateSave SaveImageComeToPhotosLabraryResult:resultType];
                
            }
        }
            break;
            //使用的block
          case PhotosSaveImageModeBlock:
        {
            if (self.saveImageBlock) {
                
                self.saveImageBlock(resultType);
                
            }
            
        }
            break;
            
        default:
            
            break;
    }
    
    
}

/**
 相册权限判断

 @return 返回判断结果
 */
- (BOOL)judgePhotosPermission{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        
        
        return NO;
    }
    
    return YES;
    
}





/**
 *  获得【自定义相册】
 */
- (PHAssetCollection *)createdCollectionAction
{
    
    NSString *title;
    if (self.photosName && ![self.photosName isEqualToString:@""]) {
//自定义的名字
        title = [NSString stringWithFormat:@"%@", self.photosName];
        
    }else{
    // 获取软件的名字作为相册的标题
        
   title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    }
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //遍历出已经创建好的相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    // 代码执行到这里，说明还没有自定义相册
    
    __block NSString *createdCollectionId = nil;
    
    // 创建一个新的相册(同步操作)
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil) return nil;
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

//网络图图片保存  使用递归来处理
-(void)webImageSaveArray{
    
    NSString *urlString;
    
    if (self.countNumber >= self.imageUrlArray.count) {
        
       
        [self saveCompleteJudge];
        return;
    }else{
      
        urlString = [NSString stringWithFormat:@"%@", [self.imageUrlArray objectAtIndex:self.countNumber]];
        
        self.countNumber++;
      
    }
    
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    
    [manager downloadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        
        [weakSelf imageSaveComeToPhotosInstallImage:image];
        [weakSelf progressingComTo];
        //当同步线程执行到这里weakSelf已经被释放了；
        [self webImageSaveArray];
        
        
    }];
    
    
    
}


- (void)saveCompleteJudge{
    
    if ((self.currentSucceedNumber == self.toatlNumber) || (self.currentDefeatNumber == 0)) {
        //保存成功
        [self resultCompelteType:PhotosSaveImageTypeMsgeSucceed];
        
    }else if(self.currentDefeatNumber == self.toatlNumber){
        //        全部保存失败
        [self resultCompelteType:PhotosSaveImageTypeMsgeSaveNot];
    }else{
        //        部分保存失败
        [self resultCompelteType:PhotosSaveImageTypeMsgePartSaveNot] ;
    }
}
//本地图片开始保存
-(void)loadingImageSaveArray{
    
    for (NSInteger i = 0; i < self.toatlNumber; i++) {
        UIImage *image = [self.imageArray objectAtIndex:i];
        [self imageSaveComeToPhotosInstallImage:image];
        
        [self progressingComTo];
        
         }
    
    //保存玩的判断
    [self saveCompleteJudge];
    
    
}


/**
 进度
 */
- (void)progressingComTo{
    
    switch (self.saveImageModel) {
        case PhotosSaveImageModeBlock:
        {
          //block
            if (self.progressBlock) {
                self.progressBlock(self.currentSucceedNumber + self.currentDefeatNumber, self.toatlNumber);
            }
            
        }
            break;
          case PhotosSaveImageModeDelegate:
        {
            //协议
            
            if (self.delegateSave && [self.delegateSave respondsToSelector:@selector(SaveImageProgressReceivedSize:ExpectedSize:)]) {
                
                [self.delegateSave SaveImageProgressReceivedSize:self.currentDefeatNumber + self.currentSucceedNumber ExpectedSize:self.toatlNumber];
                
            }
        }
            break;
            
        default:
            break;
    }
    
}
//一张张进行保存
- (void)imageSaveComeToPhotosInstallImage:(UIImage *)image{
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssetsActionImage:image];
    
    
    // 获得相册
    PHAssetCollection *createdCollection = self.createdCollection;
    
    if (createdAssets == nil || createdCollection == nil) {
        
        self.currentDefeatNumber++;
        
        return;
    }
    
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 保存结果
    if (error) {
        
        self.currentDefeatNumber++;
    } else {
        
        self.currentSucceedNumber++;
        
    }
    
   
    
    
    
    
}


/**
 生成交卷的图

 @param image <#image description#>
 @return <#return value description#>
 */
- (PHFetchResult <PHAsset *> *)createdAssetsActionImage:(UIImage *)image{
    //排除nil图
    if (!image) {
        return nil;
    }
    
    
    __block NSString *createdAssetId = nil;
    

    // 添加图片到【相机胶卷】同步操作
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    
   
    
}
@end
