@EndUserText.label: 'Custom entity Settlement'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_CUSTOM_SETTLEMENT'
    }
}

@UI: {
  headerInfo: {
    typeName: 'Settlement',
    typeNamePlural: 'Settlements',
    title: { value: 'CompanyCode' },
    description: { value: 'CompanyCode' }
  }
}

define root custom entity ZI_CUSTOM_SETTL
// with parameters parameter_name : parameter_type
{
      @UI.facet      : [
           {
             id      :  'Flight_Data',
             purpose :  #STANDARD,
             type    :  #IDENTIFICATION_REFERENCE,
             label   :  'Flights',
             position: 10 }
         ]

      @UI.lineItem   : [{ position: 10 }]
      @UI.selectionField : [{position: 10}]
      @UI.identification: [{position: 10}]
      key CompanyCode     : bukrs;

      @UI.lineItem   : [{ position: 20 }]
      @UI.selectionField : [{position: 20}]
      @UI.identification: [{position: 20}]
      ClearingJournalEntry : bukrs;


}
