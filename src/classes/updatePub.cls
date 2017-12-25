public class updatePub {

    public static void setAccountCurrentBalance(list<Order> orderList){
        
        // set the query limit.
		Integer limitQueryRows = System.limits.getLimitQueryRows() /2;

        // Create an ID set for Account.
        Set<Id> AccountIds = new Set<Id>();
        for (Order order :orderList) {
            AccountIds.add(order.AccountId);
        }

        // get the Account referenced from the Order.
        List<Account> accList = new List<Account>();
        accList = [SELECT Id, Current_Balance__c FROM Account WHERE Id IN :AccountIds LIMIT :limitQueryRows];

        /* Process to Aggregating the CurrentBalance.*/
        System.debug('/* Process to Aggregating the CurrentBalance.*/');
        // get Aggregate Result by the Unpaid Order that refers to the Account.
        List<AggregateResult> results = new List<AggregateResult>();
        results = [SELECT Paid__c, AccountId, SUM(TotalAmount) summary FROM Order WHERE AccountId IN :AccountIds AND Paid__c = false GROUP BY AccountId, Paid__c LIMIT :limitQueryRows];

        /* Process to setting an CurrentBalance to Account.*/
        System.debug('/* Process to setting an CurrentBalance to Account.*/');
        // Loop the Account list.
        for (Account acc :accList){
            // Clear the value.(Or,When Account does not have Invoice.)
            acc.Current_Balance__c = 0;
            // Loop Aggregate Result list.
            for (AggregateResult result :results){
                // When the IDs match.
                if (acc.Id == result.get('AccountId')){
                    // Set the value.
                    acc.Current_Balance__c = decimal.valueof(string.valueof(result.get('summary')));
                    break;
                }
            }
        }
        // UPDATE Account list.
        UPDATE accList;

    }

}