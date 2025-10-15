#import <Foundation/Foundation.h>

typedef NS_ENUM(int, DigiDocSignatureStatus) {
    Valid,
    Warning,
    NonQSCD,
    Invalid,
    UnknownStatus
};

@interface DigiDocSignature : NSObject

@property (nonatomic, strong) NSData *signingCert;
@property (nonatomic, strong) NSData *timestampCert;
@property (nonatomic, strong) NSData *ocspCert;
@property (nonatomic, strong) NSString *signatureId;
@property (nonatomic, strong) NSString *claimedSigningTime;
@property (nonatomic, strong) NSString *signatureMethod;
@property (nonatomic, strong) NSString *ocspProducedAt;
@property (nonatomic, strong) NSString *timeStampTime;
@property (nonatomic, strong) NSString *signedBy;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSData *messageImprint;
@property (nonatomic, strong) NSString *trustedSigningTime;

@property (nonatomic, strong) NSArray *roles;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *zipCode;

@property (nonatomic, assign) DigiDocSignatureStatus status;
@property (nonatomic, strong) NSString *diagnosticsInfo;

@end

