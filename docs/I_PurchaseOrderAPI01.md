CDS name: Purchase Order

CDS Technical Name: I_PurchaseOrderAPI01

Purpose
This CDS view helps to retrieve the fields of a purchase order regarding the request or instruction from a purchasing organization to a vendor or a plant to supply a certain quantity of goods or services at or by a certain point in time.


Structure

Important Fields Important fields in this view include the following:

| Field Name                     | Description                                                           |
|--------------------------------|-----------------------------------------------------------------------|
| PurchaseOrder                  | Purchase order number                                                 |
| PurchaseOrderType              | Purchasing document type                                              |
| PurchaseOrderSubtype           | Control indicator for purchasing document type                        |
| PurchasingDocumentOrigin       | Status of purchasing document                                         |
| CreatedByUser                  | User of person who created a purchasing document                      |
| CreationDate                   | Creation date of purchasing document                                  |
| PurchaseOrderDate              | Purchase order date                                                   |
| Language                       | Language key                                                          |
| CorrespncExternalReference     | Your reference                                                        |
| CorrespncInternalReference     | Our reference                                                         |
| PurchasingDocumentDeletionCode | Purchase order deletion code                                          |
| ReleaseIsNotCompleted          | Release not yet completely effected                                   |
| PurchasingCompletenessStatus   | Purchase order not yet complete                                       |
| Purchasing ProcessingStatus    | Purchasing document processing state                                  |
| PurgReleaseSequenceStatus      | Release status                                                        |
| ReleaseCode                    | Release indicator: purchasing document                                |
| CompanyCode                    | Company code                                                          |
| PurchasingOrganization         | Purchasing organization                                               |
| PurchasingGroup                | Purchasing group                                                      |
| Supplier                       | Supplier                                                              |
| ManualSupplierAddressID        | Address number                                                        |
| SupplierRespSalesPersonName    | Responsible salesperson at supplier's office                          |
| SupplierPhoneNumber            | Supplier's phone number                                               |
| SupplyingSupplier              | Goods supplier                                                        |
| SupplyingPlant                 | Supplying (issuing) plant in stock transport order                    |
| InvoicingParty                 | Different invoicig party                                              |
| Customer                       | Customer number                                                       |
| SupplierQuotationExternalID    | Quotation number                                                      |
| PaymentTerms                   | Terms of payment key                                                  |
| CashDiscount1Days              | Cash discount days 1                                                  |
| CashDiscount2Days              | Cash discount days 2                                                  |
| NetPaymentDays                 | Net payment terms period                                              |
| CashDiscount1Percent           | Cash discount percentage 1                                            |
| CashDiscount2Percent           | Cash Discount percentage 2                                            |
| DownPaymentType                | Down payment indicator                                                |
| DownPaymentPercentageOfTotAmt  | Down payment percentage                                               |
| DownPaymentAmount              | Down payment amount in document currency                              |
| DownPaymentDueDate             | Due date for down payment                                             |
| IncotermsClassification        | Incoterms (Part 1)                                                    |
| IncotermsTransferLocation      | Incoterms (Part 2)                                                    |
| IncotermsVersion               | Incoterms version                                                     |
| IncotermsLocation1             | Incoterms location 1                                                  |
| IncotermsLocation2             | Incoterms location 2                                                  |
| IsIntrastatReportingRelevant   | Relevant for intrastat reporting                                      |
| IsIntrastatReportingExcluded   | Exclude from intrastat reporting                                      |
| PricingDocument                | Number of the document condition                                      |
| PricingProcedure               | Procedure (pricing, output control, account det., costing, and so on) |
| DocumentCurrency               | Currency key (currency of the document)                               |
| ValidityStartDate              | Start of validity period                                              |
| ValidityEndDate                | End of validity period                                                |
| ExchangeRate                   | Exchange rate                                                         |
| ExchangeRateIsFixed            | Indicator for fixed exchange rate                                     |
| LastChangeDateTime             | Change time stamp                                                     |
| TaxReturnCountry               | Country/region for tax report                                         |
| VATRegistration                | VAT registration number                                               |
| VATRegistrationCountry         | Country / region of sales tax ID number                               |
| PurgReasonForDocCancellation   | Reason for cancellation                                               |
| PurgReleaseTimeTotalAmount     | Total value at time of release                                        |
| PurgAggrgdProdCmplncSuplrSts   | Product compliance supplier check status (all items)                  |
| PurgAggrgdProdMarketabilitySts | Product marketability status (all items)                              |
| PurgAggrgdSftyDataSheetStatus  | Safety data sheet status (all items)                                  |
| PurgProdCmplncTotDngrsGoodsSts | Dangerous goods status (all items)                                    |
