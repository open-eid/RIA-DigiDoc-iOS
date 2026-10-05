// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>
#import "../Model/DigiDocContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocContainerWrapper : NSObject

+ (void)create:(NSString *)containerPath withDataFilePaths:(NSArray<NSString *> *)dataFilePaths completion:(void (^)(NSError * _Nullable error))completion;

+ (nullable DigiDocContainer *)open:(NSString *)containerPath validateOnline:(BOOL)validateOnline error:(NSError **)error;

+ (void)open:(NSString *)containerPath
validateOnline:(BOOL)validateOnline
  completion:(void (^)(DigiDocContainer * _Nullable container, NSError * _Nullable error))completion;

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

NS_SWIFT_SENDABLE
@interface DigiDocValidationSession : NSObject

@property (nonatomic, readonly) NSUInteger signatureCount;

+ (void)open:(NSString *)containerPath
validateOnline:(BOOL)validateOnline
  completion:(void (^NS_SWIFT_SENDABLE)(DigiDocValidationSession * _Nullable session,
                                        DigiDocContainer * _Nullable container,
                                        NSError * _Nullable error))completion
    NS_SWIFT_NAME(open(_:validateOnline:completion:));

- (void)validateSignatureAtIndex:(NSUInteger)index
                      completion:(void (^NS_SWIFT_SENDABLE)(DigiDocSignature * _Nullable signature,
                                                            NSError * _Nullable error))completion
    NS_SWIFT_NAME(validateSignature(at:completion:));

- (void)closeWithCompletion:(void (^NS_SWIFT_SENDABLE)(void))completion
    NS_SWIFT_NAME(close(completion:));

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
