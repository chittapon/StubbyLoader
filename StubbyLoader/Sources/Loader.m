//
//  Loader.m
//  StubbyLoader
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//

#import <Foundation/Foundation.h>

@interface StubbyLoader: NSObject
@end

@implementation NSObject(StubbyLoader)

+ (void)load {
    static StubbyLoader *singleton;
    singleton = [[StubbyLoader alloc] init];
}

@end
