public class ZeroLight_LiveStreamController {
    
    
    @AuraEnabled
    public static String getZeroLightCode(Id recordId) {
        String result;
        try{
            if( !String.isEmpty( recordId)){
                String sObjName = recordId.getSObjectType().getDescribe().getName();
                if( sObjName == 'Account'){
                    //Result = getAccount_ZeroLightCode( recordId );
                }else if(  sObjName == 'Lead' ){
                    result = getLead_ZeroLightCode(recordId);    
                } else if( sObjName == 'Opportunity' ){
                    Result = getOpportunity_ZeroLightCode(recordId);  	   
                } else{
                    
                }
                
            }
            
            return result;
        }catch(Exception E)
        { 
            system.debug(LoggingLevel.ERROR,'getAllPayments Error !!!: '+E);
            return null ;
        }
    }
    
    public static String getLead_ZeroLightCode(Id recordId)
    {
        Lead lsData = [Select Id,ZeroLightCode__c From Lead where Id =: recordId];   
        return lsData.ZeroLightCode__c;
    }
    public static String getOpportunity_ZeroLightCode(Id recordId)
    {
        Lead lsData = [Select Id,ZeroLightCode__c From Lead where ConvertedOpportunityId =: recordId];   
        return lsData.ZeroLightCode__c;
    }
}