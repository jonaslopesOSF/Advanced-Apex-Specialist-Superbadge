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
        
        for (Integer i = 0; i < 0; i++) {
            TestDataFactory.verifyQuantityOrdered(products[i], productsUpdated[i], Constants.DEFAULT_ROWS);
        }
    }
}