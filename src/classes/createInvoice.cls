public class createInvoice {
    
    public static void createOrderAndOrderItem(list<Opportunity> oppList){
        
        // set the query limit.
        Integer limitQueryRows = System.limits.getLimitQueryRows() /5;
        
        // Create an ID set for Opportunity.
        Set<Id> OpportunityIds = new Set<Id>();
        for (Opportunity opp :oppList) {
            OpportunityIds.add(opp.Id);
        }
        
        // get the OpportunityLineItem Related to the Opportunity.
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        oppLineItemList = [SELECT Id, OpportunityId, Product2Id, PricebookEntryId, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId IN :OpportunityIds LIMIT :limitQueryRows];
        
        // get the Existing Order Related to the Opportunity.
        List<Order> existOrderList = new List<Order>();
        existOrderList = [SELECT Id, OpportunityId FROM Order WHERE OpportunityId IN :OpportunityIds LIMIT :limitQueryRows];
        // DELETE Existing Orders.
        DELETE existOrderList;
        
        // Create an ID set for Account.
        Set<Id> AccountIds = new Set<Id>();
        for (Opportunity opp :oppList) {
            AccountIds.add(opp.AccountId);
        }
        
        // get the Account referenced from the Opportunity.
        List<Account> accList = new List<Account>();
        accList = [SELECT Id, Current_Balance__c FROM Account WHERE Id IN :AccountIds LIMIT :limitQueryRows];
        
        // get the MB Accounting Queue
        String MBAQ = 'MB Accounting Queue';
        Group queue = new Group();
        queue = [SELECT Id, Name, Type FROM Group WHERE Name = :MBAQ AND Type = 'Queue' Limit 1];
        
        // Initialize Order list for INSERT
        List<Order> insertOrderList = new List<Order>();
        // Initialize OrderItem list for INSERT
        List<OrderItem> insertOrderItemList = new List<OrderItem>();
        
        /* Process to create a Order from Opportunity.*/
        System.debug('/* Process to create a Order from Opportunity.*/');
        // Loop the Opportunity list.
        for (Opportunity opp :oppList){
            // When StageName is Verified. Just in case. I will specify the content of the judgment condition.
            if ( opp.StageName == 'Verified'){
                // Create Order for INSERT
                Order insertOrder = new Order();
                insertOrder.OpportunityId = opp.Id;
                insertOrder.OwnerId = queue.Id;
                insertOrder.AccountId = opp.AccountId;
                insertOrder.Status = 'Draft';
                insertOrder.Paid__c = false;
                insertOrder.EffectiveDate = opp.CloseDate;
                insertOrder.EndDate = opp.CloseDate;
                insertOrder.Pricebook2Id = opp.Pricebook2Id;
                insertOrder.Invoice_Total__c = 0; // temporarily set to zero.
                // Loop the Account list.(to set Current Balance.)
                for (Account acc :accList){
                    // When the IDs match.
                    if (acc.Id == opp.AccountId){
                        // When Current Balance is null.
                        if (acc.Current_Balance__c == null){
                            // Set to zero.
                            insertOrder.Current_Balance__c = 0;
                            break;
                        }
                        // When Current Balance is not null.
                        else{
                            // Set the value.
                            insertOrder.Current_Balance__c = acc.Current_Balance__c;
                            break;
                        }
                    }
                }
                insertOrderList.add(insertOrder);
            }
        }
        // INSERT the Orders.
        INSERT insertOrderList;
        
        /* Process to setting an Order to Opportunity.*/
        System.debug('/* Process to setting an Order to Opportunity.*/');
        // Loop the Opportunity list.
        for (Opportunity opp :oppList){
            // Loop the Order list.
            for (Order insertOrder :insertOrderList){
                // When the IDs match.
                if (insertOrder.OpportunityId == opp.Id){
                    // set an Invoice for Opportunity. 
                    opp.Invoice__c = insertOrder.Id;
                }
            }
        }
        
        /* Process to create a OrderItem from OpportunityItem.*/
        System.debug('/* Process to create a OrderItem from OpportunityItem.*/');
        // Loop the Order list.
        for (Order insertOrder :insertOrderList){
            // Loop the OpportunityLineItem list.
            for (OpportunityLineItem oppLineItem :oppLineItemList){
                // When the IDs match.
                if (insertOrder.OpportunityId == oppLineItem.OpportunityId){
                    // Create OrderItem for INSERT
                    OrderItem insertOrderItem = new OrderItem();
                    insertOrderItem.Quantity = oppLineItem.Quantity;
                    insertOrderItem.UnitPrice = oppLineItem.UnitPrice;
                    insertOrderItem.PricebookEntryId = oppLineItem.PricebookEntryId;
                    insertOrderItem.OrderId = insertOrder.Id;
                    insertOrderItemList.add(insertOrderItem);
                }                    
            }
        }
        // INSERT the OrderItems.
        INSERT insertOrderItemList;
        
        /* Process to setting an Invoice Total to Order.*/
        System.debug('/* Process to setting an Invoice Total to Order.*/');
        // Create an ID set for Order.
        Set<Id> OrderIds = new Set<Id>();
        for (Order insertOrder :insertOrderList) {
            OrderIds.add(insertOrder.Id);
        }
        // Re-Select the Orders.
        List<Order> reSelectOrderList = new List<Order>();
        reSelectOrderList = [SELECT Id, AccountId, Invoice_Total__c, TotalAmount, Current_Balance__c FROM Order WHERE Id IN :OrderIds LIMIT :limitQueryRows];
        // Loop Re-Select Order list.
        for (Order reSelectOrder :reSelectOrderList){
            // Set the value.
            reSelectOrder.Invoice_Total__c = reSelectOrder.Current_Balance__c + reSelectOrder.TotalAmount;
        }
        // UPDATE Re-Select Orders.
        UPDATE reSelectOrderList;
        
    }
    
}