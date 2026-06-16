@AbapCatalog.sqlViewName: 'ZV_PRPOGRHISTLN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item GR History Lines'

/*
  Individual goods receipt and reversal lines per PO item from
  I_PurchaseOrderHistoryAPI01.  Only category E (goods receipts) and
  movement types 101 (GR) and 102 (GR reversal) are included.

  This view is exposed as a navigation target from ZC_PRPODIFOT_C so
  that the Fiori Object Page can show the individual GR lines for a
  selected PO item in a table.
*/
define view ZC_PRPOGRHistoryLines
  as select from I_PurchaseOrderHistoryAPI01
{
  /* ── Keys ─────────────────────────────────────────────────────── */
  key PurchaseOrder,
  key PurchaseOrderItem,

  @EndUserText.label: 'Material Document'
  @UI.lineItem: [{ position: 10, label: 'Material Doc.' }]
  key PurchasingHistoryDocument,

  key PurchasingHistoryDocumentItem,

  /* ── Document Info ─────────────────────────────────────────────── */
  @EndUserText.label: 'Document Type'
  PurchasingHistoryDocumentType,

  @EndUserText.label: 'Material Document Year'
  PurchasingHistoryDocumentYear,

  @EndUserText.label: 'History Category'
  PurchasingHistoryCategory,

  @EndUserText.label: 'Movement Type'
  @UI.lineItem: [{ position: 20, label: 'Mvt Type' }]
  GoodsMovementType,

  @EndUserText.label: 'Posting Date'
  @UI.lineItem: [{ position: 30, label: 'Posting Date' }]
  PostingDate,

  @EndUserText.label: 'Document Date'
  DocumentDate,

  /* ── Quantity / Amount ─────────────────────────────────────────── */
  @EndUserText.label: 'Dr/Cr Indicator'
  @UI.lineItem: [{ position: 40, label: 'Dr/Cr' }]
  DebitCreditCode,

  @EndUserText.label: 'Quantity'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  @UI.lineItem: [{ position: 50, label: 'Quantity' }]
  Quantity,

  @EndUserText.label: 'PO Quantity Unit'
  PurchaseOrderQuantityUnit,

  @EndUserText.label: 'GR Blocked Stock Qty'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  GdsRcptBlkdStkQtyInOrdQtyUnit,

  @EndUserText.label: 'Amount in PO Currency'
  @Semantics.amount.currencyCode: 'DocumentCurrency'
  @UI.lineItem: [{ position: 60, label: 'Amount (PO Curr.)' }]
  PurchaseOrderAmount,

  @EndUserText.label: 'PO Currency'
  DocumentCurrency,

  @EndUserText.label: 'Amount in Company Code Currency'
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  PurOrdAmountInCompanyCodeCrcy,

  @EndUserText.label: 'Company Code Currency'
  CompanyCodeCurrency,

  /* ── Reference / Delivery Doc ──────────────────────────────────── */
  @EndUserText.label: 'Reference Document'
  ReferenceDocument,

  @EndUserText.label: 'Delivery Document'
  DeliveryDocument,

  @EndUserText.label: 'Delivery Item'
  DeliveryDocumentItem,

  /* ── Material / Plant ──────────────────────────────────────────── */
  @EndUserText.label: 'Material'
  Material,

  @EndUserText.label: 'Plant'
  Plant,

  @EndUserText.label: 'Batch'
  Batch,

  /* ── Dates ─────────────────────────────────────────────────────── */
  @EndUserText.label: 'Accounting Document Creation Date'
  AccountingDocumentCreationDate,

  @EndUserText.label: 'Complete Delivery Indicator'
  IsCompletelyDelivered
}
where PurchasingHistoryCategory = 'E'
  and ( GoodsMovementType = '101' or GoodsMovementType = '102' )
