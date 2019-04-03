global class ZeroLight_InboundEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        EmailMessage em = new EmailMessage();
        em.TextBody = email.plainTextBody;
        em.HtmlBody = email.htmlBody;
        insert em;
        
        Integer startIndex = -1; 
        Integer endIndex = -1; 
        String myPlainText= '';
        myPlainText = email.plainTextBody;
        system.debug('dav>>>>>>');
        system.debug(email.htmlBody);
        system.debug(email.plainTextBody);
        
        if(String.isEmpty(myPlainText)){
            myPlainText = email.htmlBody.stripHtmlTags();
        }
    
        String carCode = '';
        String configuratorLeadName = '';
        
        if( !String.isEmpty( myPlainText )   ){
            startIndex = myPlainText.indexOf('?code=');
            if( startIndex >-1  )
            {
                
                carCode = myPlainText.substring( startIndex + 6 );
                
                endIndex = carCode.indexOf(' ');
                
                if( endIndex > - 1 ) carCode = myPlainText.substring(0, endIndex -1 );
                
                configuratorLeadName = '';
                startIndex = myPlainText.indexOf('Dear ');
                
                if( startIndex > -1 ) configuratorLeadName = myPlainText.substring( startIndex + 5 );
                endIndex = configuratorLeadName.indexOf(',');
                if( endIndex > - 1 ) configuratorLeadName = configuratorLeadName.substring(0, endIndex  );
            }
        }
        
        Lead ld;
        String firstName = ''; 
        String lastName = '';
        startIndex = -1;
        
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ZeroLightLead').getRecordTypeId();
        system.debug(configuratorLeadName);
        if(!String.isEmpty(configuratorLeadName)){
            startIndex = configuratorLeadName.indexOf(' ');
            if( startIndex >-1 ) firstName = configuratorLeadName.substring( 0, startIndex );
            if( startIndex >-1 ) lastName = configuratorLeadName.substring( startIndex );
            ld = new Lead(
                FirstName = firstName,
                LastName = lastName,
                ZeroLightCode__c = carCode,
                LeadSource = 'ZeroLightProductConfigurator'
            );
            
            if( !String.isEmpty(devRecordTypeId) )  ld.RecordTypeId = devRecordTypeId;
            insert ld;
        }
        result.success = true;
        
        
        return result;
    }
    
}