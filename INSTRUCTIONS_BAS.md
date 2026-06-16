# PO DIFOT — Fiori App Creation and Deployment Using SAP Business Application Studio

## Overview

This guide covers how to create a proper, deployable SAP Fiori Elements List Report application on top of the OData V4 service you built in `INSTRUCTIONS.md`, and how to expose it on the S/4HANA Cloud Public Edition Fiori Launchpad.

The service binding preview accessible from ADT is **not a deployable app**. To get a tile on the Fiori Launchpad that business users can access, you must generate a project in BAS, deploy it to the ABAP repository in S/4HANA Cloud, create an IAM App and Business Catalog in ADT, and then assign access through the Launchpad administration apps.

### What BAS deployment creates in S/4HANA Cloud

When you deploy from BAS, three ABAP repository objects are created automatically:

| Object type | Description |
|---|---|
| `WAPA` — BSP Application | The SAPUI5 application itself, stored in the ABAP repository |
| `UIAD` — Launchpad App Descriptor Item | The tile metadata (semantic object, action, title, subtitle) that the Launchpad reads |
| SAPUI5 ABAP Repository entry | Links the BSP app to the Launchpad infrastructure |

The IAM App and Business Catalog that control **who can see and access** the tile are created separately in ADT (Steps 4–5 below).

### Prerequisites

| Requirement | Detail |
|---|---|
| BAS Dev Space | A **SAP Fiori** type Dev Space must exist in your BAS Dev Space Manager |
| BAS destination | A destination pointing to your S/4HANA Cloud system must be configured in your BTP subaccount (see below) |
| Business catalogs on your user | `SAP_A4C_BC_DEV_UID_PC` — allows BAS to discover OData services and deploy apps; `SAP_CORE_BC_EXT_TST` — allows app preview in BAS; `SAP_A4C_BC_DEV_PC` — required for IAM App and Business Catalog creation in ADT |
| Open transport request | An open ABAP transport request in your development system |
| OData V4 service published | `ZC_PRPODIFOT_UI_V4` service binding published (Step 7 of `INSTRUCTIONS.md`) |

---

## Step 1 — Configure the BAS Destination in BTP (if not already done)

Before BAS can connect to your S/4HANA Cloud system, a destination must exist in your BTP subaccount.

1. Log on to the **SAP BTP Cockpit** for your subaccount.
2. Navigate to **Connectivity → Destinations → New Destination**.
3. Set the following:
   - **Name**: `SAP_Business_Application_Studio` *(this exact name is expected by the BAS integration)*
   - **Type**: `HTTP`
   - **URL**: `https://<your-s4hana-cloud-host>` (the base URL of your S/4HANA Cloud system)
   - **Authentication**: `OAuth2SAMLBearerAssertion` or `BasicAuthentication` depending on your trust setup
   - **Additional Properties**:
     - `WebIDEEnabled`: `true`
     - `WebIDESystem`: `ABAP`
     - `WebIDEUsage`: `odata_abap,dev_abap,abap_cloud`
     - `HTML5.DynamicDestination`: `true`
     - `sap-client`: `<your client number>`
4. **Save** and test the connection.

> For the complete trust and destination setup guide see SAP Help: *Integrating SAP Business Application Studio* for SAP S/4HANA Cloud Public Edition.

---

## Step 2 — Create the Fiori Application Project in BAS

1. Log on to **SAP Business Application Studio** via your BTP subaccount.
2. Open your **SAP Fiori** Dev Space (create one if needed: Dev Space Manager → New Dev Space → Kind: **SAP Fiori**).
3. On the Welcome screen, choose **New Project from Template**.
4. On the **Select Template** screen, choose **SAP Fiori Application** → **Start**.
5. On the **Template Selection** screen, choose **List Report Page** → **Next**.

### Data Source and Service Selection

6. On the **Data Source and Service Selection** screen:
   - **Data Source**: `Connect to a System`
   - **System**: select the destination you configured in Step 1 (e.g. `SAP_Business_Application_Studio`)
   - **Service**: BAS will retrieve the service catalogue from S/4HANA Cloud — select `ZC_PRPODIFOT_SRV` → `ZC_PRPODIFOT_SRV(0001) - OData V4`
7. Click **Next**.

### Entity Selection

8. On the **Entity Selection** screen:
   - **Main Entity**: `PODIFOTItem`
   - **Navigation Entity**: leave blank (the GR Lines sub-table is driven by the `_GRLines` association already annotated in the CDS view)
9. Click **Next**.

### Project Attributes

10. On the **Project Attributes** screen, enter:
    - **Module Name**: `zc_prpodifot`
    - **Application Title**: `PO DIFOT Analysis`
    - **Application Namespace**: `com.yourcompany.podifot` *(replace `yourcompany` with your namespace)*
    - **Description**: `Purchase Order DIFOT - Delivered In Full and On Time`
    - **Project Folder Path**: `/home/user/projects/zc_prpodifot` *(type the path exactly as shown — the generator creates the folder automatically if it does not exist; alternatively, pre-create it in the BAS terminal with `mkdir -p /home/user/projects/zc_prpodifot`)*
    - **Add Deployment Configuration**: `Yes`
    - **Add FLP Configuration**: `Yes`
11. Click **Next**.

### Deployment Configuration

12. On the **Deployment Configuration** screen:
    - **Target**: `ABAP`
    - **Destination**: *(pre-filled from the system chosen above)*
    - **SAPUI5 ABAP Repository**: `ZC_PRPODIFOT`
    - **Deployment Description**: `PO DIFOT Analysis`
    - **Package**: `ZPURCHASING` *(or your custom package)*
    - **Transport Request**: enter your open transport request number
13. Click **Next**.

### Fiori Launchpad Configuration

14. On the **Fiori Launchpad Configuration** screen:
    - **Semantic Object**: `ZPRPODifot`
    - **Action**: `display`
    - **Title**: `PO DIFOT Analysis`
    - **Subtitle** *(optional)*: `Delivered In Full and On Time`
15. Click **Finish**.

BAS generates the project and opens the **Application Info** view automatically.

> **Important:** The semantic object and action combination must be unique across your Launchpad. The values above are suggestions — use your own naming convention if required.

---

## Step 3 — Preview the Application in BAS

Before deploying, verify the app renders correctly against your live data.

1. In BAS, open the **Application Info** view (or run **View → Find Command → Fiori: Open Application Info**).
2. Click **Preview Application**.
3. Select **start** (or `fiori run --open`) from the list of scripts.
4. BAS opens a browser tab connected to your S/4HANA Cloud system.
5. In the Smart Filter Bar, enter a Purchase Order number and click **Go**.
6. Verify the DIFOT Status, Quantity Variance, and Date Variance columns appear correctly.
7. Click a row — the Object Page should open with four tabs: PO Details, DIFOT Details, Schedule & GR, and Goods Receipt Lines.

---

## Step 4 — Deploy the Application to S/4HANA Cloud

1. In BAS, open a **Terminal** (Terminal → New Terminal).
2. Navigate to your project folder:
   ```
   cd /home/user/projects/zc_prpodifot
   ```
3. Run the deployment command:
   ```
   npm run deploy
   ```
4. BAS authenticates against the S/4HANA Cloud system using the configured destination and uploads the app.
5. On success you will see a confirmation message showing the BSP application name (`ZC_PRPODIFOT`) and the UIAD launchpad descriptor item that were created.

> If the deployment fails with an authorisation error, verify that `SAP_A4C_BC_DEV_UID_PC` is assigned to your user and that the destination is configured correctly.

---

## Step 5 — Create the IAM App and Business Catalog in ADT

The deployed BSP application is not yet accessible to business users. You must create an IAM App (which links the Fiori UI to the OData service) and a Business Catalog (which groups apps for role assignment) in ADT.

### Stage 5a — Create the IAM App

1. In ADT, right-click your package `ZPURCHASING` → **New → Other ABAP Repository Object**.
2. Under **Identity and Access Management**, select **IAM App** → **Next**.
3. Set:
   - **Name**: `ZC_PRPODIFOT_TILE`
   - **Description**: `PO DIFOT Analysis`
4. Click **Next**, assign the transport request → **Finish**.
5. In the IAM App editor, **Overview** tab:
   - **App Type**: `EXT_UI`
   - **Fiori Launchpad App Descr Item ID**: enter the UIAD object name created by BAS deployment — this is `ZC_PRPODIFOT` (check in ADT under your package → Fiori User Interface → Launchpad App Descriptor Items if unsure)
6. Go to the **Services** tab → **Add**:
   - **Service Type**: `OData V4`
   - **Service Name**: `ZC_PRPODIFOT_UI_V4                 0001` *(technical name from your service binding editor)*
7. **Save** and **Activate**.
8. Click **Publish Locally**.

### Stage 5b — Create the Business Catalog

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

## Step 6 — Assign the Catalog to a Business Role

1. Open your S/4HANA Cloud Fiori Launchpad and launch the **Maintain Business Roles** app.
2. Create a new role or open an existing procurement role:
   - **Business Role ID**: `ZBR_PR_PODIFOT_USER`
   - **Description**: `PO DIFOT Reporting`
3. Go to **Assigned Business Catalogs** → **Add** → search for `ZC_PRPODIFOT_BC` and add it.
4. Under **Access Categories**, grant at minimum **Read** and **Value Help**.
5. **Save**.

---

## Step 7 — Assign the Role to Your User

1. Launch the **Maintain Business Users** app.
2. Find your user → **Assigned Business Roles** → **Add** → select `ZBR_PR_PODIFOT_USER`.
3. **Save**.
4. Log out and back in to the Launchpad.

---

## Step 8 — Add the Tile to the Fiori Launchpad Home Page

1. On the Launchpad home page, click the **pencil (Edit)** icon.
2. Click **App Finder**.
3. Search for `DIFOT` or `PO DIFOT` — the tile should appear with the title `PO DIFOT Analysis`.
4. Click **+** or the **pin** icon to add it to your home page.
5. Click **Save** to close edit mode.

> **If the tile does not appear in App Finder:**
> - Confirm Stage 5a and 5b were both **Published Locally** (not just activated) in ADT.
> - Confirm the Business Role was saved in Step 6 and the user assignment was saved in Step 7.
> - Log out and back in — role assignment changes require a fresh session.
> - Check the deployed BSP app exists: in ADT, expand your package → Other Objects → UI5 Application Resources — you should see `ZC_PRPODIFOT`.

---

## Step 9 — Test the Deployed Application

1. Click the **PO DIFOT Analysis** tile on your Launchpad home page.
2. The deployed Fiori Elements List Report opens (this is the full BSP application, not the BAS preview).
3. Enter a Purchase Order in the Smart Filter Bar and click **Go**.
4. Verify all columns appear: Purchase Order, PO Item, Supplier, Material, Plant, Ordered Qty, GR Quantity, Qty Variance, Sched Del. Date, Latest GR Date, Date Var. (Days), In Full?, On Time?, DIFOT Status, Failure Reason.
5. Click a row and confirm the Object Page opens with all four tabs populated.
6. Navigate to the **Goods Receipt Lines** tab and confirm individual GR movements appear.

---

## Relationship Between INSTRUCTIONS.md and This Guide

| | INSTRUCTIONS.md (ADT only) | INSTRUCTIONS_BAS.md (BAS + ADT) |
|---|---|---|
| **What you get** | Service binding preview app (developer access only) | Fully deployed BSP app accessible to business users via tile |
| **Fiori Launchpad tile** | No tile — accessed via service binding preview URL | Proper tile on the Launchpad home page |
| **Transport** | CDS + service artefacts via ABAP transport | CDS + service artefacts + BSP app + UIAD all on same transport |
| **IAM App / Catalog** | Created in ADT, references service binding | Created in ADT, references service binding AND the UIAD from BAS deployment |
| **Intended audience** | Developer testing and validation | Production deployment for business users |

> **Both approaches use ADT for IAM App and Business Catalog creation.** This is correct and supported for S/4HANA Cloud Public Edition under the Developer Extensibility model (confirmed by SAP Help: *Develop an SAP Fiori Application UI*, S/4HANA Cloud Public Edition 2602). The business catalog `SAP_A4C_BC_DEV_PC` must be assigned to your user to see the IAM and Business Catalog object types in the ADT New Object wizard.

---

## Troubleshooting

| Symptom | Likely Cause | Action |
|---|---|---|
| BAS cannot find the service in the wizard | Destination not configured correctly or `SAP_A4C_BC_DEV_UID_PC` not assigned | Verify the destination in BTP Cockpit and confirm the business catalog is assigned to your user |
| `npm run deploy` fails with 401/403 | User lacks deployment authorisation | Ensure `SAP_A4C_BC_DEV_UID_PC` is assigned and the destination authentication is correct |
| BSP app deployed but tile not in App Finder | IAM App or Business Catalog not published locally | In ADT, open `ZC_PRPODIFOT_TILE` and `ZC_PRPODIFOT_BC` and click **Publish Locally** on both |
| App opens but shows no data | OData service not published or user lacks access to the service | Confirm `ZC_PRPODIFOT_UI_V4` is published in ADT; confirm the IAM App Services tab references `OData V4` not V2 |
| Object Page sections are empty | Facet type issue in CDS view | See troubleshooting in `INSTRUCTIONS.md` — ensure `ZC_PRPODIFOT_C` uses `#FIELDGROUP_REFERENCE` facets |
| Goods Receipt Lines tab empty | `ZC_PRPOGRHISTORYLINES` activation or filter issue | See troubleshooting in `INSTRUCTIONS.md` — verify `BEWTP = 'E'` in EKBE for your test PO |
