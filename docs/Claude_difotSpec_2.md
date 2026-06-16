

**Problem Statement**
As a purchasing and supply chain professional responsible for supplier compliance, I need to analyse the DIFOT  of purchase orders items — determining whether each PO item was delivered in full (100% of ordered quantity) and on time (on or before the scheduled delivery date). The solution must proactively call out quantity and date discrepancies per PO item, and allow me to query this on demand through a List report Fiori application

Goals & Metrics
- Schedule Line Compared — Scheduled delivery date and quantity from PO schedule lines are retrieved and compared against actual goods receipts
- DIFOT Status Determined — Each PO item is classified as DIFOT (full + on time), NOT DIFOT (with specific reason: late, short, or both)
- Discrepancies Surfaced — Quantity variance (ordered vs received) and date variance (scheduled vs actual) are explicitly called out
- Instantly determine whether a specific PO item was delivered in full and on time
- Understand the precise nature of any discrepancy (how short, how late)

# Product Requirements Document (PRD)
**Elevator Pitch:**  
Purchasing teams currently have no way to score whether a supplier delivered in full and on time at the PO item level. This solution provides a Fiori list report app that calculates DIFOT status per PO item directly from SAP S/4HANA data — surfacing discrepancies, explaining variances, and enabling data-driven supplier performance conversations.

**Business Need:**  
Existing S/4HANA screens require manual cross-referencing of PO schedule lines and goods receipt history with no automated DIFOT scoring or discrepancy flagging. This creates delays in supplier performance reviews and keeps supplier management reactive rather than proactive.

**Expected Value:**  
- Eliminate manual effort spent cross-referencing PO schedule lines and GR records
- Enable buyers to assess supplier DIFOT performance in seconds, not hours
- Provide a consistent, objective DIFOT score

**Product Objectives (Prioritized):**
1. Accurately calculate DIFOT status (strict: 100% quantity, on or before delivery date) for every queried PO item
2. Clearly explain discrepancies — quantity shortfall, late delivery, or both — with specific figures
3. Aggregate DIFOT performance by supplier, plant, material group, and time period via a visual dashboard

Solution Architecture
- I am using SAP S/4HANA Cloud Public Edition and also using ADT (ABAP Developer tools), so the solution must use these tools.
- I want to create a Fiori application that will provide users with data from an underlying custom CDS and deliver supplier DIFOT (Delivered In Full and On Time) reporting capability.
- The data that will be provided via this custom CDS will be data that pertains to purchase orders, purchase order items, their history and current status.

The custom CDS could be a join between several data sources which I have thus far identified to be as below. I will let you decide which are most pertinent:
Source 1:
This will be purchase order items information. This information will be provided by the CDS I_PurchaseOrderItemAPI01 and the documentation of this CDS is available on the SAP api hub here https://api.sap.com/cdsviews/I_PURCHASEORDERITEMAPI01. The SAP help for this API is here https://help.sap.com/docs/SAP_S4HANA_CLOUD/0e602d466b99490187fcbb30d1dc897c/33192c1211354eed9e40fac66e55fcc1.html?locale=en-US.

Source 2:
This will be purchase order  history information. This information will be provided by the CDS I_PurchaseOrderHistoryAPI01 and the documentation of this CDS is availale on the SAP api hub here https://api.sap.com/cdsviews/I_PURCHASEORDERHISTORYAPI01. The SAP help for this API is here https://help.sap.com/docs/SAP_S4HANA_CLOUD/0e602d466b99490187fcbb30d1dc897c/1c5ef1f414f74b1bba6967346c59c1d6.html?locale=en-US.

Source 3:
This will be the purchase order schedule line  information. This CDS view retrieves schedule line fields corresponding to purchase order items. Schedule line fields are, for example delivery date, start- and end date of performance period, scheduled quantity, and so on. This information will be provided by the CDS I_POSupplierConfirmationAPI01 and the documentation of this CDS is available on the SAP API hub here https://api.sap.com/cdsviews/I_POSUPPLIERCONFIRMATIONAPI01. The SAP help documentation for this CDS is available here https://help.sap.com/docs/SAP_S4HANA_CLOUD/0e602d466b99490187fcbb30d1dc897c/6e52f71dfb5a481b810ce0697708baf2.html?locale=en-US&version=2602.500.

Source 4:
This will be the purchase order supplier confirmation information. Note that not all purchase orders will have supplier confirmation information. This information will be provided by the CDS I_PurOrdScheduleLineAPI01 and the documentation of this CDS is available on the SAP API hub here https://api.sap.com/cdsviews/I_PURORDSCHEDULELINEAPI01. The SAP help documentation for this CDS is available here https://help.sap.com/docs/SAP_S4HANA_CLOUD/0e602d466b99490187fcbb30d1dc897c/46125872c9a345d7b2b32f26c1c164d7.html?locale=en-US&version=2602.500.

Source 5:
This will be purchase order information and is provided by the CDS I_PurchaseOrderAPI01. 

Note that the list of sources I have provided is not exhaustive. If you want to suggest and use better ones, please do so.

Also, I will rely on you to add additional columns to the report where it is worked out the purchase order item was indeed delivered in full and on time. One column should be used to determine if it was delivered in full (i.e quantity delivered - quantity ordered) and another column should be used to determine if the item was delivered on time (i.e delivered on or before the purchase order item requested delivery date)

These data sources can be joined by the fields PurchaseOrder and PurchaseOrderItem.

I want you to give me step by step instructions on what I need to do excactly in either my SAP S/4HANA Cloud Public Edition System or in ADT to produce this application.

I give you full rights to the folder named 'Claude_PO_Difot2' to generate all required files and save the instructions and needed source code to deliver this result. If you require more infomration from to proceed, then tell me.