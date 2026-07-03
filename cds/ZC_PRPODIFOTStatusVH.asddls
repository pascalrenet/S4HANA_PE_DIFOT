@AbapCatalog.sqlViewName: 'ZV_PRPODIFOTSTVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIFOT Status Value Help'
@Search.searchable: true

define view ZC_PRPODIFOTStatusVH
  as select from I_Language

{
  @Search.defaultSearchElement: true
  @UI.lineItem: [{ position: 10 }]
  @EndUserText.label: 'DIFOT Status'
  key cast( 'DIFOT' as abap.char(10) )               as DIFOTStatus,

  @UI.lineItem: [{ position: 20 }]
  @EndUserText.label: 'Description'
  cast( 'Delivered In Full and On Time' as abap.char(40) ) as DIFOTStatusText
}
where Language = 'E'

union all

select from I_Language
{
  key cast( 'NOT DIFOT' as abap.char(10) )           as DIFOTStatus,
  cast( 'Delivery Failed' as abap.char(40) )         as DIFOTStatusText
}
where Language = 'E'

union all

select from I_Language
{
  key cast( 'PENDING' as abap.char(10) )             as DIFOTStatus,
  cast( 'No Goods Receipt Yet' as abap.char(40) )    as DIFOTStatusText
}
where Language = 'E'
