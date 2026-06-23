@AbapCatalog.sqlViewName: 'ZV_PRPODIFOT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'PO DIFOT - Delivered In Full and On Time'
@Metadata.ignorePropagatedAnnotations: true

/*
  Core DIFOT calculation view.
  Joins:
    - I_PurchaseOrderItemAPI01      (PO item master data, ordered qty)
    - I_PurchaseOrderAPI01          (PO header: supplier, plant, doc date)
    - ZC_PRPOSchedLineSummary       (scheduled delivery date + scheduled qty)
    - ZC_PRPOItemGRSummary          (actual goods receipt qty + posting date)

  DIFOT Rules (strict):
    DeliveredInFull  = TotalGRQuantity >= OrderQuantity
    DeliveredOnTime  = LatestGRPostingDate <= LatestSchedDelivDate
    DIFOTStatus      = 'DIFOT' if both true, else 'NOT DIFOT'
    DIFOTReason      = NULL / 'LATE' / 'SHORT' / 'SHORT AND LATE'
*/
define view ZC_PRPODIFOT
  as select from I_PurchaseOrderItemAPI01 as item

  inner join I_PurchaseOrderAPI01            as po
    on po.PurchaseOrder = item.PurchaseOrder

  left outer join ZC_PRPOSchedLineSummary    as sched
    on  sched.PurchaseOrder     = item.PurchaseOrder
    and sched.PurchaseOrderItem = item.PurchaseOrderItem

  left outer join ZC_PRPOItemGRSummary       as gr
    on  gr.PurchaseOrder     = item.PurchaseOrder
    and gr.PurchaseOrderItem = item.PurchaseOrderItem

{
  /* ── Keys ─────────────────────────────────────────────────── */
  key item.PurchaseOrder,
  key item.PurchaseOrderItem,

  /* ── PO Header ────────────────────────────────────────────── */
  @EndUserText.label: 'Supplier'
  po.Supplier,

  @EndUserText.label: 'Company Code'
  po.CompanyCode,

  @EndUserText.label: 'Purchasing Organization'
  po.PurchasingOrganization,

  @EndUserText.label: 'Purchase Order Type'
  po.PurchaseOrderType,

  @EndUserText.label: 'Purchasing Group'
  po.PurchasingGroup,

  @EndUserText.label: 'PO Date'
  po.PurchaseOrderDate,

  @EndUserText.label: 'Document Currency'
  po.DocumentCurrency,

  /* ── PO Item ──────────────────────────────────────────────── */
  @EndUserText.label: 'Material'
  item.Material,

  @EndUserText.label: 'Material Group'
  item.MaterialGroup,

  @EndUserText.label: 'Short Text'
  item.PurchaseOrderItemText,

  @EndUserText.label: 'Plant'
  item.Plant,

  @EndUserText.label: 'Storage Location'
  item.StorageLocation,

  @EndUserText.label: 'PO Order Quantity'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  item.OrderQuantity,

  @EndUserText.label: 'PO Quantity Unit'
  item.PurchaseOrderQuantityUnit,

  @EndUserText.label: 'Net Price Amount'
  @Semantics.amount.currencyCode: 'DocumentCurrency'
  item.NetPriceAmount,

  @EndUserText.label: 'Net Amount'
  @Semantics.amount.currencyCode: 'DocumentCurrency'
  item.NetAmount,

  @EndUserText.label: 'Delivery Complete Indicator'
  item.IsCompletelyDelivered,

  /* ── Schedule Line Aggregates ─────────────────────────────── */
  @EndUserText.label: 'Total Scheduled Quantity'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  sched.TotalScheduledQuantity,

  @EndUserText.label: 'Earliest Scheduled Delivery Date'
  sched.EarliestSchedDelivDate,

  @EndUserText.label: 'Latest Scheduled Delivery Date'
  sched.LatestSchedDelivDate,

  @EndUserText.label: 'Number of Schedule Lines'
  sched.NumberOfScheduleLines,

  /* ── GR Actuals ───────────────────────────────────────────── */
  @EndUserText.label: 'Total GR Quantity Received'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  gr.TotalGRQuantity,

  @EndUserText.label: 'First GR Date'
  gr.FirstGRPostingDate,

  @EndUserText.label: 'Latest GR Date'
  gr.LatestGRPostingDate,

  /* ── DIFOT Calculated Fields ──────────────────────────────── */

  /*
    Quantity Variance = GR Quantity - Ordered Quantity.
    Negative = short delivery.  Null when no GR has occurred yet.
  */
  @EndUserText.label: 'Quantity Variance (GR - Ordered)'
  @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
  cast(
    gr.TotalGRQuantity - item.OrderQuantity
  as abap.dec( 13, 3 ) )                          as QuantityVariance,

  /*
    Date Variance in days = LatestGRPostingDate - LatestSchedDelivDate.
    Positive = late.  Zero or negative = on time or early.
    Null when either date is missing.
  */
  @EndUserText.label: 'Date Variance in Days (Actual - Scheduled)'
  cast(
    case
      when gr.LatestGRPostingDate    is not null
       and sched.LatestSchedDelivDate is not null
      then dats_days_between( sched.LatestSchedDelivDate, gr.LatestGRPostingDate )
      else 0
    end
  as abap.int4 )                                  as DateVarianceInDays,

  /*
    Delivered In Full flag.
    'X' = yes, '' = no.
  */
  @EndUserText.label: 'Delivered In Full'
  cast(
    case
      when gr.TotalGRQuantity >= item.OrderQuantity then 'X'
      else ''
    end
  as abap.char( 1 ) )                             as IsDeliveredInFull,

  /*
    Delivered On Time flag.
    'X' = yes, '' = no or no GR/schedule line.
  */
  @EndUserText.label: 'Delivered On Time'
  cast(
    case
      when gr.LatestGRPostingDate    is null          then ''
      when sched.LatestSchedDelivDate is null          then ''
      when gr.LatestGRPostingDate <= sched.LatestSchedDelivDate then 'X'
      else ''
    end
  as abap.char( 1 ) )                             as IsDeliveredOnTime,

  /*
    Overall DIFOT Status:
      'DIFOT'     – full AND on time
      'NOT DIFOT' – any failure
      'PENDING'   – no GR received yet
  */
  @EndUserText.label: 'DIFOT Status'
  cast(
    case
      when gr.TotalGRQuantity is null
        then 'PENDING'
      when gr.TotalGRQuantity >= item.OrderQuantity
       and ( sched.LatestSchedDelivDate is null
             or gr.LatestGRPostingDate <= sched.LatestSchedDelivDate )
        then 'DIFOT'
      else 'NOT DIFOT'
    end
  as abap.char( 10 ) )                            as DIFOTStatus,

  /*
    DIFOT Failure Reason — explains WHY it failed:
      'SHORT'          – quantity short only
      'LATE'           – date late only
      'SHORT AND LATE' – both short and late
      ''               – DIFOT (no failure) or PENDING
  */
  @EndUserText.label: 'DIFOT Failure Reason'
  cast(
    case
      when gr.TotalGRQuantity is null then ''   -- PENDING
      when gr.TotalGRQuantity <  item.OrderQuantity
       and sched.LatestSchedDelivDate is not null
       and gr.LatestGRPostingDate >  sched.LatestSchedDelivDate
        then 'SHORT AND LATE'
      when gr.TotalGRQuantity <  item.OrderQuantity
        then 'SHORT'
      when sched.LatestSchedDelivDate is not null
       and gr.LatestGRPostingDate >  sched.LatestSchedDelivDate
        then 'LATE'
      else ''
    end
  as abap.char( 15 ) )                           as DIFOTFailureReason

}
where item.PurchasingDocumentDeletionCode = ''   -- exclude deleted items
