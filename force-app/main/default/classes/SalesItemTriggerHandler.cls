public with sharing class SalesItemTriggerHandler extends TriggerHandler{
    List<Sales_Item__c> newItems;
    List<Sales_Item__c> oldItems;
    Map<Id, Sales_Item__c> mapNewItems;
    Map<Id, Sales_Item__c> mapOldItems;

    public SalesItemTriggerHandler(){
        newItems = (List<Sales_Item__c>)Trigger.New;
        oldItems = (List<Sales_Item__c>)Trigger.Old;
        mapNewItems = (Map<Id, Sales_Item__c>)Trigger.NewMap;
        mapOldItems = (Map<Id, Sales_Item__c>)Trigger.OldMap;
    }
    public override void beforeInsert(){
        Map<Id, List<Sales_Item__c>> mapSalesItemsByOppId = new Map<Id, List<Sales_Item__c>>();

        for(Sales_Item__c si : newItems){
            if(!mapSalesItemsByOppId.containsKey(si.Opportunity__c)){
                mapSalesItemsByOppId.put(si.Opportunity__c, new List<Sales_Item__c>());
            }
            mapSalesItemsByOppId.get(si.Opportunity__c).add(si);
        }
        Map<Id, Opportunity> mapOpps = getMapIdOpp(mapSalesItemsByOppId.keySet());

        for(Sales_Item__c si : newItems){
            Opportunity opp = mapOpps.get(si.Opportunity__c);
            Integer oppItemsNum = mapSalesItemsByOppId.get(si.Opportunity__c).size();

            if(opp.Sales_Item_Num__c + oppItemsNum > opp.Sales_Items_Capacity__c){
                si.addError(Label.sales_item_capacity_full);
            }
        }
        
        update mapOpps.values();
    }
    public override void beforeUpdate(){
        Set<Id> setOppIds = new Set<Id>();

        Map<Id, List<Sales_Item__c>> mapSalesItemsByOppId = new Map<Id, List<Sales_Item__c>>();
        for(Sales_Item__c si : newItems){
            if(si.Opportunity__c == mapOldItems.get(si.Id).Opportunity__c){
                continue;
            }
            if(!mapSalesItemsByOppId.containsKey(si.Opportunity__c)){
                mapSalesItemsByOppId.put(si.Opportunity__c, new List<Sales_Item__c>());
            }
            mapSalesItemsByOppId.get(si.Opportunity__c).add(si);
            
            setOppIds.add(si.Opportunity__c);
            setOppIds.add(mapOldItems.get(si.Id).Opportunity__c);
        }

        if(setOppIds.isEmpty() || mapSalesItemsByOppID.isEmpty()){
            return;
        }

        Map<Id, Opportunity> mapNewOpps = getMapIdOpp(setOppIds);
        for(Sales_Item__c si : newItems){
            Integer salesItemsNum = mapSalesItemsByOppId.get(si.Opportunity__c).size();
            Opportunity newOpp = mapNewOpps.get(si.Opportunity__c);

            if(newOpp.Sales_Items_Capacity__c < newOpp.Sales_Item_Num__c + salesItemsNum){
                mapNewItems.get(si.Id).addError(Label.sales_item_capacity_full);
            }
        }

        update mapNewOpps.values();
    }
    private Map<Id, Opportunity> getMapIdOpp(Set<Id> setOppIds){
        return new Map<Id, Opportunity>([
            SELECT Name, Sales_Item_Num__c, Sales_Items_Capacity__c, Current_Sales_Items_Number__c 
            FROM Opportunity 
            WHERE Id=: setOppIds
        ]);
    }
}