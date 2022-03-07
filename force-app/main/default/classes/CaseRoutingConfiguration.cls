public with sharing class CaseRoutingConfiguration {

  private static CaseRoutingConfiguration instance;
  private Map<String, Routing_Configuration__mdt> configMap;

  private CaseRoutingConfiguration() {
      configMap = new Map<String, Routing_Configuration__mdt>();
      this.init();
  }

  public static CaseRoutingConfiguration getInstance() {
      if (instance == null) {
          instance = new CaseRoutingConfiguration();

      }
      return instance;
  }


  private List<Routing_Configuration__mdt> retrieveMetadata() {
      return [
              SELECT Id, DeveloperName,Queue__c, Routing_Chinese__c, Routing_English__c,
                      Routing_French__c, Routing_German__c, Routing_Italian__c,
                      Routing_Portuguese__c
              FROM Routing_Configuration__mdt
      ];
  }
  private void fillConfigMap(List<Routing_Configuration__mdt> caseRoutingConfig) {
      for (Routing_Configuration__mdt routing : caseRoutingConfig) {
          configMap.put(routing.Queue__c, routing);
      }
  }

  private void init() {
      fillConfigMap(retrieveMetadata());
  }

  public Routing_Configuration__mdt getRoutingData(String queueDispatcherApiName) {
      return configMap.get(queueDispatcherApiName);
  }
}





