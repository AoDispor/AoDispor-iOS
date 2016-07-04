//
//  Indexer.m
//  Ao Dispor
//
//  Created by André Lamelas on 23/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreSpotlight/CoreSpotlight.h>

@interface Indexer : NSObject {
    // Protected instance variables (not recommended)
}
+ (void)index:(NSArray *)professionals;
@end


@implementation Indexer

+ (void)index:(NSArray<CSSearchableItem *> *)professionals {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"number of professionals: %lu", (unsigned long)professionals.count);
        CSSearchableIndex *index = [[CSSearchableIndex alloc] init];
        [index beginIndexBatch];
        [index indexSearchableItems:professionals completionHandler:^(NSError * __nullable error)
         {
             NSLog(@"indexSearchableItems (error %@)", error);
         }];
        [index fetchLastClientStateWithCompletionHandler:^(NSData * _Nullable clientState, NSError * _Nullable error) {
            [index endIndexBatchWithClientState:clientState completionHandler:^(NSError * __nullable error)
             {
                 NSLog(@"endIndexBatchWithClientState (error %@)", error);
             }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Finished!");
        });
    });
}

@end