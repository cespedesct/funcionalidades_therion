SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Calcular_Tarifa_TEST @datos='<root><p><c>tipoinmueble</c><v>0</v></p><p><c>superficie</c><v></v></p><p><c>codentid</c><v>PAR</v></p><p><c>municipio</c><v>37657</v></p><p><c>importemanual</c><v>importemanual.value</v></p><p><c>tramitacionurgente</c><v>tramitacionurgente.value</v></p></root>'

ALTER procedure [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Calcular_Tarifa]
 (@datos          varchar(max)
 ,@aplicar_tarifa bit=1
 ,@debug          bit=0
 )

 as 

------------------------------------------
set nocount on
set dateformat dmy
set transaction isolation level read uncommitted
------------------------------------------

begin

declare @prbbdd       varchar(300)=object_name(@@procid)
      , @paso         char(80)='Sin Iniciar'
      , @mess         varchar(max)
      , @npaso        int=0
      , @cpaso        varchar(100)
      , @fecha_inicio datetime=getdate()
      , @trancount    int=@@trancount

begin try
      ------------------------------


      declare @x1 xml=convert(xml,@datos)
      --select xc.value('c[1]', 'varchar(500)'), xc.value('v[1]', 'varchar(max)') from @x1.nodes('/root/p') as xt(xc)

      declare @tipoinmueble       varchar(200)
             ,@superficie         varchar(200)
             ,@codentid           varchar(20)
             ,@municipio          varchar(20) 
             ,@importemanual      varchar(20) 
             ,@abririmportemanual varchar(20) 
             ,@tramitacionurgente varchar(20)

      select @tipoinmueble      =xc.value('v[1]', 'varchar(200)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='tipoinmueble'
      select @superficie        =xc.value('v[1]', 'varchar(200)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='superficie'
      select @codentid          =xc.value('v[1]', 'varchar(20)' ) from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(20)' )='codentid'
      select @municipio         =xc.value('v[1]', 'varchar(20)' ) from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(20)' )='municipio'
      select @importemanual     =xc.value('v[1]', 'varchar(20)' ) from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(20)' )='importemanual'
      select @abririmportemanual=xc.value('v[1]', 'varchar(20)' ) from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(20)' )='abririmportemanual'
      select @tramitacionurgente=xc.value('v[1]', 'varchar(20)' ) from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(20)' )='tramitacionurgente'

      set @cpaso='1'

      declare @nsuperficie         decimal(19,2)
      declare @nimportemanual      decimal(19,2)
      declare @porcentaje_urgente  decimal(19,2)=1.00
      declare @nmunicipio          int

      --select [@tipoinmueble      ]=@tipoinmueble      
      --      ,[@superficie        ]=@superficie        
      --      ,[@codentid          ]=@codentid          
      --      ,[@municipio         ]=@municipio         
      --      ,[@importemanual     ]=@importemanual     
      --      ,[@tramitacionurgente]=@tramitacionurgente

      declare @js varchar(max)=''
      set @js+='codentid.innerHTML="'+@codentid+'";'
              +'codobjet.innerHTML="'+@tipoinmueble+'";'
              +'importemanual.style.color="black";'
              +'if (abririmportemanual.checked) {importemanual.style.color="red"};' 

      if rtrim(ltrim(@tipoinmueble))=''
        begin
            set @js+='ivaaplicado.innerHTML="";'
                    +'totalimporte.innerHTML="";'
                    +'if (!abririmportemanual.checked) {importemanual.value=""};' 
            select 'OKNORELOAD'+replace('[INIEVAL]'+isnull(@js,'')+'[FINEVAL]','[INIEVAL][FINEVAL]','')
            return
        end

      if rtrim(ltrim(@municipio))!=''
         begin   
           set @nmunicipio=convert(int,@municipio)
         end
      else
        begin
            set @js+='ivaaplicado.innerHTML="";'
                    +'totalimporte.innerHTML="";'
                    +'if (!abririmportemanual.checked) {importemanual.value=""};' 
            select 'OKNORELOAD'+replace('[INIEVAL]'+isnull(@js,'')+'[FINEVAL]','[INIEVAL][FINEVAL]','')
            return
        end

      set @cpaso='2'

      if rtrim(ltrim(@superficie))!=''
         begin   
           set @nsuperficie=convert(decimal(19,2),@superficie)
         end
       else
         begin
            set @nsuperficie=0
         end
      set @cpaso='3'

      if rtrim(ltrim(@importemanual))!=''
         begin   
            set @nimportemanual=convert(decimal(19,2),@importemanual)
         end

      set @cpaso='4'

      set @porcentaje_urgente=1.00
      if exists (select rtrim(ltrim(@tramitacionurgente)) intersect select '1')
         begin   
            set @porcentaje_urgente=1.15
         end

      set @cpaso='5'
      --select [@tipoinmueble      ]=@tipoinmueble      
      --      ,[@superficie        ]=@superficie        
      --      ,[@codentid          ]=@codentid          
      --      ,[@municipio         ]=@municipio         
      --      ,[@importemanual     ]=@importemanual     
      --      ,[@tramitacionurgente]=@tramitacionurgente
      --      ,[@nmunicipio]        =@nmunicipio 

      -----------------------
      -- Cálcular la Tarifa
      -----------------------

      declare @importe_pago_base	 decimal(19,2)
             ,@porcentaje_iva	    decimal(19,2)
             ,@importe_pago_total	decimal(19,2)
             ,@tipo_iva	          varchar(100)

      select @porcentaje_iva=convert(decimal(19,2),iva.iva), @tipo_iva=iva.nombre_impuesto
      from INE_CRUDO_MUNICIPIO i (nolock) 
      inner join CORITEL.dbo.taoprovi  p (nolock) on p.codprovi=convert(varchar,i.CPRO)
      outer apply (select top 1 [iva]=i.porcenta, [nombre_impuesto]=ltrim(rtrim(i.desimpue)) from CORITEL.dbo.taoimpue i (nolock) where i.codimpue=p.codimpue) [iva]
      where i.codigo=@nmunicipio

      set @importe_pago_base=null
      
      set @cpaso='2'

      if exists (select rtrim(ltrim(@abririmportemanual)) intersect select '1')
         begin   
            select @importe_pago_base=@nimportemanual
         end
       else 
         begin
            select @importe_pago_base=isnull([tar].tarifa,[tar].tarifa)*@porcentaje_urgente
            from (select [c]=0) a      
            outer apply (select top 1 [tarifa]=t.importe_sin_iva
                         from TH_Presupuestos_Web_Tarifas t (nolock)
                         where t.fk_TH_Entidades=(select top 1 e.codigo from TH_Entidades e (nolock) where e.codentid=@codentid    )
                           and t.fk_TH_Objetos  =(select top 1 o.codigo from TH_Objetos   o (nolock) where o.codobjet=@tipoinmueble)
                           and isnull(@nsuperficie,0) between isnull(t.superficie_desde,0) and isnull(t.superficie_hasta,20000000)
                           and exists (select @aplicar_tarifa intersect select 1)
                         ) [tar]
        
            -- select @importe_pago_base=450
         end

      select @importe_pago_base=@importe_pago_base

      /*

      select * from TH_Presupuestos_Web_Tarifas t (nolock)

      select isnull([tar].tarifa,[tarbase].tarifa)
            ,[tar].tarifa
            ,[tarbase].tarifa
            ,[codtarifa]=[tar].codtarifa
            ,[fk_TH_Objetos]
      from (select [c]=0) a      
      outer apply (select top 1 [tarifa]=t.importe_sin_iva, [codtarifa]=t.codigo, [fk_TH_Objetos]=t.fk_TH_Objetos
                   from TH_Presupuestos_Web_Tarifas t (nolock)
                   where t.fk_TH_Entidades=(select top 1 e.codigo from TH_Entidades e (nolock) where e.codentid='PAR'  )
                     and t.fk_TH_Objetos  =(select top 1 o.codigo from TH_Objetos   o (nolock) where o.codobjet='80008')
                     and 0 between isnull(t.superficie_desde,0) and isnull(t.superficie_hasta,20000000)
                     and exists (select 0 intersect select 1)
                   ) [tar]
      outer apply (select top 1 [tarifa]=400.00) [tarbase]

      */
      
      ----------------------------------------------------------------
      -- Calcular el importe según tarifa y grabar en el presupuesto
      ----------------------------------------------------------------

      set @importe_pago_total=convert(decimal(19,2),@importe_pago_base*(1.00+(@porcentaje_iva/100.00)))

      set @js+='ivaaplicado.innerHTML ="";'
              +'totalimporte.innerHTML="";'
              +'if (!abririmportemanual.checked) {importemanual.value=""};' 

      if @porcentaje_iva is not null
         begin
            set @js+='ivaaplicado.innerHTML="'+@tipo_iva+' <b>'+format(@porcentaje_iva,'0.00','de-DE')+'%</b>";'
            set @js+='totalimporte.innerHTML="Total: <b>'+format(@importe_pago_total,'#,0.00','de-DE')+' €</b>";'
         end

      set @js+=case when @importe_pago_base is not null then 
                   'if (!abririmportemanual.checked) {importemanual.value="'+replace(format(@importe_pago_base,'0.00','de-DE'),',','.')+'"};' 
                   else '' 
               end

      ---------------------------
      select 'OKNORELOAD'
             +replace('[INIEVAL]'+isnull(@js,'')+'[FINEVAL]','[INIEVAL][FINEVAL]','')

end try begin catch
      
      declare @p_error varchar(2000)
          set @p_error= 'ERROR (Paso '+@cpaso+').'+char(13)
                       +isnull(convert(varchar(300),ERROR_MESSAGE()),'')+char(13)
                       +'Informática Recibirá un Correo informando del mismo para solucionar el problema.'+char(13)
      declare @error_email varchar(max)

      set @error_email= 'NºErr: '+isnull(convert(varchar(300),ERROR_NUMBER()),'')+char(13)+char(13)
                       +'Proc.: '+@prbbdd+char(13)+char(13)
                       +'Paso => '+@cpaso+char(13)
                       +'Línea: '+isnull(convert(varchar(300),ERROR_LINE()),'')+char(13)+char(13)
                       +'Error: '+isnull(convert(varchar(300),ERROR_MESSAGE()),'')+char(13)+char(13)

      set @error_email=replace(replace(@error_email,char(13),'<br/>'),char(10),'<br/>')

      --exec Email_Error_Sistema null, @error_email
      
      --------------------------------------------------------------------
      select 'OKNORELOAD.'+isnull(@p_error,'')

end catch

end

GO
