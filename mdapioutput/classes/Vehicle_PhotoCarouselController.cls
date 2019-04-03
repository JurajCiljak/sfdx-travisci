public with sharing class Vehicle_PhotoCarouselController {

    @AuraEnabled
    public static List<ContentDocumentLink> getVehiclePictures(Id parentId) {
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            
        }
 
        return [Select Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :parentId];
    }
   }