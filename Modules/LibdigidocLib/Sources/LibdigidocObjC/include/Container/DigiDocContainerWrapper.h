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
