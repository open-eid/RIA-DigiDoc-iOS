/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#import <Foundation/Foundation.h>
#import "../Model/DigiDocContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocContainerWrapper : NSObject

+ (void)create:(NSString *)containerPath withDataFilePaths:(NSArray<NSString *> *)dataFilePaths completion:(void (^)(NSError * _Nullable error))completion;

+ (nullable DigiDocContainer *)open:(NSString *)containerPath validateOnline:(BOOL)validateOnline error:(NSError **)error;

// Asynchronous variant of the call above. Runs the whole native open - including the
// per-signature validation, which costs signatureCount x datafileBytes - on the dedicated
// libdigidocpp serial queue, so the main thread stays responsive and the iOS watchdog
// cannot kill the app while a large container is being opened.
+ (void)open:(NSString *)containerPath
validateOnline:(BOOL)validateOnline
  completion:(void (^)(DigiDocContainer * _Nullable container, NSError * _Nullable error))completion;

// Opens the container and reports its contents in two phases over one native container instance.
// `metadata` fires as soon as parsing is done, with every signature's details but no validity
// verdict. `validated` then fires once per signature as its validation completes - that step costs
// a full re-hash of every data file per signature, so on a large container it dominates. Returning
// YES from `isCancelled` stops the loop between signatures.
+ (void)openProgressively:(NSString *)containerPath
           validateOnline:(BOOL)validateOnline
              isCancelled:(BOOL (^)(void))isCancelled
                 metadata:(void (^)(DigiDocContainer *container))metadata
                validated:(void (^)(NSUInteger index, DigiDocSignature *signature))validated
               completion:(void (^)(NSError * _Nullable error))completion;

+ (void)addDataFilesToContainerWithPath:(NSString *)containerPath withDataFilePaths:(NSArray<NSString*> *)dataFilePaths completion:(void (^)(NSError * _Nullable error))completion;

+ (void)container:(NSString *)containerPath saveDataFile:(NSString *)fileName to:(NSString *)path completion:(void (^)(NSError * _Nullable error))completion;

+ (void)removeSignature:(NSUInteger)index fromContainerWithPath:(NSString *)containerPath completion:(void (^)(NSError * _Nullable error))completion;

+ (void)removeDataFileFromContainerWithPath:(NSString *)containerPath atIndex:(NSUInteger)dataFileIndex completion:(void (^)(NSError * _Nullable error))completion;

+ (NSString *)libdigidocppVersion;
+ (NSString *)mediaType;

+ (void)extendLastSignatureToLTA:(NSString *)containerPath completion:(void (^)(NSError * _Nullable error))completion;

// Extends validity of all signatures. Legacy containers (DDOC, BDOC time-mark) are wrapped into a new
// ASiC-S container (written to outputAsicsPath) with an archive timestamp. ASiC-E containers are extended in place.
// The completion returns the path that was actually written.
+ (void)extendContainerToLTA:(NSString *)containerPath
             outputAsicsPath:(NSString *)outputAsicsPath
                  completion:(void (^)(NSString * _Nullable savedPath, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
