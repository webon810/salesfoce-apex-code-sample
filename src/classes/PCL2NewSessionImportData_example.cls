public with sharing class PCL2NewSessionImportData {

    public Pcl2CreateSessionWrapper wrapper {get; set;}
    public Pcl2ImportFromFileWrapper wrapperpcl {get; set;}    
    public String endpoint {get; set;}

    public String oppId {get;set;}
    public Opportunity opp {get;set;}
    public Account loAccount {get;set;};}
    public Opportunity getoppDetail() {
    
       oppId = Apexpages.currentpage().getparameters().get('id');
  
       if(opp == null) opp = [SELECT Name,Id,AccountId,Amount,RecordTypeId
       FROM Opportunity WHERE ID =: oppId];
              
       return opp;
    
    }
    
    
    public Account getAccount()  
       {
       
       oppId = Apexpages.currentpage().getparameters().get('id');
       
       List<Account> loAccount2ndList = [SELECT Id,OwnerId,PersonContactId,FirstName,LastName,MiddleName   
       FROM Account WHERE PersonContactId in (SELECT ContactId FROM OpportunityContactRole WHERE Role = 'Realtor' AND OpportunityId = : oppId) and IsPersonAccount = true LIMIT 1];
       
       if(loAccount2ndList.size()>0)
           loAccount2nd=loAccount2ndList[0];
       else
           loAccount2nd = new Account(); 
       return loAccount2nd;
       
       }
       
    public pageReference CurrentPageReference()  
        {
            parseCreateSessionImportFile(); 
            return null; 
        }   


    public HttpResponse parseCreateSessionImportFile() {

        String oppId = Apexpages.currentpage().getparameters().get('id');
        
        List<Opportunity> opp = new List<Opportunity>();
        List<Account> loAccount = new List<Account>();
        List<Account> loAccount2nd = new List<Account>();
         
       //--------------
       opp = [SELECT Name,Id,AccountId,Amount,Down_Payment_Source_List_Value__c,Loan_Purpose__c,RecordTypeId  
       FROM Opportunity WHERE ID =: oppId];
       //----------------
       
       //----------------
       loAccount = [SELECT Id,OwnerId,PersonContactId,FirstName,LastName,MiddleName,SSN__c,Marital_Status__c,Marital_Status_Value__c,Monthly_Total_Income_Value__c,Employer_Phone__c,Outstanding_Judgements_Value__c,US_Citizenship_Value__c 
       FROM Account WHERE Id in (SELECT AccountId FROM Opportunity WHERE Id = : oppId) and IsPersonAccount = true LIMIT 1];
       //----------------
       

        integer Nonce;
        String CurrentGMT = DateTime.now().formatGMT('yyyyMMddHHmm');
        
            
        Blob hash1 = Crypto.generateDigest('SHA1',Blob.valueOf(OrigPassword));
        String Password = 'SHA1' + EncodingUtil.convertToHex(hash1).toUpperCase();
        
        String str0 = HarcodedValue + AppID + AppPassword;
        Blob hash2 = Crypto.generateDigest('SHA256',Blob.valueOf(str0)); 
            
        String postData = 'APIVersion=' + APIVersion +
            '&AppID=' + AppID


        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpointfile + 'create_session');

        request.setMethod('POST');
        
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Accept-Encoding', 'gzip,deflate,identity');
        request.setHeader('Content-Length', String.valueof(postData.length()));

        request.setBody(postData);

        request.setTimeout(10000);
        HttpResponse response = http.send(request);
        
        //String resp = response.getBody();   
        //System.debug(resp); 
        

        Pcl2CreateSessionWrapper newSession = Pcl2CreateSessionWrapper.parse(response.getBody());
        
        String NewSessionId = newSession.SessionID;
        String NewNonce = newSession.Nonce;

        integer FileType = 1;
        String DateName = 'Prequalified';
        integer LoanNumber;
        
        //line of 01A
        String LoanType;  //Christine Ross - do not pass the selected value from SFDC to ensure proper start loan defaults processing 05/31/17
        String LoanAmount;  
        String NoOfMonths;  
        
        if (opp[0].Loan_Type_Value__c != null) LoanType = opp[0].Loan_Type_Value__c; else LoanType = '  '.substring(0,2);
        if (opp[0].Amount != null) LoanAmount = '               '.substring(0, (15-string.valueof(opp[0].Amount).length())) + string.valueof(opp[0].Amount); else LoanAmount = '               '.substring(0,15);
        if (opp[0].Term__c != null) NoOfMonths = opp[0].Term__c; else NoOfMonths = '   '.substring(0,3);

        //line of 02A
        String LOSAddr1;
        String LOSCity;
        String LOSState;
        String LOSZip;
        String LOSUnits;
        String LOSYearBuilt;
        
      if (opp[0].Property_Address__c != null) LOSAddr1 = '                                                                                             '.substring(0, (50-opp[0].Property_Address__c.length())) + opp[0].Property_Address__c; else LOSAddr1 = '                                                                                             '.substring(0,50); 
      if (opp[0].Property_City__c != null) LOSCity =  '                                                                                '.substring(0, (35-opp[0].Property_City__c.length())) + opp[0].Property_City__c; else LOSCity =  '                                                                                '.substring(0,35); 
      if (opp[0].Property_State__c != null) LOSState = opp[0].Property_State__c; else LOSState = '  '.substring(0,2);
      if (opp[0].Property_Zipcode__c != null) LOSZip = opp[0].Property_Zipcode__c; else LOSZip = '     '.substring(0,5);
      if (opp[0].Units__c != null) LOSUnits =  '   '.substring(0, (3-string.valueof(opp[0].Units__c).length())) + string.valueof(opp[0].Units__c); else LOSUnits = '   '.substring(0,3);
      if (opp[0].Year_Property_Built__c != null) LOSYearBuilt = string.valueof(opp[0].Year_Property_Built__c); else LOSYearBuilt = '    '.substring(0,4);
        
        String PurposeofLoan;   
        String Propertywillbe; 
        
      if (opp[0].Loan_Purpose_Value__c != null) PurposeofLoan = opp[0].Loan_Purpose_Value__c; else PurposeofLoan = '  '.substring(0,2);
      if (opp[0].Occupancy_Value__c != null) Propertywillbe = opp[0].Occupancy_Value__c; else Propertywillbe = ' '.substring(0,1);
        
        String CostOfImprovements;  
        String PurposeOfRefinance; 
        
        if (opp[0].Improvement_Cost__c != null) CostOfImprovements = '              '.substring(0, (15-string.valueof(opp[0].Improvement_Cost__c).length())) + string.valueof(opp[0].Improvement_Cost__c); else CostOfImprovements = '               '.substring(0,15);
        if (opp[0].Purpose_of_Refinance_Value__c != null) PurposeOfRefinance = opp[0].Purpose_of_Refinance_Value__c; else PurposeOfRefinance = '  '.substring(0,2);
        
        //line of 02E
         String LOSDowPaymentType;   
         String LOSDowPaymentAmount;
        
         if (opp[0].Down_Payment_Source_List_Value__c != null) LOSDowPaymentType = opp[0].Down_Payment_Source_List_Value__c; else LOSDowPaymentType = '  '.substring(0,2);
         if (opp[0].Down_Payment__c != null) LOSDowPaymentAmount =  '               '.substring(0, (15-string.valueof(opp[0].Down_Payment__c).length())) + opp[0].Down_Payment__c; else LOSDowPaymentAmount = '               '.substring(0,15);
        
        //line of 03A BW
        String BorrowerSSN;    
        String BorrowerFName;  
        String BorrowerMName;  
        String BorrowerLName;  
        
        String BorrowerPhone;  
        String BorrowerAge;    
        String BorrowerStatus; 
        
        String CoBorrowerJointly; 
        
        String BorrowerReferenceCoBorrower; 
        String BorrowerDOB;    

        String BorrowerEmail;  
        
        Blob cryptoKey = Crypto.generateAesKey(256);  
        Blob cocryptoKey = Crypto.generateAesKey(256);  
        
       if (loAccount[0].SSN__c != null) BorrowerSSN = '         '.substring(0, (9-(Crypto.decryptWithManagedIV('AES256', cryptoKey, (Crypto.encryptWithManagedIV('AES256', cryptoKey, (Blob.valueOf(loAccount[0].SSN__c)))))).toString().length())) + (Crypto.decryptWithManagedIV('AES256', cryptoKey, (Crypto.encryptWithManagedIV('AES256', cryptoKey, (Blob.valueOf(loAccount[0].SSN__c)))))).toString(); else BorrowerSSN = '         '.substring(0,9);        
       if (loAccount[0].FirstName != null) BorrowerFName =  '                                   '.substring(0, (35-string.valueof(loAccount[0].FirstName).length())) + loAccount[0].FirstName; else BorrowerFName = '                                   '.substring(0,35);
             
       String CoBorrowerCode;   
       String CoBorrowerSSN;    
       String CoBorrowerFName;  

        
       if (loAccount2nd.size() > 0 && loAccount2nd[0].Marital_Status_Value__c != null && opp[0].CoBorrower_Assets_Jointly_Value__c =='Y' && loAccount2nd[0].Marital_Status_Value__c == 'M') CoBorrowerCode = 'QZ'; else CoBorrowerCode = 'BW';
       if (loAccount2nd.size() > 0 && loAccount2nd[0].SSN__c != null) CoBorrowerSSN = '         '.substring(0, (9-(Crypto.decryptWithManagedIV('AES256', cocryptoKey, (Crypto.encryptWithManagedIV('AES256', cocryptoKey, (Blob.valueOf(loAccount2nd[0].SSN__c)))))).toString().length())) + (Crypto.decryptWithManagedIV('AES256', cocryptoKey, (Crypto.encryptWithManagedIV('AES256', cocryptoKey, (Blob.valueOf(loAccount2nd[0].SSN__c)))))).toString(); else CoBorrowerSSN = '         '.substring(0,9);
       if (loAccount[0].SSN__c != null && opp[0].CoBorrower_Assets_Jointly_Value__c == 'Y') CoBorrowerReferenceBorrower =  '         '.substring(0, (9-(Crypto.decryptWithManagedIV('AES256', cryptoKey, (Crypto.encryptWithManagedIV('AES256', cryptoKey, (Blob.valueOf(loAccount[0].SSN__c)))))).toString().length())) + (Crypto.decryptWithManagedIV('AES256', cryptoKey, (Crypto.encryptWithManagedIV('AES256', cryptoKey, (Blob.valueOf(loAccount[0].SSN__c)))))).toString(); else CoBorrowerReferenceBorrower = '         '.substring(0,9);

      String BorrowerMailingStreet;    
      String BorrowerMailingCity;  
      String BorrowerMailingState;  
      String BorrowerMailingPostalCode;  
      String BorrowerMailingOwnorRent;  

      if (loAccount[0].PersonMailingStreet != null) BorrowerMailingStreet = '                                                  '.substring(0, (50-loAccount[0].PersonMailingStreet.length())) + loAccount[0].PersonMailingStreet; else BorrowerMailingStreet = '                                                  '.substring(0,50);
      if (loAccount[0].PersonMailingCity != null) BorrowerMailingCity = '                                   '.substring(0, (35-loAccount[0].PersonMailingCity.length())) + loAccount[0].PersonMailingCity; else BorrowerMailingStreet = '                                   '.substring(0,35);
      if (loAccount[0].PersonMailingState != null) BorrowerMailingState = loAccount[0].PersonMailingState; else BorrowerMailingState = '  '.substring(0,2);
      if (loAccount[0].PersonMailingPostalCode != null) BorrowerMailingPostalCode = '     '.substring(0, (5-loAccount[0].PersonMailingPostalCode.length())) + loAccount[0].PersonMailingPostalCode; else BorrowerMailingPostalCode = '     '.substring(0,5);
       if (loAccount[0].Own_or_Rent_Value__c != null) BorrowerMailingOwnorRent = loAccount[0].Own_or_Rent_Value__c; else BorrowerMailingOwnorRent = ' '.substring(0,1);
      
    String CoBorrowerOtherStreet;  
    String CoBorrowerOtherCity;  
    String CoBorrowerOtherState;   

    if (loAccount2nd.size() > 0 && loAccount2nd[0].PersonMailingStreet != null) CoBorrowerOtherStreet = '                                                  '.substring(0, (50-loAccount2nd[0].PersonMailingStreet.length())) + loAccount2nd[0].PersonMailingStreet; else CoBorrowerOtherStreet = '                                                  '.substring(0,50);
    if (loAccount2nd.size() > 0 && loAccount2nd[0].PersonMailingCity != null) CoBorrowerOtherCity = '                                   '.substring(0, (35-loAccount2nd[0].PersonMailingCity.length())) + loAccount2nd[0].PersonMailingCity; else CoBorrowerOtherCity = '                                   '.substring(0,35);

    String BorrowerEmployeeName;  
    String BorrowerEmployeeStreeAddr;  
    String BorrowerEmployeeCity;  

    if (loAccount[0].Employer_Name__c != null) BorrowerEmployeeName = '                                   '.substring(0, (35-loAccount[0].Employer_Name__c.length())) + loAccount[0].Employer_Name__c; else BorrowerEmployeeName = '                                   '.substring(0,35);
    if (loAccount[0].Employer_Address__c != null) BorrowerEmployeeStreeAddr = '                                   '.substring(0, (35-loAccount[0].Employer_Address__c.length())) + loAccount[0].Employer_Address__c; else BorrowerEmployeeStreeAddr = '                                   '.substring(0,35);
   
    if (loAccount[0].Self_Employed_Value__c != null) BorrowerEmployeeSelf = loAccount[0].Self_Employed_Value__c; else BorrowerEmployeeSelf = ' '.substring(0,1);
    if (loAccount[0].Years_on_Job__c != null) BorrowerEmployeeYearsJob = '  '.substring(0, (2-string.valueof(loAccount[0].Years_on_Job__c).length())) + string.valueof(loAccount[0].Years_on_Job__c.intValue()); else BorrowerEmployeeYearsJob = '  '.substring(0,2);
    if (loAccount[0].Months_on_Job__c != null) BorrowerEmployeeMonthsJob = '  '.substring(0, (2-string.valueof(loAccount[0].Months_on_Job__c).length())) + string.valueof(loAccount[0].Months_on_Job__c.intValue()); else BorrowerEmployeeMonthsJob = '  '.substring(0,2);

    String CoBorrowerEmployeeName;  
    String CoBorrowerEmployeeStreeAddr;  
    String CoBorrowerEmployeeCity;  
    String CoBorrowerEmployeeStateAbb;  

    
   if (loAccount2nd.size() > 0 && loAccount2nd[0].Employer_Name__c != null) CoBorrowerEmployeeName = '                                   '.substring(0, (35-loAccount2nd[0].Employer_Name__c.length())) + loAccount2nd[0].Employer_Name__c; else CoBorrowerEmployeeName = '                                   '.substring(0,35);
   if (loAccount2nd.size() > 0 && loAccount2nd[0].Employer_Address__c != null) CoBorrowerEmployeeStreeAddr = '                                   '.substring(0, (35-loAccount2nd[0].Employer_Address__c.length())) + loAccount2nd[0].Employer_Address__c; else CoBorrowerEmployeeStreeAddr = '                                   '.substring(0,35);
   if (loAccount2nd.size() > 0 && loAccount2nd[0].Employer_City__c != null) CoBorrowerEmployeeCity = '                                   '.substring(0, (35-loAccount2nd[0].Employer_City__c.length())) + loAccount2nd[0].Employer_City__c; else CoBorrowerEmployeeCity= '                                   '.substring(0,35);

     String BorrowerMonthlyIncomeValue;  
     if (loAccount[0].Monthly_Total_Income_Value__c != null) BorrowerMonthlyIncomeValue = '               '.substring(0, (15-string.valueof(loAccount[0].Monthly_Total_Income_Value__c).length())) + string.valueof(loAccount[0].Monthly_Total_Income_Value__c); else BorrowerMonthlyIncomeValue = '               '.substring(0,15);

     String CoBorrowerMonthlyIncomeValue;  
     if (loAccount2nd.size() > 0 && loAccount2nd[0].Monthly_Total_Income_Value__c != null) CoBorrowerMonthlyIncomeValue = '               '.substring(0, (15-string.valueof(loAccount2nd[0].Monthly_Total_Income_Value__c).length())) + string.valueof(loAccount2nd[0].Monthly_Total_Income_Value__c); else CoBorrowerMonthlyIncomeValue = '               '.substring(0,15);

     String PropertyPurchasePrice;
    if (opp[0].Purchase_Price__c != null) PropertyPurchasePrice = '               '.substring(0, (15-string.valueof(opp[0].Purchase_Price__c).length())) + opp[0].Purchase_Price__c; else PropertyPurchasePrice = '               '.substring(0,15);

     String BKLast7YearsValue;  
     String ForeclosureShortsaleValue;  
     String IntendOccupy;  
     String OutstandingJudgements;    
     String USCitizenship;
     if (loAccount[0].Bankruptcy_Value__c != null) BKLast7YearsValue = loAccount[0].Bankruptcy_Value__c; else BKLast7YearsValue = ' '.substring(0,1);
     if (loAccount[0].Foreclosure_Shortsale_Value__c != null) ForeclosureShortsaleValue = loAccount[0].Foreclosure_Shortsale_Value__c; else ForeclosureShortsaleValue = ' '.substring(0,1);
  
    String CoBKLast7YearsValue;  
    String CoForeclosureShortsaleValue;    
    String CoOutstandingJudgements;  
    String CoUSCitizenship;     
    if (loAccount2nd.size() > 0 && loAccount2nd[0].Bankruptcy_Value__c != null) CoBKLast7YearsValue = loAccount2nd[0].Bankruptcy_Value__c; else CoBKLast7YearsValue = ' '.substring(0,1);

    String BorrowerEthnicity; 
    String BorrowerGender; 
    if (loAccount[0].Ethnicity_Value__c != null) BorrowerEthnicity = loAccount[0].Ethnicity_Value__c; else BorrowerEthnicity =  ' '.substring(0,1);
    if (loAccount[0].Gender_Value__c != null) BorrowerGender = loAccount[0].Gender_Value__c; else BorrowerGender =  ' '.substring(0,1);
    
    //line of 10R
    String BorrowerRace; 
    if (loAccount[0].Race_Value__c != null) BorrowerRace = '  '.substring(0, (2-loAccount[0].Race_Value__c.length())) + loAccount[0].Race_Value__c; else BorrowerRace =  '  '.substring(0,2);
    
    //line of 10A
    String CoBorrowerEthnicity; 
    String CoBorrowerGender; 
    if (loAccount2nd.size() > 0 && loAccount2nd[0].Ethnicity_Value__c != null) CoBorrowerEthnicity = loAccount2nd[0].Ethnicity_Value__c; else CoBorrowerEthnicity =  ' '.substring(0,1);
    if (loAccount2nd.size() > 0 && loAccount2nd[0].Gender_Value__c != null) CoBorrowerGender = loAccount2nd[0].Gender_Value__c; else CoBorrowerGender =  ' '.substring(0,1);
    
    //line of 10R
    String CoBorrowerRace; 
    if (loAccount2nd.size() > 0 && loAccount2nd[0].Race_Value__c != null) CoBorrowerRace = '  '.substring(0, (2-loAccount2nd[0].Race_Value__c.length())) + loAccount2nd[0].Race_Value__c; else CoBorrowerRace =  '  '.substring(0,2);
    
    //line of LNC
    String LienTypeCode; 
    String PropertyTypeCode; 
    if (opp[0].Lien_Position_Value__c != null) LienTypeCode = opp[0].Lien_Position_Value__c; else LienTypeCode =  ' '.substring(0,1);
    if (opp[0].Property_Type_Value__c != null) PropertyTypeCode = opp[0].Property_Type_Value__c; else PropertyTypeCode =  '  '.substring(0,2);
                
    
    List<List<String>> names = new List<List<String>>{
        new List<String>{'EH ','',''},
        new List<String>{'TH ','T185859-888','123456789'},
        new List<String>{'TPI', ' 1.00','01','                              ','N'},
        new List<String>{'02B','  ',PurposeofLoan,'                                                                                ',Propertywillbe,'                                                            ','1' },
        new List<String>{'02D','    ','               ','               ','               ',CostOfImprovements,PurposeOfRefinance },
        new List<String>{'02E', LOSDowPaymentType, LOSDowPaymentAmount},
    };
 
    String linesOf00 = string.valueof((names[0][0]) + (names[0][1]));
    String linesOf01 = string.valueof((names[1][0]) + (names[1][1]) + (names[1][2]));
    String linesOf27 = string.valueof((names[27][0]) + (names[27][1]));
    
    String linesOfFNMHeader;
    String linesOfFNMFirstBorrower;

 
    linesOfFNMHeader = string.valueof(linesOf00 + '\n' + linesOf01 + '\n' + linesOf02 + '\n');
    linesOfFNMSecond = string.valueof(linesOf09+ '\n' + linesOf11 + '\n' + linesOf13 + '\n' + linesOf15 + '\n' + linesOf18 + '\n' + linesOf20 + '\n' + linesOf22 + '\n'); 

    if(loAccount[0].SSN__c != null && loAccount2nd.size() > 0 && loAccount2nd[0].SSN__c != null) linesOfFNM = linesOfFNMHeader + linesOfFNMFirstandSecondBorrower + linesOfFNMFooter; else if (loAccount[0].SSN__c != null && loAccount2nd.size() > 0 && loAccount2nd[0].SSN__c == null) linesOfFNM = linesOfFNMHeader + linesOfFNMFirstBorrower + linesOfFNMFooter; else linesOfFNM = linesOfFNMHeader + linesOfFNMFirstBorrower + linesOfFNMFooter;
        
       String beforefnmfile = linesOfFNM;
        
        Blob beforefnmfileblob = Blob.valueOf(beforefnmfile);
        String fnmfilevalue = EncodingUtil.base64Encode(beforefnmfileblob);

        String postDataFNM = 'SessionID=' + NewSessionId +
            '&Nonce=' + NewNonce +
            '&FileType=' + FileType +
            '&DateName=' + DateName +
            '&LoanNumber=' + LoanNumber +
            '&Base64FileData=' + fnmfilevalue;

         HttpRequest requestFNM = new HttpRequest();
         requestFNM.setEndpoint(endpointfile + 'import_from_file');
         requestFNM.setMethod('POST');
         requestFNM.setHeader('Accept', 'application/x-www-form-urlencoded');
         HttpResponse responseFNM = http.send(requestFNM);


         Pcl2ImportFromFileWrapper newpcl2LoanNumber = Pcl2ImportFromFileWrapper.parse(responseFNM.getBody());

         integer NewLOLoanNumber = newpcl2LoanNumber.NewLoanNumberID;
         
        Account viewAcct;
        Opportunity updateopp;

        updateopp = [SELECT Name,Id,Loan__c,Loan_Notes__c,AccountId FROM Opportunity WHERE ID =: oppId LIMIT 1];
        viewAcct = [SELECT Name,Id FROM Account WHERE Id =: updateOpp.AccountId LIMIT 1];
        
        try {
        
        oppId = Apexpages.currentpage().getparameters().get('id');
        
        Case newCase = new Case(
                   Origin = 'Pcl new Session, and new sessionID' + newSession.SessionID,
                    Description = 'SessionID: ' + newSession.SessionID + 'and Nonce: ' + newSession.Nonce + 'oppID: ' + oppId + 'opp name: ' + opp[0].Name + 'updateopp.Loan__c' + updateopp.Loan__c
                );
        insert newCase;
            
        
       if(updateopp.Loan__c != null) 
        {
        updateOpp.Loan_Notes__c = 'opp name: ' + updateOpp.Name + 'Loan__c: ' + updateOpp.Loan__c + 'SessionID: ' + newSession.SessionID + 'and Nonce: ' + newSession.Nonce + 'oppID: ' + oppId;
        }
        if(updateopp.Loan__c == null) 
        {

        updateOpp.Name = viewAcct.Name + '-' +NewLOLoanNumber;
        
        updateOpp.Loan_Notes__c = 'opp name: ' + updateOpp.Name + 'Loan#: ' + NewLOLoanNumber + 'SessionID: ' + newSession.SessionID + 'and Nonce: ' + newSession.Nonce + 'oppID: ' + oppId;
        }
        
        update updateopp;    
        
                
        }
        catch (Exception e) {

        }
            
        return response; 

    }
}