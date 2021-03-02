/***********************************************************************************************************************
* Name:    HereTokenIntegration
* Author:  Konrad Russa - konrad.russa@cognizant.com
* Purpose: Class used for integration with HERE service to obrain token and store in Custom Setting
*======================================================================================================================*
* History                                                                                                              *
* -------                                                                                                              *
* VERSION  AUTHOR           DATE              DETAIL                                               RELEASE/CSR         *
*   1.0 -  Konrad Russa     11.12.2020        INITIAL DEVELOPMENT                                         *
************************************************************************************************************************/

/*
    Prerequisites (created by System Administrator): 
        - Here.com account and project created, credentials obtained (Freemium and later Business account for Production)
        - Remote Site settings created for https://account.api.here.com
        - Custom setting HereSettings__c organization default created 
*/

public with sharing class HereTokenIntegration implements HereTokenScheduler.ISchedule {

    //NamedCredentials to be used
    private static final String HERE_ACCESS_KEY_ID = 'KJE4dEhnut_TFI3rhvI7iw';
    private static final String HERE_ACCESS_KEY_SECRET= 'C68tKsODEjuNEwP4VgRxG_tD-GmsOOs3AKP_wLvDjJTRj02sJooXKficecSHwKU4bkrPaKyXSzHHXLqKl5kX2Q';
    
    private static final String HERE_TOKEN_ENDPOINT_URL = 'https://account.api.here.com/oauth2/token';

    private static final String ACCESS_TOKEN = 'access_token';
    private static final String EXPIRES_IN = 'expires_in';

    private static final Integer HTTP_CODE_OK = 200;

    public static String accessToken;
    public static Integer expiresIn;
    private static Http httpClient;

    private static DateTime startTime;

    static {
        startTime = System.now();
    }

    /**********************************************************
        From ISchedule interface
        
        Method executed when scheduled with HereTokenScheduler apex class
    **********************************************************/
    public void execute(SchedulableContext sc) {
        HereTokenIntegration.storeHereTokenFuture();
    }

    public static Http getHttpClient() {
        if(httpClient == null) {
            httpClient = new Http();
        }
        return httpClient;
    }

    @future(callout=true)
    public static void storeHereTokenFuture() {
        HereTokenIntegration.storeHereToken();
    }

    //Token is valid for 24H - hence can be stored
    //Public to be run manually with HereTokenIntegration.storeHereToken();
    public static void storeHereToken() {

        HttpRequest req = new HttpRequest();
        
        String nonce = createNonce();
        Long seconds = DateTime.now().getTime()/1000;

        String authHeader = 'OAuth '
            + 'oauth_consumer_key="' + HERE_ACCESS_KEY_ID +'", '
            + 'oauth_nonce="' + nonce +'", '
            + 'oauth_signature="' + genrateSignature(nonce, seconds) +'", '
            + 'oauth_signature_method="HMAC-SHA256", '
            + 'oauth_timestamp="' + seconds +'", '
            + 'oauth_version="1.0"';

        req.setHeader('Authorization', authHeader);
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');

        req.setBody('grant_type=client_credentials');

        req.setEndpoint(HERE_TOKEN_ENDPOINT_URL);
        req.setMethod('POST');
    
        // Send the request, and return a response
        HttpResponse res = getHttpClient().send(req);
        String responseBody = res.getBody();

        String token = null;
        Integer expiresTime = null;

        if(res.getStatusCode() == HTTP_CODE_OK && !String.isBlank(responseBody)) {
            
            //System.debug('Token : ' + responseBody);

            Map<String, Object> jsonBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            if(jsonBodyMap.containsKey(ACCESS_TOKEN) && jsonBodyMap.containsKey(EXPIRES_IN)) {
                token = (String)jsonBodyMap.get(ACCESS_TOKEN);
                expiresTime = (Integer)jsonBodyMap.get(EXPIRES_IN);
                accessToken = token;
                expiresIn = expiresTime;
                HereTokenIntegration.storeTokenInCustomSetting(accessToken, expiresIn);
            }
        }
        
    }

    private static String genrateSignature(final String nonce, final Long seconds) {
        String baseString = createBaseString(nonce, seconds);
        String signature = generateHmacSHA256Signature(baseString);
        return signature;
    }

    private static String generateHmacSHA256Signature(final String baseString) {
        Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(baseString), Blob.valueOf(HERE_ACCESS_KEY_SECRET + '&'));
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(hmacData), 'UTF-8');
    }

    private static String createBaseString(final String nonce, final Long seconds) {

        return 'POST' + '&' + EncodingUtil.urlEncode(HERE_TOKEN_ENDPOINT_URL, 'UTF-8') 
                      + '&' + EncodingUtil.urlEncode('grant_type=client_credentials'
                                    + '&oauth_consumer_key=' + HERE_ACCESS_KEY_ID
                                    + '&oauth_nonce=' + nonce
                                    + '&oauth_signature_method=HMAC-SHA256'
                                    + '&oauth_timestamp=' + seconds
                                    + '&oauth_version=1.0', 
                                'UTF-8');
    }

    private static String createNonce() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 32) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    private static void storeTokenInCustomSetting(final string accessToken, final Integer expiresInSeconds) {
        HereSettings__c setting = HereSettings__c.getOrgDefaults();

        try {
            if(setting == null || setting.SetupOwnerId != UserInfo.getOrganizationId()) {
                setting = new HereSettings__c(SetupOwnerId = UserInfo.getOrganizationId());
                insert setting;
            }

            String[] splitArray = split(accessToken, 255, 4);

            setting.TokenPart1__c = splitArray[0];
            setting.TokenPart2__c = splitArray[1];
            setting.TokenPart3__c = splitArray[2];
            setting.TokenPart4__c = splitArray[3];
            setting.TokenExpires__c = startTime.addSeconds(expiresInSeconds);
            update setting;
        } catch(Exception e) {
            ErrorLogUtilities.logException(e);
        }
    }

    private static String[] split(String accessToken, Integer size, Integer fieldsNumber) {
        String toSplit = String.valueOf(accessToken);

        String[] splitArray = new String[fieldsNumber];

        for(Integer i = 0; i < fieldsNumber; i++) {
            splitArray[i] = stringBySize(toSplit, size);
            toSplit = toSplit.removeStart(splitArray[i]);
        }
        return splitArray;
    }

    private static String stringBySize(String toSplit, Integer size) {
        if(toSplit.length() > size) {
            return toSplit.substring(0, toSplit.length() > size ? size : toSplit.length()-1);
        } else  if(toSplit.length() > 0) {
            return toSplit;
        } else {
            return '';   
        } 
    }
}