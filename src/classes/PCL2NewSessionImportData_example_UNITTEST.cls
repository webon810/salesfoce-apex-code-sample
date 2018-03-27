@IsTest
private class PCL2CreateSessionImportFile_CSIF_TEST {

    public Pcl2CreateSessionWrapper wrapper {get; set;}

    static Account objBorrowerAcct;
    static Account objCoBorrowerAcct;
    static Opportunity objOpportunity;

    static void createSettings(){
        
         PclApp_Setting__c setting = new  PclApp_Setting__c();
         
         setting.Comments__c = null;//'Test Comments';
         setting.Environment__c = null;//'Others';
         setting.IsActived__c = 'Yes';
         setting.Pcl_APIVersion__c = null;//'test';
         setting.Pcl_Endpointfile__c = 'https://price.uat.pclender.com/companyname/';
         setting.Pcl_HarcodedValue__c = null; //'test';
         setting.Pcl_AppID__c = null;//'test';
         setting.Pcl_AppPassword__c = null; //'test';
         
         insert setting;   
    
    }


    static void LoadData(){
        createBorrowerAcct();
        createCoBorrowerAcct();
        createOpportunity();
        createSettings();
    }
       
    static void createBorrowerAcct(){
        objBorrowerAcct = new Account();
        objBorrowerAcct.FirstName = 'Test';
        objBorrowerAcct.LastName = 'Borrower Name';
        objBorrowerAcct.RecordTypeId = [Select ID from RecordType Where DeveloperName =: 'Client' LIMIT 1].Id;
        insert objBorrowerAcct;
    }

    static void createCoBorrowerAcct(){
        objCoBorrowerAcct = new Account();
        objCoBorrowerAcct.Name = 'Test Name';
        insert objCoBorrowerAcct;
    }

    static void createOpportunity(){
        objOpportunity = new Opportunity();
        objOpportunity.Name = 'dodowife baysf - Loan Prequal';
        
       // System.AssertEquals(objBorrowerAcct.Id, null);
        
        objOpportunity.AccountId = objBorrowerAcct.Id;
        objOpportunity.CloseDate = date.ValueOf('2017-05-04');
        objOpportunity.Loan_Purpose__c = 'Purchase';
        objOpportunity.Loan_Type__c = 'Conventional';
        objOpportunity.Term__c = '360';
        objOpportunity.StageName = 'Prequalified';
        insert objOpportunity;
    }
       
    static testMethod void testCallout(){

        LoadData();    
        
        //Set User Values for LoginName and OrigPassword
        Opportunity o = [Select ID, OwnerId from Opportunity Limit 1];
        User u = new User(Id=o.OwnerId, PCL__c = 'Test', PCL_Password__c='Test');
        update u;
              
     Test.startTest();  
     
        //Test.setCurrentPageReference(new PageReference('Page.Pcl2CreateSession2'));
        System.currentPageReference().getParameters().put('id', objOpportunity.Id);
     
        ApexPages.StandardController sc = new ApexPages.StandardController(objOpportunity);
        PCL2CreateSessionImportFile myPcl2CSC = new PCL2CreateSessionImportFile();
  
        Test.setMock(HttpCalloutMock.class, new PCL2MockHttpResponseGenerator_CSIF_TEST());
        
        myPcl2CSC.getOppDetail();
        myPcl2CSC.getAccount();
        myPcl2CSC.CurrentPageReference();     
      
    Test.stopTest();
     
    }
    

    static testMethod void testCallout2(){

        LoadData();    
        
        //Set User Values for LoginName and OrigPassword
        Opportunity o = [Select ID, OwnerId from Opportunity Limit 1];
        User u = new User(Id=o.OwnerId, PCL__c = 'Test', PCL_Password__c='Test');
        update u;
              
     Test.startTest();  
     
        //Test.setCurrentPageReference(new PageReference('Page.Pcl2CreateSession3'));
        System.currentPageReference().getParameters().put('id', objOpportunity.Id);
     
        ApexPages.StandardController sc = new ApexPages.StandardController(objOpportunity);
        PCL2CreateSessionImportFile myPcl2CSC = new PCL2NewSessionImportData();
  
        Test.setMock(HttpCalloutMock.class, new PCL2MockHttpResponseGenerator_UNITTEST());

        //HttpResponse response = PCL2CreateSessionImportFile.parseCreateSessionImportFile();
        HttpResponse response = myPcl2CSC.parseCreateSessionImportFile();
       
         // Verify response received contains fake values   
        String Accept = response.getHeader('Accept');
        
        System.assert(Accept == 'application/x-www-form-urlencoded');
        String AcceptEncoding = response.getHeader('Accept-Encoding');
        System.assert(AcceptEncoding == 'gzip,deflate,identity');
        String actualValue = response.getBody();
        String expectedValue = '{"SessionID":"9359FAF5BB","APIVersion":{"MajorVersion":1,"MinorVersion":0,"Build":1},"Successful": true,"ErrorCode":0,"ErrorMessage":"OK", "Tags":"","Nonce":"2327306952","Stats":{"TotalDatabaseTime":46,"TotalServerTime":776,"MethodTime":776,"LOSTime":0}}';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());    
      
    Test.stopTest();
     
    }

}