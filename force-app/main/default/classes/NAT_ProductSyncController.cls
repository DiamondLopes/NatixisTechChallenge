public with sharing class NAT_ProductSyncController {
    @AuraEnabled
    public static void refreshProductData() {
        NAT_ProductSyncHelper.syncProducts();
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return Database.query('SELECT Id, Name, NAT_Category__c, NAT_Brand__c, NAT_Price__c, NAT_Stock__c, NAT_ThumbnailURL__c FROM Product2 WHERE NAT_ExternalID__c != null');
    }
}
