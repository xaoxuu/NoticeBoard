//
//  UIImage+AXAdd.h
//  AXKit
//
//  Created by xaoxuu on 05/03/2017.
//  Copyright © 2017 Titan Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIImage (AXAdd)

/**
 读取图片，优先从asset中读取
 找不到图片则从mainBundle中读取
 找不到则以传入值为路径读取图片。
 */
+ (UIImage *(^)(NSString *))named;

/**
 以传入view创建截图
 */
+ (instancetype)imageWithView:(UIView *)view;
/**
 创建一个纯色图片
 
 @return 图片
 */
+ (instancetype)imageWithPureColor:(UIColor *)color size:(CGSize)size;
/**
 从bundle中读取图片（自动追加.png/.jpg/.jpeg扩展名）

 @return 图片
 */
+ (instancetype)imageWithNamed:(NSString *)named inBundle:(NSBundle *)bundle;
/**
 把图片剪裁为正方形
 
 @return 图片
 */
- (instancetype)squared;
/**
 把图片剪裁为圆形

 @return 图片
 */
- (instancetype)rounded;
/**
 毛玻璃效果

 @return 毛玻璃效果处理后的图片
 */
- (instancetype)blurred:(CGFloat)ratio;

/**
 毛玻璃效果
 
 @param ratio     毛玻璃效果指数
 @param completion 处理完成后执行的block 
 */
- (void)blurred:(CGFloat)ratio completion:(void (^)(UIImage *blurredImage))completion;


- (UIImage *(^)(CGFloat ratio))NonInterpolatedScaleWithRatio;

- (UIImage *(^)(CGFloat length))NonInterpolatedScaleWithLength;

- (UIImage *(^)(CGSize size))NonInterpolatedScaleWithSize;


@end

NS_ASSUME_NONNULL_END
