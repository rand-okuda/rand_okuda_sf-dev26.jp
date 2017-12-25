@isTest
public class DeliveryEditerTest {

    // Description -> dedf.createDatas(xx,xx,xx,xx,xx);
    // The meaning of (1,2,150,10,10) is 
    // 
    //   Account x1, Owner= Executive
    //   | | |
    //   | | +- Product x150, IsActive= true
    //   | |
    //   | +-Opportunity x1, Owner= Delivery
    //   |   | |
    //   |   | +-OpportunityLineIte(Pickup) x10, UnitPrice= -10 Quantity=1
    //   |   +-OpportunityLineIte(Delivery) x10, UnitPrice= 10 Quantity=1
    //   |
    //   +-Opportunity x1, Owner= Delivery
    //     | |
    //     | +-OpportunityLineIte(Pickup) x10, UnitPrice= -10 Quantity=1
    //     +-OpportunityLineIte(Delivery) x10, UnitPrice= 10 Quantity=1

    // Create New Delivery and Select Account.
    @isTest(SeeAllData=false)
    static void UnitTest010() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,0,150,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Create a new Opportunity,
            Opportunity newOpp = new Opportunity();
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Test at account selecting.
            Test.startTest();
            newOpp.AccountId = dedf.accs[0].Id;
            extController.initAccInfo();
            Test.stopTest();
        }
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Create New Delivery and Select Account, that Account address is not entered.
    @isTest(SeeAllData=false)
    static void UnitTest110a() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,0,150,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Create a new Opportunity,
            Opportunity newOpp = new Opportunity();
            // Account address is not entered.
            dedf.accs[0].ShippingCountry = null;
            dedf.accs[0].ShippingState = null;
            dedf.accs[0].ShippingCity = null;
            dedf.accs[0].ShippingStreet = null;
            dedf.accs[0].ShippingPostalCode = null;
            UPDATE dedf.accs[0];
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Test at account selecting.
            Test.startTest();
            newOpp.AccountId = dedf.accs[0].Id;
            extController.initAccInfo();
            Test.stopTest();
        }
        // asserts that an error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), false);
    }

    // Create New Delivery and Select Account, that Account have no active BEER.
    @isTest(SeeAllData=false)
    static void UnitTest110b() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,0,150,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Create a new Opportunity,
            Opportunity newOpp = new Opportunity();
            // Account have no active BEER.
            for (Product2 pd2 :dedf.pd2s){
                pd2.IsActive = false;
            }
            UPDATE dedf.pd2s;
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Test at account selecting.
            Test.startTest();
            newOpp.AccountId = dedf.accs[0].Id;
            extController.initAccInfo();
            Test.stopTest();
        }
        // asserts that an error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), false);
    }

    // Edit and Return next page reference Initialization.
    @isTest(SeeAllData=false)
    static void UnitTest011() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(10,10,24,12,24);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // assert that transition to Opportunity detail page.
            String SaveNextPage = extController.saveButton().getUrl();
            System.assertEquals('/'+dedf.opps[0].Id, SaveNextPage);
        }
        // Execute with given user.
        System.runAs(dedf.uExecutive) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // assert that transition to Opportunity detail page.
            String SubmitNextPage = extController.submitButton().getUrl();
            System.assertEquals('/'+dedf.opps[0].Id, SubmitNextPage);
        }
    }

    // Save Button without DmlExceptione for Pickup, INSERT 100 records. when Create New.
    @isTest(SeeAllData=false)
    static void UnitTest020() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,0,100,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Create a new Opportunity,
            Opportunity newOpp = new Opportunity();
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // account selecting.
            newOpp.AccountId = dedf.accs[0].Id;
            extController.initAccInfo();
            // Set all pickup quantities to 1 piece.
            for (Integer i=0;i<100;i++) {
                extController.editPikupOppLineItemList[i].oppli.Quantity = 1;
            }
            // Test at Save button.
            Test.startTest();
            extController.saveButton();
            Test.stopTest();
        }
        // assert that amount of Opportunity.
        Opportunity dedfopps0a = [SELECT Id,Amount FROM Opportunity];
        System.assertEquals(dedfopps0a.Amount, -1000);
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Save Button without DmlExceptione for Pickup, DELEAT 100 records. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest021() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,100,100,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // assert that amount of Opportunity.
            Opportunity dedfopps0 = [SELECT Id,Amount FROM Opportunity];
            System.assertEquals(dedfopps0.Amount, -1000);
            // Set all quantities to 0 piece.
            for (Integer i=0;i<100;i++) {
                extController.editPikupOppLineItemList[i].oppli.Quantity = 0;
            }
            // Test at Save button.
            Test.startTest();
            extController.saveButton();
            Test.stopTest();
        }
        // assert that amount of Opportunity.
        Opportunity dedfopps0a = [SELECT Id,Amount FROM Opportunity];
        System.assertEquals(dedfopps0a.Amount, 0);
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Save Button with DmlExceptione for Pickup. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest121() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,2,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);        
            // Set a blank in UnitPrice, and Save button.
            Test.startTest();
            extController.editPikupOppLineItemList[0].oppli.Quantity = 1;
            extController.editPikupOppLineItemList[0].oppli.UnitPrice = null;
            extController.saveButton();
            Test.stopTest();
        }
        // asserts that an error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), false);
    }

    // Search 100 records without Error Message for Delivery. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest030() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(2,1,100,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // That keyword searched 100 BEERs.
            Test.startTest();
            extController.searchBeveragesButton();
            extController.SearchString = 'PUB-0';
            extController.getDeliveryBeverages();
            Test.stopTest();
        }
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Search 200 records with Error Message for Delivery. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest130() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(2,1,100,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // That keyword searched 200 BEERs.
            Test.startTest();
            extController.searchBeveragesButton();
            extController.SearchString = 'PUB-';
            extController.getDeliveryBeverages();
            Test.stopTest();
        }
        // asserts that an error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), false);
    }

    // Search 200 inactive records without Error Message for Delivery. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest031() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(2,1,100,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // inacivate all BEERs.
            for (Product2 pd2 :dedf.pd2s){
                pd2.IsActive=false;
            }
            UPDATE dedf.pd2s;
            // Inactive BEER is not searched.
            Test.startTest();
            extController.searchBeveragesButton();
            extController.SearchString = 'PUB-';
            extController.getDeliveryBeverages();
            Test.stopTest();
        }
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Save Button for Delivery, DELEAT 100 records. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest040() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,100,0,100);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // assert that amount of Opportunity.
            Opportunity dedfopps0 = [SELECT Id,Amount FROM Opportunity];
            System.assertEquals(dedfopps0.Amount, 1000);
            // Set all quantities to 0 piece.
            for (Integer i=0;i<100;i++) {
                extController.editDeliveryOppLineItemList[i].oppli.Quantity = 0;
            }
            // Test at Save button.
            Test.startTest();
            extController.saveButton();
            Test.stopTest();
        }
        // assert that amount of Opportunity.
        Opportunity dedfopps0a = [SELECT Id,Amount FROM Opportunity];
        System.assertEquals(dedfopps0a.Amount, 0);
    }

    // Add to Delivery button and Save Button for Delivery, INSERT 100 records, after Search. when Create New.
    @isTest(SeeAllData=false)
    static void UnitTest041() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(2,0,100,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Create a new Opportunity,
            Opportunity newOpp = new Opportunity();
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // account selecting.
            newOpp.AccountId = dedf.accs[0].Id;
            extController.initAccInfo();
            // Search 100 BEERs.
            extController.SearchString = 'PUB-1';
            extController.getDeliveryBeverages();
            // AddToDelivery of the searched BEER one by one, and Set quantities to 0 piece.
            for (Integer i=100;i<200;i++) {
                pageRef.getParameters().put('addPricebookEntryId', dedf.pbes[i].Id);
                extController.addToDeliveryButton();
                extController.editDeliveryOppLineItemList[i-100].oppli.Quantity = 1;
            }
            // Test at Save button.
            Test.startTest();
            extController.saveButton();
            Test.stopTest();
        }
        // assert that amount of Opportunity.
        Opportunity dedfopps0a = [SELECT Id,Amount FROM Opportunity];
        System.assertEquals(dedfopps0a.Amount, 1000);
    }

    // Delete Button for when record was inserted. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest042() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,100,0,100);
        // Execute with given user.        
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Test at Delete button.
            Test.startTest();
            // Select the Delete button at the bottom of the list.
            pageRef.getParameters().put('deleteOpportunityLineItemId', dedf.opplis[99].Id);
            extController.deleteButton();
            // Select the Delete button at the top of the list in turn.
            for (Integer i=0;i<99;i++) {
                pageRef.getParameters().put('deleteOpportunityLineItemId', dedf.opplis[i].Id);
                extController.deleteButton();
            }
            Test.stopTest();
        }
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Delete Button for when record was notinserted . when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest043() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(2,1,1,0,0);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Search 1 BEER.
            extController.SearchString = 'PUB-';
            extController.getDeliveryBeverages();
            // AddToDelivery of the searched BEER.
            pageRef.getParameters().put('addPricebookEntryId', dedf.pbes[1].Id);
            extController.addToDeliveryButton();
            // Delete the BEER that was addToDelivery.
            Test.startTest();
            pageRef.getParameters().put('deletePricebookEntryAddedTime', extController.editDeliveryOppLineItemList[0].addedtime);
            extController.deleteButton();
            Test.stopTest();
        }
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Submit Button without DmlExceptione. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest050() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,1,1,1);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Test at Submit button.
            Test.startTest();
            extController.submitButton();
            Test.stopTest();
        }
        // assert that no error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), true);
    }

    // Submit Button with DmlExceptione. when Edit.
    @isTest(SeeAllData=false)
    static void UnitTest150() {
        // Prepare the user and data.
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,1,1,1);
        // Execute with given user.
        System.runAs(dedf.uDelivery) {
            // Display DeliveryEditor,
            PageReference pageRef = Page.DeliveryEditer;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController = new DeliveryEditerController(stdController);
            // Load same delivery in parallel.
            ApexPages.StandardController stdController2 = new ApexPages.StandardController(dedf.opps[0]);
            DeliveryEditerController extController2 = new DeliveryEditerController(stdController2);
            // submitted delivery once again submit.
            Test.startTest();
            extController.submitButton();
            extController2.submitButton();
            Test.stopTest();
        }
        // asserts that an error message is displayed.
        List<Apexpages.Message> msgList = new List<Apexpages.Message>();
        System.assert(msgList.isEmpty(), false);
    }

    // verification processing test at Trigger.
    @isTest(SeeAllData=false)
    static void UnitTest060() {
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,3,2,1,2);
        // Create two Order from the same Pub.
        Test.startTest();
        dedf.opps[0].StageName = 'Delivered';
        dedf.opps[1].StageName = 'Delivered';
        dedf.opps[2].StageName = 'Delivered';
        UPDATE dedf.opps;
        // will create the first Order.
        dedf.opps[0].StageName = 'Verified';
        UPDATE dedf.opps[0];
        // will create the second Order.
        dedf.opps[1].StageName = 'Verified';
        UPDATE dedf.opps[1];
        // will change Paid__c TRUE at Any one orders.
        Order order = [SELECT Id,Paid__c FROM Order ORDER BY Id LIMIT 1];
        order.Paid__c = true;
        UPDATE order;
        // will create the third Order.
        dedf.opps[2].StageName = 'Verified';
        UPDATE dedf.opps[2];
        Test.stopTest();
        // assert that amount of Order.
        List<Order> orders = [SELECT Id,TotalAmount,Current_Balance__c,Invoice_Total__c,Opportunity.Id,Account.Id,EndDate,EffectiveDate,OwnerId FROM Order ORDER BY Id];
        System.assertEquals(orders[0].Current_Balance__c, 0);
        System.assertEquals(orders[0].TotalAmount, 10);
        System.assertEquals(orders[0].Invoice_Total__c, 10);
        System.assertEquals(orders[1].Current_Balance__c, 10);
        System.assertEquals(orders[1].TotalAmount, 10);
        System.assertEquals(orders[1].Invoice_Total__c, 20);
        System.assertEquals(orders[2].Current_Balance__c, 10);
        System.assertEquals(orders[2].TotalAmount, 10);
        System.assertEquals(orders[2].Invoice_Total__c, 20);
        // assert that Relation of Order and Opportunity and Account.
        List<Opportunity> opps = [SELECT Id,Invoice__r.Id,Account.Id,CloseDate FROM Opportunity ORDER BY Invoice__r.Id];
        for(Integer i=0;i<3;i++) {
            System.assertEquals(opps[i].Invoice__r.Id, orders[i].Id);
            System.assertEquals(opps[i].Id, orders[i].Opportunity.Id);
            System.assertEquals(opps[i].Account.Id, orders[i].Account.Id);            
        }
        // assert that CloseDate and EndDate and EffectiveDate.
        for(Integer i=0;i<3;i++) {
            System.assertEquals(opps[i].CloseDate, orders[i].EndDate);
            System.assertEquals(opps[i].CloseDate, orders[i].EffectiveDate);            
        }
        // assert that Owner of  the Order.
        String MBAQ = 'MB Accounting Queue';
        Group queue = [SELECT Id, Name, Type FROM Group WHERE Name = :MBAQ AND Type = 'Queue' Limit 1];
        for(Integer i=0;i<3;i++) {
            System.assertEquals(orders[i].OwnerId, queue.Id);
        }
        // assert that Current_Balance__c of Account.
        List<Account> accs = [SELECT Id,Current_Balance__c FROM Account];
        System.assertEquals(accs[0].Current_Balance__c, 20);
        // Accounting User can access Order.
        System.runAs(dedf.uAccounting) {
            PageReference pageRef = new PageReference('/' + orders[0].Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(orders[0]);
        }
    }

    // which NullPointException does not occur, when Pub's Current_Balance__c is blank.  Trigger Test.
    @isTest(SeeAllData=false)
    static void UnitTest160a() {
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,2,1,2);
        // Create an order, with Current_Balance__c set to null.
        Test.startTest();
        dedf.accs[0].Current_Balance__c = null;
        UPDATE dedf.accs[0];
        dedf.opps[0].StageName = 'Delivered';
        UPDATE dedf.opps;
        dedf.opps[0].StageName = 'Verified';
        UPDATE dedf.opps;
        Test.stopTest();
        // assert that amount of Order.
        List<Order> orders = [SELECT Id,TotalAmount,Current_Balance__c,Invoice_Total__c,Opportunity.Id,Account.Id,EndDate,EffectiveDate,OwnerId FROM Order ORDER BY Id];
        System.assertEquals(orders[0].Current_Balance__c, 0);
        System.assertEquals(orders[0].TotalAmount, 10);
        System.assertEquals(orders[0].Invoice_Total__c, 10);
        // assert that Relation of Order and Opportunity and Account.
        List<Opportunity> opps = [SELECT Id,Invoice__r.Id,Account.Id,CloseDate FROM Opportunity ORDER BY Invoice__r.Id];
        System.assertEquals(opps[0].Invoice__r.Id, orders[0].Id);
        System.assertEquals(opps[0].Id, orders[0].Opportunity.Id);
        System.assertEquals(opps[0].Account.Id, orders[0].Account.Id);
        // assert that CloseDate and EndDate and EffectiveDate.
        System.assertEquals(opps[0].CloseDate, orders[0].EndDate);
        System.assertEquals(opps[0].CloseDate, orders[0].EffectiveDate);
        // assert that Owner of  the Order.
        String MBAQ = 'MB Accounting Queue';
        Group queue = [SELECT Id, Name, Type FROM Group WHERE Name = :MBAQ AND Type = 'Queue' Limit 1];
        System.assertEquals(orders[0].OwnerId, queue.Id);
        // assert that Current_Balance__c of Account.
        List<Account> accs = [SELECT Id,Current_Balance__c FROM Account];
        System.assertEquals(accs[0].Current_Balance__c, 10);
    }

    // when recreate Order, will set Account Current_Balance__c correctly. Trigger Test.
    @isTest(SeeAllData=false)
    static void UnitTest160b() {
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(1,1,2,1,2);
        // Create an Order twice from the same Delivery.
        Test.startTest();
        dedf.opps[0].StageName = 'Delivered';
        UPDATE dedf.opps[0];
        dedf.opps[0].StageName = 'Verified';
        UPDATE dedf.opps[0];
        dedf.opps[0].StageName = 'Delivered';
        UPDATE dedf.opps[0];
        dedf.opps[0].StageName = 'Verified';
        UPDATE dedf.opps[0];
        Test.stopTest();
        // assert that amount of Order.
        List<Order> orders = [SELECT Id,TotalAmount,Current_Balance__c,Invoice_Total__c,Opportunity.Id,Account.Id,EndDate,EffectiveDate,OwnerId FROM Order ORDER BY Id];
        System.assertEquals(orders[0].Current_Balance__c, 0);
        System.assertEquals(orders[0].TotalAmount, 10);
        System.assertEquals(orders[0].Invoice_Total__c, 10);
        // assert that Relation of Order and Opportunity and Account.
        List<Opportunity> opps = [SELECT Id,Invoice__r.Id,Account.Id,CloseDate FROM Opportunity ORDER BY Invoice__r.Id];
        System.assertEquals(opps[0].Invoice__r.Id, orders[0].Id);
        System.assertEquals(opps[0].Id, orders[0].Opportunity.Id);
        System.assertEquals(opps[0].Account.Id, orders[0].Account.Id);
        // assert that CloseDate and EndDate and EffectiveDate.
        System.assertEquals(opps[0].CloseDate, orders[0].EndDate);
        System.assertEquals(opps[0].CloseDate, orders[0].EffectiveDate);
        // assert that Owner of  the Order.
        String MBAQ = 'MB Accounting Queue';
        Group queue = [SELECT Id, Name, Type FROM Group WHERE Name = :MBAQ AND Type = 'Queue' Limit 1];
        System.assertEquals(orders[0].OwnerId, queue.Id);
        // assert that Current_Balance__c of Account.
        List<Account> accs = [SELECT Id,Current_Balance__c FROM Account];
        System.assertEquals(accs[0].Current_Balance__c, 10);
    }

    // 200 bulk verification processing. Trigger Test.
    @isTest(SeeAllData=false)
    static void UnitTest061() {
        DeliveryEditerTestDataFactory dedf = new DeliveryEditerTestDataFactory();
        dedf.createDatas(200,1,1,0,1);
        // Execute with given user. Change all to Delivered.
        System.runAs(dedf.uDelivery) {
            for (Opportunity opp :dedf.opps){
                opp.StageName = 'Delivered';
            }
            UPDATE dedf.opps;
        }
        // Execute with given user. Change all to Verified.
        System.runAs(dedf.uWarehouse) {
            Test.startTest();
            for (Opportunity opp :dedf.opps){
                opp.StageName = 'Verified';
            }
            UPDATE dedf.opps;
            Test.stopTest();
        }
        // assert that amount of Order.
        List<Order> orders = [SELECT Id,TotalAmount,Current_Balance__c,Invoice_Total__c,Opportunity.Id,Account.Id,EndDate,EffectiveDate,OwnerId FROM Order ORDER BY Id];
        for (Order order :orders){
            System.assertEquals(order.Current_Balance__c, 0);
            System.assertEquals(order.TotalAmount, 10);
            System.assertEquals(order.Invoice_Total__c, 10);
        }
        // assert that Relation of Order and Opportunity and Account.
        List<Opportunity> opps = [SELECT Id,Invoice__r.Id,Account.Id,CloseDate FROM Opportunity ORDER BY Invoice__r.Id];
        for(Integer i=0;i<199;i++) {
            System.assertEquals(opps[i].Invoice__r.Id, orders[i].Id);
            System.assertEquals(opps[i].Id, orders[i].Opportunity.Id);
            System.assertEquals(opps[i].Account.Id, orders[i].Account.Id);
        }
        // assert that CloseDate and EndDate and EffectiveDate.
        for(Integer i=0;i<199;i++) {
            System.assertEquals(opps[i].CloseDate, orders[i].EndDate);
            System.assertEquals(opps[i].CloseDate, orders[i].EffectiveDate);            
        }
        // assert that Owner of  the Order.
        String MBAQ = 'MB Accounting Queue';
        Group queue = [SELECT Id, Name, Type FROM Group WHERE Name = :MBAQ AND Type = 'Queue' Limit 1];
        for(Integer i=0;i<199;i++) {
            System.assertEquals(orders[i].OwnerId, queue.Id);
        }
        // assert that Current_Balance__c of Account.
        List<Account> accs = [SELECT Id,Current_Balance__c FROM Account];
        for (Account acc :accs){
            System.assertEquals(acc.Current_Balance__c, 10);
        }
    }

}