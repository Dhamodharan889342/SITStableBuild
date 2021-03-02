@IsTest
global class HereCalloutMocksTest {
    
    global class HereTokenHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://account.api.here.com/oauth2/token', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"eyJhbGciOiJSUzUxMiIsImN0eSI6IkpXVCIsImlzcyI6IkhFUkUiLCJhaWQiOiJPSk1leHg4VEZjYnJGTDNST2J1MSIsImlhdCI6MTYwODgwMjMzMiwiZXhwIjoxNjA4ODg4NzMyLCJraWQiOiJqMSJ9.ZXlKaGJHY2lPaUprYVhJaUxDSmxibU1pT2lKQk1qVTJRMEpETFVoVE5URXlJbjAuLnlpU2s4U0pOaF9FaUxaT3dmRjFKNFEuMkxWVmNfaUthSklXYU5hY1NxTG5oNVpmb19KUVh2cG1SVGRHX0FpNzU1ZkRoN1NKWV9lcWIzM3VOYzZMUklqSkpZczU5QzRTcWw2cm1jU2lHMXBhbXBKeFBfczhnbDlDLXVMNkFObUFQYVdveGVzV1Z3S1FoOUw0Y0U4aTRzMURURXYtb2FHempMZHJkN2VONkZkUWx3LjhEUk1WaDBGZFNSLXR1UlRGaVp3TUMtOE1TeU8xM2tMRFlONkNzMTBzOU0.WQOwK0AuHEWiQDaOJ1RuTHj2O2PuT0wizRWs6wqv_DZ6GrqyvoKmXc1Lf58PKAm-FaGASgWqrDEO6KKmYAh-7ZBrCsHc8Wxg2voW0XP-Ekw0esvbj8NKl768gau-4W-R7yG19PdCjejHIKeDi6bir2w_lKnYYK1ei1O8SEEGs4LLV63h9ZKMl_VJIgBgK366dyboIuWVJNQYok-ZGF9UWfYqNIpQXUsfzpq_TEtl0k1iL3WnkyodNxkmlT_JVac8VcA_M9CLTxaJZsc0hZebuAe3u7816kftmHaTU-KR557zQKeG4GhWrjjPX_urWvmszXC9_VaYXyqAh2HziIhw-Q",'
                        + '"token_type":"bearer",'
                        + '"expires_in":86399}');
            res.setStatusCode(200);
            return res;
        }
    }

    global class HereGeolocationOrDistanceHttpCalloutMock implements HttpCalloutMock {

        Boolean showCorrect;

        public HereGeolocationOrDistanceHttpCalloutMock() {
            this.showCorrect = true;
        }

        public HereGeolocationOrDistanceHttpCalloutMock(Boolean showCorrect) {
            this.showCorrect = showCorrect;
        }

        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            List<String> endpoints = new List<String>{'https://geocode.search.hereapi.com/v1/geocode',
                                                      'https://router.hereapi.com/v8/routes'};
            
            String endpointIn = req.getEndpoint().split('\\?')[0];
            
            System.assert(endpoints.contains(endpointIn), 'Either geolocation or route endpoint allowed, got ' + req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String geolocationBodyCorrect = '{"items":[{"title":"Hirsch-Gereuth-Straße 10, 81369 München, Deutschland","id":"here:af:streetsection:P-xZLk.6MiBlrhJsRwM6SB:CgcIBCD1xN9QEAEaAjEwKGQ","resultType":"houseNumber","houseNumberType":"PA","address":{"label":"Hirsch-Gereuth-Straße 10, 81369 München, Deutschland","countryCode":"DEU","countryName":"Deutschland","stateCode":"BY","state":"Bayern","countyCode":"M","county":"München (Stadt)","city":"München","district":"Sendling-Westpark","street":"Hirsch-Gereuth-Straße","postalCode":"81369","houseNumber":"10"},"position":{"lat":48.10705,"lng":11.53153},"access":[{"lat":48.10678,"lng":11.53149}],"mapView":{"west":11.53018,"south":48.10615,"east":11.53288,"north":48.10795},"scoring":{"queryScore":0.95,"fieldScore":{"country":1.0,"city":1.0,"streets":[1.0],"houseNumber":1.0,"postalCode":1.0}}}]}';
            String distanceBodyCorrect = '{"routes":[{"id":"b40bec11-38c6-424e-a330-aca401f46516","sections":[{"id":"fefe88b0-971a-4b86-a1af-21cb7c16d314","type":"vehicle","departure":{"time":"2020-12-24T11:16:27+01:00","place":{"type":"place","location":{"lat":52.5309838,"lng":13.3845671},"originalLocation":{"lat":52.5307999,"lng":13.3847}}},"arrival":{"time":"2020-12-24T11:19:11+01:00","place":{"type":"place","location":{"lat":52.5323264,"lng":13.378874},"originalLocation":{"lat":52.5323,"lng":13.3789}}},"summary":{"duration":164,"length":1051,"baseDuration":155},"transport":{"mode":"car"}}]}]}';
            
            String geolocationBodyINCorrect = '{"title":"Malformed request","status":400,"code":"E605001","cause":"Error while parsing request: \'origin\' parameter is required\n","action":"","correlationId":"73def9bc-248d-425a-a2f8-f3edc399ca97"}';
            String distanceBodyINCorrect = '{"items":[{"title":"Sandrea Ln S, Ladoga, IN 47954, United States","id":"here:af:street:EOI9Msaa-u8YvZq6AZ7HEB","resultType":"street","address":{"label":"Sandrea Ln S, Ladoga, IN 47954, United States","countryCode":"USA","countryName":"United States","stateCode":"IN","state":"Indiana","county":"Montgomery","city":"Ladoga","street":"Sandrea Ln S","postalCode":"47954"},"position":{"lat":39.93456,"lng":-86.74026},"mapView":{"west":-86.74212,"south":39.93455,"east":-86.73841,"north":39.93753},"scoring":{"queryScore":0.89,"fieldScore":{"streets":[0.9]}}},{"title":"Sandrea Ln, Ladoga, IN 47954, United States","id":"here:af:street:I98zrltH3hxpyuCMdJsmGA","resultType":"street","address":{"label":"Sandrea Ln, Ladoga, IN 47954, United States","countryCode":"USA","countryName":"United States","stateCode":"IN","state":"Indiana","county":"Montgomery","city":"Ladoga","street":"Sandrea Ln","postalCode":"47954"},"position":{"lat":39.93456,"lng":-86.74026},"mapView":{"west":-86.74212,"south":39.93455,"east":-86.73841,"north":39.93753},"scoring":{"queryScore":0.78,"fieldScore":{"streets":[0.85]}}}]}';


            if(endpointIn.equals(endpoints.get(0))) {
                if(this.showCorrect) {
                    res.setBody(geolocationBodyCorrect);
                    res.setStatusCode(200);
                } else {
                    res.setBody(geolocationBodyINCorrect);
                    res.setStatusCode(400);
                }
                
            } else if(endpointIn.equals(endpoints.get(1))) {
                if(this.showCorrect) {
                    res.setBody(distanceBodyCorrect);
                    res.setStatusCode(200);
                } else {
                    res.setBody(distanceBodyINCorrect);
                    res.setStatusCode(200);
                }
            }

            
            return res;
        }
    }

}