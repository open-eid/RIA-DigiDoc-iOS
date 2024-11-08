#import <Foundation/Foundation.h>

typedef NS_ENUM(int, DigiDocSignatureStatus) {
    Valid,
    Warning,
    NonQSCD,
    Invalid,
    UnknownStatus
};

@interface DigiDocSignature : NSObject

@property (strong, nonatomic) NSData *signingCert;
@property (strong, nonatomic) NSData *timestampCert;
@property (strong, nonatomic) NSData *ocspCert;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *claimedSigningTime;
@property (strong, nonatomic) NSString *signatureMethod;
@property (strong, nonatomic) NSData *dataToSign;
@property (strong, nonatomic) NSString *ocspProducedAt;
@property (strong, nonatomic) NSString *timeStampTime;
@property (strong, nonatomic) NSString *signedBy;
@property (strong, nonatomic) NSString *trustedSigningTime;

@property (assign, nonatomic) DigiDocSignatureStatus status;
@property (strong, nonatomic) NSString *diagnosticsInfo;

@end

