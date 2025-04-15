@IsTest
private class NAT_ProductSyncHelperTest {
    
    private static final Integer CATEGORY_PRODUCT_LIMIT = 100;
    
    private class DummyJSONMockOverLimits implements HttpCalloutMock {
    
        private final Integer CATEGORY_PRODUCT_LIMIT = 100;
        

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/auth/login')) {
                res.setStatusCode(200);
                res.setBody('{ "accessToken": "mock-token" }');
            } else if (req.getEndpoint().contains('/products')) {
                res.setStatusCode(200);

                //create products over the limit
                String productList = '{"products":[{"id":"0","title":"Sync Product","brand":"SyncBrand","category":"TestCategory","price":90,"thumbnail":"http://img.com/p.jpg","stock":5}';
                for(Integer i=1; i < CATEGORY_PRODUCT_LIMIT+1; i++){
                    productList += ',{"id":"'+i+'","title":"Sync Product","brand":"SyncBrand","category":"TestCategory","price":90,"thumbnail":"http://img.com/p.jpg","stock":5}';
                }
                productList += ']}';
                res.setBody(productList);
            }
            return res;
        }
    }

    @IsTest
    static void testSyncProduct() {
        Test.setMock(HttpCalloutMock.class, new DummyJSONMockOverLimits());

        Test.startTest();
        NAT_ProductSyncHelper.syncProducts();
        Test.stopTest();

        List<Product2> results = [SELECT Name from Product2];
        System.assertEquals(CATEGORY_PRODUCT_LIMIT, results.size());
        System.assertEquals('Sync Product', results[0].Name);
    }
}
