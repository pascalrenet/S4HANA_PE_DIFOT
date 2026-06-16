@AbapCatalog.sqlViewName: 'ZV_PRPODIFOTFRVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIFOT Failure Reason Value Help'
@Search.searchable: true

define view ZC_PRPODIFOTFailReasonVH
  as select from I_Language

{
  @Search.defaultSearchElement: true
  @UI.lineItem: [{ position: 10 }]
  @EndUserText.label: 'Failure Reason'
  key cast( '' as abap.char(15) )                         as DIFOTFailureReason,

  @UI.lineItem: [{ position: 20 }]
  @EndUserText.label: 'Description'
  cast( 'None - Delivered In Full On Time' as abap.char(40) ) as DIFOTFailureReasonText
}
where Language = 'E'

union all

select from I_Language
{
  key cast( 'SHORT' as abap.char(15) )                   as DIFOTFailureReason,
  cast( 'Short - Quantity Short' as abap.char(40) )      as DIFOTFailureReasonText
}
where Language = 'E'

union all

select from I_Language
{
  key cast( 'LATE' as abap.char(15) )                    as DIFOTFailureReason,
  cast( 'Late - Delivered Late' as abap.char(40) )       as DIFOTFailureReasonText
}
where Language = 'E'

union all

select from I_Language
{
  key cast( 'SHORT AND LATE' as abap.char(15) )          as DIFOTFailureReason,
  cast( 'Short and Late' as abap.char(40) )              as DIFOTFailureReasonText
}
where Language = 'E'
