
#import "SBURLSessionService.h"

@implementation SBURLSessionService

+(void)doGenericGetCall:(NSString *)url
           onCompletion:(OnCompletion)completion
              onFailure:(OnFailure)failure {
    
    __block OnCompletion completionBlock = completion;
    __block OnFailure failureBlock = failure;
    __block SBURLSessionOperation *fetcher = [[SBURLSessionOperation alloc]init];
    
    [fetcher executeJSONGet:url onSuccess:^(NSString *responseString) {
        __block id data;
        
        [fetcher parseJSON:responseString onParseComplete:^(NSDictionary *root) {
            data = root;
        }];
        
        
        if (completionBlock) {
            completionBlock(data);
        }
        data = nil;
        completionBlock = nil;
        
    } onFailure:^(NSError * error) {
        
        
        if (failureBlock){
            failureBlock(error);
        }
        
        failureBlock = nil;
    }];
}


+(void)doGenericPostCall:(NSString *)param
             serviceType:(NSString*)serviceType
            onCompletion:(OnCompletion)completion
               onFailure:(OnFailure)failure {
    
    __block OnCompletion completionBlock = completion;
    __block OnFailure failureBlock = failure;
    __block SBURLSessionOperation *fetcher = [[SBURLSessionOperation alloc]init];
    
    
    NSData *requestBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    [fetcher executeJSONPost:[NSString stringWithFormat:@"%@%@", SERVER_NAME, serviceType]
                 requestBody:requestBody onSuccess:^(NSString *responseString) {
                     __block id data;
                     
                     [fetcher parseJSON:responseString onParseComplete:^(NSDictionary *root) {
                         data = root;
                         
                         if (completionBlock) {
                             completionBlock(data);
                         }
                         data = nil;
                         completionBlock = nil;
                     }];
                     
                 } onFailure:^(NSError *error) {
                     
                     if (failureBlock){
                         failureBlock(error);
                     }
                     
                     failureBlock = nil;
                 }];
}

+(void)doGenericPutCall:(NSString *)param
            serviceType:(NSString *)serviceType
           onCompletion:(OnCompletion)completion
              onFailure:(OnFailure)failure {
    
    __block OnCompletion completionBlock = completion;
    __block OnFailure failureBlock = failure;
    __block SBURLSessionOperation *fetcher = [[SBURLSessionOperation alloc]init];
    
    
    NSData *requestBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    [fetcher executeJSONPut:[NSString stringWithFormat:@"%@%@", SERVER_NAME, serviceType]
                 requestBody:requestBody onSuccess:^(NSString *responseString) {
                     __block id data;
                     
                     [fetcher parseJSON:responseString onParseComplete:^(NSDictionary *root) {
                         data = root;
                         
                         if (completionBlock) {
                             completionBlock(data);
                         }
                         data = nil;
                         completionBlock = nil;
                     }];
                     
                 } onFailure:^(NSError *error) {
                     
                     if (failureBlock){
                         failureBlock(error);
                     }
                     
                     failureBlock = nil;
                 }];
}

+(void)doGenericDeleteCall:(NSString *)url
              onCompletion:(OnCompletion)completion
                 onFailure:(OnFailure)failure {
    
    __block OnCompletion completionBlock = completion;
    __block OnFailure failureBlock = failure;
    __block SBURLSessionOperation *fetcher = [[SBURLSessionOperation alloc]init];
    
    [fetcher executeJSONDelete:url onSuccess:^(NSString *responseString) {
        __block id data;
        
        [fetcher parseJSON:responseString onParseComplete:^(NSDictionary *root) {
            data = root;
        }];
        
        
        if (completionBlock) {
            completionBlock(data);
        }
        data = nil;
        completionBlock = nil;
        
    } onFailure:^(NSError * error) {
        
        
        if (failureBlock){
            failureBlock(error);
        }
        
        failureBlock = nil;
    }];
}


+(void)getGeonamesWithNorth:(NSString*)north
                      south:(NSString*)south
                       east:(NSString*)east
                       west:(NSString*)west
                       lang:(NSString*)lang
                   userName:(NSString*)userName
               onCompletion:(OnCompletion)completion
                  onFailure:(OnFailure)failure {

    NSString *url = [NSString stringWithFormat:@"%@%@%@&south=%@&east=%@&west=%@&lang=%@&username=%@", SERVER_NAME, GEONAMES, north, south, east, west, lang, userName];
    
    NSLog(@"URL %@",url);
    [self doGenericGetCall:url
              onCompletion:completion onFailure:failure];

}


@end
