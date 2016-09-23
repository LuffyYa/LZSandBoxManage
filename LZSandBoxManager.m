//
//  LZSandBoxManager.m
//  ACrowd
//
//  Created by Luffy_Zheng on 16/9/20.
//  Copyright © 2016年 Luffy. All rights reserved.
//

#import "LZSandBoxManager.h"
#import "SDImageCache.h"

#define FILE_CACHE_USER                 @"User"
#define FILE_CACHE_WebKit               @"WebKit"
#define FILE_Group_list                 @"GroupList.plist"       // 群组列表
#define FILE_Activity_list              @"ActivityList.plist"    // 群组列表

@implementation LZSandBoxManager

+ (NSFileManager *)initFileManager {
    NSFileManager *manager;
    if (manager == nil) {
       manager = [NSFileManager defaultManager];
    }
    return manager;
}

#pragma mark - 获取沙盒目录 -

/** 获取沙盒Document目录 */
+ (NSString *)getDocumentDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

/** 获取沙盒Liabrary目录 */
+ (NSString *)getLibraryDirectory {
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
}

/** 获取沙盒Library/Caches目录 */
+ (NSString *)getCachesDirectory {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
}

/** 获取沙盒Preference目录 */
+ (NSString *)getPreferenceDirectory {
    return NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES)[0];
}

/** 获取沙盒Tmp目录 */
+ (NSString *)getTmpDirectory {
    return NSTemporaryDirectory();
}

#pragma mark - 清除沙盒目录文件内容 -

/** 根据路径返回目录或文件的大小 */
+ (CGFloat)sizeWithFilePath:(NSString *)path {
    // 1.获得文件管理权限
    NSFileManager *manager = [self initFileManager];
    
    // 2.检测路径合理性
    BOOL directory = NO;
    BOOL exist = [manager fileExistsAtPath:path isDirectory:&directory];
    if (!exist) return 0;

    // 3.判断是否为文件夹
    // 文件夹
    if (directory) {
        // 这个方法能获得这个文件夹下面的所有子路径(直接\间接子路径)
        NSArray *subPaths = [manager subpathsAtPath:path];
        int totalSize = 0;
        for (NSString *subPath in subPaths) {
            NSString *fullSubPath = [path stringByAppendingPathComponent:subPath]; // 拼出子目录的全路径
            
            BOOL directory = NO;
            [manager fileExistsAtPath:fullSubPath isDirectory:&directory];
            
            // 子路径是个文件
            if (!directory) {
                NSDictionary *attrs = [manager attributesOfItemAtPath:fullSubPath error:nil];
                totalSize += [attrs[NSFileSize] intValue];
            }
        }
        return totalSize / (1024*1024.0);
    }
    
    // 文件
    else  {
        NSDictionary *attrs = [manager attributesOfItemAtPath:path error:nil];
        return [attrs[NSFileSize] intValue] / (1024*1024.0);
    }
}

/** 得到指定目录下的所有文件 */

+ (NSArray *)getAllFileNames:(NSString *)dirPath {
    NSArray *files = [[self initFileManager] subpathsOfDirectoryAtPath:dirPath error:nil];
    return files;
}

/** 删除指定目录或文件 */
+ (BOOL)clearCachesWithFilePath:(NSString *)path {
    return [[self initFileManager] removeItemAtPath:path error:nil];
}

/** 清空指定目录下文件 */
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath {
    // 获得全部文件数组
    NSArray *fileArr = [self getAllFileNames:dirPath];
    BOOL flag = NO;
    for (NSString *fileName in fileArr) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        flag = [self clearCachesWithFilePath:filePath];
        if (!flag) {
            break;
        }
    }
    return flag;
}

/** 清理图片缓存 */
+ (void)clearCachesImage {
   SDImageCache *sdCache = [SDImageCache sharedImageCache];
   [sdCache clearDisk];
}

/** 清理网页缓存 */
+ (BOOL)clearCachesWeb {
    NSString *path = [[self getCachesDirectory] stringByAppendingPathComponent:FILE_CACHE_WebKit];
    return [self clearCachesWithFilePath:path];
}

/** 清理信息类缓存 */
+ (BOOL)clearCachesInfo {
    return [self clearCachesWithFilePath:[self getCacheUserPath]];
}

/** 清理所有缓存 */
+ (void)clearAllCaches {
    [self clearCachesImage];
    [self clearCachesWeb];
    [self clearCachesInfo];
}

/** 获取缓存大小 */
+ (NSUInteger)getCachesSize {
    NSUInteger totalSize = 0;
    // 1.动态草稿
    
    // 2.SDWebImage缓存大小
    SDImageCache *sdCache = [SDImageCache sharedImageCache];
    NSUInteger sdCacheSize = [sdCache getSize];
    
    // 3.用户浏览信息列表缓存
    NSArray *filesArr = [self getAllFileNames:[self getCacheUserPath]];
    NSUInteger infoSize = 0;
    for (NSString *filePath in filesArr) {
        NSString *filePathAppend = [[self getCacheUserPath] stringByAppendingPathComponent:filePath];
        NSData *data = [NSData dataWithContentsOfFile:filePathAppend];
        infoSize += data.length;
    }
    
    // 4.WebKit缓存
    NSString *webKitPath = [[self getCachesDirectory] stringByAppendingPathComponent:FILE_CACHE_WebKit];
    NSArray *webFileArr = [self getAllFileNames:webKitPath];
    NSUInteger webSize = 0;
    for (NSString *filePath in webFileArr) {
        NSString *filePathAppend = [webKitPath stringByAppendingPathComponent:filePath];
        NSData *data = [NSData dataWithContentsOfFile:filePathAppend];
        webSize += data.length;
    }
    
    totalSize = sdCacheSize + infoSize + webSize;
    
    return totalSize;
}

/** 获取缓存大小字符串 */
+ (NSString *)getCachesSizeString {
    NSUInteger cacheSize =  [self getCachesSize] / 1024 / 1024;
    if (cacheSize == 0) return nil;
    
    NSString *cacheSizeStr = cacheSize >= 1 ? [NSString stringWithFormat:@"%luM", (unsigned long)cacheSize] : [NSString stringWithFormat:@"%luK", (unsigned long)cacheSize];
    return cacheSizeStr;
}

/** 创建cache/User文件夹 */
+ (void)createUserCacheFile {
    NSFileManager *fm = [self initFileManager];
    NSString *path = [[self getCachesDirectory] stringByAppendingPathComponent:FILE_CACHE_USER];
    if (![fm fileExistsAtPath:path]) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else
        NSLog(@"File path Cache/User has been existed !");
}

/** 获取cache/User文件夹路径 */
+ (NSString *)getCacheUserPath {
    NSString *userPath = [[self getCachesDirectory] stringByAppendingPathComponent:FILE_CACHE_USER];
    return userPath;
}

#pragma mark - 缓存归档与解档 -

/** 归档群组列表 */
+ (void)archiveGroupList:(NSMutableArray *)groupArr {
    [self createUserCacheFile];
    NSString *path = [[LZSandBoxManager getCacheUserPath] stringByAppendingPathComponent:FILE_Group_list];
    [NSKeyedArchiver archiveRootObject:groupArr toFile:path];
}

/** 归档活动列表 */
+ (void)archiveActivityList:(NSMutableArray *)actArr {
    [self createUserCacheFile];
    NSString *path = [[LZSandBoxManager getCacheUserPath] stringByAppendingPathComponent:FILE_Activity_list];
    [NSKeyedArchiver archiveRootObject:actArr toFile:path];
}

/** 载入群组列表缓存 */
+ (NSMutableArray *)unarchiveGroupList {
    NSString *path = [[LZSandBoxManager getCacheUserPath] stringByAppendingPathComponent:FILE_Group_list];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return array;
}

/** 载入活动列表缓存 */
+ (NSMutableArray *)unachiveActivityList {
    NSString *path = [[LZSandBoxManager getCacheUserPath] stringByAppendingPathComponent:FILE_Activity_list];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return array;
}

@end
