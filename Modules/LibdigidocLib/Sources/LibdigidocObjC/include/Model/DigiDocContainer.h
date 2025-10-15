#import <Foundation/Foundation.h>
#import "DigiDocDataFile.h"
#import "DigiDocSignature.h"

@interface DigiDocContainer : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSArray<DigiDocDataFile *> *dataFiles;
@property (nonatomic, strong) NSArray<DigiDocSignature *> *signatures;
@property (nonatomic, strong) NSString *mediatype;

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                       dataFiles:(NSArray<DigiDocDataFile *> *)dataFiles
                      signatures:(NSArray<DigiDocSignature *> *)signatures
                       mediatype:(NSString *)mediatype;

@end
