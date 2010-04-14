//
// BKDataPool.h
// Licensed under the terms of the BSD License, as specified below.
//

/*
 Copyright (c) 2010, Samuel Mendes
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of ᐱ nor the names of its
 contributors may be used to endorse or promote products derived
 from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

/** Pool indexed by tokens and holding their data.
 
 You should never have to handle an object of this class directly.
 */
@interface BKDataPool : NSObject <NSFastEnumeration, NSCoding> {
    NSString *name;
    
    @private
    NSUInteger _tokensTotalCount;
    NSMutableDictionary *_tokensData;
}


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Name of the pool. */
@property (readonly) NSString *name;

@property (readonly, getter=tokensTotalCount) NSUInteger _tokensTotalCount;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initialize a pool
//////////////////////////////////////////////////////////////////////////////////////////

/** Initialize a data pool with a given name.
 
 @param aName The pool's name.
 @return An initialized data pool.
 */
- (id)initWithName:(NSString*)aName;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Handling tokens' count
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the number of occurences counted for a token.
 
 @param token The token to get the count property from.
 @return The number of occurences counted for the token. 0 if no token is found.
 */
- (NSUInteger)countForToken:(NSString*)token;

/** Sets the number of occurences counted for a token.
 
 This will add the token to the pool with the given count number or will replace
 the existing one.
 @param count The number of occurences counted.
 @param token The token counted.
 @see addCount:forToken:
 */
- (void)setCount:(NSUInteger)count forToken:(NSString*)token;

/** Adds to the number of occurences counted for a token.
 
 This will add the token to the pool with the given count number or will be 
 added to the existing one.
 @param count The number of occurences counted to ass.
 @param token The token counted.
 @exception NSException if the count property will overflow.
 @see setCount:forToken:
 */
- (void)addCount:(NSUInteger)count forToken:(NSString*)token;

/** Increase the number of occurences counted for a token by 1.
 
 Act like @c addCount:forToken:() with the count argument set to 1.
 @param token The token counted.
 @see addCount:forToken:
 @see setCount:forToken:
 */
- (void)increaseCountForToken:(NSString*)token;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Handling tokens' probability
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the probability associated with a token.
 
 @param token The token to get the probability property from.
 @return The probability associated with the token. 0 if no token is found.
 @see probabilitiesForTokens:
 */
- (float)probabilityForToken:(NSString*)token;

/** Returns an array containing the probabilities for a group of tokens
 
 Only the probabilities of tokens existing within the pool are returned.
 The others are simply ignored. So the array returned may be smaller than the tokens' one.
 @param tokens An array containing tokens.
 @return An array of NSNumber holding tokens probabilities.
 @see probabilityForToken:
 */
- (NSArray*)probabilitiesForTokens:(NSArray*)tokens;

/** Sets the probability associated with a token.
 
 Unlike @c setCount:forToken: This will @b not add the token to the pool.
 @param count The probability for the token.
 @param token The token associated.
 */
- (void)setProbability:(float)probability forToken:(NSString*)token;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Remove tokens
//////////////////////////////////////////////////////////////////////////////////////////

/** Remove a token from the pool and release any associated data.
 
 @param token The token to remove.
 */
- (void)removeToken:(NSString*)token;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Accessing tokens
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns every token of the pool. */
- (NSArray*)allTokens;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Print statistics
//////////////////////////////////////////////////////////////////////////////////////////

/** Print some basics statistics on the receiver */
- (void)printInformations;

@end
