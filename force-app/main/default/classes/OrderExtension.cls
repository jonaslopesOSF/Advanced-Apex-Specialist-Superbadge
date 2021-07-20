/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<ChartHelper.ChartData> pieData {get;set;}
    public Decimal total {get;set;}
    public Map<Id, OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;
    
    public OrderExtension(ApexPages.StandardController standardController) {
        this.orderRecord = (Order) standardController.getRecord();
        orderItemMap = new Map<id, OrderItem>();
        
        if (this.orderRecord.Id != null) {
            this.orderRecord = queryOrderRecord(orderRecord.Id);
        }
        
        resetStandardSetController();
        total = 0;

        populateOrderItemMap();
        PopulateOrderItems();
    }

    private void resetStandardSetController() {
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c'
            		 + ' FROM PricebookEntry WHERE IsActive = TRUE';
        
        if (selectedFamily != null && selectedFamily != Constants.SELECT_ONE) {
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        
        query += ' ORDER BY Name';
        
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    
    private void populateOrderItemMap() {
        for (OrderItem oi : orderRecord.OrderItems) {
            orderItemMap.put(oi.Product2Id, oi);
            
            populatePieData(oi);
        }
    }
    
    private void populatePieData(OrderItem oi) {
        if (oi.Quantity > 0) {
            if (pieData == null) {
                pieData = new List<ChartHelper.ChartData>();
            }
            
            String name = oi.Product2.Name;
            Decimal val = (oi.Quantity * oi.UnitPrice);
            pieData.add(new ChartHelper.ChartData(name, val));
            total += (oi.UnitPrice * oi.Quantity);
        }
    }
    
    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection	
    private void PopulateOrderItems() {
        orderItemList = new List<OrderItem>();
        
        for (SObject obj : standardSetController.getRecords()) {
            PricebookEntry pbe = (PricebookEntry) obj;
            
            if (orderItemMap.containsKey(pbe.Product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            } else {
                orderItemList.add(new OrderItem(
                    PricebookEntryId = pbe.Id,
                    Product2Id = pbe.Product2Id,
                    UnitPrice = pbe.UnitPrice,
                    Quantity = 0,
                    Product2 = pbe.Product2
                ));
            }
        }
    }

    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange() {
        //ToDo: Implement logic to store the values changed on the page and populate pieData and populate total
        for (OrderItem oi : orderItemList) {
            orderItemMap.put(oi.Product2Id, oi);
        }
        
        // and populate total
        pieData = null;
        total = 0;
        
        for (OrderItem oi : orderItemMap.values()) {
            populatePieData(oi);
        }
    }
    
    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily() {
        //ToDo: Implement logic to filter based on the selected product family
        resetStandardSetController();
        PopulateOrderItems();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save() {
        //ToDo: Implement logic to save the Order and populated OrderItems
		Savepoint sp = Database.setSavepoint();
        
        try {
            if (orderRecord.Pricebook2Id == null) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            
            upsert orderRecord;
            
            List<OrderItem> orderItemsToBeUpserted = new List<OrderItem>();
            List<OrderItem> orderItemsToBeDeleted = new List<OrderItem>();
            
            for (OrderItem oi : orderItemMap.values()) {
                if(oi.Quantity > 0) {
                    if (oi.OrderId == null) {
                        oi.OrderId = orderRecord.Id;
                    }
                    
                    orderItemsToBeUpserted.add(oi);
                } else {
                    if (oi.Id != null) {
                        orderItemsToBeDeleted.add(oi);
                    }
                }
            }
            
            upsert orderItemsToBeUpserted;
            delete orderItemsToBeDeleted;
        } catch(Exception ex) {
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE);
            ApexPages.addMessage(message);
            Database.rollback(sp);
        }
    }

    /**
     * @name First
     * @description
    **/
    public void First() {
        standardSetController.first();
        PopulateOrderItems();
    }

    /**
     * @name Next
     * @description
    **/
    public void Next() {
		standardSetController.next();
        PopulateOrderItems();
    }

    /**
     * @name Previous
     * @description
    **/
    public void Previous() {
        standardSetController.previous();
        PopulateOrderItems();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last() {
		standardSetController.last();
        PopulateOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious() {
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext() {
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages() {
        Decimal totalSize = standardSetController.getResultSize();
        Decimal pageSize = standardSetController.getPageSize();
        Decimal totalPages = totalSize/pageSize;
        return (Integer) totalPages.round(System.RoundingMode.CEILING);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber() {
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        
        for (Schema.PicklistEntry value : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(value.getLabel(), value.getValue()));
        }
        
        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId) {
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems 
                    WHERE PricebookEntry.isActive = TRUE
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}