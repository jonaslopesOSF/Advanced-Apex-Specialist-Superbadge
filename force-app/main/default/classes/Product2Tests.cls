@IsTest(seeAllData = false)
private class Product2Tests {
    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @IsTest
    static void testingConstructor() {
        ApexPages.StandardController controller;
        
        Test.startTest();
            Product2Extension ext = new Product2Extension(controller);
        Test.stopTest();
    }
    
    @IsTest
    private static void Product2Extension_UnitTest() {
        Product2 prod = new Product2(name='Test', isActive=true);
        ApexPages.StandardController controller = new ApexPages.StandardController(prod);
        Product2Extension ext = new Product2Extension(controller);
        
        Test.startTest();
        	PageReference pageRef = Page.Product2New;
            Test.setCurrentPage(pageRef);
            ext.addRows();
        Test.stopTest();
        
        System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());
    }
    
    @IsTest 
    static void testGetFamilyOptions() {
        ApexPages.StandardController controller;
        Product2Extension ext = new Product2Extension(controller);
        
        Test.startTest();
            List<SelectOption> options = ext.getFamilyOptions();
        Test.stopTest();
        
        System.assertEquals(Constants.PRODUCT_FAMILY.size() + 1, options.size());
    }
    
    @IsTest 
    static void testGetInventory() {
        ApexPages.StandardController controller;
        Product2Extension ext = new Product2Extension(controller);
        insert TestDataFactory.ConstructProducts(4);
        
        Test.startTest();
            List<ChartHelper.ChartData> chartData = ext.GetInventory();
        Test.stopTest();
        
        System.assert(chartData.size() > 0);
    }
    
    @IsTest
    static void testSave() {
        ApexPages.StandardController controller;
        Product2Extension ext = new Product2Extension(controller);
        List<Product2> products = TestDataFactory.ConstructProducts(5);
        
        for (Integer i = 0; i < ext.productsToInsert.size(); i++) {
            ext.productsToInsert[i].productRecord = products[i];
            ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 10;
        }
        
        Test.startTest();
        	ext.save();
        Test.stopTest();
        
        List<Product2> productsCreated = [SELECT Id FROM Product2];
        List<PriceBookEntry> priceBookEntryCreated = [SELECT Id FROM PriceBookEntry];
        
        System.assertEquals(Constants.DEFAULT_ROWS, productsCreated.size());
        System.assertEquals(Constants.DEFAULT_ROWS, priceBookEntryCreated.size());
    }
    
    @IsTest
    private static void Product2Trigger_UnitTest() {
        Account account = new Account(Name = 'Account - ');
        insert account;
        Order order = TestDataFactory.ConstructOrders(1, new List<Account>{account}).get(0);
        insert order;
        List<Product2> products = TestDataFactory.ConstructProducts(1);
        insert products;
        List<PriceBookEntry> priceBookEntries = TestDataFactory.ConstructPricebookEntries(products);
        insert priceBookEntries;
        List<OrderItem> orderItems = TestDataFactory.ConstructOrderItems(products.size(), priceBookEntries, new List<Order>{order});
        insert orderItems;
        
        Test.startTest();
            order.Status = Constants.ACTIVATED_ORDER_STATUS;
            update order;
        Test.stopTest();
        
        List<Product2> productsUpdated = [SELECT Id, Quantity_Ordered__c FROM Product2 Order By Id ASC];
        TestDataFactory.verifyQuantityOrdered(products[0], productsUpdated[0], Constants.DEFAULT_ROWS);
    } 
}