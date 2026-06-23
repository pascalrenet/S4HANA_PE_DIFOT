@AbapCatalog.sqlViewName: 'ZV_PRPOSCLINES'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Supplier Confirmation Lines'

/*
  Individual supplier confirmation lines per PO item from
  I_POSupplierConfirmationAPI01.  Only active (non-deleted) records
  are included.

  This view is exposed as a navigation target from ZC_PRPODIFOT_C so
  that the Fiori Object Page can show all confirmation lines for a
  selected PO item in a table.
*/
define view ZC_PRPOSuppConfLines
  as select from I_POSupplierConfirmationAPI01
{
  /* ── Keys ─────────────────────────────────────────────────────── */
  key PurchaseOrder,
  key PurchaseOrderItem,

  @EndUserText.label: 'Sequential Number'
  @UI.lineItem: [{ position: 20, label: 'Seq. No.' }]
  key SequentialNmbrOfSuplrconf,

  /* ── Confirmation Header ───────────────────────────────────────── */
  @EndUserText.label: 'Confirmation Category'
  @UI.lineItem: [{ position: 10, label: 'Category' }]
  SupplierConfirmationCategory,

  @EndUserText.label: 'Delivery Date'
  @UI.lineItem: [{ position: 30, label: 'Delivery Date' }]
  DeliveryDate,

  @EndUserText.label: 'Delivery Date Category'
  DelivDateCategory,

  /* ── Quantity ──────────────────────────────────────────────────── */
  @EndUserText.label: 'Confirmed Quantity'
  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  @UI.lineItem: [{ position: 40, label: 'Confirmed Qty' }]
  ConfirmedQuantity,

  @EndUserText.label: 'Order Quantity Unit'
  @UI.lineItem: [{ position: 50, label: 'Unit' }]
  OrderQuantityUnit,

  /* ── Creation ──────────────────────────────────────────────────── */
  @EndUserText.label: 'Created On'
  @UI.lineItem: [{ position: 60, label: 'Created On' }]
  CreationDate,

  @EndUserText.label: 'Created At'
  CreationTime,

  /* ── Reference ─────────────────────────────────────────────────── */
  @EndUserText.label: 'External Reference Number'
  SupplierConfirmationExtNumber,

  @EndUserText.label: 'Delivery Document'
  DeliveryDocument,

  @EndUserText.label: 'Delivery Document Item'
  DeliveryDocumentItem,

  /* ── Deletion ──────────────────────────────────────────────────── */
  @EndUserText.label: 'Deleted'
  IsDeleted
}
where IsDeleted = ''
