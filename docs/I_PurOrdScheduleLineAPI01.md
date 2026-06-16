CDS name:Schedule Line in Purchase Order

CDS Technical Name: I_PurOrdScheduleLineAPI01

Purpose
This CDS view retrieves schedule line fields corresponding to purchase order items. Schedule line fields are, for example delivery date, start- and end date of performance period, scheduled quantity, and so on.

Structure

Important Fields Important fields in this view include the following:

| Field Name                     | Description                                                        |
|--------------------------------|--------------------------------------------------------------------|
| PurchaseOrder                  | Purchase order number                                              |
| PurchaseOrderItem              | Item number in purchase order                                      |
| PurchaseOrderScheduleLine      | Delivery schedule line counter                                     |
| PerformancePeriodStartDate     | Start date for period of performance                               |
| PerformancePeriodEndDate       | End date for period of performance                                 |
| DelivDateCategory              | Category of delivery date                                          |
| ScheduleLineDeliveryDate       | Item delivery date                                                 |
| SchedLineStscDeliveryDate      | Statistics-relevant delivery date                                  |
| ScheduleLineDeliveryTime       | Delivery date time-spot                                            |
| ScheduleLineOrderQuantity      | Scheduled quantity                                                 |
| RoughGoodsReceipQty            | Quantity of goods received                                         |
| PurchaseOrderQuantityUnit      | Purchase order unit of measure                                     |
| PurchaseRequisition            | Purchase requisition number                                        |
| PurchaseRequisitionItem        | Item number of purchase requisition                                |
| SourceOfCreation               | Creation indicator (purchase requisition/schedule lines)           |
| PrevDelivQtyOfScheduleLine     | Previous quantity (delivery schedule lines)                        |
| NoOfRemindersOfScheduleLine    | Number of reminders/expediters for schedule line                   |
| ScheduleLineIsFixed            | Schedule line is fixed                                             |
| ScheduleLineCommittedQuantity  | Commited quantity                                                  |
| Reservation                    | Number of reservation/dependent requirements                       |
| ProductAvailabilityDate        | Material staging/availability date                                 |
| MaterialStagingTime            | Material staging time (local, relating to a plant)                 |
| TransportationPlanningDate     | Transportation planning date                                       |
| TransportationPlanningTime     | Transportation planning time (local, relating to a shipping point) |
| LoadingDate                    | Loading date                                                       |
| LoadingTime                    | Loading time (local time relating to a shipping point              |
| GoodsIssueDate                 | Goods issue date                                                   |
| GoodsIssueTime                 | Time of goods issue (local, relating to a plant)                   |
| STOLatestPossibleGRDate        | Goods receipt end date                                             |
| STOLatestPossibleGRTime        | Goods receipt end time (local, relating to a plant)                |
| StockTransferDeliveredQuantity | Quantity delivered (stock Transfer)                                |
| ScheduleLineIssuedQuantity     | Issued quantity                                                    |
| Batch                          | Batch number                                                       |
