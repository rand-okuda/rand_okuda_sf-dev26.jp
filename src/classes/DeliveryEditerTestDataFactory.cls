public class DeliveryEditerTestDataFactory {

    // this class is "@isTest" not set because the code coverage rate is 100%.

    public List<Account> accs;
    public List<Product2> pd2s;
    public List<Opportunity> opps;
    public List<PricebookEntry> pbes;
    public List<OpportunityLineItem> opplis;

    public User uDelivery;
    public User uWarehouse;
    public User uAccounting;
    public User uExecutive;

    /* Constructor */
    public DeliveryEditerTestDataFactory(){
        // First, create a user.
        createUsers();
    }

    /* Process to INSERT various objects. DELEAT then INSERT. */
    public void createDatas(Integer numAccs, Integer numOppPerAcc, Integer numProductsPerAcc, Integer numPickupPerOpp, Integer numDeliveryPerOpp) {

        List<Opportunity> delOpps = new List<Opportunity>();
        delOpps = [SELECT Id FROM Opportunity];
        DELETE delOpps;
        List<Product2> delpd2s = new List<Product2>();
        delpd2s = [SELECT Id FROM Product2];
        DELETE delpd2s;
        List<Pricebook2> delpb2s = new List<Pricebook2>();
        delpb2s = [SELECT Id FROM Pricebook2];
        DELETE delpb2s;
        List<Account> delAccs = new List<Account>();
        delAccs = [SELECT Id FROM Account];
        DELETE delAccs;

        accs = new List<Account>();
        for(Integer i=0;i<numAccs;i++) {
            Account a = new Account(Name='PUB-' + i,ShippingCountry='Japan',ShippingState='Osaka',ShippingCity='Osaka',ShippingStreet='Chuo',ShippingPostalCode='1-7-9',Purchase_Discount__c=10,Sale_Discount__c=10,OwnerId=uExecutive.Id);
            accs.add(a);
        }
        insert accs;
        opps = new List<Opportunity>();
        for (Integer j=0;j<numAccs;j++) {
            Account acc = accs[j];
            for (Integer k=0;k<numOppPerAcc;k++) {
                opps.add(new Opportunity(Name='New Delivery',StageName='In Progress',CloseDate=System.today(),AccountId=acc.Id,OwnerId =uDelivery.Id));
            }
        }
        insert opps;
        pd2s = new List<Product2>();
        for (Integer j=0;j<numAccs;j++) {
            Account acc = accs[j];
            for (Integer l=0;l<numProductsPerAcc;l++){
                pd2s.add(new Product2(Name='BEER-'+l,Description='Descript : '+ acc.Name ,Craft_Brewer__c=acc.Id,IsActive=true));
            }
        }
        insert pd2s;
        Id pb2Id  = Test.getStandardPricebookId();
        pbes = new List<PricebookEntry>();
        for (Product2 pd2 :pd2s){
            pbes.add(new PricebookEntry(Pricebook2Id=pb2Id,Product2Id=pd2.Id,UnitPrice=100,IsActive=true,UseStandardPrice=false));
        }
        insert pbes;
        opplis = new List<OpportunityLineItem>();
        for (Opportunity opp :opps){
            for (Integer m=0;m<numPickupPerOpp;m++) {
                opplis.add(new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId=pbes[m].Id,Quantity=1,UnitPrice=-10,Pick_Up__c=true));
            }
            for (Integer m=0;m<numDeliveryPerOpp;m++) {
                opplis.add(new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId=pbes[m].Id,Quantity=1,UnitPrice=10,Pick_Up__c=false));
            }
        }
        insert opplis;
    }

    /* Process to creating a user for testing. */
    public void createUsers() {

        Profile pDelivery = [SELECT Id FROM Profile WHERE Name LIKE '%Delivery%']; 
        Profile pWarehouse = [SELECT Id FROM Profile WHERE Name LIKE '%Warehouse%']; 
        Profile pAccounting = [SELECT Id FROM Profile WHERE Name LIKE '%Accounting%']; 
        Profile pExecutive = [SELECT Id FROM Profile WHERE Name LIKE '%Executive%']; 

        uDelivery = new User
            (Alias = 'Deliv', Email='Delivery@mb.com', 
            EmailEncodingKey='UTF-8', LastName='Delivery', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pDelivery.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Delivery@mb.201705221934.com');
        INSERT uDelivery;
        uWarehouse = new User
            (Alias = 'Wareh', Email='Warehouse@mb.com', 
            EmailEncodingKey='UTF-8', LastName='Delivery', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pWarehouse.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Warehouse@mb.201705221934.com');
        INSERT uWarehouse;
        uAccounting = new User
            (Alias = 'Accoun', Email='Accounting@mb.com', 
            EmailEncodingKey='UTF-8', LastName='Delivery', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pAccounting.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Accounting@mb.201705221934.com');
        INSERT uAccounting;
        uExecutive = new User
            (Alias = 'Exec', Email='Executive@mb.com', 
            EmailEncodingKey='UTF-8', LastName='Executive', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pExecutive.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Executive@mb.201705221934.com');
        INSERT uExecutive;
    }

}