public class OEM_ProductService {
	public static void assignGlobalId(List<sObject> scope){
        for(sObject rec : scope){
            if( String.isEmpty((String)rec.get('ProductGlobalExternalId__c'))) 
                rec.put('ProductGlobalExternalId__c', GuidUtil.NewGuid());
        }
    }
    public class OEM_ProductServiceException extends Exception{}
}