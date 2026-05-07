SELECT TOP (1000) [codigo]
      ,[fk_TH_Entidades]
      ,[fk_TH_Objetos]
      ,[superficie_desde]
      ,[superficie_hasta]
      ,[importe_sin_iva]
      ,[obs]
      ,[grid_busqueda]
      ,[flag_regenerar_grid_busqueda]
      ,[codigo_control]
      ,[cascading]
  FROM [ETHER].[dbo].[TH_Presupuestos_Web_Tarifas]

  select * from TH_Objetos where codigo = 108

  DECLARE @codentid VARCHAR(10) = 'PAR'
  DECLARE @tipoinmueble VARCHAR(10) = '80007'
    DECLARE @nsuperficie DECIMAL(18,2) = 150
    DECLARE @aplicar_tarifa bit= 1
    DECLARE @porcentaje_urgente DECIMAL(5,2) = 0.10 -- Ejemplo de porcentaje para urgente
    DECLARE @importe_pago_base DECIMAL(18,2)
    DECLARE @importe_pago_urgente DECIMAL(18,2)


                 select top 1 e.codigo from TH_Entidades e (nolock) where e.codentid=@codentid 
                 select top 1 o.codigo from TH_Objetos   o (nolock) where o.codobjet=@tipoinmueble
                 select @aplicar_tarifa intersect select 1


select top 1 [tarifa]=t.importe_sin_iva
                         from TH_Presupuestos_Web_Tarifas t (nolock)
                         where t.fk_TH_Entidades=(select top 1 e.codigo from TH_Entidades e (nolock) where e.codentid=@codentid    )
                           and t.fk_TH_Objetos  =(select top 1 o.codigo from TH_Objetos   o (nolock) where o.codobjet=@tipoinmueble)

                                and exists (select @aplicar_tarifa intersect select 1)
                       
                           and isnull(@nsuperficie,0) between isnull(t.superficie_desde,0) and isnull(t.superficie_hasta,20000000)
                       
  select @importe_pago_base=isnull([tar].tarifa,[tar].tarifa)
            from (select [c]=0) a      
            outer apply (select top 1 [tarifa]=t.importe_sin_iva
                         from TH_Presupuestos_Web_Tarifas t (nolock)
                         where t.fk_TH_Entidades=(select top 1 e.codigo from TH_Entidades e (nolock) where e.codentid=@codentid    )
                           and t.fk_TH_Objetos  =(select top 1 o.codigo from TH_Objetos   o (nolock) where o.codobjet=@tipoinmueble)
                           and isnull(@nsuperficie,0) between isnull(t.superficie_desde,0) and isnull(t.superficie_hasta,20000000)
                           and exists (select @aplicar_tarifa intersect select 1)
                         ) [tar]

select @importe_pago_base as importe_pago_base



select (@importe_pago_urgente =  @importe_pago_base+ (@importe_pago_base*@porcentaje_urgente) ) as importe_pago_urgente
   