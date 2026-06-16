CDS name:  Supplier Confirmation Data Referring to a Purchase Order

CDS Technical Name: I_POSupplierConfirmationAPI01


Purpose
This CDS view retrieves supplier confirmation data referring to a purchase order, for example the confirmed quantity, the delivery date, and so on.



Structure

Important Fields Important fields in this view include the following:

| Field Name                    | Description                                                |
|-------------------------------|------------------------------------------------------------|
| PurchaseOrder                 | Purchase order number                                      |
| PurchaseOrderItem             | Item number of purchase order                              |
| SequentialNmbrOfSuplrconf     | Sequential number of supplier confirmation                 |
| SupplierConfirmationCategory  | Confirmation category                                      |
| DeliveryDate                  | Delivery date of supplier confirmation                     |
| DelivDateCategory             | Confirmation category                                      |
| DeliveryTime                  | Delivery date time-spot in supplier confirmation           |
| CreationDate                  | Creation date of confirmation                              |
| CreationTime                  | Time at which supplier confirmation was created            |
| ConfirmedQuantity             | Quantity as per supplier confirmation                      |
| MRPRelevantQuantity           | Quantity reduced (MRP)                                     |
| SuplrConfCreationCategory     | Creation indicator: supplier confirmation                  |
| IsDeleted                     | Supplier confirmation deletion indicator                   |
| ConfIsRelevantToMRP           | Indicator: confirmation is relevant to materials planning  |
| SupplierConfirmationExtNumber | Reference document number (for dependencies see long text) |
| DeliveryDocument              | Delivery                                                   |
| DeliveryDocumentItem          | Delivery item                                              |
| ManufacturerPartProfile       | Manufacturer part profile                                  |
| ManufacturerMaterial          | Material number corresponding to manufacturer              |
| NumberOfReminders             | Number of reminders/expediters                             |
| Batch                         | Batch number                                               |
| DeliveryIsInPlant             | Delivery has status: in plant                              |
| HandoverDate                  | Handover date at the handover location                     |
| HandoverTime                  | Handover time at the handover location                     |
| PerformancePeriodStartDate    | Start date for period of performance                       |
| PerformancePeriodEndDate      | End date for period of performance                         |
| ServicePerformer              | Service performer                                          |
| OrderQuantityUnit             | Purchase order unit of measure                             |
| SupplierConfirmation          | Supplier confirmation number                               |
| SupplierConfirmationItem      | Supplier confirmation item                                 |
