public class OEM_AccountService {
    public static void assignGlobalId(List<sObject> scope){
        for(sObject rec : scope){
            if( String.isEmpty((String)rec.get('CustomerGlobalId__c'))) 
                rec.put('CustomerGlobalId__c', GuidUtil.NewGuid());
        }
    }
    public class OEM_AccountServiceException extends Exception{}
}