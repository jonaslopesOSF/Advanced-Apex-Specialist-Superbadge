@IsTest(seeAllData = false)
private class OrderTests {
	@TestSetup
    static void SetupTestData() {
        TestDataFactory.InsertTestData(Constants.DEFAULT_ROWS);
    }
    
    @IsTest
    static void OrderUpdate_UnitTest() {
        List<Order> orders = [SELECT Id, Status FROM Order];
        List<Product2> products = [SELECT Id, Quantity_Ordered__c FROM Product2 Order By Id ASC];
            
        for(Order order : orders) {
            order.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        
        Test.startTest();
        	update orders;
        Test.stopTest();
        
        List<Product2> productsUpdated = [SELECT Id, Quantity_Ordered__c FROM Product2 Order By Id ASC];
        
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
            System.debug('product - ' + products[i]);
            System.debug('product updated - ' + productsUpdated[i]);
            TestDataFactory.verifyQuantityOrdered(products[i], productsUpdated[i], Constants.DEFAULT_ROWS);
        }
    }
    
    @IsTest 
    static void OrderExtension_UnitTest() {
        Account account = new Account(Name = 'Account - ');
        insert account;
        Order order = TestDataFactory.ConstructOrders(1, new List<Account>{account}).get(0);
        insert order;
        List<Product2> products = TestDataFactory.ConstructProducts(Constants.DEFAULT_ROWS);
        insert products;
        List<PriceBookEntry> priceBookEntries = TestDataFactory.ConstructPricebookEntries(products);
        insert priceBookEntries;
        List<OrderItem> orderItems = TestDataFactory.ConstructOrderItems(products.size(), priceBookEntries, new List<Order>{order});
        insert orderItems;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(order);
        OrderExtension orderExtension = new OrderExtension(standardController);
        
        Test.startTest();
        	PageReference pageRef = Page.OrderEdit;
        	Test.setCurrentPage(pageRef);
        Test.stopTest();
        
        System.assertEquals(priceBookEntries.size(), orderExtension.orderItemList.size());
        System.assertEquals(Constants.DEFAULT_ROWS, orderExtension.orderItemMap.values().size());
        System.assertEquals(Constants.DEFAULT_ROWS, orderExtension.pieData.size());
        System.assertEquals(getTotalPrice(orderItems), orderExtension.total);
        
        testGetFamilyOptions(orderExtension);
        testOtherCallingMethods(orderExtension);
    }
    
    static void testGetFamilyOptions(OrderExtension orderExtension) {
        List<SelectOption> options = orderExtension.getFamilyOptions();
        System.assertEquals(Constants.PRODUCT_FAMILY.size() + 1, options.size());
    }
    
    static void testOtherCallingMethods(OrderExtension orderExtension) {
        orderExtension.OnFieldChange();
        orderExtension.SelectFamily();
        
        orderExtension.First();
        System.assertEquals(true, orderExtension.GetHasNext());
        orderExtension.Next();
        System.assert(true, orderExtension.GetHasPrevious());
        orderExtension.Previous();
        orderExtension.Last();
        System.assertEquals(2, orderExtension.GetTotalPages());
        System.assertEquals(2, orderExtension.GetPageNumber());
        orderExtension.Save();
    }
    
    private static Double getTotalPrice(List<OrderItem> orderItems) {
        Double total = 0;
        
        for (OrderItem oi : orderItems) {
            total += (oi.UnitPrice * oi.Quantity);
        }
        
        return total;
    }
}