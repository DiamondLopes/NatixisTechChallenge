public with sharing class NAT_ProductAPI {
    private static final String LOGIN_API_RECORD = 'loginAPI';
    private static final String PRODUCTS_API_RECORD = 'productsAPI';
    private static String authToken;

    //API objects
    public class AuthResponse {
        public String accessToken;
    }

    //API methods
    public static void authenticate() {
        DataAPI__mdt api = [SELECT Endpoint__c, Password__c, Username__c FROM DataAPI__mdt WHERE Label = :LOGIN_API_RECORD LIMIT 1][0];

        HttpRequest request = new HttpRequest();

        try{
            request.setEndpoint(api.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(new Map<String, String>{
                'username' => api.Username__c,
                'password' => api.Password__c
            }));
    
            Http http = new Http();
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('login response: '+response.getBody());
                AuthResponse auth = (AuthResponse) JSON.deserialize(response.getBody(), AuthResponse.class);
                if(auth.accessToken != null){
                    authToken = auth.accessToken;
                } else {
                    authToken = 'error';
                }
            } else {
                
                throw new CalloutException('Login failed: ' + response.getBody());
            }

		} catch(Exception ex) {

			System.debug(ex.getMessage());
		}
    }

    public static List<Product2> fetchProducts() {

        
        List<Product2> productsResponse= new List<Product2>();

        //Login
        if (authToken == null || authToken == 'error'){
           authenticate();
        } 

        if (authToken != null && authToken != 'error'){

        
            DataAPI__mdt api = [SELECT Endpoint__c FROM DataAPI__mdt WHERE Label = :PRODUCTS_API_RECORD LIMIT 1][0];

            HttpRequest request = new HttpRequest();
    
            try{
                request.setEndpoint(api.Endpoint__c);
                request.setMethod('GET');
                request.setHeader('Authorization', 'Bearer ' + authToken);
        
                Http http = new Http();
                HttpResponse response = http.send(request);
        
                if (response.getStatusCode() == 200) {
        
                    //Process response
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
                    List<Map<String, Object>> productData = new List<Map<String, Object>>();
                    for (Object instance : (List<Object>) jsonResponse.get('products')){
                    productData.add((Map<String, Object>)instance);  
                    }
        
                    for (Map<String, Object> product : productData) {
                        Product2 newProduct = new Product2();
                        newProduct.Name = (String) product.get('title'); 
                        newProduct.NAT_Price__c = (Decimal) product.get('price');
                        newProduct.NAT_Category__c = (String) product.get('category');
                        newProduct.NAT_Brand__c = (String) product.get('brand'); 
                        newProduct.NAT_Stock__c = (Integer) product.get('stock');
                        newProduct.NAT_ThumbnailURL__c = (String) product.get('thumbnail'); 
                        newProduct.NAT_ExternalID__c = (String) String.valueOf(product.get('id')); 
                        productsResponse.add(newProduct);
                    }
        
                    return productsResponse;
        
                } else {
                    throw new CalloutException('Failed to fetch products: ' + response.getBody());
                }
    
            } catch(Exception ex) {
    
                System.debug(ex.getMessage());
            }
        } 
        
        return productsResponse;
    }
}