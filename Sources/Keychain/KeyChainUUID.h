//
//  KeyChainUUID.h
//
//  Created by zlm on 16/7/6.
//使用前需要引入Security.framework

#import <Foundation/Foundation.h>

@interface KeyChainUUID : NSObject

/**
 每次获取不重复的uuid
 */
+ (NSString*)getOnceUUID;

/**
 获取UUID
 */
+ (NSString*)getUUID;

@end
