@AbapCatalog.sqlViewName: 'ZV_PRPOITGRSUMM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item GR Quantity Summary'

/*
  Aggregates all valid goods receipt (GoodsMovementType 101) quantities
  per PO item from the PO history view.  Only non-reversal GR lines are
  summed; reversal movements (102) are excluded here because the history
  view already records them with negative quantities when they share the
  same DebitCreditCode 'H'.  Using SUM(Quantity) with DebitCreditCode
  filtering gives the net received quantity in purchase-order UoM.
*/
define view ZC_PRPOItemGRSummary
  as select from I_PurchaseOrderHistoryAPI01
{
  key PurchaseOrder,
  key PurchaseOrderItem,

      @EndUserText.label: 'Total GR Quantity (PO UoM)'
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      sum( case DebitCreditCode
             when 'S' then Quantity   -- debit = goods receipt
             when 'H' then -Quantity  -- credit = reversal
             else 0
           end ) as TotalGRQuantity,

      @EndUserText.label: 'PO Quantity Unit'
      max( PurchaseOrderQuantityUnit )    as PurchaseOrderQuantityUnit,

      @EndUserText.label: 'Latest GR Posting Date'
      max( PostingDate )                  as LatestGRPostingDate,

      @EndUserText.label: 'First GR Posting Date'
      min( case DebitCreditCode when 'S' then PostingDate end ) as FirstGRPostingDate

} where PurchasingHistoryCategory = 'E'   -- E = goods receipt category
    and ( GoodsMovementType = '101' or GoodsMovementType = '102' )
group by PurchaseOrder, PurchaseOrderItem
