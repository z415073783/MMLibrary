//
//  KeyChainUUID.m
//
//  Created by zlm on 16/7/6.
//

#import "KeyChainUUID.h"
#import "SAMKeychain.h"

@implementation KeyChainUUID

#define SERVICE_NAME @"UUID"
#define ACCOUNT_NAME @"ZENGLIANGMIN.com.zlm"  //组织名称((appleid前缀).(bundleid前半部分))

//每次获取不重复的uuid
+ (NSString*)getOnceUUID {
    return [KeyChainUUID setUUID];
}

+ (NSString*)getUUID {
    NSString* currentUUID = [SAMKeychain passwordForService:SERVICE_NAME
                                                    account:ACCOUNT_NAME];
    if (!currentUUID) {
        currentUUID = [KeyChainUUID setUUID];
    }
    return currentUUID;
}

+ (NSString*)setUUID {
    NSError* err = nil;
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [SAMKeychain setPassword:uuid forService:SERVICE_NAME account:ACCOUNT_NAME error:&err];
    if (err) {
        NSLog(@"----保存UUID失败:%@-----\n",err);
    }
    NSLog(@"----保存UUID成功:%@-----\n",uuid);
    return uuid;
}


@end
