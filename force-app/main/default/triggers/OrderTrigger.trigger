/**
 * @name orderTrigger
 * @description
**/
trigger OrderTrigger on Order (after insert, after update) {
    try {
        for (Order o : Trigger.New) {
            for (OrderItem oi : [SELECT Id, OrderId, Order.Status, Product2Id, Product2.Quantity_Ordered__c, Quantity
                                 FROM OrderItem
                                 WHERE OrderId = :o.Id]) {
                    
				if (oi.Order.Status == Constants.ACTIVATED_ORDER_STATUS) {
                    Product2 p = oi.Product2;
                    p.Quantity_Ordered__c -= oi.Quantity;
                        
                    update p;
                }
					
            }
        }
    } catch (Exception e) {
    
    }
}