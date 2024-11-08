#import <Foundation/Foundation.h>

@interface DigiDocDataFile : NSObject

@property (strong, nonatomic) NSString *fileId;
@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) long fileSize;
@property (strong, nonatomic) NSString *mediaType;

@end

