public class Customer_ProfilePhotoController {
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 
        
        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            throw new System.NoAccessException();
            
        }
        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.contentType = contentType;
        insert attachment;
        return attachment.id;
    }
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new System.NoAccessException();
            
        }
        try{
            Attachment Result = new Attachment( Id = null,ContentType = '' , Name = '' );
            List<Attachment> lsData = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
                                       WHERE parentId=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
                                       ORDER BY LastModifiedDate DESC LIMIT 1];
            if( lsData != null && lsData.size() > 0) Result = lsData.get(0);
            return Result;
        }catch(Exception E){
            return new Attachment( Id = null ,ContentType = '' , Name = '' );
        }
    }
    @AuraEnabled
    public static Attachment getProfilePictureLead(String customerGlobalId) {
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new System.NoAccessException();
            
        }
        try{
            Account acc = [Select Id from Account where CustomerGlobalId__c =: customerGlobalId];
            Attachment Result = new Attachment( Id = null,ContentType = '' , Name = '' );
            List<Attachment> lsData = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
                                       WHERE parentId=:acc.Id AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
                                       ORDER BY LastModifiedDate DESC LIMIT 1];
            if( lsData != null && lsData.size() > 0) Result = lsData.get(0);
            return Result;
        }catch(Exception E){
            return new Attachment( Id = null ,ContentType = '' , Name = '' );
        }
    }
    
    @AuraEnabled
    public static Account getAccountDetail(String parentId) {
        // Attachment permissions are set in parent object (Contact)
        try{
            if (!Schema.sObjectType.Account.isAccessible()) {
                throw new System.NoAccessException();
                
            }
            
            system.debug(LoggingLevel.ERROR, 'parentId:'+parentId);
                
            List<Account> lsData = [Select Id, Website, CustomerGlobalId__c,	Phone, Industry from Account where Id = :parentId];
            Account Result = new Account( Id = null );
            if(lsData!= null & lsData.size() > 0) Result =lsData.get(0);
            system.debug(LoggingLevel.ERROR, 'Result:'+Result);
            return Result;
            
        }catch(Exception E){
            return new Account ( Id = null);
        }
    }
    
}