public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    
    public Product2Extension(ApexPages.StandardController controller) {
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void addRows() {
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
            productsToInsert.add(new ProductWrapper());
        }
    }
    
    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        
        for (Schema.PicklistEntry value : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(value.getLabel(), value.getValue()));
        }
        
        return options;
    }

    public List<ChartHelper.ChartData> GetInventory() {
        return ChartHelper.GetInventory();
    }

    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        
        try {
            List<ProductWrapper> filteredProductWrappers = new List<ProductWrapper>();
            List<Product2> productsToInsertObject = new List<Product2>();
            List<PricebookEntry> pricebookEntryToInsert = new List<PricebookEntry>();
            
            filteredProductWrappers.addAll(retrieveProductsFromWrapper());
            
            for(ProductWrapper pw : filteredProductWrappers) {
                productsToInsertObject.add(pw.productRecord);
            }
            
            List<Database.SaveResult> productSaveResults = Database.insert(productsToInsertObject, false);
            
            pricebookEntryToInsert.addAll(retrievePricebookEntryFromWrapper(productSaveResults, filteredProductWrappers));
            insert pricebookEntryToInsert;
                        
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.INFO, productsToInsertObject.size() + ' Inserted');
            ApexPages.addMessage(message);
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE);
			ApexPages.addMessage(message);
            Database.rollback(sp);
        }
        
        return null;
    }
    
    private List<ProductWrapper> retrieveProductsFromWrapper() {
        List<ProductWrapper> products = new List<ProductWrapper>();
        
        for (ProductWrapper pw : productsToInsert) {
            if(!String.isBlank(pw.productRecord.Name) && 
               !String.isBlank(pw.productRecord.Family) && 
               pw.productRecord.Family != Constants.SELECT_ONE && 
               pw.productRecord.isActive &&
               pw.pricebookEntryRecord.UnitPrice != null && 
               pw.pricebookEntryRecord.UnitPrice != 0 &&
               pw.productRecord.Initial_Inventory__c != null && 
               pw.productRecord.Initial_Inventory__c != 0) {
				products.add(pw);
			}        
        }
        
        return products;
    }
    
    private List<PriceBookEntry> retrievePricebookEntryFromWrapper(List<Database.SaveResult> productSaveResults, 
                                                                   List<ProductWrapper> filteredProductWrappers) {
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();
        
        for (Integer i = 0; i < productSaveResults.size(); i++) {
            if (productSaveResults.get(i).isSuccess()) {
                filteredProductWrappers[i].pricebookEntryRecord.Product2Id = filteredProductWrappers[i].productRecord.Id;
            	priceBookEntries.add(filteredProductWrappers[i].pricebookEntryRecord);
            }
        }
        
        return priceBookEntries;
    }

    public class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        
        public ProductWrapper() {
        	productRecord = new Product2();
            productRecord.Initial_Inventory__c = 0;
            productRecord.isActive = true;
            
        	pricebookEntryRecord = new PriceBookEntry();
			pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pricebookEntryRecord.UnitPrice = 0;
            pricebookEntryRecord.isActive = true;
        }
    }
}