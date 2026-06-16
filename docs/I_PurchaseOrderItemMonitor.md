CDS name:  Purchase Order Item Monitor

CDS Technical Name: I_PurchaseOrderItemMonitor


Purpose
This CDS view is designed to monitor purchase order items by providing detailed information about the quantities and values related to delivery and invoicing. It aggregates data from various associated entities to give a comprehensive overview of the status of purchase order items.

- This CDS view provides the data to answer the following business questions:
- What is the next scheduled delivery date and quantity for a purchase order item?
- How much quantity and value have been delivered for a purchase order item?
- What is the remaining quantity and value to be delivered for a purchase order item?
- How much quantity and value have been invoiced for a purchase order item?
- What is the remaining quantity and value to be invoiced for a purchase order item?
- Is a purchase order item fully delivered and invoiced?

Structure

Important Fields Important fields in this view include the following:

| Field Name                     | Description                   |
|--------------------------------|-------------------------------|
| PurchaseOrder                  | Purchase order                |
| PurchaseOrderItem              | Item number of purchase order |
| PurchaseOrderQuantityUnit      | Unit of measure               |
| DocumentCurrency               | Currency                      |
| ScheduleLineDeliveryDate       | Next schedule line date       |
| ScheduleLineOpenQty            | Next schedule line quantity   |
| GoodsReceiptQty                | Delivered quantity            |
| GoodsReceiptAmountInCoCodeCrcy | Delivered value               |
| StillToBeDeliveredQuantity     | Quantity to be delivered      |
| StillToBeDeliveredValue        | Value to be delivered         |
| InvoiceReceiptQty              | Invoiced quantity             |
| InvoiceReceiptAmount           | Invoiced value                |
| StillToInvoiceQuantity         | Quantity to be invoiced       |
| StillToInvoiceValue            | Value to be invoiced          |
| IsCompleted                    | Fully delivered and invoiced  |
