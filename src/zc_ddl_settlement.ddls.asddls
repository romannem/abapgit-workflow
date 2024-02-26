@EndUserText.label: 'Projection view k Z_DDL_SETTLEMENT'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_DDL_SETTLEMENT
  as projection on Z_DDL_SETTLEMENT as zsettl
{
  key zsettl.CompanyCode,
  key zsettl.FiscalYear,
  key zsettl.AccountingDocument,
      //    zsettl.AccountingDocumentType,
      zsettl.DocumentDate,
      zsettl.PostingDate,
      zsettl.FiscalPeriod,
      zsettl.AccountingDocumentCreationDate,
      zsettl.CreationTime,
      zsettl.LastManualChangeDate,
      zsettl.LastAutomaticChangeDate,
      zsettl.LastChangeDate,
      zsettl.ExchangeRateDate,
      zsettl.AccountingDocCreatedByUser,
      zsettl.TransactionCode,
      zsettl.IntercompanyTransaction,
      zsettl.DocumentReferenceID,
      zsettl.RecurringAccountingDocument,
      zsettl.RecrrgJournalEntryCompanyCode,
      zsettl.RecrrgJournalEntryFiscalYear,
      zsettl.ReverseDocument,
      zsettl.ReverseDocumentFiscalYear,
      zsettl.AccountingDocumentHeaderText,
      zsettl.TransactionCurrency,
      zsettl.AbsoluteExchangeRate,
      zsettl.ExchRateIsIndirectQuotation,
      zsettl.EffectiveExchangeRate,
      zsettl.AccountingDocumentCategory,
      zsettl.NetAmountIsPosted,
      zsettl.JrnlEntryIsPostedToPrevPeriod,
      zsettl.BatchInputSession,
      zsettl.ReferenceDocumentType,
      zsettl.OriginalReferenceDocument,
      zsettl.CompanyCodeCurrency,
      zsettl.AdditionalCurrency1,
      zsettl.AdditionalCurrency2,
      zsettl.ReversalIsPlanned,
      zsettl.PlannedReversalDate,
      zsettl.TaxIsCalculatedAutomatically,
      zsettl.AdditionalCurrency1Role,
      zsettl.AdditionalCurrency2Role,
      zsettl.TaxBaseAmountIsNetAmount,
      zsettl.SourceCompanyCode,
      zsettl.LogicalSystem,
      zsettl.ReferenceDocumentLogicalSystem,
      zsettl.TaxAbsoluteExchangeRate,
      zsettl.ReversalReason,
      zsettl.ParkedByUser,
      zsettl.ParkingDate,
      zsettl.ParkingTime,
      zsettl.Branch,
      zsettl.NmbrOfPages,
      zsettl.IsDiscountDocument,
      zsettl.Reference1InDocumentHeader,
      zsettl.Reference2InDocumentHeader,
      zsettl.InvoiceReceiptDate,
      zsettl.AlternativeReferenceDocument,
      zsettl.TaxReportingDate,
      zsettl.TaxFulfillmentDate,
      zsettl.AccountingDocumentClass,
      zsettl.ExchangeRateType,
      zsettl.MarketDataAbsoluteExchangeRate,
      zsettl.MktDataEffectiveExchangeRate,
      zsettl.SenderLogicalSystem,
      zsettl.SenderCompanyCode,
      zsettl.SenderAccountingDocument,
      zsettl.SenderFiscalYear,
      zsettl.ReversalReferenceDocumentCntxt,
      zsettl.ReversalReferenceDocument,
      zsettl.LatePaymentReason,
      zsettl.SalesDocumentCondition,
      zsettl.IsReversal,
      zsettl.IsReversed,
      zsettl.GLBusinessTransactionGroup,
      zsettl.CostAccountingValuationDate,
      zsettl.TaxCountry,
      zsettl.JournalEntryLastChangeDateTime,
      zsettl.JrnlEntryCntrySpecificRef1,
      zsettl.JrnlEntryCntrySpecificDate1,
      zsettl.JrnlEntryCntrySpecificRef2,
      zsettl.JrnlEntryCntrySpecificDate2,
      zsettl.JrnlEntryCntrySpecificRef3,
      zsettl.JrnlEntryCntrySpecificDate3,
      zsettl.JrnlEntryCntrySpecificRef4,
      zsettl.JrnlEntryCntrySpecificDate4,
      zsettl.JrnlEntryCntrySpecificRef5,
      zsettl.JrnlEntryCntrySpecificDate5,
      zsettl.JrnlEntryCntrySpecificBP1,
      zsettl.JrnlEntryCntrySpecificBP2,
      zsettl.WithholdingTaxReportingDate,
      /* Associations */
      _SettlementDocs : redirected to composition child ZC_DDL_SETTLEMENT_DOCS
      //    _SettlementDocs : redirected to ZC_DDL_SETTLEMENT_DOCS
}
