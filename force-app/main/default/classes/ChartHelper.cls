public without sharing class ChartHelper {
	
    @AuraEnabled
    public static List<ChartData> GetInventory() {
        List<ChartData> chartData = new List<ChartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        List<AggregateResult> productResult = [SELECT Family, SUM(Quantity_Remaining__c) sum 
                                               FROM Product2 
                                               WHERE IsActive = true AND 
                                               		 Quantity_Remaining__c > 0  
                                               GROUP BY Family];
    
		//  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
		for (AggregateResult result : productResult) {
            String name = (String) result.get('Family');
            Decimal val = (Decimal) result.get('sum');
    		chartData.add(new ChartData(name, val));
		}

        return chartData;
    }
    
    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val) {
            this.name = name;
            this.val = val;
        }
    }

}