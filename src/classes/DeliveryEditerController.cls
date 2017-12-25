public class DeliveryEditerController {
    
    // Governor's select limit value.
    public Integer limitQueryRows;
    // Editing Opportunity.
    public Opportunity currentOpportunity;
    // Selected Account.
    public Account currentAccount{get;set;}
    // You can change Account.
    public Boolean isAccCanChange{get;set;}
    // Account address has already been entered.
    public Boolean isAccAddressExist{get;set;}
    // Display the beverage search area.
    public Boolean dispSearch{get;set;}
    // String to search for a beverage.
    public String SearchString{get;set;}

    // List of Pickup Edit screen.
    public List<EditPikupLineItem> editPikupOppLineItemList{get;set;}
    // List of beverage brewed by puffs.
    public List<PricebookEntry> pubsPikupBeverageList;
    // Pickup registered list.
    public List<OpportunityLineItem> existPikupOppLineItemList;

    // List of Delivery Edit Screen.
    public List<EditDeliveryLineItem> editDeliveryOppLineItemList{get;set;}
    // List of beverage searched.
    public List<PricebookEntry> searchDeliveryBeverageList{get;set;}
    // ID for delivery Addition.
    public String addPricebookEntryId;
    // ID to  delete from delivery . (for inserted record)
    public String deleteOpportunityLineItemId;
    // Datetime to delete from delivery. (for uninserted record)
    public String deletePricebookEntryAddedTime;
    // Delivery registered list.
    public List<OpportunityLineItem> existDeliveryOppLineItemList;

    // beverage list for UPSERT.
    public List<OpportunityLineItem> upsertOppLineItemList;
    // beverage list for DELETE.
    public List<OpportunityLineItem> deleteOppLineItemList;

    // Error string that exceeding 100 search results.
    private String errorMessage1 = 'The result should not exceed 100.';
    // Error string that specifies the search keyword.
    private String errorMessage2 = 'You must enter a more specific search.';
    // Error string that below 0 search results.
    private String errorMessage10 = 'There was no result.';
    // Error string that different the search keyword.
    private String errorMessage20 = 'You must enter a different search.';
    // Error string that account address is not entered.
    private String errorMessage3 = 'Please enter Pub Shipping address.';
    // Error string that enter account address.
    private String errorMessage4 = 'Address can not be displayed.';
    // Error string that create an active BEER.
    private String errorMessage5 = 'Please create an active BEER.';
    // Error string that must have active BEER.
    private String errorMessage6 = 'Pub must have active BEER.';    

    /* Constructor */
    public DeliveryEditerController(ApexPages.StandardController stdController){

        // SELECT four times with one transaction.
        limitQueryRows = System.limits.getLimitQueryRows() /4;
        // Instantiate each variable.
        editPikupOppLineItemList = new List<EditPikupLineItem>();
        pubsPikupBeverageList = new List<PricebookEntry>();
        existPikupOppLineItemList = new List<OpportunityLineItem>();
        editDeliveryOppLineItemList = new List<EditDeliveryLineItem>();
        searchDeliveryBeverageList = new List<PricebookEntry>();
        existDeliveryOppLineItemList = new List<OpportunityLineItem>();
        upsertOppLineItemList = new List<OpportunityLineItem>();
        deleteOppLineItemList= new List<OpportunityLineItem>();
        currentAccount = new Account();
        // Opportunity initial value setting.
        currentOpportunity = (Opportunity)stdController.getRecord();
        currentOpportunity.Purchase_Discount__c = 15;
        currentOpportunity.Sale_Discount__c = 30;
        // Set the opportunity name and stage name only when newly created.
        if (currentOpportunity.Name == null){
            currentOpportunity.Name = 'New Delivery';
            currentOpportunity.StageName = 'In Progress';
        }
        // Account can be changed only when newly created.
        isAccCanChange = false;
        if (currentOpportunity.AccountId == null){
            isAccCanChange = true;
        }
        // When account is selected during editing.
        else{
            initAccInfo();
        }

        // Opportunity initial value setting.
        setOppDeliveryDate();
        // Delivery initial setting.
        getDeliveryLineItem();
        createEditDeliveryList();

    }
    
    /* Process to be executed each time Account is selected. */
    public void initAccInfo(){
        getCurrentAccount();
        setOppDiscount();
        getPikupLineItem();
        getPikupBeverages();
        createEditPickupList();
    }

    /* Process when click the Save button. */
    public PageReference saveButton() {
        // case where DmlException occurs.
        try{
            saveOpportunity();
            saveOpportunityLineItem();
            // Go to the Opportunity's standard details page.
            PageReference pageRef = new PageReference('/' + currentOpportunity.Id);
            return pageRef;
        }catch (System.DmlException e){
            // Display DmlException error message.
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));
                System.debug('*** DmlException = ' + e.getDmlMessage(i));
            }
        }
        return null;
    }

    /* Process when click the Submit button. */
    public PageReference submitButton() {
        // case where DmlException occurs.
        try{
            saveOpportunity();
            saveOpportunityLineItem();
            approvalOpportunity();
            // Go to the Opportunity's standard details page.
            PageReference pageRef = new PageReference('/' + currentOpportunity.Id);
            return pageRef;
        }catch (System.DmlException e){
            // Display DmlException error message.
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));
                System.debug('*** DmlException = ' + e.getDmlMessage(i));
            }
        }
        return null;
    }
    
    /* Process when click the Search for Beverages button. */
    public void searchBeveragesButton() {
        // will display the beverage search area.
        dispSearch = true;
    }
    
    /* Process when click the Add to Delivery button. */
    public void addToDeliveryButton(){
        // Will Hide the beverage search area.
        dispSearch = false;
        // Get the record ID string of the button clicked from Visualforce.
        addPricebookEntryId = ApexPages.currentPage().getParameters().get('addPricebookEntryId');
        addEditDeliveryList();
    }

    /* Process when click the Deleat button. */
    public void deleteButton(){
        // Get the record added time string of the button clicked from Visualforce.
        deletePricebookEntryAddedTime = ApexPages.currentPage().getParameters().get('deletePricebookEntryAddedTime');
        // Get the record ID string of the button clicked from Visualforce.
        deleteOpportunityLineItemId = ApexPages.currentPage().getParameters().get('deleteOpportunityLineItemId');
        deleteEditDeliveryList();
    }
    
    /* Process to save Opportunity. */
    public void saveOpportunity() {
        UPSERT currentOpportunity;
    }
    
    /* Process to save Pickup and Delivery. */
    public void saveOpportunityLineItem(){
        // Process values in the pickup edit screen.
        for (EditPikupLineItem editPikupOppLineItem :editPikupOppLineItemList){
            // Only when there is more than one quantity.
            if (editPikupOppLineItem.oppli.Quantity > 0){
                // When Opportunity is newly created. Set Opportunity Id.
                if (editPikupOppLineItem.oppli.OpportunityId == null){
                    editPikupOppLineItem.oppli.OpportunityId = currentOpportunity.Id;
                }
                upsertOppLineItemList.add(editPikupOppLineItem.oppli);
            }
            // When the Quantity of Beverage is 0. Delete the beverage.
            else if (editPikupOppLineItem.oppli.Id != null){
                deleteOppLineItemList.add(editPikupOppLineItem.oppli);
            }
        }
        // Process value in the delivery edit screen.
        for (EditDeliveryLineItem editDeliveryOppLineItem :editDeliveryOppLineItemList){
            // Only when there is more than one quantity.
            if (editDeliveryOppLineItem.oppli.Quantity > 0){
                // When Opportunity is newly created. Set Opportunity Id.
                if (editDeliveryOppLineItem.oppli.OpportunityId == null){
                    editDeliveryOppLineItem.oppli.OpportunityId = currentOpportunity.Id;
                }
                upsertOppLineItemList.add(editDeliveryOppLineItem.oppli);
            }
            // When the Quantity of Beverage is 0. Delete the beverage.
            else if (editDeliveryOppLineItem.oppli.Id != null){
                deleteOppLineItemList.add(editDeliveryOppLineItem.oppli);
            }
        }
        DELETE deleteOppLineItemList;
        UPSERT upsertOppLineItemList;
    }
    
    /* Process to start Opportunity approval. */
    public void approvalOpportunity() {
        Approval.ProcessSubmitRequest apsr = new Approval.ProcessSubmitRequest();
        apsr.setObjectId(currentOpportunity.Id);
        // Select the next approver who has already been set up.
        apsr.setNextApproverIds(null);
        Approval.ProcessResult apr = Approval.process(apsr);
    }
    
    /* Process to get value of Account. */
    public void getCurrentAccount() {
        // will check if can have select an account. case where an account that does not exist is entered.
        Integer currentAccCount = [SELECT COUNT() FROM Account WHERE Id = :currentOpportunity.AccountId ];
        // Only when it can SELECT, will get the value.
        if (currentAccCount > 0){
            currentAccount = [SELECT Id, Name, ShippingAddress, ShippingCountry, ShippingState, ShippingCity, ShippingStreet, ShippingPostalCode, Sale_Discount__c, Purchase_Discount__c FROM Account WHERE Id = :currentOpportunity.AccountId];
        }
        // Map and address are displayed only when address of Account has been entered.
        if (currentAccount.ShippingAddress != null){
            isAccAddressExist = true;
        }
        // If address of account is not entered, an error message will displayed.
        else{
            isAccAddressExist = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage3));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage4));
        }
    }
    
    /* Process to setting Opportunity discount. */
    public void setOppDiscount(){
        // case where account discount has not been entered.
        if (currentAccount.Purchase_Discount__c > 0){
            currentOpportunity.Purchase_Discount__c = currentAccount.Purchase_Discount__c;
        }
        // case where account discount has not been entered.
        if (currentAccount.Sale_Discount__c > 0){
            currentOpportunity.Sale_Discount__c = currentAccount.Sale_Discount__c;
        }
    }
        
    /* Process to setting Opportunity closing date. */
    public void setOppDeliveryDate(){
        // Do not overwrite if the opportunitie has already set close date.
        if (currentOpportunity.CloseDate == null){
            currentOpportunity.CloseDate = date.today();
        }
    }

    /* Process to selecting registered Pickup. */
    public void getPikupLineItem() {
        existPikupOppLineItemList = [SELECT Id, Name, OpportunityId, ListPrice, Pick_Up__c, Product2Id, Product2.Name, Product2.Description, Quantity, UnitPrice, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.Description, PricebookEntry.UnitPrice FROM OpportunityLineItem WHERE Pick_Up__c = true AND OpportunityId = :currentOpportunity.Id LIMIT :limitQueryRows];
    }
    
    /* Process to selecting pub beverage. */
    public void getPikupBeverages() {
        pubsPikupBeverageList = [SELECT Id, Name, Product2Id, Product2.Craft_Brewer__c, Product2.Name, Product2.Description, UnitPrice, Product2.IsActive FROM PricebookEntry WHERE Product2.IsActive = true AND Product2.Craft_Brewer__c = :currentAccount.Id LIMIT :limitQueryRows];
        // If account have no active BEER, an error message will displayed.
        if (pubsPikupBeverageList.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage5));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage6));
        }
    }
    
    /* Process to creating list for Pickup edit. */
    public void createEditPickupList(){
        editPikupOppLineItemList.clear();
        EditPikupLineItem addItem;
        for (PricebookEntry pubsPikupBeverage :pubsPikupBeverageList){
            Boolean isExistOppLineItem = false;
            addItem = new EditPikupLineItem();
            for (OpportunityLineItem existPikupOppLineItem :existPikupOppLineItemList){
                // when already registered in Pickup, select the registered value.
                if (pubsPikupBeverage.Id == existPikupOppLineItem.PricebookEntryId){
                    isExistOppLineItem = true;
                    addItem.oppli = existPikupOppLineItem;
                    addItem.pbe = existPikupOppLineItem.PricebookEntry;
                    addItem.name = existPikupOppLineItem.Product2.Name;
                    addItem.descript = existPikupOppLineItem.Product2.Description;
                }
            }
            if (isExistOppLineItem){
                editPikupOppLineItemList.add(addItem);
            }
            // when not registered in the pickup, set quantity 0.
            else{
                addItem = new EditPikupLineItem();
                addItem.oppli.OpportunityId = currentOpportunity.Id;
                addItem.oppli.PricebookEntryId = pubsPikupBeverage.Id;
                addItem.oppli.Pick_Up__c = true;
                addItem.oppli.UnitPrice = pubsPikupBeverage.UnitPrice * currentOpportunity.Purchase_Discount__c / 100 * -1;
                addItem.oppli.Quantity = 0;
                addItem.pbe = pubsPikupBeverage;
                addItem.name = pubsPikupBeverage.Product2.Name;
                addItem.descript = pubsPikupBeverage.Product2.Description;
                editPikupOppLineItemList.add(addItem);
            }
        }
    }
    
    /* Process to adding beverage for delivery. */
    public void addEditDeliveryList(){
        EditDeliveryLineItem addItem;
        for (PricebookEntry searchDeliveryBeverage :searchDeliveryBeverageList){
            // When selected from the search beverage, add it to delivery.
            if (searchDeliveryBeverage.Id == addPricebookEntryId){
                addItem = new EditDeliveryLineItem();
                addItem.oppli.OpportunityId = currentOpportunity.Id;
                addItem.oppli.PricebookEntryId = addPricebookEntryId;
                addItem.oppli.UnitPrice = searchDeliveryBeverage.UnitPrice * currentOpportunity.Sale_Discount__c / 100;
                addItem.oppli.Pick_Up__c = false;
                addItem.oppli.Quantity = 0;
                addItem.pbe = searchDeliveryBeverage;
                addItem.name = searchDeliveryBeverage.Product2.Name;
                addItem.descript = searchDeliveryBeverage.Product2.Description;
                addItem.addedtime = String.valueOf(Datetime.now());
                editDeliveryOppLineItemList.add(addItem);
                break;                
            }
        }
    }

    /* Process to Deleting beverage for delivery. */
    public void deleteEditDeliveryList(){
        Integer listIndex = 0;
        // the remove list has, store the List Index number to be deleted.
        List<Integer> removeIndexList = new List<Integer>();
        for (EditDeliveryLineItem editDeliveryOppLineItem :editDeliveryOppLineItemList){
                // when record was notinserted, the record whose addedtime matches.
            if (deletePricebookEntryAddedTime != null && deletePricebookEntryAddedTime == editDeliveryOppLineItem.addedtime){
                // Add List Index number to the remove list.
                removeIndexList.add(listIndex);
                break;
            }
            // when record was inserted, the record whose ID matches.
            if	(deleteOpportunityLineItemId != null && deleteOpportunityLineItemId == String.valueOf(editDeliveryOppLineItem.oppli.Id)){
                // Add List Index number to the remove list.
                removeIndexList.add(listIndex);
                // Add record to the Delete list.
                deleteOppLineItemList.add(editDeliveryOppLineItem.oppli);
                break;
            }
            // Increment the array number.
            listIndex ++;
        }
        // Delete line from the delivery edit list, by the remove list.
        Integer shiftNumber = 0;
        for(Integer removeIndex :removeIndexList) {
            removeIndex -= shiftNumber;
            editDeliveryOppLineItemList.remove(removeIndex);
            shiftNumber ++;
        }
    }

    /* Process to searching for beverages by strings. */
    public void getDeliveryBeverages() {
        // Add '%' to the search string.
        String likeString = '%' + SearchString+ '%';
        // Count the number of search results.
        Integer searchDeliveryBeverageCount;
        searchDeliveryBeverageCount = [SELECT COUNT() FROM PricebookEntry WHERE Product2.IsActive = true AND ( Product2.Name LIKE :likeString OR Product2.Description LIKE :likeString ) LIMIT :limitQueryRows ];
        // Up to 100 results are searched.
        searchDeliveryBeverageList = [SELECT Id, Name, Product2Id, Product2.Craft_Brewer__c, Product2.Craft_Brewer__r.Name, Product2.Name, Product2.Description, UnitPrice, Product2.IsActive FROM PricebookEntry WHERE Product2.IsActive = true AND ( Product2.Name LIKE :likeString OR Product2.Description LIKE :likeString ) ORDER BY Product2.Craft_Brewer__r.Name LIMIT 100 ];
        // when the search result exceeds 100, an error message is displayed.
        if (searchDeliveryBeverageCount > 100){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage1));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage2));
        } else if (searchDeliveryBeverageCount == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage10));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage20));            
        }
    }

    /* Process to selecting registered delivery. */
    public void getDeliveryLineItem(){
        existDeliveryOppLineItemList.clear();
        existDeliveryOppLineItemList = [SELECT Id, Name, OpportunityId, ListPrice, Pick_Up__c, Product2Id, Product2.Name, Product2.Description, Quantity, UnitPrice, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.Description, PricebookEntry.UnitPrice FROM OpportunityLineItem WHERE Pick_Up__c = false AND OpportunityId = :currentOpportunity.Id LIMIT :limitQueryRows];
        // when there is no registered delivery, the search area will be displayed.
        dispSearch = false;
        if (existDeliveryOppLineItemList.isEmpty()){
            dispSearch = true;
        }
    }

    /* Process to creating list for Delivery edit. */
    public void createEditDeliveryList(){
        editDeliveryOppLineItemList.clear();
        EditDeliveryLineItem addItem;
        for (OpportunityLineItem existDeliveryOppLineItem :existDeliveryOppLineItemList){
            addItem = new EditDeliveryLineItem();
            addItem.oppli = existDeliveryOppLineItem;
            addItem.pbe = existDeliveryOppLineItem.PricebookEntry;
            addItem.name = existDeliveryOppLineItem.Product2.Name;
            addItem.descript = existDeliveryOppLineItem.Product2.Description;
            editDeliveryOppLineItemList.add(addItem);
        }
    }
    
    /* Wapper class for Pickup edit. */
    public class EditPikupLineItem {
        public OpportunityLineItem oppli { get; set; }
        public PricebookEntry pbe { get; set; }
        public String name { get; set; }
        public String descript { get; set; }
        EditPikupLineItem(){
            oppli = new OpportunityLineItem();
            pbe = new PricebookEntry();
        }
    }

    /* Wapper class for Delivery edit. */
    public class EditDeliveryLineItem {
        public OpportunityLineItem oppli { get; set; }
        public PricebookEntry pbe { get; set; }
        public String name { get; set; }
        public String descript { get; set; }
        public String addedtime { get; set; }
        EditDeliveryLineItem(){
            oppli = new OpportunityLineItem();
            pbe = new PricebookEntry();
        }
    }

}