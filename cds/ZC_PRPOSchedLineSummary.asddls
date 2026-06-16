@AbapCatalog.sqlViewName: 'ZV_PRPOSCHLSUMM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Schedule Line Summary'

/*
  Aggregates schedule line data per PO item.
  A PO item can have multiple schedule lines (e.g. split deliveries).
  We take:
    - SUM of ScheduleLineOrderQuantity  → total ordered/scheduled quantity
    - MIN of ScheduleLineDeliveryDate   → earliest (first expected) delivery date
    - MAX of ScheduleLineDeliveryDate   → latest expected delivery date
  For DIFOT purposes the spec compares against the schedule line delivery
  date.  Where multiple lines exist we use the LATEST date as the
  "deadline" — a delivery is on time if it arrives by the latest scheduled
  line date (conservative approach that avoids false failures on split
  deliveries).
*/
define view ZC_PRPOSchedLineSummary
  as select from I_PurOrdScheduleLineAPI01
{
  key PurchaseOrder,
  key PurchaseOrderItem,

      @EndUserText.label: 'Total Scheduled Quantity'
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      sum( ScheduleLineOrderQuantity )     as TotalScheduledQuantity,

      @EndUserText.label: 'PO Quantity Unit'
      max( PurchaseOrderQuantityUnit )     as PurchaseOrderQuantityUnit,

      @EndUserText.label: 'Earliest Scheduled Delivery Date'
      min( ScheduleLineDeliveryDate )      as EarliestSchedDelivDate,

      @EndUserText.label: 'Latest Scheduled Delivery Date'
      max( ScheduleLineDeliveryDate )      as LatestSchedDelivDate,

      @EndUserText.label: 'Number of Schedule Lines'
      count(*)                             as NumberOfScheduleLines

} group by PurchaseOrder, PurchaseOrderItem
