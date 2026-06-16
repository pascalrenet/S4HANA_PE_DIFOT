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
├── INSTRUCTIONS.md          ← this file
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
    ├── Claude_difotSpec_2.md
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
   - **Name**: `ZPURCHASING` (or your preferred name — use it consistently throughout this guide)
   - **Description**: `Purchasing Custom Objects`
   - **Package Type**: `Development`
   - **Application Component**: `MM-PUR` (or your preferred component)
4. Assign it to a transport request when prompted. Note the transport number.
5. Click **Finish**.

---

## Step 2 — Create CDS View `ZC_PRPOItemGRSummary`

This view aggregates net goods receipt quantities per PO item.

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPOITEMGRSUMMARY`
   - **Description**: `PO Item GR Quantity Summary`
   - **Template**: `Define View`
4. Click **Next**, assign the transport request → **Finish**.
5. ADT opens the editor. **Replace the entire content** with the code from `cds/ZC_PRPOItemGRSummary.asddls`.
6. Press **Ctrl+S** to save, then press **F8** or click **Activate** (the white circle icon in the toolbar).
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
   - **Template**: `Define View`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPOGRHistoryLines.asddls`.
6. Press **Ctrl+S** to save, then **Activate**. Verify there are no errors in the **Problems** view.

> **Key points about this view:**
> - Filters on `PurchasingHistoryCategory = 'E'` and movement types `101`/`102` — same scope as `ZC_PRPOItemGRSummary` but returns one row per document line instead of aggregating
> - Keys are `PurchaseOrder`, `PurchaseOrderItem`, `PurchasingHistoryDocument`, and `PurchasingHistoryDocumentItem`
> - Used exclusively as a navigation target; not directly consumed by the DIFOT calculation

---

## Step 6 — Create CDS Value Help Views

These two small views provide fixed-value lists for the **DIFOT Status** and **Failure Reason** filter fields in the Smart Filter Bar. Both are custom calculated fields with no standard SAP value help.

> **Both views must be created before `ZC_PRPODIFOT_C`** — the consumption view in Step 7 references them via `@Consumption.valueHelpDefinition` and will fail to activate if they do not exist.

### 6a — Create `ZC_PRPODIFOTStatusVH`

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Core Data Services**, select **Data Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOTSTATUSVH`
   - **Description**: `DIFOT Status Value Help`
   - **Template**: `Define View`
4. Click **Next**, assign the transport request → **Finish**.
5. **Replace the entire content** with the code from `cds/ZC_PRPODIFOTStatusVH.asddls`.
6. Press **Ctrl+S** to save, then **Activate**. Verify there are no errors in the **Problems** view.

### 6b — Create `ZC_PRPODIFOTFailReasonVH`

1. Repeat the "New → Data Definition" steps above.
2. Set:
   - **Name**: `ZC_PRPODIFOTFAILRSNVH`
   - **Description**: `DIFOT Failure Reason Value Help`
   - **Template**: `Define View`
3. **Replace the entire content** with the code from `cds/ZC_PRPODIFOTFailReasonVH.asddls`.
4. Save and **Activate**.

> **How these views work:** The CDS `VALUES` clause (inline literal table) is only supported in BTP ABAP Environment, not in S/4HANA Cloud Public Edition. Instead, both views use `UNION ALL` over `I_Language` (filtered to a single row with `Language = 'E'`) combined with `cast()` literals to produce one fixed row per value. `I_Language` is a released SAP view that is guaranteed to exist and always contains the `'E'` row.

---

## Step 7 — Create CDS Consumption View `ZC_PRPODIFOT_C`

This view adds Fiori UI annotations and declares a navigation association to `ZC_PRPOGRHistoryLines` for the Object Page drill-down. OData service exposure is handled in Step 8 via an explicit service definition and binding.

1. Create a new **Data Definition** named `ZC_PRPODIFOT_C`.
   - **Description**: `PO DIFOT List Report`
2. Replace the content with the code from `cds/ZC_PRPODIFOT_C.asddls`.
3. Save and **Activate**.

> **Note:** `@OData.publish: true` is not released for customer/partner use in S/4HANA Cloud Public Edition. The view therefore carries no `@OData.publish` annotation; the OData service is created in Step 8 using a service definition and service binding instead.

> **Object Page facet types:** The three content sections (PO Details, DIFOT Details, Schedule & GR) use `type: #FIELDGROUP_REFERENCE` with a `targetQualifier` pointing at the matching `@UI.fieldGroup` qualifier on each field. This is required to render the fields inside the section. The fourth section (Goods Receipt Lines) uses `type: #LINEITEM_REFERENCE` with `targetElement: '_GRLines'` to render the navigation association as a table.

---

## Step 8 — Create Service Definition and Service Binding (OData V4)

S/4HANA Cloud Public Edition requires an explicit service definition and binding to expose a CDS view as an OData service (`@OData.publish: true` is not released for customer use).

### 8a — Create the Service Definition

1. In ADT, right-click your package → **New → Other ABAP Repository Object**.
2. Under **Business Services**, select **Service Definition** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_SRV`
   - **Description**: `PO DIFOT OData Service Definition`
4. Replace the content with the code from `service/ZC_PRPODIFOT_SRV.asdefs`.
5. Save and **Activate**.

### 8b — Create the Service Binding (OData V4)

1. Right-click the package again → **New → Other ABAP Repository Object** → **Service Binding** → **Next**.
2. Set:
   - **Name**: `ZC_PRPODIFOT_UI_V4`
   - **Description**: `PO DIFOT OData V4 Service Binding`
   - **Binding Type**: `OData V4 - UI`
   - **Service Definition**: `ZC_PRPODIFOT_SRV`
3. Save and **Activate**.
4. In the Service Binding editor, click **Publish Local Service Endpoint**.

> The service will be registered under the technical name shown in the binding editor (typically `ZC_PRPODIFOT_SRV_0001`). Use this name when constructing OData URLs in Step 10.

> **OData V4 vs V2:** The binding type `OData V4 - UI` generates a V4-compliant service. The URL path prefix, query syntax, and metadata format differ from V2 — see Step 10 for the correct V4 URL patterns.

---

## Step 9 — Make the App Accessible in the Fiori Launchpad

> **Important — ADT-only vs BAS approach:**
> The official SAP documentation for S/4HANA Cloud Public Edition ("Develop an SAP Fiori Application UI", 2602) describes IAM App and Business Catalog creation in ADT **as part of a BAS-based workflow** — specifically as the step that follows a `npm run deploy` from SAP Business Application Studio. The documentation does not describe or confirm an ADT-only path (without BAS deployment) as a supported approach.
>
> The stages below may work in practice for developer testing via the service binding preview URL, but they are **not the SAP-documented production deployment path**. For a fully supported deployment that creates a proper BSP application and Fiori Launchpad tile accessible to business users, follow `INSTRUCTIONS_BAS.md` instead.
>
> If you do proceed with the stages below, your user must have business catalog `SAP_A4C_BC_DEV_PC` assigned in addition to the prerequisites listed above.

This step has five stages: create an IAM App in ADT, create a Business Catalog in ADT, assign the catalog to a Business Role in the Launchpad, assign the role to your user, then pin the tile to your home page.

---

### Stage 1 — Create an IAM App in ADT

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Identity and Access Management**, select **IAM App** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_TILE`
   - **Description**: `PO DIFOT Analysis`
4. Click **Next**, assign the transport request → **Finish**.
5. In the IAM App editor, on the **Overview** tab:
   - **App Type**: `EXT_UI`
   - Leave **Fiori Launchpad App Descr Item ID** blank.
6. Go to the **Services** tab → **Add**:
   - **Service Type**: `OData V4`
   - **Service Name**: `ZC_PRPODIFOT_UI_V4                 0001` *(the technical name shown in your service binding editor)*
7. **Save** and **Activate**.
8. Click **Publish Locally**.

---

### Stage 2 — Create a Business Catalog in ADT

1. Right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Cloud Identity and Access Management**, select **Business Catalog** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_BC`
   - **Description**: `PO DIFOT Reporting`
4. Click **Next**, assign the transport request → **Finish**.
5. In the Business Catalog editor, go to the **Apps** tab → **Add** → select `ZC_PRPODIFOT_TILE`.
6. **Save** and **Activate**.
7. Click **Publish Locally**.

---

### Stage 3 — Assign the Catalog to a Business Role (in the Launchpad)

1. Open your Fiori Launchpad and launch the **Maintain Business Roles** app.
2. Create a new role (e.g. name `ZBR_PR_PODIFOT_USER`, description `PO DIFOT Reporting`) or open an existing procurement role you want to add the app to.
3. Go to **Assigned Business Catalogs** → **Add** → search for `ZC_PRPODIFOT_BC` and add it.
4. Under **Access Categories**, ensure at minimum **Read** and **Value Help** are granted.
5. **Save**.

---

### Stage 4 — Assign the Role to your User (in the Launchpad)

1. Launch the **Maintain Business Users** app.
2. Find your user → **Assigned Business Roles** → **Add** → select the role from Stage 3.
3. **Save**.
4. Log out and back in to the Launchpad.

---

### Stage 5 — Pin the Tile to your Home Page

1. On the Launchpad home page, click the **pencil (Edit)** icon.
2. Click **App Finder**.
3. Search for `DIFOT` or `PO DIFOT` — the app should appear listed under the IAM App description `PO DIFOT Analysis`.
4. Click the **+** or **pin** icon next to it to add it to your home page.
5. Once pinned you can rename the tile and add a subtitle directly on the home page.

> **If the app does not appear in App Finder:**
> - Verify Stage 1 and Stage 2 objects were both **Published Locally** (not just activated).
> - Confirm Stage 3 and Stage 4 were saved and you have logged out and back in.
> - Check the service binding `ZC_PRPODIFOT_UI_V4` is published — open it in ADT and confirm **Publish Local Service Endpoint** has been clicked.

---

## Step 10 — Test the Application

### 10a — Service Metadata via OData V4 URL

OData V4 services use a different URL path than V2. Navigate to the metadata document to verify the service exposes all expected entity sets:

```
https://<your-system>/sap/opu/odata4/sap/zc_prpodifot_srv/default/sap/zc_prpodifot_srv/0001/$metadata
```

You should see `PODIFOTItem` and `POGRHistoryLine` entity sets with all their properties.

> **URL pattern differences — V2 vs V4:**
>
> | | OData V2 | OData V4 |
> |---|---|---|
> | Base path | `/sap/opu/odata/sap/<SERVICE>/` | `/sap/opu/odata4/sap/<service>/default/sap/<service>/0001/` |
> | Metadata | `$metadata` | `$metadata` |
> | Filter operator | `eq`, `ne`, etc. | `eq`, `ne`, etc. (same) |
> | Count inline | `$inlinecount=allpages` | `$count=true` |
> | JSON format | `$format=json` | JSON is the default; `$format=json` still accepted |

### 10b — Data Test via $filter

Retrieve all NOT DIFOT items:

```
https://<your-system>/sap/opu/odata4/sap/zc_prpodifot_srv/default/sap/zc_prpodifot_srv/0001/PODIFOTItem?$filter=DIFOTStatus eq 'NOT DIFOT'
```

Retrieve all late deliveries for a specific supplier:

```
https://<your-system>/sap/opu/odata4/sap/zc_prpodifot_srv/default/sap/zc_prpodifot_srv/0001/PODIFOTItem?$filter=Supplier eq '1000001' and DIFOTFailureReason eq 'LATE'
```

Retrieve GR lines for a specific PO item via navigation:

```
https://<your-system>/sap/opu/odata4/sap/zc_prpodifot_srv/default/sap/zc_prpodifot_srv/0001/PODIFOTItem(PurchaseOrder='4500000001',PurchaseOrderItem='00010')/_GRLines
```

### 10c — Fiori App Test

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

## Troubleshooting

| Symptom | Likely Cause | Action |
|---|---|---|
| Object Page sections appear but are empty | Facet type was `#COLLECTION` instead of `#FIELDGROUP_REFERENCE` | Ensure each content facet in `ZC_PRPODIFOT_C` uses `type: #FIELDGROUP_REFERENCE` and has a `targetQualifier` matching the `@UI.fieldGroup` qualifier on the fields |
| Activation error on `ZC_PRPODIFOT`: "view not found" | A dependent view (`ZC_PRPOItemGRSummary` or `ZC_PRPOSchedLineSummary`) is not activated | Activate the two aggregation views first (Steps 2–3), then activate `ZC_PRPODIFOT` |
| Activation error on `ZC_PRPODIFOT_C`: "data source does not exist or is not active" | `ZC_PRPOGRHistoryLines`, `ZC_PRPODIFOTStatusVH`, or `ZC_PRPODIFOTFailReasonVH` has not been created or activated | Complete Steps 5 and 6 first, then re-activate `ZC_PRPODIFOT_C` |
| `TotalGRQuantity` is null for a PO item that has GR | `PurchasingHistoryCategory` filter — check that the GR documents have category `E` in EKBE | Use SE16N on EKBE table to verify `BEWTP = 'E'` for your test POs |
| `LatestSchedDelivDate` is null | The PO item has no schedule lines in `I_PurOrdScheduleLineAPI01` | Check whether the PO item type creates schedule lines; items with item category `D` (service) may not |
| OData service not found | Service binding not published | In ADT, open the service binding `ZC_PRPODIFOT_UI_V4` and click **Publish Local Service Endpoint**; then check the OData service catalogue app in the Fiori Launchpad |
| DIFOTStatus always 'PENDING' | GR history records exist but are not matching | Check that `GoodsMovementType` is `101`/`102` and `PurchasingHistoryCategory = 'E'`; adjust filter if your system uses different values |
| SQL view name too long | ABAP SQL view names are limited to 16 chars | The `@AbapCatalog.sqlViewName` values in each file (`ZV_PRPOITGRSUMM`, `ZV_PRPOSCHLSUMM`, `ZV_PRPODIFOT`, `ZV_PRPODIFOTC`, `ZV_PRPOGRHISTLN`) are already within the limit |
| 404 on OData V4 URL | Wrong URL path format | OData V4 path is `/sap/opu/odata4/sap/<service>/default/sap/<service>/0001/` — note the `/odata4/` segment and the `/default/` qualifier; V2 URLs (`/odata/`) will not work |
| Metadata visible but entity set returns no data | IAM App service type set to V2 | In the IAM App `ZC_PRPODIFOT_TILE`, check the Services tab — the Service Type must be **OData V4**, not OData V2 |

---

## Object Page Drill-Down — GR History Lines

The Object Page drill-down is built into the standard setup above. `ZC_PRPOGRHistoryLines` (Step 5), `ZC_PRPODIFOT_C` (Step 6), and `ZC_PRPODIFOT_SRV` (Step 7) together deliver:

- An Object Page that opens when a user clicks any row in the List Report
- Four tabs on the Object Page: **PO Details**, **DIFOT Details**, **Schedule & GR**, and **Goods Receipt Lines**
- The **Goods Receipt Lines** tab shows every individual GR and reversal movement for the selected PO item (material document, movement type, posting date, quantity, amount)

> **Troubleshooting the Goods Receipt Lines tab:**
> - If the tab does not appear, verify `ZC_PRPOGRHISTORYLINES` activated without errors (Step 5) and that `_GRLines` is present in the SELECT list of `ZC_PRPODIFOT_C`.
> - If the tab appears but is empty for a PO item that has GRs, check the `PurchasingHistoryCategory` filter: use SE16N on table EKBE and confirm `BEWTP = 'E'` for your test PO.

---

## Next Steps / Optional Enhancements

- **Add authority check**: Replace `#NOT_REQUIRED` with `#CHECK` in `ZC_PRPOItemGRSummary`, `ZC_PRPOSchedLineSummary`, and `ZC_PRPOGRHistoryLines` and create an access control (DCL) object to restrict by purchasing organisation or company code.
- **KPI tile**: Add a Fiori Smart Business KPI tile that shows the percentage of DIFOT items over the last 30 days.
- **Analytical list page**: Change the Fiori template from List Report to Analytical List Page to add a chart view showing DIFOT rate by supplier over time.
- **i18n labels**: Add a `@Semantics.text` annotation to `DIFOTStatus` and create value help texts for the status values.

---

## Enhancement 2 — Value Help for Smart Filter Bar Fields

This enhancement wires up search help dialogs to filter fields in the Smart Filter Bar so users can browse and search for valid values rather than typing free text.

Only `ZC_PRPODIFOT_C` needs to be updated — no changes to the service definition or binding are required.

### Value Help Wiring in `ZC_PRPODIFOT_C`

| Filter Field | Value Help CDS | Key Element |
|---|---|---|
| Purchase Order | `I_PurchasingDocumentStdVH` | `PurchasingDocument` |
| Supplier | `I_Supplier_VH` | `Supplier` |
| Material | `I_ProductStdVH` | `Product` |
| Plant | `I_PlantStdVH` | `Plant` |
| DIFOT Status | `ZC_PRPODIFOTStatusVH` | `DIFOTStatus` |
| Failure Reason | `ZC_PRPODIFOTFailReasonVH` | `DIFOTFailureReason` |

The `DIFOT Status` and `Failure Reason` value helps (`ZC_PRPODIFOTStatusVH` and `ZC_PRPODIFOTFailReasonVH`, created in Step 6) are custom fixed-value views since there are no standard SAP value helps for these calculated fields. Both use `UNION ALL` over `I_Language` (filtered to `Language = 'E'`) with `cast()` literals to produce one fixed row per value — no database table is needed.

A `@Search.defaultSearchElement: true` annotation is also set on `PurchaseOrder` to satisfy the requirement that at least one element is nominated as the default search element when `@Search.searchable: true` is set at view level.

All `@Consumption.valueHelpDefinition` annotations are already present in `cds/ZC_PRPODIFOT_C.asddls`. No additional steps are required beyond activating the views in the order described in the guide.

SAP Help Documentation
- https://developers.sap.com/tutorials/abap-custom-ui-bas-develop-s4hc.html
- https://userapps.support.sap.com/sap/support/knowledge/en/3445942