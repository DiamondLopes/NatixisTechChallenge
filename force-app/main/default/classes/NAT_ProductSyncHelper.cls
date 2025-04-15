public with sharing class NAT_ProductSyncHelper {

    //Business limits
    private static final Integer CATEGORY_PRODUCT_LIMIT = 100;
    private static final Integer CATEGORY_PRICE_LIMIT = 10000;

    public static void syncProducts() {

        List<Product2> products = NAT_ProductAPI.fetchProducts();

        if(!products.isEmpty()){

            List<Product2> productsToUpsert = new List<Product2>();

            // Categorize and filter by business rule
    
            //Map products by category
            Map<String, List<Product2>> productsByCategory = new Map<String, List<Product2>>();
    
            for (Product2 product : products) {
                if (!productsByCategory.containsKey(product.NAT_Category__c)) {
                    productsByCategory.put(product.NAT_Category__c, new List<Product2>());
                }
                productsByCategory.get(product.NAT_Category__c).add(product);
            }
    
            //Check category limits
            for (String category : productsByCategory.keySet()) {
                List<Product2> categoryProducts = productsByCategory.get(category);
                List<Product2> limitedList = new List<Product2>();
                Decimal priceSum = 0;
    
                for (Product2 product : categoryProducts) {
                    if (limitedList.size() >= CATEGORY_PRODUCT_LIMIT || priceSum + product.NAT_Price__c > CATEGORY_PRICE_LIMIT){
                        break;
                    } 
                    limitedList.add(product);
                    priceSum += product.NAT_Price__c;
                }
    
                for (Product2 product : limitedList) {
                    productsToUpsert.add(product);
                }
            }
    
            //Upsert products filtering by their external ID
            if (!productsToUpsert.isEmpty()) {
                upsert productsToUpsert NAT_ExternalID__c;
            }
        }
    }
}