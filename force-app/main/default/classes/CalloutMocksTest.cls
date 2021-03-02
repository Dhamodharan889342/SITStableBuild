@IsTest
global class CalloutMocksTest {
    
    @TestSetup static void prepareToken() {
        HereSettings__c setting = new HereSettings__c(SetupOwnerId = UserInfo.getOrganizationId());
        setting.TokenPart1__c = '1234';
        setting.TokenPart2__c = '1234';
        setting.TokenPart3__c = '1234';
        setting.TokenPart4__c = '1234';
        setting.TokenExpires__c = System.now().addDays(1);
        insert setting;
        
    }

    global class GlobalHttpCalloutMock implements HttpCalloutMock {

        Boolean showCorrect;

        public GlobalHttpCalloutMock() {
            this.showCorrect = true;
        }

        public GlobalHttpCalloutMock(Boolean showCorrect) {
            this.showCorrect = showCorrect;
        }

        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            List<String> endpoints = new List<String>{'https://geocode.search.hereapi.com/v1/geocode',
                                                      'https://router.hereapi.com/v8/routes',
                                                      'callout:CXPDIHInterface'};
            
            String endpointIn = req.getEndpoint();
            if(req.getEndpoint().contains('?')) {
                endpointIn = req.getEndpoint().split('\\?')[0];
            } 
            
            System.assert(endpoints.contains(endpointIn), 'Either HEREgeolocation or HEREroute or CXP_ERPCalloutMock endpoint allowed, got ' + req.getEndpoint());
            
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String geolocationBodyCorrect = '{"items":[{"title":"Hirsch-Gereuth-Straße 10, 81369 München, Deutschland","id":"here:af:streetsection:P-xZLk.6MiBlrhJsRwM6SB:CgcIBCD1xN9QEAEaAjEwKGQ","resultType":"houseNumber","houseNumberType":"PA","address":{"label":"Hirsch-Gereuth-Straße 10, 81369 München, Deutschland","countryCode":"DEU","countryName":"Deutschland","stateCode":"BY","state":"Bayern","countyCode":"M","county":"München (Stadt)","city":"München","district":"Sendling-Westpark","street":"Hirsch-Gereuth-Straße","postalCode":"81369","houseNumber":"10"},"position":{"lat":48.10705,"lng":11.53153},"access":[{"lat":48.10678,"lng":11.53149}],"mapView":{"west":11.53018,"south":48.10615,"east":11.53288,"north":48.10795},"scoring":{"queryScore":0.95,"fieldScore":{"country":1.0,"city":1.0,"streets":[1.0],"houseNumber":1.0,"postalCode":1.0}}}]}';
            String distanceBodyCorrect = '{"routes":[{"id":"b40bec11-38c6-424e-a330-aca401f46516","sections":[{"id":"fefe88b0-971a-4b86-a1af-21cb7c16d314","type":"vehicle","departure":{"time":"2020-12-24T11:16:27+01:00","place":{"type":"place","location":{"lat":52.5309838,"lng":13.3845671},"originalLocation":{"lat":52.5307999,"lng":13.3847}}},"arrival":{"time":"2020-12-24T11:19:11+01:00","place":{"type":"place","location":{"lat":52.5323264,"lng":13.378874},"originalLocation":{"lat":52.5323,"lng":13.3789}}},"summary":{"duration":164,"length":1051,"baseDuration":155},"transport":{"mode":"car"}}]}]}';
            
            String geolocationBodyINCorrect = '{"title":"Malformed request","status":400,"code":"E605001","cause":"Error while parsing request: \'origin\' parameter is required\n","action":"","correlationId":"73def9bc-248d-425a-a2f8-f3edc399ca97"}';
            String distanceBodyINCorrect = '{"items":[{"title":"Sandrea Ln S, Ladoga, IN 47954, United States","id":"here:af:street:EOI9Msaa-u8YvZq6AZ7HEB","resultType":"street","address":{"label":"Sandrea Ln S, Ladoga, IN 47954, United States","countryCode":"USA","countryName":"United States","stateCode":"IN","state":"Indiana","county":"Montgomery","city":"Ladoga","street":"Sandrea Ln S","postalCode":"47954"},"position":{"lat":39.93456,"lng":-86.74026},"mapView":{"west":-86.74212,"south":39.93455,"east":-86.73841,"north":39.93753},"scoring":{"queryScore":0.89,"fieldScore":{"streets":[0.9]}}},{"title":"Sandrea Ln, Ladoga, IN 47954, United States","id":"here:af:street:I98zrltH3hxpyuCMdJsmGA","resultType":"street","address":{"label":"Sandrea Ln, Ladoga, IN 47954, United States","countryCode":"USA","countryName":"United States","stateCode":"IN","state":"Indiana","county":"Montgomery","city":"Ladoga","street":"Sandrea Ln","postalCode":"47954"},"position":{"lat":39.93456,"lng":-86.74026},"mapView":{"west":-86.74212,"south":39.93455,"east":-86.73841,"north":39.93753},"scoring":{"queryScore":0.78,"fieldScore":{"streets":[0.85]}}}]}';

            String CXP_ERPCalloutMock = '{"response":{"header":{"ifId":"IF_EU_CXP_DIH_0000","ifSender":"CXP","ifDateTime":"20200331131523","ifReceiver":"DIH","ifSenderGrp":"EU","ifTrackingId":" ","ifReceiverGrp":"EU"},"payload":{"ErrorMsg":" ","ErrorCode":" ","ResultCode":"S"}}}';

            if(endpointIn.equals(endpoints.get(0))) {
                System.assertEquals('GET', req.getMethod());
                if(this.showCorrect) {
                    res.setBody(geolocationBodyCorrect);
                    res.setStatusCode(200);
                } else {
                    res.setBody(geolocationBodyINCorrect);
                    res.setStatusCode(400);
                }
                
            } else if(endpointIn.equals(endpoints.get(1))) {
                System.assertEquals('GET', req.getMethod());
                if(this.showCorrect) {
                    res.setBody(distanceBodyCorrect);
                    res.setStatusCode(200);
                } else {
                    res.setBody(distanceBodyINCorrect);
                    res.setStatusCode(200);
                }
            } else if(endpointIn.equals(endpoints.get(2))) {  
                System.assertEquals('POST', req.getMethod());   
                res.setBody(CXP_ERPCalloutMock);
                res.setStatusCode(200);
            }

            
            return res;
        }
    }
}