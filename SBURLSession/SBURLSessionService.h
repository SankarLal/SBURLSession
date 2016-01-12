
#import <Foundation/Foundation.h>
#import "SBURLSessionOperation.h"


#define SERVER_NAME     @"http://api.geonames.org"
#define GEONAMES        @"/citiesJSON?north="

@interface SBURLSessionService : NSObject

+(void)getGeonamesWithNorth:(NSString*)north
                      south:(NSString*)south
                       east:(NSString*)east
                       west:(NSString*)west
                       lang:(NSString*)lang
                   userName:(NSString*)userName
               onCompletion:(OnCompletion)completion
                  onFailure:(OnFailure)failure;

@end
