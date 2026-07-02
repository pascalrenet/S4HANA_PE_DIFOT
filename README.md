# PO DIFOT Fiori List Report — Step-by-Step Implementation Guide

## Foreword
Use at Your Own Risk. You acknowledge and agree that your use of this software is entirely at your own risk. We do not guarantee that the software will be error-free, secure, or uninterrupted. We shall not be responsible or liable for any data loss, system damage, or financial costs arising from the use of this software.

## Overview

This guide walks you through building a Fiori List Report that scores every purchase order item for **DIFOT** (Delivered In Full, On Time) status directly in SAP S/4HANA Cloud Public Edition.

### Architecture at a Glance

```
I_PurchaseOrderItemAPI01    ──┐
I_PurchaseOrderAPI01         ─┤
I_PurOrdScheduleLineAPI01    ─┼──► ZC_PRPOSchedLineSummary  ──┐
I_PurchaseOrderHistoryAPI01  ─┼──► ZC_PRPOItemGRSummary     ──┼──► ZC_PRPODIFOT ──► ZC_PRPODIFOT_C ──► OData V4 ──► Fiori App
                              ┘   ZC_PRPOGRHistoryLines ───────┘     (core calc)   (UI annotations)
                                                                                          │
I_POSupplierConfirmationAPI01 ──► ZC_PRPOSuppConfLines ───────────────────────────────────┘
```

### File Reference

| File | Location | Description |
|---|---|---|
| `ZC_PRPOItemGRSummary.asddls` | `cds/` | Aggregates net GR quantity per PO item from purchase order history |
| `ZC_PRPOSchedLineSummary.asddls` | `cds/` | Aggregates scheduled quantity and delivery dates from schedule lines |
| `ZC_PRPODIFOT.asddls` | `cds/` | Joins all sources; calculates DIFOT status, flags, variances |
| `ZC_PRPOGRHistoryLines.asddls` | `cds/` | Individual GR lines — navigation target for the Object Page drill-down; must exist before `ZC_PRPODIFOT_C` |
| `ZC_PRPODIFOTStatusVH.asddls` | `cds/` | Fixed-value value help for the DIFOT Status filter field (four values: DIFOT, NOT DIFOT, OVERDUE, PENDING) |
| `ZC_PRPODIFOTFailReasonVH.asddls` | `cds/` | Fixed-value value help for the Failure Reason filter field (four values: blank, SHORT, LATE, SHORT AND LATE) |
| `ZC_PRPODIFOT_C.asddls` | `cds/` | Consumption view with Fiori/OData UI annotations |
| `ZC_PRPOSuppConfLines.asddls` | `cds/` | Individual supplier confirmation lines — navigation target for the Object Page Supplier Confirmation Lines section |
| `ZC_PRPODIFOT_SRV.asdefs` | `service/` | Service definition — exposes `ZC_PRPODIFOT_C` as an OData V4 service |

### Folder Structure

```
project root/
├── README.md          ← this file
├── cds/                     ← all CDS Data Definition (.asddls) files
│   ├── ZC_PRPOItemGRSummary.asddls
│   ├── ZC_PRPOSchedLineSummary.asddls
│   ├── ZC_PRPODIFOT.asddls
│   ├── ZC_PRPOGRHistoryLines.asddls
│   ├── ZC_PRPODIFOTStatusVH.asddls
│   ├── ZC_PRPODIFOTFailReasonVH.asddls
│   ├── ZC_PRPODIFOT_C.asddls
│   └── ZC_PRPOSuppConfLines.asddls        
└──  service/                 ← service definition (.asdefs) file
    └── ZC_PRPODIFOT_SRV.asdefs

```

---

## Changes

### 2 July 2026

**Filter bar reduction**
Removed the following fields from the default Smart Filter Bar (they remain available via *Adapt Filters*):
- Purchase Order Item
- Purchase Order Type
- Purchasing Group
- Plant
- Material Group

**New DIFOT status: OVERDUE**
A fourth DIFOT status value has been introduced to distinguish PO items that are past their scheduled delivery date with no goods receipt posted yet. Changes were made to three files:
- `ZC_PRPODIFOT.asddls` — updated `DIFOTStatus` calculation logic (see *DIFOT Status Determination Logic* below)
- `ZC_PRPODIFOTStatusVH.asddls` — added `OVERDUE` as a fourth value help entry
- `ZC_PRPODIFOT_C.asddls` — added `OVERDUE` to the criticality mapping (displayed in red)

**Bug fix: fully-reversed goods receipts**
A PO item where a goods receipt (movement 101) has been fully cancelled by a reversal (movement 102) results in a net GR quantity of zero. The original logic only tested for `null` to detect "no GR", so net-zero items were incorrectly classified and displayed misleading field values. The following corrections were made:

- `ZC_PRPOItemGRSummary.asddls` — `LatestGRPostingDate` now only considers receipt movements (`DebitCreditCode = 'S'`), excluding reversal posting dates
- `ZC_PRPODIFOT.asddls` — all "no GR" conditions now treat net GR quantity of zero the same as null:
  - `DIFOTStatus` — correctly classifies net-zero items as OVERDUE or PENDING
  - `DIFOTFailureReason` — returns blank for net-zero items
  - `IsDeliveredInFull` — returns blank for net-zero items
  - `IsDeliveredOnTime` — returns blank for net-zero items
  - `FirstGRPostingDate` — returns blank (`00000000`) for net-zero items
  - `LatestGRPostingDate` — returns blank (`00000000`) for net-zero items
  - `QuantityVariance` — returns `0` for net-zero items
  - `DateVarianceInDays` — returns `0` for net-zero items

---

## DIFOT Status Determination Logic

The `DIFOTStatus` field is a calculated field derived at query time in `ZC_PRPODIFOT.asddls`. It is based on three inputs:

- **`TotalGRQuantity`** — the net goods receipt quantity posted against the PO item to date (from `ZC_PRPOItemGRSummary`). This is the net of all receipts (movement 101) minus all reversals (movement 102). A fully reversed GR results in a net quantity of zero and is treated the same as no GR at all.
- **`OrderQuantity`** — the ordered quantity on the PO item
- **`LatestSchedDelivDate`** — the latest scheduled delivery date across all schedule lines for the PO item (from `ZC_PRPOSchedLineSummary`). This is the PO schedule date — **not** the actual goods receipt date.

The logic evaluates the four statuses in the following order of precedence:

---

### DIFOT — green

> The supplier has delivered in full and on time.

**Conditions:**
- Net `TotalGRQuantity >= OrderQuantity` (full quantity received), **AND**
- Either no schedule line exists (`LatestSchedDelivDate` is null), **OR** the latest GR posting date is on or before the scheduled delivery date (`LatestGRPostingDate <= LatestSchedDelivDate`)

---

### NOT DIFOT — red

> A net positive goods receipt exists but the delivery has failed — either short, late, or both.

**Conditions:**
- Net `TotalGRQuantity > 0` (at least some quantity has been received and not fully reversed), **AND**
- The received quantity is less than ordered, or the GR was posted after the scheduled delivery date

This status also captures partial deliveries where the scheduled delivery date has already passed and the supplier can no longer complete the delivery on time.

The `DIFOTFailureReason` field provides further detail:

| Failure Reason | Meaning |
|---|---|
| `SHORT` | Quantity received is less than ordered, but delivery was on time |
| `LATE` | Full quantity received, but after the scheduled delivery date |
| `SHORT AND LATE` | Both short and late |
| *(blank)* | No failure — status is DIFOT, PENDING, or OVERDUE |

---

### OVERDUE — red

> The scheduled delivery date has passed and no net goods receipt exists.

**Conditions:**
- Net `TotalGRQuantity` is null or zero (no GR posted, or all GRs have been fully reversed), **AND**
- `LatestSchedDelivDate` is not null, **AND**
- `LatestSchedDelivDate < TODAY` (the delivery window has closed)

This is distinct from NOT DIFOT in that no net quantity has been received at all. A fully reversed GR is treated the same as no GR.

When a line is OVERDUE, the following fields are intentionally left blank as no meaningful delivery data exists: `FirstGRPostingDate`, `LatestGRPostingDate`, `QuantityVariance`, `DateVarianceInDays`, `IsDeliveredInFull`, `IsDeliveredOnTime`.

---

### PENDING — orange

> No net goods receipt yet, but the delivery window is still open.

**Conditions:**
- Net `TotalGRQuantity` is null or zero (no GR, fully reversed GR, or partial GR not yet exceeding ordered qty), **AND**
- `LatestSchedDelivDate >= TODAY` (the scheduled delivery date is today or in the future), **OR** no schedule line exists

This status applies to items with no GR at all, fully reversed GRs, and partial GRs, as long as the supplier still has time to complete the delivery. Once the scheduled date passes, the status transitions to OVERDUE (net zero GR) or NOT DIFOT (partial GR).

---

### Summary Table

| Net GR Qty | Qty >= Ordered? | Sched. Date vs Today | Status |
|---|---|---|---|
| > 0 (full) | Yes | On time or no sched. date | **DIFOT** |
| > 0 (full) | Yes | Late | **NOT DIFOT** |
| > 0 (partial) | No | Past or any | **NOT DIFOT** |
| > 0 (partial) | No | Future | **PENDING** |
| Zero or null | — | Future or no sched. date | **PENDING** |
| Zero or null | — | Past | **OVERDUE** |

---

## Prerequisites

- ADT (ABAP Developer Tools) installed in Eclipse and connected to your S/4HANA Cloud Public Edition system
- A custom package in your system (e.g. `ZPURCHASING` or similar — if you do not have one, create it in Step 1 below)
- Your user has the developer role (e.g. `SAP_BR_DEVELOPER`)
- The standard CDS views `I_PurchaseOrderItemAPI01`, `I_PurchaseOrderAPI01`, `I_PurOrdScheduleLineAPI01`, `I_PurchaseOrderHistoryAPI01`, and `I_POSupplierConfirmationAPI01` exist in your system (they are delivered with S/4HANA Cloud Public Edition).

---

## Step 1 — Create a Custom Package (if needed)

1. In ADT, open the **ABAP Repository** perspective.
2. Right-click your system node → **New → ABAP Package**.
3. Set:
   - **Name**: `ZPURCHASING` (or your preferred name — use it consistently throughout this guide)
   - **Description**: `Supplier DIFOT development`
   - **Superpackage**: `Your own predefined Superpackage`
4. Assign it to a transport request when prompted, if not a LOCAL development.
5. Click **Finish**.

---

## Step 2 — Create CDS View `ZC_PRPOItemGRSummary`

This view aggregates net goods receipt quantities per PO item.

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPOITEMGRSUMMARY`
   - **Description**: `PO Item GR Quantity Summary`
4. Click **Next**, assign the transport request , if development is not LOCAL→ **Finish**.
5. ADT opens the editor. **Replace the entire content** with the code from `cds/ZC_PRPOItemGRSummary.asddls`.
6. Press **Ctrl+S** to save, then click **Activate** (the icon that looks like a match).
7. Verify it activates without errors in the **Problems** view.

> **Key points about this view:**
> - Filters on `PurchasingHistoryCategory = 'E'` (goods receipts only)
> - Filters on movement types `101` (GR) and `102` (GR reversal)
> - Uses `DebitCreditCode` to net off reversals (`S` = debit/receipt, `H` = credit/reversal)
> - Produces `TotalGRQuantity`, `FirstGRPostingDate`, `LatestGRPostingDate` per PO item

---

## Step 3 — Create CDS View `ZC_PRPOSchedLineSummary`

This view aggregates schedule line data per PO item.

1. Repeat the "New → Data Definition" steps as in Step 2.
2. Set:
   - **Name**: `ZC_PRPOSCHEDLINESUMM`
   - **Description**: `PO Item Schedule Line Summary`
3. Replace the content with the code from `cds/ZC_PRPOSchedLineSummary.asddls`.
4. Save and **Activate**.

> **Key points:**
> - Aggregates `TotalScheduledQuantity`, `EarliestSchedDelivDate`, `LatestSchedDelivDate`
> - For DIFOT date comparison we use `LatestSchedDelivDate` as the deadline — a delivery arriving before or on the latest scheduled line date is considered on time

---

### Step 4 — Create CDS View `ZC_PRPOGRHistoryLines`

This view reads individual (non-aggregated) goods receipt and reversal lines from `I_PurchaseOrderHistoryAPI01`.

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPOGRHISTORYLINES`
   - **Description**: `PO Item GR History Lines`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPOGRHistoryLines.asddls`.
6. Press **Ctrl+S** to save, then **Activate**.

### Step 5 — Create CDS View `ZC_PRPOSuppConfLines`

This view reads individual supplier confirmation lines from `I_POSupplierConfirmationAPI01`. It shows all active (non-deleted) confirmation records for a PO item on the Object Page, in a dedicated **Supplier Confirmation Lines** section below the Goods Receipt Lines section. All confirmation categories are shown (no category filter is applied in this view).

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPOSUPPCONFLINES`
   - **Description**: `PO Item Supplier Confirmation Lines`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPOSuppConfLines.asddls`.
6. Press **Ctrl+S** to save, then **Activate**.

> **Key points about this view:**
> - Filters `IsDeleted = ''` — deleted confirmations are hidden
> - One row per confirmation line (no aggregation) — keyed by `PurchaseOrder`, `PurchaseOrderItem`, and `SequentialNmbrOfSuplrconf`
> - Shows: Category, Seq. No., Delivery Date, Confirmed Qty, Unit, Created On


---

## Step 6 — Create CDS Value Help Views

These two small views provide fixed-value lists for the **DIFOT Status** and **Failure Reason** filter fields in the Smart Filter Bar. Both are custom calculated fields so we give it a value help.

### 6a — Create `ZC_PRPODIFOTStatusVH`

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOTSTATUSVH`
   - **Description**: `DIFOT Status Value Help`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPODIFOTStatusVH.asddls`.
6. Press **Ctrl+S** to save, then **Activate**. 

### 6b — Create `ZC_PRPODIFOTFailReasonVH`

1. Repeat the "New → Data Definition" steps above.
2. Set:
   - **Name**: `ZC_PRPODIFOTFAILRSNVH`
   - **Description**: `DIFOT Failure Reason Value Help`
3. **Replace the entire content** with the code from `cds/ZC_PRPODIFOTFailReasonVH.asddls`.
4. Save and **Activate**.


---

## Step 7 — Create CDS View `ZC_PRPODIFOT`

This is the core DIFOT calculation view. It joins the two aggregation views with PO item and PO header data.


1. Create a new **Data Definition** named `ZC_PRPODIFOT`.
   - **Description**: `PO DIFOT - Delivered In Full and On Time`
2. Replace the content with the code from `cds/ZC_PRPODIFOT.asddls`.
3. Save and **Activate**.

> **DIFOT Logic Summary:**
>
> | Field | Logic |
> |---|---|
> | `QuantityVariance` | `TotalGRQuantity − OrderQuantity` (negative = short) |
> | `DateVarianceInDays` | `LatestGRPostingDate − LatestSchedDelivDate` in days (positive = late) |
> | `IsDeliveredInFull` | `'X'` if `TotalGRQuantity >= OrderQuantity` |
> | `IsDeliveredOnTime` | `'X'` if `LatestGRPostingDate <= LatestSchedDelivDate` |
> | `DIFOTStatus` | `'DIFOT'` / `'NOT DIFOT'` / `'OVERDUE'` / `'PENDING'` (no GR yet, window open) |
> | `DIFOTFailureReason` | `'SHORT'` / `'LATE'` / `'SHORT AND LATE'` / `''` |

---

## Step 8 — Create CDS Consumption View `ZC_PRPODIFOT_C`

This view adds Fiori UI annotations and declares navigation associations to `ZC_PRPOGRHistoryLines` and `ZC_PRPOSuppConfLines` for the Object Page drill-down sections. OData service exposure is handled in Step 8 via an explicit service definition and binding.

This view now declares two navigation associations and two corresponding Object Page line-item facets:
- **Goods Receipt Lines** (position 40) — navigates to `ZC_PRPOGRHistoryLines`
- **Supplier Confirmation Lines** (position 50) — navigates to `ZC_PRPOSuppConfLines`

The three supplier confirmation fields that were previously shown in the **Schedule & GR** field group (`ConfirmedQuantity`, `SupplierConfirmedDelivDate`, `SupplierConfirmationCategory`) have been removed. Confirmation data is now exclusively visible in the **Supplier Confirmation Lines** table section on the Object Page.

1. Create a new **Data Definition** named `ZC_PRPODIFOT_C`.
   - **Description**: `PO DIFOT List Report`
2. Replace the content with the code from `cds/ZC_PRPODIFOT_C.asddls`.
3. Save and **Activate**.


---

## Step 9 — Create Service Definition and Service Binding (OData V4)

S/4HANA Cloud Public Edition requires an explicit service definition and binding to expose a CDS view as an OData service.

### 9a — Create the Service Definition

1. In ADT, right-click your package → **New → Other ABAP Repository Object**.
2. Under **Business Services**, select **Service Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_SRV`
   - **Description**: `PO DIFOT OData Service Definition`
4. Click **Next**, assign the transport request → **Finish**.
5. Replace the content with the code from `service/ZC_PRPODIFOT_SRV.asdefs`.
   The service definition now exposes three entity sets: `PODIFOTItem` (main list), `POGRHistoryLine` (GR detail navigation), and `POSuppConfLine` (supplier confirmation detail navigation).
6. Save and **Activate**.

### 9b — Create the Service Binding (OData V4)

1. Right-click the package again → **New → Other ABAP Repository Object** → **Service Binding** → **Next**.
2. Set:
   - **Name**: `ZC_PRPODIFOT_UI_V4`
   - **Description**: `PO DIFOT OData V4 Service Binding`
   - **Binding Type**: `OData V4 - UI`
   - **Service Definition**: `ZC_PRPODIFOT_SRV`
3. Click **Next**, assign the transport request → **Finish**.
4. Click **Activate**.
5. In the Service Binding editor, click **Publish** Local Service Endpoint.


---
## Step 10 — Create the Fiori App

To create the Fiori app per se, you can either use ADT itself, or you can use SAP BAS (Business Application Studio)

### Step 10a — If you are using ADT
I suggest the following resources:
- [Quickly Generate and Deploy SAP Fiori Apps from ABAP Development Tools for Eclipse](https://community.sap.com/t5/application-development-and-automation-blog-posts/quickly-generate-and-deploy-sap-fiori-apps-from-abap-development-tools-for/ba-p/14116822)
- [Creating SAP Fiori App Using Quick Fiori Application Generator](https://help.sap.com/docs/abap-cloud/abap-development-tools-user-guide/creating-sap-fiori-app-using-quick-fiori-application-generator?locale=en-US)

1. Open the Service Binding `ZC_PRPODIFOT_UI_V4` you create in step 8b
2. In the right pane `Service Version Details`, locate the button `Create a SAP Fiori Application` and click it
![Quick Create Fiori Application](imagery/createFioriApp.png)
3. Select the option `Create SAP Fiori app with Quick Fiori Application generator in ADT` and click **Create**
![Quick Create in ADT](imagery/quickCreate.png)
4. Enter the details required to generate the object
   - **Package**: `ZPURCHASING`
   - **Referenced Object**: The service Binding `ZC_PRPODIFOT_UI_V4`
5. Click **Next**
6. Enter the Generator details as in the image below
![Generator](imagery/generatorDetails.png)
7. View ABAP Artifacts Generation List 
![Generator](imagery/abapArtifacts.png)
8. Click **Next**, assign the transport request → **Finish**.
9. You should receive a success generation message
![Generator](imagery/appSuccess.png)
10. This will update the Fiori App URL in the service Binding
![Generator](imagery/fioriAppUrl.png)


### Step 10b — If you are using BAS (SAP Business Application Studio)
I suggest you follow the Developer learning journey and follow the tutorial [Develop a Custom UI for an SAP S/4HANA Cloud System](https://developers.sap.com/tutorials/abap-custom-ui-bas-develop-s4hc.html). You also have this Developer tutorial that will show you how to create a Destination in BTP to connect to your SAP S/4HANA Cloud system [Connect SAP Business Application Studio and SAP S/4HANA Cloud System](https://developers.sap.com/tutorials/abap-custom-ui-bas-connect-s4hc.html).

This path I will not elaborate on, as the above tutorials are quite explicit.


## Step 11 — Create the IAM App and Business Catalog in ADT

You must create an IAM App (which links the Fiori UI to the OData service) and a Business Catalog (which groups apps for role assignment) in ADT.

### Step 11a — Create the IAM App

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Identity and Access Management**, select **IAM App** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_TILE`
   - **Description**: `PO Item DIFOT`
   - **Application Type**: `External App`
![Create IAM App](imagery/appTile.png)
4. Click **Next**, assign the transport request → **Finish**.
5. In the IAM App editor, **Overview** tab:
   - **Fiori Launchpad App Descr Item ID**: `ZPODIFOT_UI5R` enter the UIAD object name created during the deployment — this is `ZPODIFOT_UI5R` (check in ADT under your package → Fiori User Interface → Launchpad App Descriptor Items if unsure)
![App Descriptor](imagery/appDescriptor.png)
6. Go to the **Services** tab → **Add**:
   - **Service Type**: `OData V4`
   - **Service Name**: `ZC_PRPODIFOT_UI_V4` *(technical name from your service binding editor)*
7. **Save** and .
8. Click **Publish Locally**.

### Step 11b — Create the Business Catalog

1. Right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Cloud Identity and Access Management**, select **Business Catalog** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_BC`
   - **Description**: `PO Item DIFOT`
4. Click **Next**, assign the transport request → **Finish**.
5. In the Business Catalog editor, go to the **Apps** tab → **Add** → select `ZC_PRPODIFOT_TILE_EXT`.
4. Click **Next**, assign the transport request → **Finish**.
7. Click **Publish Locally**.
--> You could also here in the 'Restirction Types' tab add authorisation restrictions


### Step 12 — Assign the Catalog to a Business Role (in the Launchpad)

1. Open your Fiori Launchpad and launch the **Maintain Business Roles** app.
2. Create a new role (e.g. name `ZBR_PR_PODIFOT_USER`, description `PO DIFOT Reporting`) or open an existing procurement role you want to add the app to.
3. Go to **Assigned Business Catalogs** → **Add** → search for `ZC_PRPODIFOT_BC` and add it.
4. Under **Access Categories**, ensure at minimum **Read** and **Value Help** are granted.
5. **Save**.

---

### Step 13 — Assign the Role to your User (in the Launchpad)

1. Launch the **Maintain Business Users** app.
2. Find your user → **Assigned Business Roles** → **Add** → select the role from Stage 3.
3. **Save**.
4. Refresh your browser to reload the business role.

---

### Step 14 — Pin the Tile to your Home Page

I would suggest you create a dedidcated Fiori Launchpad Space and Page


1. On the Launchpad home page, click the **pencil (Edit)** icon.
2. Click **App Finder**.
3. Search for `DIFOT` or `PO DIFOT` — the app should appear listed under the IAM App description `PO DIFOT Analysis`.
4. Click the **+** or **pin** icon next to it to add it to your home page.
5. Once pinned you can rename the tile and add a subtitle directly on the home page.


---


### Running the App

All things running smoothly, you should at the end be able to launch the App, which will provide you a list page with a drill down to an object page, specific to a selected purchase order item.

In terms of presentation yo will have a large number of filters at your disposal, with most having a value help to help you search for data, based on data that exists in your system. Some custom value help filters have also been added to help you filter on the custom DIFOT fields introduced in this report.

![Report Filters](imagery/filters.png)

Once you execute the report the main list will be presented with data corresponding to your search criteria, including various DIFOT values and indicators, colour coded.
have also been added to help you filter on the custom DIFOT fields introduced in this report.

![List Report](imagery/listReport.png)

Clciking a specific line, will then drill down to an object page with data specific to the selected purchase order  item line, including the purchase order history, limited to goods movements. This may help you to understand goods receipts and cancellations.

![Object Page](imagery/objectPage.png)

The Object Page now includes a second detail table section — **Supplier Confirmation Lines** — displayed below the Goods Receipt Lines section. This table shows all active supplier confirmation records for the selected PO item, including confirmation category, sequential number, delivery date, confirmed quantity, and creation date. Deleted confirmations are filtered out automatically.
