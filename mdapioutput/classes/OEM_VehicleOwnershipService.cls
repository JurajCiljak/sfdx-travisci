/**
 * Created by admin on 3/1/2019.
 */

public with sharing class OEM_VehicleOwnershipService {
	
    public static void assignVehicleOwnershipGlobalId(List<VehicleOwnership__c> scope){
        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, Vehicle__c> vhMap = new Map<Id, Vehicle__c>();
        List<VehicleOwnership__c> filteredScope = new List<VehicleOwnership__c>();
        for(VehicleOwnership__c vo : scope){
            if(String.isEmpty(vo.VehicleOwnershipGlobalExternalId__c)){
                filteredScope.add(vo);
                accMap.put(vo.Account_ref__c, null);
                vhMap.put(vo.Vehicle_ref__c,null);
            }
        }
        accMap = new Map<Id, Account>([Select CustomerGlobalId__c from Account where Id in :accMap.keySet()]);
        vhMap = new Map<Id, Vehicle__c>([Select VehicleIdentificationNumber__c from Vehicle__c where Id in :vhMap.keySet()]);
        for(VehicleOwnership__c vo : filteredScope){
            if(!accMap.containsKey(vo.Account_ref__c) || String.isEmpty(accMap.get(vo.Account_ref__c).CustomerGlobalId__c))
                vo.VehicleOwnershipGlobalExternalId__c.addError('Related Customer does not have Global Id assigned or relationship is not filled');
            if(!vhMap.containsKey(vo.Vehicle_ref__c) || String.isEmpty(vhMap.get(vo.Vehicle_ref__c).VehicleIdentificationNumber__c))
                vo.VehicleOwnershipGlobalExternalId__c.addError('Related Vehicle does not have VIN assigned or relationship is not filled');
           	if(accMap.containsKey(vo.Account_ref__c) && !String.isEmpty(accMap.get(vo.Account_ref__c).CustomerGlobalId__c) && vhMap.containsKey(vo.Vehicle_ref__c) && !String.isEmpty(vhMap.get(vo.Vehicle_ref__c).VehicleIdentificationNumber__c))
            	vo.VehicleOwnershipGlobalExternalId__c = vhMap.get(vo.Vehicle_ref__c).VehicleIdentificationNumber__c + '_VehicleOwnership_'+accMap.get(vo.Account_ref__c).CustomerGlobalId__c;
        }
    }

    public static void mainBeforeInsertLoop(List <SObject> soLst, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        /*
        function mainBeforeInsertLoop responsible for main forloop in After insert trigger
        @soLst : Collection of records which are processed
        @oldMap: Map Collection of records with old Values
        @newMap: Map Collection of records with new walues
        */
        Map<Id, VehicleOwnership__c> oldData = new Map<Id, VehicleOwnership__c>() ;
        VehicleOwnership__c oldRec;
        Set<String> Ids = new Set<String>();
        Set<String> customerGlobalNumber = new Set<String>();
        if (oldMap != null) oldData = (Map<Id, VehicleOwnership__c>) oldMap;
        List<VehicleOwnership__c> vehicleOwnership = new List<VehicleOwnership__c>();
        Set<String> vehicles = new Set<String>();
        Set<String> customerProfiles = new Set<String>();

        try {

            for (VehicleOwnership__c vo : (List<VehicleOwnership__c>) soLst) {

                oldRec = oldData.get(vo.Id);
                system.debug(LoggingLevel.Error, 'vo !!!: ' + vo);
                if (oldRec == null) oldRec = new VehicleOwnership__c(VehicleOwnershipGlobalExternalId__c = '');
                //if( String.isEmpty(vo.Vehicle_ref__c)) cs.CaseGlobalId__c = GuidUtil.NewGuid();

                if (!String.isEmpty(vo.Vehicle_ref__c) && String.isEmpty(vo.VehicleOwnershipGlobalExternalId__c)) {

                    vehicleOwnership.Add(vo);
                    vehicles.Add(vo.Vehicle_ref__c);
                    customerProfiles.Add(vo.Account_ref__c);


                }// else cs.VehicleOwnership_ref__c = null;


            }   // for(VehicleOwnership__c vo: (List<VehicleOwnership__c>)soLst)

            setupVehicleOwnerShip(vehicleOwnership, vehicles, customerProfiles);
        } catch (Exception E) {
            system.debug(LoggingLevel.Error, 'mainAfterInsertLoop Error!!!: ' + E);
        }
    }

    public static String getVehicleOwnerShipGlobalId(String customerGlobalId, String vehicleIdentificationNumber) {
        String prefix = '_VehicleOwnerShip_';
        String Result = '';

        /*  Format of VehicleOwnershipGlobalId__c should be concatination of VIN number & Customer Profile Name
            Example : 1234567890PLASERT_VehicleOwnerShip_HjG123K9o8 -> VIN: 1234567890PLASERT, customerProfileGlobalId : HjG123K9o8
            This is due the synchronization
        */
        system.debug(LoggingLevel.Error, 'vehicleIdentificationNumber Error!!!: ' + vehicleIdentificationNumber);
        system.debug(LoggingLevel.Error, 'customerGlobalId Error!!!: ' + customerGlobalId);
        if (vehicleIdentificationNumber != null) {
            Result = vehicleIdentificationNumber + prefix;
        }
        if (customerGlobalId != null) {
            Result += customerGlobalId;
        }

        return Result;
    }


    public static void setupVehicleOwnerShip(List<VehicleOwnership__c> vehicleOwnership, Set<String> vehicles, Set<String> customerProfiles) {
        try {



            Account myAcc;
            Vehicle__c myVc;

            if (vehicleOwnership != null && vehicleOwnership.size() > 0) {
                List< Account > lsAccounts = [Select Id,CustomerGlobalId__c From Account Where Id = :customerProfiles];
                Map<String, Account> mapAccount = new Map<String, Account>();


                mapAccount.PutAll(lsAccounts);


                List< Vehicle__c > lsVehicles = [Select Id,VehicleIdentificationNumber__c From Vehicle__c Where Id = :vehicles];
                Map<String, Vehicle__c> mapVehicles = new Map<String, Vehicle__c>();
                mapVehicles.PutAll(lsVehicles);

                system.debug(LoggingLevel.Error, 'vehicles !!!: ' + vehicles);
                system.debug(LoggingLevel.Error, 'customerProfiles !!!: ' + customerProfiles);
                system.debug(LoggingLevel.Error, 'lsVehicles !!!: ' + lsVehicles);
                system.debug(LoggingLevel.Error, 'mapAccount !!!: ' + mapAccount);
                system.debug(LoggingLevel.Error, 'vehicleOwnership !!!: ' + vehicleOwnership);
                for (VehicleOwnership__c vo : vehicleOwnership) {
                    myAcc = mapAccount.get(vo.Account_ref__c) ;
                    if (myAcc == null) {
                        myAcc = new Account();//vo.Account_ref__c = myAcc.Id;
                    }

                    myVc = mapVehicles.get(vo.Vehicle_ref__c) ;
                    if (myVc == null) {
                        myVc = new Vehicle__c(VehicleIdentificationNumber__c = '');//vo.Vehicle_ref__c = myVc.Id;
                    }
                    vo.VehicleOwnershipGlobalExternalId__c = getVehicleOwnerShipGlobalId(myAcc.CustomerGlobalId__c, myVc.VehicleIdentificationNumber__c);
                }
                system.debug(LoggingLevel.Error, 'vehicleOwnership !!!: ' + vehicleOwnership);
            }
        } catch (Exception E) {
            system.debug(LoggingLevel.Error, 'mainAfterInsertLoop Error!!!: ' + E);
        }

    }
    public class OEM_VehicleOwnershipServiceException extends Exception{}
}