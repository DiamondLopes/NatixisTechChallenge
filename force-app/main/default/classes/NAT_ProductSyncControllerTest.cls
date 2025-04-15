@IsTest
private class NAT_ProductSyncControllerTest {
    private class DummyJSONMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/auth/login')) {
                res.setStatusCode(200);
                res.setBody('{ "accessToken": "mock-token" }');
            } else if (req.getEndpoint().contains('/products')) {
                res.setStatusCode(200);
                res.setBody('{"products":[' +
                    '{"id":"1", "title":"Test Product","brand":"BrandA","category":"CatA","price":99.9,"thumbnail":"http://img.com/1.jpg","stock":12}' +
                ']}');
            }
            return res;
        }
    }

    @IsTest
    static void testControllerMethods() {

        Test.setMock(HttpCalloutMock.class, new DummyJSONMock());

        Test.startTest();
        // Trigger the refresh logic (will insert 1 product)
        NAT_ProductSyncController.refreshProductData();
        Test.stopTest();

        // Validate that a product is inserted and can be retrieved
        List<Product2> filtered = NAT_ProductSyncController.getProducts();
        System.assertEquals(1, filtered.size());
        System.assertEquals('Test Product', filtered[0].Name);
    }
}
