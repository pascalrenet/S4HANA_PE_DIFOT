@AbapCatalog.sqlViewName: 'ZV_PRPODIFOTC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'PO DIFOT List Report'
@Metadata.ignorePropagatedAnnotations: false

/* OData service exposure is handled via a separate service definition (.srvd).
   @OData.publish is not released for customer use in S/4HANA Cloud. */

/* ── Object Page Header ───────────────────────────────────────── */
@UI.headerInfo: {
  typeName:       'PO DIFOT Item',
  typeNamePlural: 'PO DIFOT Items',
  title:          { value: 'PurchaseOrder' },
  description:    { value: 'PurchaseOrderItemText' }
}

/* ── Selection Fields (smart filter bar) ─────────────────────── */
@Search.searchable: true

define view ZC_PRPODIFOT_C
  as select from ZC_PRPODIFOT

  /* Navigation to individual GR lines for the Object Page table */
  association [0..*] to ZC_PRPOGRHistoryLines as _GRLines
    on  _GRLines.PurchaseOrder     = $projection.PurchaseOrder
    and _GRLines.PurchaseOrderItem = $projection.PurchaseOrderItem

  /* Navigation to supplier confirmation lines for the Object Page table */
  association [0..*] to ZC_PRPOSuppConfLines  as _ConfLines
    on  _ConfLines.PurchaseOrder     = $projection.PurchaseOrder
    and _ConfLines.PurchaseOrderItem = $projection.PurchaseOrderItem

{
  /* ── Keys ──────────────────────────────────────────────────── */
  @UI.facet: [{ id: 'PODetails',    type: #FIELDGROUP_REFERENCE, label: 'PO Details',          position: 10,
                targetQualifier: 'PODetails' },
              { id: 'DIFOTDetails', type: #FIELDGROUP_REFERENCE, label: 'DIFOT Details',       position: 20,
                targetQualifier: 'DIFOTDetails' },
              { id: 'SchedLines',   type: #FIELDGROUP_REFERENCE, label: 'Schedule & GR',       position: 30,
                targetQualifier: 'SchedLines' },
              { id: 'GRLines',      type: #LINEITEM_REFERENCE,   label: 'Goods Receipt Lines',         position: 40,
                targetElement: '_GRLines' },
              { id: 'ConfLines',    type: #LINEITEM_REFERENCE,   label: 'Supplier Confirmation Lines', position: 50,
                targetElement: '_ConfLines' }]

  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem:       [{ position: 10, importance: #HIGH,   label: 'Purchase Order' }]
  @UI.identification: [{ position: 10 }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 5 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchasingDocumentStdVH', element: 'PurchasingDocument' } }]
  @Search.defaultSearchElement: true
  key PurchaseOrder,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 20, importance: #HIGH,   label: 'PO Item'        }]
  @UI.identification: [{ position: 20 }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 6 }]
  key PurchaseOrderItem,

  /* ── PO Header Fields ──────────────────────────────────────── */
  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem:       [{ position: 30, importance: #HIGH,   label: 'Supplier'       }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier_VH', element: 'Supplier' } }]
  Supplier,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 20 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
  CompanyCode,

  @UI.selectionField: [{ position: 40 }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 30 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchasingOrganization', element: 'PurchasingOrganization' } }]
  PurchasingOrganization,

  @UI.selectionField: [{ position: 45 }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 35 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderType', element: 'PurchaseOrderType' } }]
  PurchaseOrderType,

  @UI.selectionField: [{ position: 50 }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 40 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchasingGroup', element: 'PurchasingGroup' } }]
  PurchasingGroup,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 50 }]
  PurchaseOrderDate,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 60 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH', element: 'Currency' } }]
  DocumentCurrency,

  /* ── PO Item Fields ────────────────────────────────────────── */
  @UI.selectionField: [{ position: 60 }]
  @UI.lineItem:       [{ position: 40, importance: #MEDIUM, label: 'Material'       }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 70 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
  Material,

  @UI.selectionField: [{ position: 70 }]
  @UI.lineItem:       [{ position: 50, importance: #MEDIUM, label: 'Plant'          }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 80 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
  Plant,

  @UI.selectionField: [{ position: 75 }]
  @UI.lineItem:       [{ position: 60, importance: #MEDIUM, label: 'Material Group' }]
  @UI.fieldGroup:     [{ qualifier: 'PODetails', position: 85 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CnsldtnMaterialGroupVH', element: 'MaterialGroup' } }]
  MaterialGroup,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 90 }]
  PurchaseOrderItemText,

  @UI.lineItem:   [{ position: 70, importance: #HIGH,   label: 'Ordered Qty'    }]
  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 100 }]
  OrderQuantity,

  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure' } }]
  PurchaseOrderQuantityUnit,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 110 }]
  NetPriceAmount,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 120 }]
  NetAmount,

  @UI.fieldGroup: [{ qualifier: 'PODetails', position: 130 }]
  IsCompletelyDelivered,

  /* ── Schedule Line Fields ──────────────────────────────────── */
  @UI.fieldGroup: [{ qualifier: 'SchedLines', position: 10 }]
  TotalScheduledQuantity,

  @UI.fieldGroup:     [{ qualifier: 'SchedLines', position: 20 }]
  @UI.selectionField: [{ position: 80 }]
  EarliestSchedDelivDate,

  @UI.fieldGroup: [{ qualifier: 'SchedLines', position: 30 }]
  @UI.lineItem:   [{ position: 100, importance: #HIGH,   label: 'Sched Del. Date'  }]
  LatestSchedDelivDate,

  @UI.fieldGroup: [{ qualifier: 'SchedLines', position: 40 }]
  NumberOfScheduleLines,

  /* ── GR Fields ─────────────────────────────────────────────── */
  @UI.lineItem:   [{ position: 80,  importance: #HIGH,   label: 'GR Quantity'      }]
  @UI.fieldGroup: [{ qualifier: 'SchedLines', position: 50 }]
  TotalGRQuantity,

  @UI.fieldGroup: [{ qualifier: 'SchedLines', position: 60 }]
  FirstGRPostingDate,

  @UI.lineItem:   [{ position: 110, importance: #HIGH,   label: 'Latest GR Date'   }]
  @UI.fieldGroup: [{ qualifier: 'SchedLines', position: 70 }]
  LatestGRPostingDate,

  /* ── DIFOT Calculated Fields ───────────────────────────────── */
  @UI.lineItem:   [{ position: 90,  importance: #HIGH,   label: 'Qty Variance'     }]
  @UI.fieldGroup: [{ qualifier: 'DIFOTDetails', position: 10 }]
  QuantityVariance,

  @UI.lineItem:   [{ position: 120, importance: #HIGH,   label: 'Date Var. (Days)' }]
  @UI.fieldGroup: [{ qualifier: 'DIFOTDetails', position: 20 }]
  DateVarianceInDays,

  @UI.lineItem:   [{ position: 130, importance: #HIGH,   label: 'In Full?'         }]
  @UI.fieldGroup: [{ qualifier: 'DIFOTDetails', position: 30 }]
  IsDeliveredInFull,

  @UI.lineItem:   [{ position: 140, importance: #HIGH,   label: 'On Time?'         }]
  @UI.fieldGroup: [{ qualifier: 'DIFOTDetails', position: 40 }]
  IsDeliveredOnTime,

  /*
    DIFOT Status with colour-coded criticality:
      1 = red    (NOT DIFOT)
      2 = orange (PENDING)
      3 = green  (DIFOT)
  */
  @UI.selectionField: [{ position: 90 }]
  @UI.lineItem:       [{ position: 150, importance: #HIGH, label: 'DIFOT Status',
                         criticality: 'DIFOTCriticality', criticalityRepresentation: #WITH_ICON }]
  @UI.fieldGroup:     [{ qualifier: 'DIFOTDetails', position: 50, criticality: 'DIFOTCriticality' }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_PRPODIFOTStatusVH', element: 'DIFOTStatus' } }]
  DIFOTStatus,

  @UI.lineItem:   [{ position: 160, importance: #HIGH,   label: 'Failure Reason'   }]
  @UI.fieldGroup: [{ qualifier: 'DIFOTDetails', position: 60 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_PRPODIFOTFailReasonVH', element: 'DIFOTFailureReason' } }]
  DIFOTFailureReason,

  /* Virtual criticality field – drives the colour of DIFOTStatus */
  @UI.hidden: true
  cast(
    case DIFOTStatus
      when 'DIFOT'     then 3   -- green
      when 'NOT DIFOT' then 1   -- red
      when 'PENDING'   then 2   -- orange
      else 0
    end
  as abap.int1 )                as DIFOTCriticality,

  /* Navigation associations – exposed so OData can navigate to detail lines */
  _GRLines,
  _ConfLines
}
