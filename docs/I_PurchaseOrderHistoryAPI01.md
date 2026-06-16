CDS name: Purchase Order History

CDS Technical Name: I_PurchaseOrderHistoryAPI01

Purpose
This CDS view helps to retrieve a history of all the transactions that have occurred referring to a purchase order item to date (for example, goods and invoice receipts relating to the item, incurrence of delivery costs, down-payments, and so on).

Structure

Important Fields Important fields in this view include the following:

| Field Name                     | Description                                                     |
|--------------------------------|-----------------------------------------------------------------|
| PurchaseOrder                  | Purchase order number                                           |
| PurchaseOrderItem              | Item number in purchase order                                   |
| AccountAssignmentNumber        | Sequential number of account assignment                         |
| PurchasingHistoryDocumentType  | Transaction /event type, purchase order history                 |
| PurchasingHistoryDocumentYear  | Material document year                                          |
| PurchasingHistoryDocument      | Number of material document                                     |
| PurchasingHistoryDocumentItem  | Item in material document                                       |
| PurchasingHistoryCategory      | Purchase order history category                                 |
| GoodsMovementType              | Movement type (inventory management)                            |
| PostingDatte                   | posting date in the document                                    |
| Currency                       | Currency key (purchase order currency)                          |
| DebitCreditCode                | Debit/credit indicator                                          |
| IsCompletelyDelivered          | Delivery completed indicator                                    |
| ReferenceDocumentFiscalYear    | Fiscal year of a reference document                             |
| ReferenceDocument              | Document number of a reference document                         |
| ReferenceDocumentItem          | Item of a reference document                                    |
| Material                       | Material number                                                 |
| Plant                          | Plant                                                           |
| RvslOfGoodsReceiptIs Allowed   | Reversal of GR allowed for GR-based IV despite invoice          |
| PricingDocument                | Number of the document condition                                |
| TaxCode                        | Tax on sales / purchase code                                    |
| DocumentDate                   | Document date in document                                       |
| InventoryValuationType         | Valuation type                                                  |
| DocumentReferenceID            | Reference document number                                       |
| DeliveryQuantityUnit           | Unit of measure from delivery note                              |
| ManufacturerMaterial           | Material number                                                 |
| AccountingDocumentCreationDate | Day on which accounting document was entered                    |
| PurgHistDocumentCreationTime   | Time of entry                                                   |
| Quantity                       | Quantity                                                        |
| PurOrdAmountInCompanyCodeCrcy  | Amount in local currency                                        |
| PurchaseOrderAmount            | Amount in document currency                                     |
| QtyInPurchaseOrderPriceUnit    | Quantity in purchase order price unit                           |
| GRIRAcctClrgAmtInCoCodeCrcy    | GR/IR account clearing value in local currency                  |
| GdsRcptBlkdStkQtyInOrdQtyUnit  | Goods receipt blocked stock in order unit                       |
| GdsRcptBlkdStkQtyInOrdPrcUnit  | Quantity in GR blocked stock in order price unit                |
| InvoiceAmtInCocodeCrcy         | Invoice value entered (in local currency)                       |
| ShipgInstrnSupplierCompliance  | Compliance with shipping instructions                           |
| InvoiceAmountInFrgnCurrency    | Invoice value in foreign currency                               |
| QuantityInDeliveryQtyUnit      | Quantity in unit of measure from delivery note                  |
| GRIRAcctClrgAmtInTransacCrcy   | Clearing value on GR/IR clearing account (transactual currency) |
| QuantityInBaseUnit             | Quantity                                                        |
| Batch                          | Batch number                                                    |
| GRIRAcctClrgAmtInOrdTrnsacCrcy | Clearing value on GR/IR account in purchase order currency      |
| InvoiceAmtInPurOrdTransacCrcy  | Invoice amount in purchase order currency                       |
| VltdGdsRcptBlkdStkQtyInOrdUnit | Valuated goods receipt blocked stock in order unit              |
| VltdGdsRcptBlkdQtyInOrdPrcUnit | Quantity in valuated GR blocked stock in order price unit       |
| IsToBeAcceptedAtOrigin         | Acceptance At Origin                                            |
| ExchangeRateDifferenceAmount   | Exchange rate difference amount                                 |
| ExchangeRate                   | Exchange rate                                                   |
| DeliveryDocument               | Delivery                                                        |
| DeliveryDocumentItem           | Delivery item                                                   |
| OrderPriceUnit                 | Order price unit (purchasing)                                   |
| PurchaseOrderQuantiyUnit       | Purchase order unit of measure                                  |
| BaseUnit                       | Base unit of measure                                            |
| DocumentCurrency               | Currency key (document currency)                                |
| CompanyCodeCurrency            | Currency key (local -company code-currency)                     |
