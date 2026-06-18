# PO DIFOT Fiori List Report — Step-by-Step Implementation Guide

## Overview

This guide walks you through building a Fiori List Report that scores every purchase order item for **DIFOT** (Delivered In Full, On Time) status directly in SAP S/4HANA Cloud Public Edition.

### Architecture at a Glance

```
I_PurchaseOrderItemAPI01  ──┐
I_PurchaseOrderAPI01       ─┤
I_PurOrdScheduleLineAPI01  ─┼──► ZC_PRPOSchedLineSummary  ──┐
I_PurchaseOrderHistoryAPI01─┼──► ZC_PRPOItemGRSummary     ──┼──► ZC_PRPODIFOT ──► ZC_PRPODIFOT_C ──► OData V4 ──► Fiori App
I_POSupplierConfirmationAPI01┘   ZC_PRPOGRHistoryLines ──────┘     (core calc)   (UI annotations)
```

### File Reference

| File | Location | Description |
|---|---|---|
| `ZC_PRPOItemGRSummary.asddls` | `cds/` | Aggregates net GR quantity per PO item from purchase order history |
| `ZC_PRPOSchedLineSummary.asddls` | `cds/` | Aggregates scheduled quantity and delivery dates from schedule lines |
| `ZC_PRPODIFOT.asddls` | `cds/` | Joins all sources; calculates DIFOT status, flags, variances |
| `ZC_PRPOGRHistoryLines.asddls` | `cds/` | Individual GR lines — navigation target for the Object Page drill-down; must exist before `ZC_PRPODIFOT_C` |
| `ZC_PRPODIFOTStatusVH.asddls` | `cds/` | Fixed-value value help for the DIFOT Status filter field (three values: DIFOT, NOT DIFOT, PENDING) |
| `ZC_PRPODIFOTFailReasonVH.asddls` | `cds/` | Fixed-value value help for the Failure Reason filter field (four values: blank, SHORT, LATE, SHORT AND LATE) |
| `ZC_PRPODIFOT_C.asddls` | `cds/` | Consumption view with Fiori/OData UI annotations |
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
│   └── ZC_PRPODIFOT_C.asddls
├── service/                 ← service definition (.asdefs) file
│   └── ZC_PRPODIFOT_SRV.asdefs
└── docs/                    ← API reference documentation
    ├── I_PurchaseOrderItemAPI01.md
    ├── I_PurchaseOrderAPI01.md
    ├── I_PurchaseOrderHistoryAPI01.md
    ├── I_PurchaseOrderItemMonitor.md
    └── I_PurOrdScheduleLineAPI01.md
```

---

## Prerequisites

- ADT (ABAP Developer Tools) installed in Eclipse and connected to your S/4HANA Cloud Public Edition system
- A custom package in your system (e.g. `ZPURCHASING` or similar — if you do not have one, create it in Step 1 below)
- Your user has the developer role (e.g. `SAP_BR_DEVELOPER`)
- The standard CDS views `I_PurchaseOrderItemAPI01`, `I_PurchaseOrderAPI01`, `I_PurOrdScheduleLineAPI01`, `I_PurchaseOrderHistoryAPI01`, and `I_POSupplierConfirmationAPI01` exist in your system (they are delivered with S/4HANA Cloud Public Edition)

---

## Step 1 — Create a Custom Package (if needed)

1. In ADT, open the **ABAP Repository** perspective.
2. Right-click your system node → **New → ABAP Package**.
3. Set:
   - **Name**: `ZLOCAL_DIFOT_MM` (or your preferred name — use it consistently throughout this guide)
   - **Description**: `Supplier DIFOT development`
   - **Superpackage**: `Your own predefined Superpackage`
   - **Application Component**: `MM-PUR` (or your preferred component)
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
6. Press **Ctrl+S** to save, then press **F3** or click **Activate** (the icon that looks like a match).
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
     *(Note: the SQL view name `ZV_PRPOSCHLSUMM` is defined inside the file; ADT object name has a 30-char limit)*
   - **Description**: `PO Item Schedule Line Summary`
3. Replace the content with the code from `cds/ZC_PRPOSchedLineSummary.asddls`.
4. Save and **Activate**.

> **Key points:**
> - Aggregates `TotalScheduledQuantity`, `EarliestSchedDelivDate`, `LatestSchedDelivDate`
> - For DIFOT date comparison we use `LatestSchedDelivDate` as the deadline — a delivery arriving before or on the latest scheduled line date is considered on time

---

## Step 4 — Create CDS View `ZC_PRPODIFOT`

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
> | `DIFOTStatus` | `'DIFOT'` / `'NOT DIFOT'` / `'PENDING'` (no GR yet) |
> | `DIFOTFailureReason` | `'SHORT'` / `'LATE'` / `'SHORT AND LATE'` / `''` |

---

## Step 5 — Create CDS View `ZC_PRPOGRHistoryLines`

This view reads individual (non-aggregated) goods receipt and reversal lines from `I_PurchaseOrderHistoryAPI01`. It is used as a navigation target from `ZC_PRPODIFOT_C` so the Fiori Object Page can show a table of individual GR movements when a user drills into a PO item.

> **Must be created before `ZC_PRPODIFOT_C`** — the consumption view in Step 6 declares an association to this view and will fail to activate if it does not exist.

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPOGRHISTORYLINES`
   - **Description**: `PO Item GR History Lines`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPOGRHistoryLines.asddls`.
6. Press **Ctrl+S** to save, then **Activate**. Verify there are no errors in the **Problems** view.


---

## Step 6 — Create CDS Value Help Views

These two small views provide fixed-value lists for the **DIFOT Status** and **Failure Reason** filter fields in the Smart Filter Bar. Both are custom calculated fields with no standard SAP value help.

### 6a — Create `ZC_PRPODIFOTStatusVH`

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOTSTATUSVH`
   - **Description**: `DIFOT Status Value Help`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPODIFOTStatusVH.asddls`.
6. Press **Ctrl+S** to save, then **Activate**. Verify there are no errors in the **Problems** view.

### 6b — Create `ZC_PRPODIFOTFailReasonVH`

1. Repeat the "New → Data Definition" steps above.
2. Set:
   - **Name**: `ZC_PRPODIFOTFAILRSNVH`
   - **Description**: `DIFOT Failure Reason Value Help`
3. **Replace the entire content** with the code from `cds/ZC_PRPODIFOTFailReasonVH.asddls`.
4. Save and **Activate**.


---

## Step 7 — Create CDS Consumption View `ZC_PRPODIFOT_C`

This view adds Fiori UI annotations and declares a navigation association to `ZC_PRPOGRHistoryLines` for the Object Page drill-down. OData service exposure is handled in Step 8 via an explicit service definition and binding.

1. Create a new **Data Definition** named `ZC_PRPODIFOT_C`.
   - **Description**: `PO DIFOT List Report`
2. Replace the content with the code from `cds/ZC_PRPODIFOT_C.asddls`.
3. Save and **Activate**.


---

## Step 8 — Create Service Definition and Service Binding (OData V4)

S/4HANA Cloud Public Edition requires an explicit service definition and binding to expose a CDS view as an OData service (`@OData.publish: true` is not released for customer use).

### 8a — Create the Service Definition

1. In ADT, right-click your package → **New → Other ABAP Repository Object**.
2. Under **Business Services**, select **Service Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_SRV`
   - **Description**: `PO DIFOT OData Service Definition`
4. Click **Next**, assign the transport request → **Finish**.
5. Replace the content with the code from `service/ZC_PRPODIFOT_SRV.asdefs`.
6. Save and **Activate**.

### 8b — Create the Service Binding (OData V4)

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
********* Add Generate Fiori app in ADT
## Step 9 — Create the IAM App and Business Catalog in ADT

The deployed BSP application is not yet accessible to business users. You must create an IAM App (which links the Fiori UI to the OData service) and a Business Catalog (which groups apps for role assignment) in ADT.

### Step 9a — Create the IAM App

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Identity and Access Management**, select **IAM App** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_TILE`
   - **Description**: `PO Item DIFOT`
   - **Application Type**: `External App`
4. Click **Next**, assign the transport request → **Finish**.
5. In the IAM App editor, **Overview** tab:
   - **Fiori Launchpad App Descr Item ID**: `ZPODIFOT_UI5R` enter the UIAD object name created during the deployment — this is `ZPODIFOT_UI5R` (check in ADT under your package → Fiori User Interface → Launchpad App Descriptor Items if unsure)
6. Go to the **Services** tab → **Add**:
   - **Service Type**: `OData V4`
   - **Service Name**: `ZC_PRPODIFOT_UI_V4` *(technical name from your service binding editor)*
7. **Save** and .
8. Click **Publish Locally**.

### Step 9b — Create the Business Catalog

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


### Step 10 — Assign the Catalog to a Business Role (in the Launchpad)

1. Open your Fiori Launchpad and launch the **Maintain Business Roles** app.
2. Create a new role (e.g. name `ZBR_PR_PODIFOT_USER`, description `PO DIFOT Reporting`) or open an existing procurement role you want to add the app to.
3. Go to **Assigned Business Catalogs** → **Add** → search for `ZC_PRPODIFOT_BC` and add it.
4. Under **Access Categories**, ensure at minimum **Read** and **Value Help** are granted.
5. **Save**.

---

### Step 11 — Assign the Role to your User (in the Launchpad)

1. Launch the **Maintain Business Users** app.
2. Find your user → **Assigned Business Roles** → **Add** → select the role from Stage 3.
3. **Save**.
4. Log out and back in to the Launchpad.

---

### Step 12 — Pin the Tile to your Home Page

1. On the Launchpad home page, click the **pencil (Edit)** icon.
2. Click **App Finder**.
3. Search for `DIFOT` or `PO DIFOT` — the app should appear listed under the IAM App description `PO DIFOT Analysis`.
4. Click the **+** or **pin** icon next to it to add it to your home page.
5. Once pinned you can rename the tile and add a subtitle directly on the home page.


---



### Step 13 — Fiori App Test

1. Open the **PO DIFOT Analysis** tile from your Fiori Launchpad.
2. In the Smart Filter Bar, enter a **Purchase Order** number you know has had a goods receipt.
3. Click **Go**.
4. Verify:
   - DIFOT Status column shows green (`DIFOT`), red (`NOT DIFOT`), or orange (`PENDING`)
   - Quantity Variance and Date Variance columns populate correctly
   - Failure Reason column shows `SHORT`, `LATE`, `SHORT AND LATE`, or is blank

---

## Understanding the DIFOT Columns

| Column | What it means |
|---|---|
| **Ordered Qty** | The quantity on the PO item (`OrderQuantity`) |
| **GR Quantity** | Net goods receipts posted against this PO item (`TotalGRQuantity`) |
| **Qty Variance** | GR Quantity minus Ordered Quantity. **Negative = short delivery** |
| **Sched Del. Date** | The latest scheduled delivery date from the PO schedule lines |
| **Latest GR Date** | The latest date a goods receipt was posted for this PO item |
| **Date Var. (Days)** | Latest GR Date minus Scheduled Date in calendar days. **Positive = late** |
| **In Full?** | Tick (X) if GR Quantity ≥ Ordered Quantity |
| **On Time?** | Tick (X) if Latest GR Date ≤ Scheduled Delivery Date |
| **DIFOT Status** | Green = DIFOT, Red = NOT DIFOT, Orange = PENDING (no GR yet) |
| **Failure Reason** | Explains why an item is NOT DIFOT: SHORT, LATE, or SHORT AND LATE |

---

## Filtering Suggestions

The Smart Filter Bar exposes these fields by default (defined via `@UI.selectionField`):

| Filter | Use case |
|---|---|
| Purchase Order | Drill into a specific PO |
| Purchase Order Item | Narrow to a specific item |
| Supplier | Assess all deliveries from one supplier |
| Purchasing Organization | Org-level view |
| Purchasing Group | Buyer group performance |
| Material | Material-level DIFOT |
| Plant | Plant-level DIFOT |
| Material Group | Category-level analysis |
| Earliest Scheduled Delivery Date | Filter by delivery window |
| DIFOT Status | Focus on `NOT DIFOT` or `PENDING` items |

---

