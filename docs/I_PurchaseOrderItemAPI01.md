**CDS name**:Purchase Order Item

**CDS Technical Name**: I_PurchaseOrderItemAPI01

**Purpose**
This CDS view helps to retrieve the details of items requested with a purchase order. Details are, for example the units of measure, account assignment data, the service performer, and so on.

**Structure**

Important Fields
Important fields in this view include the following:

| Field Name                     | Description                                                    |
|--------------------------------|----------------------------------------------------------------|
| PurchaseOrder                  | Purchase order number                                          |
| PurchaseOrderItem              | Item number of purchase order item                             |
| PurchaseOrderItemUniqueID      | Concatenation of EBELN and EBELP                               |
| PurchaseOrderCategory          | Purchasing document category                                   |
| DocumentCurrency               | Currency key (currency of document)                            |
| PurchasingDocumentDeletionCode | Deletion indicator in purchasing document                      |
| PurchasingDocumentItemOrigin   | Origin of a purchasing document item                           |
| MaterialGroup                  | Material group                                                 |
| Material                       | Material number                                                |
| MaterialType                   | Material type                                                  |
| SupplierMaterialNumber         | Material number used by supplier                               |
| SupplierSubrange               | Supplier subrange                                              |
| ManufacturerPartNmbr           | Manufacturer part number                                       |
| Manufacturer                   | Number of a manufacturer                                       |
| ManufacturerMaterial           | Material number                                                |
| PurchaseOrderItemText          | Short text                                                     |
| ProductType                    | Product type group                                             |
| CompanyCode                    | Company code                                                   |
| Plant                          | Plant                                                          |
| ManualDeliveryAddressID        | Manual address number in purchasing document item              |
| ReferenceDeliveryAddressID     | Number of delivery address                                     |
| Customer                       | Customer                                                       |
| Subcontractor                  | Supplier to be supplied/who is to receive delivery             |
| SupplierIsSubcontractor        | Subcontracting supplier                                        |
| CrossPlantConfigurableProduct  | Cross-plant configurable material                              |
| ArticleCategory                | Material category                                              |
| PlndOrderReplnmtElmntType      | Kanban indicator                                               |
| ProductPurchasePointsQtyUnit   | Points unit                                                    |
| ProductPurchasePointsQty       | Number of points                                               |
| StorageLocation                | Storage location                                               |
| PurchaseOrderQuantityUnit      | Purchase order unit of measure                                 |
| OrderItemQtyToBaseQtyNmrtr     | Numerator for conversion of order unit to base unit            |
| OrderItemQtyToBaseQtyDnmntr    | Denominator for conversion of order unit to base unit          |
| NetPriceQuantity               | Price unit                                                     |
| IsCompletelyDelivered          | Derliver completed indicator                                   |
| IsFinallyInvoiced              | Final invoice indicator                                        |
| GoodsReceiptIsExpected         | Goods receipt indicator                                        |
| InvoiceIsExpected              | Invoice receipt indicator                                      |
| InvoiceIsGoodsReceiptBased     | Indicator: GR-based invoice verification                       |
| PurchaseContractItem           | Item number of principal purchase agreement                    |
| PurchaseContract               | Number of principal purchase agreement                         |
| PurchaseRequisition            | Purchase requisition number                                    |
| RequirementTracking            | Requirement tracking number                                    |
| PurchaseRequisitionItem        | Item number of purchase requisition                            |
| EvaldRcptSettlmntIsAllowed     | Evaluated receipt settlement (ERS)                             |
| UnlimitedOverdeliveryIsAllowed | Unlimited overdelivery allowed                                 |
| OverdelivTolrtdLmtRatioInPct   | Overdelivery tolerance                                         |
| UnderdelivTolrtdLmtRatioInPct  | Underdelivery tolerance                                        |
| RequitionerName                | Name of requisitioner/requester                                |
| PlannedDeliveryDurationInDays  | Planned delivery time in days                                  |
| GoodsReceiptDurationInDays     | Goods receipt processing time                                  |
| PartialDeliveryIsAllowed       | Partial delivery at item level (stock transfer)                |
| ConsumptionPosting             | Consumption posting                                            |
| ServicePerformer               | Service performer                                              |
| BaseUnit                       | Base unit of measure                                           |
| PurchaseOrderItemCategory      | Item category in purchasing document                           |
| ProfitCenter                   | Profit center                                                  |
| OrderPriceUnit                 | Order price unit                                               |
| ItemVolumeUnit                 | Volume unit                                                    |
| ItemWeightUnit                 | Unit of weight                                                 |
| MultipleAcctAssgmtDistribution | Distribution indicator for multiple account assignment         |
| PartialInvoiceDistribution     | Partial invoice indicator                                      |
| PricingDateControl             | Price determination (pricing)                                  |
| IsStatisticalItem              | Item is statistical                                            |
| PurchasingParentItem           | Higher-level item in purchasing documents                      |
| GoodsReceiptLatestCreationDate | Latest possible goods reciept                                  |
| IsReturnsItem                  | Returns item                                                   |
| PurchasingOrderReason          | Reason for orddering                                           |
| IncotermsClassification        | Incoterms (part 1)                                             |
| IncotermsTransferLocation      | Incoterms (part 2)                                             |
| IncotermsLocation1             | Incoterms location 1                                           |
| IncotermsLocation2             | Incoterms location 2                                           |
| PriorSupplier                  | Prior supplier                                                 |
| InternationalArticleNumber     | International article number (EAN/UPC)                         |
| IntrastatServiceCode           | Intrastat service code                                         |
| CommodityCode                  | Comodity code                                                  |
| MaterialFreightGroup           | Material freight group                                         |
| DiscountInKindEligibility      | Material qualifies for discount in kind                        |
| PurgItemIsBlockedForDelivery   | Item blocked for SD delivery                                   |
| SupplierConfirmationControlKey | Confirmation control key                                       |
| PriceIsToBePrinted             | Price printout                                                 |
| AccountAssignmentCategory      | Account assignment category                                    |
| PurchasingInfoRecord           | Purchasing inforecord number                                   |
| NetAmount                      | Net order value in purchase order currency                     |
| GrossAmount                    | Gross order value in purchase order currency                   |
| EffectiveAmount                | Effective value of item                                        |
| Subtotal1Amount                | Subtotal 1 from pricing procedure for pricing element          |
| Subtotal2Amount                | Subtotal 2 from pricing procedure for pricing element          |
| Subtotal3Amount                | Subtotal 3 from pricing procedure for pricing element          |
| Subtotal4Amount                | Subtotal 4 from pricing procedure for pricing element          |
| Subtotal5Amount                | Subtotal 5 from pricing procedure for pricing element          |
| Subtotal6Amount                | Subtotal 6 from pricing procedure for pricing element          |
| OrderQuantity                  | Purchase order quantity                                        |
| NetPriceAmount                 | Net price in purchasing document (in document currency)        |
| ItemVolume                     | Volume                                                         |
| ItemGrossWeight                | Gross weight                                                   |
| ItemNetWeight                  | Net weight                                                     |
| OrderPriceUnitToOrderUnitNmrtr | Numerator for conversion of order price unit into order unit   |
| OrdPriceUnitToOrderUnitDnmntr  | Denominator for conversion of order price unit into order unit |
| GoodsReceiptIsNonValuated      | Goods receipt, non-valuated                                    |
| IsToBeAcceptedAtOrigin         | Acceptance at origin                                           |
| TaxCode                        | Tax on sales/purchases code                                    |
| TaxJurisdiction                | Tax jurisdiction                                               |
| ShippingInstruction            | Shipping instructions                                          |
| ShippingType                   | Shipping type                                                  |
| NonDeductibleInputTaxAmount    | Non-deductible input tax                                       |
| StockType                      | Stock type                                                     |
| ValuationType                  | Valuation type                                                 |
| ValuationCategory              | Valuation category                                             |
| ItemIsRejectedBySupplier       | Rejection indicator                                            |
| PurgDocPriceDate               | Date of price determination                                    |
| PurgDocReleaseOrderQuantity    | Standard release order quantity                                |
| EarmarkedFundsDocument         | Document number for earmarked funds                            |
| EarmarkedFundsDocumentItem     | Earmarked funds: document item                                 |
| PartnerReportedBusinessArea    | Business area reported to the partner                          |
| InventorySpecialStockType      | Special stock indicator                                        |
| DeliveryDocumentType           | Delivery type for returns to supplier                          |
| IssuingStorageLocation         | Issuing storage location for stock transport order             |
| AllocationTable                | Allocation table                                               |
| AllocationTableItem            | Allocation table item                                          |
| RetailPromotion                | Retail promotion                                               |
| DownPaymentType                | Down payment indicator                                         |
| DownPaymentPercentageOfTotAmt  | Down payment percentage                                        |
| DownPaymentAmountDo            | Down payment amount in document currency                       |
| DownPaymentDueDate             | Due date for down payment                                      |
| ExpectedOverallLimitAmount     | Expected value of overall limit                                |
| OverallLimitAmount             | Overall limit                                                  |
| PurContractForOverallLimit     | Purchase contract for enhanced limit                           |
| PurContractItemForOverallLimit | Purchase contract reference Item for enhanced limit item       |
| RequirementSegment             | Requirement segment                                            |
| PurgProdCmplncDngrsGoodsStatus | Dangerous goods status (item)                                  |
| PurgProdCmplncSupplierStatus   | Product compliance supplier check status (item)                |
| PurgProductMarketabilityStatus | Product marketability status (item)                            |
| PurgSafetyDataSheetStatus      | Safety data sheet status (item)                                |
| SubcontrgCompIsRealTmeCnsmd    | Real-time consumption posting of subcontracting components     |
| BR_MaterialOrigin              | Origin of the material                                         |
| BR_MaterialUsage               | Usage of the material                                          |
| BR_CFOPCategory                | Material CFOP category                                         |
| BR_NCM                         | Brazilian NCM Code                                             |
| BR_IsProducedInHouse           | Produced in-house                                              |
