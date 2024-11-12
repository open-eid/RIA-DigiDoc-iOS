#import <Foundation/Foundation.h>
#import "DigiDocDataFile.h"
#import "DigiDocSignature.h"

@interface DigiDocContainer : NSObject

@property (strong, nonatomic) NSArray<DigiDocDataFile *> *dataFiles;
@property (strong, nonatomic) NSArray<DigiDocSignature *> *signatures;
@property (strong, nonatomic) NSString *mediatype;

@end
