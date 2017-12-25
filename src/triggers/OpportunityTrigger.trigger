trigger OpportunityTrigger on Opportunity (before update) {

    if (Trigger.isBefore && Trigger.isUpdate){
        // Create a list of Opportunity records.
        List<Opportunity> oppList = new List<Opportunity>();
        for (Opportunity oppNew :Trigger.new){
            for (Opportunity oppOld :Trigger.old){
                // Only when stage name changes from Delivered to Verified.
                if (oppOld.Id == oppNew.Id && oppOld.StageName == 'Delivered' && oppNew.StageName == 'Verified' && oppNew.Pricebook2Id != null && oppNew.AccountId != null){
                    oppList.add(oppNew);
                }
            }
        }
        // Pass the list to the processing class.
        if (!oppList.isEmpty()){
            createInvoice.createOrderAndOrderItem(oppList);
        }
    }

}