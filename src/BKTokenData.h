//
// BKTokenData.h
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

/** Helper class for @c BKDataPool holding information on a token 
 
 You should never have to handle directly an object of this type.
 */
@interface BKTokenData : NSObject <NSCoding> {
    NSUInteger count;
    float probability;
}


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Number of occurence of a token within a pool */
@property (readwrite, assign) NSUInteger count;
/** Probability associated with a token in a pool */
@property (readwrite, assign) float probability;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creating a token data
//////////////////////////////////////////////////////////////////////////////////////////

/** Create a new token data and setup its @c count property.
 
 @param aCount The number to set @c count with.
 @return A new token data.
 @see initWithCount
 */
+ (BKTokenData*)tokenDataWithCount:(NSUInteger)aCount;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initializing a token data
//////////////////////////////////////////////////////////////////////////////////////////

/** Initialize a new token data and setup its @c count property.
 
 @param aCount The number to set @c count with.
 @return An initialized token data.
 @see tokenDataWithCount:
 */
- (id)initWithCount:(NSUInteger)aCount;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Comparing token data
//////////////////////////////////////////////////////////////////////////////////////////

/** Compare two token data by theirs @c count properties
 
 @param other The other token data to compare with.
 @return 
 - NSOrderedAscending if the count of the other is greater than the receiver’s
 - NSOrderedSame if they’re equal
 - NSOrderedDescending if the count of the other is less than the receiver’s.
 @see compareProbability
 */
- (NSComparisonResult)compareCount:(BKTokenData*)other;

/** Compare two token data by theirs @c probability properties
 
 @param other The other token data to compare with.
 @return 
 - NSOrderedAscending if the probability of the other is greater than the receiver’s
 - NSOrderedSame if they’re equal
 - NSOrderedDescending if the probability of the other is less than the receiver’s.
 @see compareCount:
 */
- (NSComparisonResult)compareProbability:(BKTokenData*)other;

@end
