@IsTest
private class NAT_ProductAPITest {

    private class DummyJSONMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/auth/login')) {
                res.setStatusCode(200);
                res.setBody('{ "accessToken": "fake-jwt-token" }');
            } else if (req.getEndpoint().contains('/products')) {
                res.setStatusCode(200);
                res.setBody('{"products":[{"id":"1", "title":"Test Product","brand":"BrandX","category":"Electronics","price":99.99,"thumbnail":"http://example.com/image.jpg","stock":10}]}');
            } else {
                res.setStatusCode(400);
                res.setBody('{"error":"Invalid endpoint"}');
            }

            return res;
        }
    }

    

    private class DummyJSONMock_FailProducts implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/auth/login')) {
                res.setStatusCode(200);
                res.setBody('{ "accessToken": "fake-jwt-token" }');
            }  else {
                res.setStatusCode(400);
                res.setBody('{"error":"Invalid request"}');
            }

            return res;
        }
    }

    private class DummyJSONMock_FailLoginServer implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            
            if (req.getEndpoint().contains('/products')) {
                res.setStatusCode(200);
                res.setBody('{"products":[{"id":"1", "title":"Test Product","brand":"BrandX","category":"Electronics","price":99.99,"thumbnail":"http://example.com/image.jpg","stock":10}]}');
            } else {
                res.setStatusCode(500);
                res.setBody('{"error":"Server error"}');
            }

            return res;
        }
    }

    private class DummyJSONMock_FailLoginCredentials implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/auth/login')) {
                res.setStatusCode(200);
                res.setBody('{ "error":"wrong credentials" }');
            }  else {
                res.setStatusCode(400);
                res.setBody('{"error":"Invalid request"}');
            }

            return res;
        }
    }

    @IsTest
    static void testLoginAndFetchProducts() {

        Test.setMock(HttpCalloutMock.class, new DummyJSONMock());

        Test.startTest();
        NAT_ProductAPI.authenticate();
        List<Product2> products = NAT_ProductAPI.fetchProducts();
        Test.stopTest();

        System.assertEquals(1, products.size());
        System.assertEquals('Test Product', products[0].Name);
    }

    @IsTest
    static void testFailTestProducts() {

        Test.setMock(HttpCalloutMock.class, new DummyJSONMock_FailProducts());

        Test.startTest();
        NAT_ProductAPI.authenticate();
        List<Product2> products = NAT_ProductAPI.fetchProducts();
        Test.stopTest();

        System.assertEquals(new List<Product2>(), products);
    }

    @IsTest
    static void testFailTestLogin() {

        Test.setMock(HttpCalloutMock.class, new DummyJSONMock_FailLoginCredentials());

        Test.startTest();
        NAT_ProductAPI.authenticate();
        List<Product2> products = NAT_ProductAPI.fetchProducts();
        Test.stopTest();

        System.assertEquals(new List<Product2>(), products);
    }

    @IsTest
    static void testFailTestLoginServerError() {

        Test.setMock(HttpCalloutMock.class, new DummyJSONMock_FailLoginServer());

        Test.startTest();
        NAT_ProductAPI.authenticate();
        List<Product2> products = NAT_ProductAPI.fetchProducts();
        Test.stopTest();

        System.assertEquals(new List<Product2>(), products);
    }
}
