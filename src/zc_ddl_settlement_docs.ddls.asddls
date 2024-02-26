@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view pro Settlement docs'
@Metadata.allowExtensions: true

define view entity ZC_DDL_SETTLEMENT_DOCS
  as projection on Z_DDL_SETTLEMENT_DOCS as zsettldocs

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
      _Settlement : redirected to parent ZC_DDL_SETTLEMENT

}
