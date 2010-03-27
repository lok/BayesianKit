//
//  BayesData.h
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BKBayesianDataPool : NSObject <NSFastEnumeration, NSCoding> {
    NSString *name;
    
    @private
    NSUInteger _tokensTotalCount;
    NSMutableDictionary *_tokensCount;
}

@property (readonly, getter=tokensTotalCount) NSUInteger _tokensTotalCount;

- (id)initWithName:(NSString*)aName;

- (void)removeToken:(NSString*)token;
- (NSUInteger)countForToken:(NSString*)token;
- (void)setCount:(NSUInteger)count forToken:(NSString*)token;
- (void)addCount:(NSUInteger)count forToken:(NSString*)token;
- (void)increaseCountForToken:(NSString*)token;

- (float)probabilityForToken:(NSString*)token;
- (void)setProbability:(float)probability forToken:(NSString*)token;
- (NSArray*)probabilitiesForTokens:(NSArray*)tokens;

- (NSArray*)allTokens;
- (void)printInformations;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end
