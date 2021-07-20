/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup() {
        return new CollaborationGroup(
        	Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS,
            CollaborationType = 'Public'
        );
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt) {
        List<Product2> productsToBeCreated = new List<Product2>();
        
        for (Integer i = 0; i < cnt; i++) {
            Product2 product = new Product2(
                Name = 'testProduct ' + i,
                IsActive = true,
                Initial_Inventory__c = 10,
                Quantity_Ordered__c = 0,
                Family = Constants.PRODUCT_FAMILY.get(math.mod(i, 4)).getValue()
            );
           
            productsToBeCreated.add(product);
        }
        
        return productsToBeCreated;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PriceBookEntry> ConstructPricebookEntries(List<Product2> prods) {
        List<PriceBookEntry> priceBookEntriesToBeCreated = new List<PriceBookEntry>();
        
        for (Product2 prod : prods) {
            PriceBookEntry pbe = new PriceBookEntry(
            	UnitPrice = 0,
                IsActive = true,
                Product2Id = prod.Id,
                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID
            );
            
            priceBookEntriesToBeCreated.add(pbe);
        }
        
        return priceBookEntriesToBeCreated;  
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt) {
        List<Account> accountsToBeCreated = new List<Account>();
        
        for (Integer i = 0; i < cnt; i++) {
            Account account = new Account(
            	Name = 'Account - ' + i
            );
            
            accountsToBeCreated.add(account);
        }
        
        return accountsToBeCreated;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts) {
        List<Contact> contactsToBeCreated = new List<Contact>();
          
        for(Integer i = 0; i < cnt; i++) {
            Integer index = Math.mod(i, accts.size());
            
            Contact contact = new Contact(
                LastName = 'TestContact' + i,
                AccountId = accts.get(index).Id
            );
           
            contactsToBeCreated.add(contact);            
        }
        
        return contactsToBeCreated;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts) {        
        List<Order> ordersToBeCreated = new List<Order>();
        
        for (Integer i = 0; i < cnt; i++) {
            Order order = new Order(
                AccountId = accts.get(Math.mod(i, accts.size())).Id,
                Status = 'Draft',
                EffectiveDate = System.today(),
                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID
            );
            
            ordersToBeCreated.add(order);   
        }
        
        return ordersToBeCreated;  
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(Integer cnt, List<PriceBookEntry> pbes, List<Order> ords) {
        List<OrderItem> ordersItemsToBeCreated = new List<OrderItem>();
          
        for (Integer i = 0; i < cnt; i++) {
            OrderItem orderItem = new OrderItem(
                Quantity = Constants.DEFAULT_ROWS,
                UnitPrice = 10,
                OrderId = ords.get(Math.mod(i, ords.size())).Id,
                PricebookEntryId = pbes.get(Math.mod(i, pbes.size())).Id
            );
            
            ordersItemsToBeCreated.add(orderItem);   
        }

        return ordersItemsToBeCreated;  
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    
    public static void InsertTestData(Integer cnt) {
        List<Account> accounts = ConstructAccounts(cnt);
        insert accounts;
        
        List<Contact> contacts = ConstructContacts(cnt, accounts);
        insert contacts;
        
        List<Product2> products = ConstructProducts(cnt);
        insert products;
        
        List<PriceBookEntry> priceBookEntries = ConstructPricebookEntries(products);
        insert priceBookEntries;
        
        List<Order> orders = ConstructOrders(cnt, accounts);
        insert orders;
        
        List<OrderItem> orderItems = ConstructOrderItems(cnt, priceBookEntries, orders);
        insert orderItems;
    }
    
    public static void verifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals(updatedProduct.Quantity_Ordered__c, originalProduct.Quantity_Ordered__c + qtyOrdered);
    }
}