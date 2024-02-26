@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Settlement docs'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_DDL_SETTLEMENT_DOCS
  as select from I_OperationalAcctgDocItem as zsettldocs
  //association to parent Z_DDL_SETTLEMENT as _Settlement on
  association to parent Z_DDL_SETTLEMENT as _Settlement on  $projection.CompanyCode          = _Settlement.CompanyCode
                                                        and $projection.FiscalYear           = _Settlement.FiscalYear
                                                        and $projection.ClearingJournalEntry = _Settlement.AccountingDocument


{
  key CompanyCode,
  key FiscalYear,
  key ClearingJournalEntry,
  key AccountingDocument,
  key AccountingDocumentItem,
      AssignmentReference,
      ChartOfAccounts,
      AccountingDocumentItemType,
      ClearingDate,
      ClearingCreationDate,
      ClearingJournalEntryFiscalYear,
      CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      AmountInCompanyCodeCurrency,
      PostingKey,
      Customer,
      Supplier,
      DebitCreditCode,
      /* associations */
      _Settlement
} where _JournalEntry.IsReversal != 'X' and _JournalEntry.IsReversed != 'X'
