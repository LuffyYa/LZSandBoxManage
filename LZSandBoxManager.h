//
//  LZSandBoxManager.h
//  ACrowd
//
//  Created by Luffy_Zheng on 16/9/20.
//  Copyright © 2016年 Luffy. All rights reserved.
//
//  沙盒文件管理

#import <Foundation/Foundation.h>

@interface LZSandBoxManager : NSObject

#pragma mark - 获取沙盒目录 -

/**
 获取沙盒Document目录

 @return Document目录
 */
+ (NSString *)getDocumentDirectory;

/**
 获取沙盒Library目录
 
 @return Library目录
 */
+ (NSString *)getLibraryDirectory;

/**
 获取沙盒Library/Caches目录
 
 @return Library/Caches目录
 */
+ (NSString *)getCachesDirectory;

/**
 获取沙盒Preference目录
 
 @return Preference目录
 */
+ (NSString *)getPreferenceDirectory;

/**
 获取沙盒Tmp目录
 
 @return Tmp目录
 */
+ (NSString *)getTmpDirectory;

#pragma mark - 清除沙盒目录文件内容 -

/**
 根据路径返回目录或文件的大小

 @param path 文件目录
 
 @return 目录文件大小
 */
+ (CGFloat)sizeWithFilePath:(NSString *)path;

/**
 得到指定目录下的所有文件

 @param dirPath 指定目录

 @return 所有文件
 */
+ (NSArray *)getAllFileNames:(NSString *)dirPath;


/**
 删除指定目录或文件

 @param path 指定目录或文件

 @return 删除结果
 */
+ (BOOL)clearCachesWithFilePath:(NSString *)path;

/**
 清空指定目录下文件

 @param dirPath 指定目录

 @return 清除结果
 */
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath;


/**
 清理图片缓存

 @return 图片缓存
 */
+ (void)clearCachesImage;


/**
 清理网页缓存

 @return 网页缓存
 */
+ (BOOL)clearCachesWeb;


/**
 清理信息类
 
 @return 信息类缓存
 */
+ (BOOL)clearCachesInfo;

/** 清理所有缓存 */
+ (void)clearAllCaches;

/**
 获得缓存大小
 
 @return 缓存大小
 */
+ (NSUInteger)getCachesSize;

/**
 获取缓存大小字符串

 @return 缓存大小字符串
 */
+ (NSString *)getCachesSizeString;

/** 创建cache/User文件夹 */
+ (void)createUserCacheFile;

/** 获取cache/User文件夹路径 */
+ (NSString *)getCacheUserPath;

#pragma mark - 缓存归档与解档 -

/** 归档群组列表 */
+ (void)archiveGroupList:(NSMutableArray *)groupArr;

/** 归档活动列表 */
+ (void)archiveActivityList:(NSMutableArray *)actArr;

/** 载入群组列表缓存 */
+ (NSMutableArray *)unarchiveGroupList;

/** 载入活动列表缓存 */
+ (NSMutableArray *)unachiveActivityList;

@end
