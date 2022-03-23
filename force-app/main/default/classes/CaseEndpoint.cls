@RestResource(urlMapping='/cases/*')
global with sharing class CaseEndpoint {
    private static final String PARAM_EXTERNAL_ID = 'external_id';
    private static final String EXCEPTION_MESSAGE_BAD_PARAMETERS = 'None or Bad External Id was passed into the parameter.';
    private static final String EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED = 'Wrong parameter provided.';
    private static final String EXCEPTION_MESSAGE_CASE_NOT_FOUND = 'Case with given id was not found.';

    @HttpPost
    global static void upsertCases() {

        String requestBody = RestContext.request.requestBody.toString();
        List<CaseWrapper> casesToUpdate = (List<CaseWrapper>) JSON.deserialize(requestBody, List<CaseWrapper>.class);
        List<Case> casesToUpdateList = new List<Case>();

        for (CaseWrapper receivedCase : casesToUpdate) {
            Case newCase = new Case();
            newCase.Preferred_Language__c = receivedCase.Preferred_Language;
            newCase.RecordTypeId = CaseUtils.getRecordTypeIdByDevName(receivedCase.record_type);
            newCase.Priority = receivedCase.Priority;
            newCase.Subject = receivedCase.Subject;
            newCase.Description = receivedCase.Description;
            newCase.Comments = receivedCase.Comments;
            newCase.SuppliedEmail = receivedCase.SuppliedEmail;
            newCase.SuppliedPhone = receivedCase.SuppliedPhone;
            newCase.SuppliedName = receivedCase.SuppliedName;
            newCase.External_Id__c = receivedCase.external_id;
            newCase.Last_Change_Org_Id__c = receivedCase.last_change_source_org;
            casesToUpdateList.add(newCase);
        }
        upsert casesToUpdateList Case.External_Id__c;
    }

    @HttpDelete
    global static void deleteCase() {
        String requestParam = RestContext.request.params.get(PARAM_EXTERNAL_ID);
        List<String> parameterValues = requestParam.split(',');
        TRY {
            List<Case> caseToDeleteByExtId = [SELECT Id FROM Case WHERE External_Id__c In :parameterValues];
            if (caseToDeleteByExtId.isEmpty()) {
                throw new ResourceNotFoundException(EXCEPTION_MESSAGE_CASE_NOT_FOUND);
            }
            if (String.isBlank(requestParam)) {
                throw new WrongParametersProvidedException(EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED);
            }
            delete caseToDeleteByExtId;

        } CATCH (Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            RestContext.response.statusCode = 400;
        }
    }

    private class ResourceNotFoundException extends Exception {
    }
    private class WrongParametersProvidedException extends Exception {
    }
}