SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* Actualizado el 2020-11-05 12:29:22.640*/

--select dbo.grid_TH_Informes (1122643,1)
--select dbo.grid_TH_Informes(1131593,1)
--select dbo.grid_TH_Informes(1131473,1)
--select dbo.grid_TH_Informes(1131426,1)

CREATE FUNCTION [dbo].[grid_TH_Informes] (@codigo int, @usuario int)

returns VARCHAR(max)
AS

  BEGIN

      declare @link_firma_digital varchar(max)
      declare @Unidad_Informativa varchar(max)=dbo.Unidad_Informacion_Informe_Identificacion (@codigo, @usuario, 0, '620px;')
      declare @restringido        bit=0 set @restringido=case when isnull(@usuario,0)=1 then 1 else 0 end

      declare @numinfor                   varchar(10)
      declare @estinfor                   varchar(10)
      declare @fileIdNotas                varchar(max)=''
      declare @tarifa_facturacion         varchar(100)
      declare @tipo_tarifa_facturacion    varchar(100)
      declare @importe_tarifa_facturacion decimal(19,2)
      declare @opcionesAbanca             varchar(max)
    --declare @pendienteAbanca            varchar(2000)
      declare @lista_clasificacion        varchar(max)
      declare @ultima_marcacion_gestasa   datetime
      declare @ultima_salida_gestasa      datetime

      declare @ns_pte int
            , @ns_ok  int
            , @ns_ko  int
      
      declare @acc_geotest bit=0
      declare @acc_TOL     bit=0

      if isnull(@usuario,0)!=0
         begin

         
           set @acc_geotest=dbo.f_SISTEMA_Accesos_Especiales ('ACC005',@usuario)
           set @acc_TOL    =dbo.f_SISTEMA_Accesos_Especiales ('ACC020',@usuario)

           select @numinfor=n.numinfor
                 ,@estinfor=e.estinfor  
                 ------------------------------------------------------------------------------------------------
                 ,@link_firma_digital=
                         --case when @usuario!=1 then ''
                         --     when e.estinfor in ('4','5','6','F') and isnull(t.chk_tasador_demo,0)=0 and isnull(d.sizebinario,0)>0
                         --     then
                         --           '<br><img class="click aumenta"'
                         --              +' src="imgEXT/firma_tasador.png" '
                         --              +' style="width:1.4vw;height:auto;vertical-align:middle;background:yellow" '
                         --              +' title="Firmar de Forma Digital-V1" '
                         --              +' onclick="WHTML_General(''THERION_html_mostrar_iframe @url=·'+dbo.f_Parametro_SISTEMA('urlexternas')+dbo.THERION_EnCriptar_Cadena_con_Clave ('FIRMA_TASADOR_Firmar_Informe_v1 @numinfor='''+n.numinfor+'''','19271812')+'· '',1);"><br>'
                         --     else ''
                         --end
                        +case when @usuario!=1 and 1=2 then ''
                              when dbo.f_SISTEMA_Accesos_Especiales ('38',@usuario)=0 then ''
                              when e.estinfor in ('4','5','6','F') and dbo.f_SISTEMA_Accesos_Especiales ('38',@usuario)=1
                                   and isnull(t.chk_tasador_demo,0)=0 
                                   and isnull(d.sizebinario     ,0)>0
                              then '<br><img class="click aumenta"'
                                       +' src="imgEXT/firma_tasador.png" '
                                       +' style="width:1.4vw;height:auto;vertical-align:middle" '
                                       +' title="Firmar de Forma Digital" '
                                       +' onclick="WHTML_General(''THERION_html_mostrar_iframe @url=·'+dbo.f_Parametro_SISTEMA('urlexternas')+dbo.THERION_EnCriptar_Cadena_con_Clave ('FIRMA_TASADOR_Firmar_Informe @numinfor='''+n.numinfor+'''','19271812')+'· '',1);"><br>'
                              else ''
                         end
                        +case when @usuario!=1  then ''
                              when dbo.f_SISTEMA_Accesos_Especiales ('38',@usuario)=0 then ''
                              when e.estinfor in ('4','5','6','F') and dbo.f_SISTEMA_Accesos_Especiales ('39',@usuario)=1
                                   and isnull(t.chk_tasador_demo,0)=0 
                                   and isnull(d.sizebinario     ,0)>0
                              then '<br><img class="click aumenta"'
                                       +' src="imgEXT/firma_tasador.png" '
                                       +' style="width:1.4vw;height:auto;vertical-align:middle" '
                                       +' title="Firmar de Forma Digital II" '
                                       +' onclick="WHTML_General(''THERION_html_mostrar_iframe @url=·'+dbo.f_Parametro_SISTEMA('urlexternas')+dbo.THERION_EnCriptar_Cadena_con_Clave ('FIRMA_TASADOR_Firmar_Informe_V1 @numinfor='''+n.numinfor+'''','19271812')+'· '',1);"><br>'
                              else ''
                         end

                        +case when dbo.f_SISTEMA_Accesos_Especiales ('39',@usuario)=0 then '<br>Sin Acceso'
                              when charindex('(4)',dbo.FIRMA_TASADOR (n.numinfor))>0  then '<br>Firmado 4'
                              when charindex('(5)',dbo.FIRMA_TASADOR (n.numinfor))>0  then '<br>Firmado 5'
                              when not e.estinfor in ('4','5','6','F')                then '<br>estinfor:'+e.estinfor
                              when isnull(t.chk_tasador_demo,0)=1                     then '<br>Tas Demo'
                              when isnull(d.sizebinario,0)=0                          then '<br>SizeBin=0'
                              when fd.fecha_firma is not null and fd.modelo in ('certificado local','signatury','signatur') then '<br>Fec.Firma not Null'
                              when isnull([rc3].items,0)<=0                           then '<br>[rc3].items=0' 
                              when isnull([rc4].items,0)<=0                           then '<br>[rc4].items=0' 
                              when CORITEL.dbo.f_TECNICOS_Cumple_ECO(n.numinfor)!='S' then '<br>No ECO' 
                              else 
                                   +'<br>'
                                   +'<br>'
                                   +'<img class="click aumenta" '
                                       +' src="img/enviar_para_firma_tasador.png"'
                                       +' style="width:1.6vw;height:auto;vertical-align:middle" '
                                       +' title="Enviar Mail para Firma Digital" '
                                       +' onclick="WSQL(''FIRMA_TASADOR_Firmar_Informe_Firmar_Email_Tasador @numinfor=·'+@numinfor+'·, @automatico=0 '');"'
                                   +'>'
                           end
                          +case when e.estinfor in ('F') and dbo.f_SISTEMA_Accesos_Especiales ('38',@usuario)=1 and @usuario=1 then 
                                   +'<br>'
                                   +'<br>'
                                   +'<img class="click aumenta" '
                                      +' src="img/cancelar_firma_tasador.png" '
                                      +' style="width:1.4vw;height:auto;vertical-align:middle" '
                                      +' title="Forzar la Salida sin Firma del tasador" '
                                      +' onclick="WSQL(''FIRMA_TASADOR_Firmar_Informe_Salida_Sin_Firmar @numinfor=·'+@numinfor+'· '');"'
                                   +'>'
                              else '' 
                         end
           ------------------------------------------------------------------------------------------------
           from TH_Informes n (nolock) 
           inner join CORITEL.dbo.taoencar e (nolock) on e.numinfor=n.numinfor
           left outer join TH_Tasadores t(nolock) on t.codtasad=e.codtasad
           outer apply (select top 1 [sizebinario]=datalength(d.pdffinalcliente)
                                   , [cod_th_docum]=d.codigo 
                        from DBSGD.dbo.th_docum d (nolock) 
                        where d.numinfor=e.numinfor
                       ) d
           outer apply (select top 1 [fecha_firma]=fd.fecha_firma 
                                    ,[autorizado] =fd.autorizado 
                                    ,[modelo]     =fd.modelo_firma 
                        from DBSGD.dbo.th_docum_firmas_digitales fd (nolock) 
                        where fd.codigo_th_docum=d.cod_th_docum
                       ) fd
           outer apply (select [items]=count(*)
                        from FIRMA_DIGITAL_Control_ConAvd_Importe [rc3] (nolock) 
                        where [rc3].numinfor=e.numinfor
                          and [rc3].estinfor='3'
                       ) [rc3]
           outer apply (select [items]=count(*)
                        from FIRMA_DIGITAL_Control_ConAvd_Importe [rc4] (nolock) 
                        where [rc4].numinfor=e.numinfor
                          and [rc4].estinfor in ('4','5','6')
                       ) [rc4]
           where n.codigo=@codigo

           ---------------------------------------------------------------                       
           ---------------------------------------------------------------

           select @fileIdNotas+=fileId+';' from NOTASIMPLE_solicitudes ns (nolock) where ns.numinfor=@numinfor
           
           if len(@fileIdNotas)>0
              begin
                 set @fileIdNotas=left(@fileIdNotas,len(@fileIdNotas)-1)
              end
         
           ----------------------------
           -- Tarificacion de Factura
           ----------------------------
           
           if @estinfor in ('3','4')
              begin
                 set @tarifa_facturacion=CORITEL.dbo.f_FACTURACION_TARIFADA (@numinfor, null) 
                 if @tarifa_facturacion is not null
                    begin
                       set @tipo_tarifa_facturacion=
                           case when left(@tarifa_facturacion,1)='T' then 'Tar. TH'
                                when left(@tarifa_facturacion,1)='G' then 'Fac. Grupo'
                                when left(@tarifa_facturacion,1)='A' then 'Tar. Cliente'
                                when left(@tarifa_facturacion,1)='E' then 'Tar. Especial'
                                when left(@tarifa_facturacion,1)='X' then 'Sin Codificar'
                                when left(@tarifa_facturacion,1)='C' then 'Sin Tarifa'
                                else                                      '¿?'  
                           end
                       set @tarifa_facturacion=substring(@tarifa_facturacion,2,100)
                       if isnumeric(@tarifa_facturacion)=1
                          begin
                             set @importe_tarifa_facturacion=convert(decimal(19,2),@tarifa_facturacion)
                          end
                        else 
                          begin
                             set @importe_tarifa_facturacion=0
                          end
                    end
              end
            else
              begin
                  set @tipo_tarifa_facturacion=''
                  set @importe_tarifa_facturacion=0
              end  
           -----------------
 
           select @opcionesAbanca=dbo.TH_Informes_crea_html_opciones (@numinfor,@usuario ,'A')  
           --set @pendienteAbanca='<img class="click" align="right" onclick= " WHTML_General(''CORITEL.dbo.TSG_Lista_Consulta 0,0,1'',1);" src="./img/ico_PendienteAbanca.png" title="Lista Pendiente Abanca" />'
          
           -----------------
           
           --select * from NOTASIMPLE_estado_solicitud         
           select @ns_pte  =sum(case when sns.fk_estado in (1,4,6)               then 1 else 0 end) -- pte
                 ,@ns_ko   =sum(case when sns.fk_estado in (2,5,8,9,10,11,12,13) then 1 else 0 end) -- ko
                 ,@ns_ok   =sum(case when sns.fk_estado in (3,7 )                then 1 else 0 end) -- ok
           from NOTASIMPLE_solicitudes sns (nolock) 
           where sns.numinfor=@numinfor 
           
           ----------------- 
           
           declare @bruto      decimal(19,2)
                  ,@minutas    decimal(19,2)
                  ,@rappel     decimal(19,2)
                  ,@gastos     decimal(19,2)
           
           select @bruto     =sum(isnull(h.bruto          ,0))
                 ,@minutas   =sum(isnull(h.minutas        ,0))
                 ,@rappel    =sum(isnull(h.rappel         ,0))
                 ,@gastos    =sum(isnull(h.gastos_registro,0))
           from TH_Facturacion_Historico h (nolock) 
           where h.numinfor=@numinfor 

           set @lista_clasificacion=
           replace(replace(replace(
           (select [a]='('+ec.codclasif+') '+tc.clasificacion
            from CORITEL.dbo.taoencar_clasificacion ec (nolock)
            outer apply (select top 1 [clasificacion]=ci.descripcion 
                         from CORITEL.dbo.th_clasificacion_informes ci (nolock)
                         where ci.codclasif=ec.codclasif
                        ) [tc]
            where ec.numinfor=@numinfor 
              and ec.anulado=0
            order by ec.fecalta
            for xml path(''), elements),'</span><span>','<br>'),'</span>',''),'<span>','')

            set @ultima_marcacion_gestasa=(select top 1 l.fecha from CORITEL.dbo.taoencar_log l (nolock) where l.numinfor=@numinfor order by l.fecha desc)
            set @ultima_salida_gestasa   =(select top 1 convert(datetime,format(dia,'00/')+format(mes,'00/')+format(año,'0000')+' '+format(hora,'00')+':00:00',103) from GESTASA_XLS_Diario d order by año desc,mes desc ,dia desc ,hora desc)
      
         end

      ---------------------------------

      declare @r varchar(max)
      declare @sombreado_tr varchar(500)='-webkit-box-shadow: 0px 6px 6px 0px rgba(0,0,0,0.33); box-shadow: 0px 6px 6px 0px rgba(0,0,0,0.33)'
      declare @hueco_tr varchar(500)    ='<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px;">'

      select @r=
          '<table class="tabla_grid"  id="#refresco_individual#">'
                +'<tr style="'+@sombreado_tr+';color:#000;'+case when isnull(isnull(e.estinfor,ee.estinfor),'X')='X' then 'text-decoration:line-through;' else '' end +'">'
                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                    +isnull(@Unidad_Informativa,'auto')
                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                    +'<td style="width:3%;text-align:center;" name="Salida">'
                       +case when isnull(@usuario,0)=0 or 1=2 then '' 
                             else 
                             +@hueco_tr
                             +isnull(case when dbo.TH_Informes_Permite_Ser_Frenado(n.numinfor)=1 and @estinfor not in ('X') 
                                          then 
                                            ' <img class="aumenta click imginforme" id="fresi_'+format(n.codigo,'0')+'" src="img\ico_nofrenado.png" title="EXPEDIENTE NO FRENADO. Hacer Click para Frenar el Expediente para Salida"'
                                                +' style="display:'+case when isnull(n.chk_frenado_para_salida,0)=1 then 'none' else '' end +'" '
                                                +' title="EXPEDIENTE NO FRENADO. Hacer Click para Frenar el Expediente para Salida"'
                                                +' onclick=" var mar=document.getElementById(''fresi_'+format(n.codigo,'0')+''');'
                                                          +' var des=document.getElementById(''freno_'+format(n.codigo,'0')+''');'
                                                          +' if (mar.style.display==''none'') {mar.style.display=''''    ;des.style.display=''none'';} '
                                                          +' else                             {mar.style.display=''none'';des.style.display=''''    ;} '
                                                          +' WHTML_General('' TH_Informes_cambiar_frenado '+format(n.codigo,'0')+''',0); " '
                                           +'>'
                                           ----------------------------
                                           +'<img class="aumenta click imginforme" id="freno_'+format(n.codigo,'0')+'" src="img\ico_frenado.png" title="EXPEDIENTE FRENADO. Hacer Click para Liberar el Expediente para Salida"'
                                                +' style="display:'+case when isnull(n.chk_frenado_para_salida,0)=1 then '' else 'none' end +'" '
                                                +' onclick=" var mar=document.getElementById(''fresi_'+format(n.codigo,'0')+''');'
                                                          +' var des=document.getElementById(''freno_'+format(n.codigo,'0')+''');'
                                                          +' if (mar.style.display==''none'') {mar.style.display=''''    ;des.style.display=''none'';} '
                                                          +' else                             {mar.style.display=''none'';des.style.display=''''    ;} '
                                                          +' WHTML_General('' TH_Informes_cambiar_frenado '+format(n.codigo,'0')+''',0); " '
                                           +'>'
                                          else ''
                                     end,'')
                             +isnull(@link_firma_digital,'')
                             +@hueco_tr
                        end
                    +'</td>'     
                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                    +'<td style="width:33%;text-align:left;vertical-align:top;" name="Direcciones">'
                     +case when isnull(@usuario,0)=0 or 1=0 then '' else 
                          +@hueco_tr
                          +'<table style="border-collapse:collapse;width:100%">'
                             +'<tr>'
                                +'<td style="width:5%;vertical-align:middle;text-align:center;border:solid 1px transparent">'
                                    +'<img class="aumenta click imginforme" src="img\ico_'+case when n.latitud is not null then 'gpsverde' else 'gpsrojo' end+'.png"'
                                             +' title="'+case when n.latitud is not null then 'Geolocalizado, Nueva geolocalización'  else 'SIN GEOLOCALIZAR. Acceso a Geolocalización ' end+'"' 
                                    +' onclick="Mapa('''+case when n.latitud is null or n.longitud is null 
                                                              then isnull(dbo.TH_Informes_Direccion_para_Google(@numinfor),'')
                                                              else n.latitud+'###'+n.longitud 
                                                         end+''''
                                                    +','''+case when n.estinfor in ('3','4','5','6','F') then '' 
                                                                else 'TH_Informes'+case when n.latitud is not null or n.longitud is not null 
                                                                                        then isnull('###'+dbo.TH_Informes_Direccion_para_Google(@numinfor),'')
                                                                                        else '' 
                                                                                   end
                                                           end
                                                         +''''
                                                    +','+format(n.codigo,'0')+')" >'
                                +'</td>'
                                +'<td style="width:auto;"><span style="color:#808;font-weight:bold;border:solid 1px transparent">'
                                     +'<span style="display:inline-block;width:100%;vertical-align:middle;word-break:break-all;">'+isnull(dbo.TH_Informes_Direccion_Completa (@numinfor),'')+'</span>'
                                +'</td>'
                                +'<td style="width:15%;vertical-align:middle;text-align:left;border:solid 1px transparent">'
                                     +case when isnull(a.ckh_google_geoposicion,0)=1
                                           then case when isnull(a.google_tipo_localizacion,'')='' 
                                                     then '<img class="aumenta click imginforme" src="img\ico_verantecedentesregenerar.png" title="Regenerar Antecedentes encontrados" onclick="WSQL('' TH_Informes_AutoGeoposicion_Regenerar @numinfor=·'+@numinfor+'· '');">'                                          
                                                     else '<img class="aumenta click imginforme" src="img\ico_verantecedentes.png"          title="Ver Posibles Antecedentes"          onclick="WHTML_General('' TH_Informes_Ver_Posibles_Antecedentes @numinfor=·'+@numinfor+'·, @usuario='+format(@usuario,'0')+'  '',1);">'
                                                     +'<span style="padding-left:0.1vw;display:inline-block;vertical-align:middle;font-weight:bold;">'
                                                       +format(case when isnull(a.google_lista_cercanos,'')='SIN ANTECEDENTES'then 0
                                                                    else (select count(*)-1 from dbo.f_split(a.google_lista_cercanos,'<numinfor>') x where ltrim(rtrim(x.items))!='')
                                                               end,'-> #,0','de-DE')
                                                     +'</span>'
                                                end
                                           else ''
                                      end
                                +'</td>'
                             +'</tr>'
                            -- +'<tr>'
                            --   +'<td><a style="color:#aaa;font-size:80%;">'
                            --       +isnull(n.geo_direccion,'')
                            --       +isnull(', '+n.geo_numero,'')
                            --        +isnull(' '+n.geo_codigo_postal,'')
                            --        +isnull(' '+n.geo_municipio,'')
                            --        +isnull(' '+n.geo_provincia,'')
                            --        +isnull(' ('+n.geo_ISO_pais+')','')
                            --        +'</a>'
                            --        +case when n.latitud is not null 
                            --              then '<a style="padding-left:4px;color:#aaa;font-size:70%;">'+isnull('('+replace(n.latitud,',','.'),'')+isnull(', '+replace(n.longitud,',','.')+')','')+'</a>' 
                            --              else '' 
                            --         end
                            --   +'</td>'
                            -- +'</tr>'
                             -----------------------------------------------------------------
                         +'</table>'
                         -------------------------
                         -- ######################
                         -- Cód. INE y Cód. TOL
                         -- ######################
                         -------------------------
                         +case when 1=1 then '' else 
                               +'<table style="border-collapse:collapse;width:100%;;font-weight:normal;color:#000;">'
                                  +'<tr style="font-size:10%;">'
                                    +'<td style="width: 18%;"></td>'
                                    +'<td style="width: 15%;"></td>'
                                    +'<td style="width: 15%;"></td>'
                                    +'<td style="width:auto;color:#fff">-</td>'
                                    +'<td style="width:  5%;"></td>'
                                  +'</tr>'
                                  --------------------
                                  +case when isnull(a.chk_descartar_autotol,0)=0 and isnull(a.ckh_google_geoposicion,0)=1 and a.calleobj_original is not null then
                                        +'<tr>'
                                          +'<td style="color:#aaa;font-size:80%;border:solid 1px #ddd">'
                                          +case when isnull(@estinfor,'X') not in ('0','1') 
                                                then '' 
                                                else '<img class="aumenta click imginforme" src="img\ico_asignardireccion.png"'
                                                             +' style="padding-right:3px;"'
                                                             +' title="Asignar esta dirección al Encargo"'
                                                             +' onclick="WSQL('' TH_Informes_Cambiar_Direccion @numinfor=·'+@numinfor+'·, @tipo_direccion=·O· '');">'
                                                    +''
                                           end
                                           +'Dir. Original'
                                          +'</td>'
                                          +'<td colspan="5" style="font-size:90%;border:solid 1px #ddd">'
                                                +isnull(a.calleobj_original,'')
                                                +isnull(', '+a.numeobje_original,'')
                                                +isnull('  '+a.pisoobje_original,'')
                                                +case when ltrim(rtrim(isnull(''+a.restdire_original,'')))!='' then '('+ltrim(rtrim(isnull(''+a.restdire_original,'')))+')' else '' end
                                                +isnull('  '+a.cposobje_original,'')
                                                +isnull('  '+a.deslocal_original,'')
                                          +'</td>'
                                        +'</tr>'
                                        else ''
                                   end
                                  +case when @acc_TOL=1 then
                                        +'<tr>'
                                          +'<td style="color:#aaa;font-size:80%;border:solid 1px #ddd">Cód. Ine:</td>'
                                          +'<td style="color:#000;font-size:90%;border:solid 1px #ddd">'+case when isnull(a.codine,'')='' then '<font style="color:red;font-weight:bold;">Falta Cód.Ine</font>' else isnull(a.codine,'') end +'</td>'
                                          +'<td style="color:#aaa;font-size:80%;border:solid 1px #ddd">Cód.TOL:</td>'
                                          +'<td style="font-size:90%;border:solid 1px #ddd" colspan="2">'+case when isnull(a.codtol,'')='' then '<font style="color:red;font-weight:bold;">Falta Cód.TOL</font>' else isnull(a.codtol,'') end +'</td>'
                                        +'</tr>'
                                        +'<tr>'
                                          +'<td style="color:#aaa;font-size:80%;border:solid 1px #ddd">Auto Cód. Ine:</td>'
                                          +'<td style="color:#0a0;font-size:90%;border:solid 1px #ddd">'+isnull(a.autocodine,'')+'</td>'
                                          +'<td style="color:#aaa;font-size:80%;border:solid 1px #ddd">Auto Cód.TOL:</td>'
                                          +'<td style="color:#0a0;font-size:90%;border:solid 1px #ddd" colspan="2">'
                                                +isnull(a.autocodtol,'')+isnull('<font style="padding-left:4px">('+ltrim(rtrim(a.autotipovia_ine))+')</font>','')
                                                +case when n.estinfor in ('4','5','6') and +isnull(a.codtol,'')='' and isnull(a.autocodtol,'')!=''
                                                      then '<img class="aumenta click imginforme"'
                                                                   +' src="img\ico_asignardireccion.png"'
                                                                   +' style="padding-right:3px;"'
                                                                   +' title="Asignar esta TOL al Encargo"'
                                                                   +' onclick="WSQL('' TH_Informes_Asignar_AutoTol_como_Tol @numinfor=·'+@numinfor+'· '');"'
                                                          +'>'
                                                          +''
                                                      else ''
                                                 end
                                          +'</td>'
                                        +'</tr>'
                                        else ''
                                   end
                                  --------------------
                                  +'<tr>'
                                    +'<td style="color:#aaa;font-size:80%;border:solid 1px #ddd">'
                                    +case when isnull(@estinfor,'X') not in ('0','1') then ''
                                          else '<img class="aumenta click imginforme"'
                                                       +' src="img\ico_asignardireccion.png"'
                                                       +' style="padding-right:3px;"'
                                                       +' title="Asignar esta dirección al Encargo"'
                                                       +' onclick="WSQL('' TH_Informes_Cambiar_Direccion @numinfor=·'+@numinfor+'·, @tipo_direccion=·I· '');">'
                                              +''
                                              +'Auto Dir. Ine:'
                                     end 
                                    +'</td>'
                                    +'<td colspan="4" style="color:#0a0;font-size:80%;border:solid 1px #ddd">'
                                          +isnull(dbo.TH_Informes_Direccion_TOL(a.autocodtol,e.pisoobje),'')
                                          +case when a.autocodtol_fiabilidad is not null 
                                                then '<a style="padding-left:5px;color:'+case when a.autocodtol_fiabilidad>90 then 'black'
                                                                                              when a.autocodtol_fiabilidad>70 then 'orange;font-weight:bold;'
                                                                                              else 'red;font-weight:bold;' 
                                                                                         end+';">Fiabilidad INE/Google: '+dbo.fFormato_Money_HTML_Decimales(case when a.autocodtol_fiabilidad>100 then 100 else a.autocodtol_fiabilidad end,2)+'%</a>'
                                                else ''
                                           end
                                    +'</td>'
                                  +'</tr>'
                                  --------------------
                                  +'<tr><td colspan="5" style="font-size:1%;color:#fff;"></td></tr>'
                                  --------------------
                               +'</table>'
                         end
                         --------------------------------------------------
                         -- AutoGeolocalización
                         --------------------------------------------------
                         /*
                            "ROOFTOP"            código geográfico preciso para el que tenemos información de ubicación exacta hasta la precisión de la dirección de la calle.
                            "RANGE_INTERPOLATED" refleja una aproximación (generalmente en una carretera) interpolada entre dos puntos precisos (como intersecciones). Los resultados interpolados generalmente se devuelven cuando los códigos geográficos de la azotea no están disponibles para una dirección postal.
                            "GEOMETRIC_CENTER"   centro geométrico de un resultado como una polilínea (por ejemplo, una calle) o un polígono (región).
                            "APPROXIMATE"        aproximado.
                         */
                         +case when 1=1 then '' else 
                               case when isnull(a.ckh_google_geoposicion,0)=0 then '' else 
                                    '<table style="border-collapse:collapse;width:100%;margin:auto;">'
                                      +'<tr style="height:1px;"><td style="width:10%"></td><td style="width:auto"></td><td style="width:20%"></td></tr>'
                                      +'<tr>'
                                         --------------------------------------------------------------------
                                         +'<td style="text-align:left;">'
                                         +'</td>'
                                         --------------------------------------------------------------------
                                         +'<td>'
                                                +case when isnull(@estinfor,'X') not in ('0','1') then '' 
                                                      else '<img class="aumenta click imginforme" src="img\ico_asignardireccion.png"'
                                                                   +' style="padding-right:3px;"'
                                                                   +' title="Asignar esta dirección al Encargo"'
                                                                   +' onclick="WSQL('' TH_Informes_Cambiar_Direccion @numinfor=·'+@numinfor+'·, @tipo_direccion=·G· '');">'
                                                          +''
                                                 end
                                                +'<a style="color:#aaa;font-size:80%;font-weight:normal;padding-right:5px;vertical-align:middle;"><u>Dir. Google</u></a>'
                                                +case when isnull(a.google_tipo_localizacion,'')='MANUAL'             then '<a style="font-size:90%;color:#7D3C98;vertical-align:middle;">MANUAL - Geoposionada por Usuario</a>'
                                                      when isnull(a.google_tipo_localizacion,'')='ROOFTOP'            then '<a style="font-size:90%;color:#0a0;vertical-align:middle;">ROOFTOP - Exacta</a>'
                                                      when isnull(a.google_tipo_localizacion,'')='RANGE_INTERPOLATED' then '<a style="font-size:90%;color:#a00;vertical-align:middle;">RANGE_INTERPOLATED - Por intersección</a>'
                                                      when isnull(a.google_tipo_localizacion,'')='GEOMETRIC_CENTER'   then '<a style="font-size:90%;color:#a00;vertical-align:middle;">GEOMETRIC_CENTER - Punto medio zona</a>'
                                                      when isnull(a.google_tipo_localizacion,'')='APPROXIMATE'        then '<a style="font-size:90%;color:#a00;vertical-align:middle;">APPROXIMATE - Zona aproximada</a>'
                                                      else                                                                 '<a style="font-size:90%;color:#a00;vertical-align:middle;">Desconocida</a>'
                                                 end
                                                +'<br>'
                                                +'<a style="color:#000;font-size:80%;font-weight:normal;">'+isnull(a.google_direccion,'')+'</a>'
                                         +'</td>'
                                         --------------------------------------------------------------------
                                         +'<td style="text-align:left;border:solid 0px #000;" >'
                                             +'<a style="color:#aaa;font-size:70%;">'+isnull(''+replace(a.google_lat,',','.'),'')+isnull('<br>'+replace(a.google_lon,',','.')+'','')+'</a>'
                                         +'</td>'
                                         --------------------------------------------------------------------
                                       +'</tr>'
                                    +'</table>'
                               end
                          end
                          ----------------------------------
                           +@hueco_tr
                           +dbo.TH_Informes_Botonera_Base (@codigo,@usuario)
                           --======================
                           -- ZONA DE NOTAS SIMPLES
                           --======================
                          +isnull(case when e.estinfor not in ('X','4','5','6','F')
                                        then  
                                          +'<img class="aumenta click imginforme" src="img\registradores_nota_simple.png" title="Solicitud de Nota Registral al Registro Oficial"'
                                          +' onclick="p_busqueda_directa='''+dbo.f_TH_Informes_Datos_Peticion_Nota_Simple (isnull(e.numinfor,ee.numinfor))+''';'
                                                    +' if (!Nuevo_Registro(''XXXX'',''NOTASIMPLE_solicitudes'')) { p_accion=''OTROS''};'
                                                    +' p_accion=''OTROS'';"  '     
                                          +' >'
                                        else ''
                                   end
                                  +case when @ns_pte>0
                                        then   '<img class="aumenta click imginforme" src="img\ico_notas_pendientes.png" title="Acceso a las Solicitudes de Notas Simples Pendientes de Gestión"'
                                              +' onclick="Mostrar_Filtrado_2(''NOTASIMPLE_solicitudes'',''convert(int,tbp.numinfor)='+isnull(e.numinfor,ee.numinfor)+' '')">'
                                              +'<span style="vertical-align:middle;padding-left:0.0vw;font-size:0.70vw;font-weight:bold">'+format(@ns_pte,'-> #,0','de-DE')+'</span>' 
                                        else ''
                                   end
                                  +case when @ns_ko>0
                                        then  '<img class="aumenta click imginforme" src="img\ico_notas_ko.png" title="Acceso a las Solicitudes de Notas Simples KO"'
                                              +' onclick="Mostrar_Filtrado_2(''NOTASIMPLE_solicitudes'',''convert(int,tbp.numinfor)='+isnull(e.numinfor,ee.numinfor)+' '')">'
                                              +'<span style="vertical-align:middle;padding-left:0.0vw;font-size:0.70vw;font-weight:bold">'+format(@ns_ko,'-> #,0','de-DE')+'</span>' 
                                        else ''
                                   end
                                  +case when @ns_ok>0
                                        then  '<img class="aumenta click imginforme" src="img\ico_notas_ok.png" title="Acceso a las Solicitudes de Notas Simples OK"' 
                                              +' onclick="Mostrar_Filtrado_2(''NOTASIMPLE_solicitudes'',''convert(int,tbp.numinfor)='+isnull(e.numinfor,ee.numinfor)+' '')">'
                                              +'<span style="vertical-align:middle;padding-left:0.0vw;font-size:0.70vw;font-weight:bold">'+format(@ns_ok,'-> #,0','de-DE')+'</span>' 
                                              +'<img class="aumenta click imginforme" src="img\ico_ver_ficheros.png" title="Acceso al pdfs de las notas simples" onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura('''+isnull(@fileIdNotas,'')+''',''NOTASIMPLE_solicitudes'',''fileId'',0)">'
                                        else ''
                                   end
                                  +case when exists(select * from INFOREGISTRO_Notas_Simples (nolock) where numinfor=isnull(isnull(e.numinfor,ee.numinfor),'XXXXXXXXXXX'))
                                         then '<img class="aumenta click imginforme" src="img\ico_notas_simples_adheridas.png" title="Notas Simples Adheridas a la Solicitud" onclick="Mostrar_Filtrado(''INFOREGISTRO_Notas_Simples'',''numinfor'','''+isnull(isnull(e.numinfor,ee.numinfor),'XXXXXXXXXXX')+''')" >'    
                                         else ''
                                   end                                
                                   ,'null en Notas Reg.')
                           -------------------------------------
                           + dbo.TH_Informes_Botonera (@codigo, @usuario)
                           -------------------------------------
                           --+@hueco_tr
                           +case when 1=2 then '' else 
                                ------------------------------------------------
                                case when isnull(@lista_clasificacion,'')!='' 
                                     then @hueco_tr
                                     else ''
                                end
                                +isnull(@lista_clasificacion,'')
                                ------------------------------------------------
                                +case when @ultima_marcacion_gestasa is not null then
                                      +@hueco_tr
                                      + case when @ultima_salida_gestasa<@ultima_marcacion_gestasa then 
                                             '<span style="vertical-align:middle;">Próximo Envío Gestasa: '+format(@ultima_marcacion_gestasa,'dd/MM/yyyy HH:mm:ss')+'</span>'
                                             else 
                                             '<span style="vertical-align:middle;">Últ. Envío Gestasa: '+format(@ultima_marcacion_gestasa,'dd/MM/yyyy HH:mm:ss')+'</span>'
                                             +'<img class="aumenta click imginforme" src="img\marcar_para_envio_gestasa.png" title="Marcar para mandar a Gestasa en el próximo envío"'
                                                 +' onclick="Pide_Parametros( '''
                                                 +'{confirmacion|Marcar para Enviar a Gestasa el informe '+@numinfor+' en próximo envío||}'
                                                 +' '',''WSQL(··TH_Informes_Generar_Salida_Gestasa @numinfor=·'+@numinfor+'· ··)'');">'
                                        end
                                      else '' 
                                 end
                            end
                           --======================
                           -- ZONA DE última Incidencia
                           --======================

                           +isnull('<section style="display:inline-block;width:100%;border:solid 1px #ddd">'
                                   +replace((select top 1 
                                             dbo.grid_TH_incidencias(i.codigo,1) 
                                             from TH_incidencias i (nolock) 
                                             where i.numinfor=@numinfor
                                             order by i.fecha_inicio desc),'class="tabla_grid"','')+'</section>','')
                            +@hueco_tr
                        end
                    +'</td>'
                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                    --+case when 1=2 then '' else 
                    --+'<td style="width:10%;text-align:center;vertical-align:top;" name="Notas Reg.">'
                    --  +case when @usuario=0 or 1=0 then '' else 
                    --    +@hueco_tr
                    --    +isnull(
                    --    --======================
                    --    -- ZONA DE NOTAS SIMPLES
                    --    --======================
                    --    case when e.estinfor not in ('X','4','5','6','F')
                    --         then  
                    --           +'<img class="aumenta click imginforme" src="img\registradores_nota_simple.png" title="Solicitud de Nota Registral al Registro Oficial"'
                    --           +' onclick="p_busqueda_directa='''+dbo.f_TH_Informes_Datos_Peticion_Nota_Simple (isnull(e.numinfor,ee.numinfor))+''';'
                    --                     +' if (!Nuevo_Registro(''XXXX'',''NOTASIMPLE_solicitudes'')) { p_accion=''OTROS''};'
                    --                     +' p_accion=''OTROS'';"  '     
                    --           +' >'
                    --           +'<hr style="width:50%;border:solid 0px;border-top:solid 1px #ddd;padding:0px;"></hr>'
                    --         else ''
                    --    end
                    --   +case when @ns_pte>0
                    --         then   '<img class="aumenta click imginforme" src="img\ico_notas_pendientes.png" title="Acceso a las Solicitudes de Notas Simples Pendientes de Gestión"'
                    --               +' onclick="Mostrar_Filtrado_2(''NOTASIMPLE_solicitudes'',''convert(int,tbp.numinfor)='+isnull(e.numinfor,ee.numinfor)+' '')">'
                    --               +'<a class="items_relativo">'+ltrim(str(@ns_pte))+'</a>'
                    --         else ''
                    --    end
                    --   +case when @ns_ko>0
                    --         then  '<img class="aumenta click imginforme" src="img\ico_notas_ko.png" title="Acceso a las Solicitudes de Notas Simples KO"'
                    --               +' onclick="Mostrar_Filtrado_2(''NOTASIMPLE_solicitudes'',''convert(int,tbp.numinfor)='+isnull(e.numinfor,ee.numinfor)+' '')">'
                    --               +'<a class="items_relativo">'+ltrim(str(@ns_ko))+'</a>'
                    --         else ''
                    --    end
                    --   +case when @ns_ok>0
                    --         then  '<img class="aumenta click imginforme" src="img\ico_notas_ok.png" title="Acceso a las Solicitudes de Notas Simples OK"' 
                    --               +' onclick="Mostrar_Filtrado_2(''NOTASIMPLE_solicitudes'',''convert(int,tbp.numinfor)='+isnull(e.numinfor,ee.numinfor)+' '')">'
                    --               +'<a class="items_relativo">'+ltrim(str(@ns_ok))+'</a>'
                    --               +'<img class="aumenta click imginforme" src="img\ico_ver_ficheros.png" title="Acceso al pdfs de las notas simples" onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura('''+isnull(@fileIdNotas,'')+''',''NOTASIMPLE_solicitudes'',''fileId'',0)" >'
                    --         else ''
                    --    end
                    --   +case when exists(select * from INFOREGISTRO_Notas_Simples (nolock) where numinfor=isnull(isnull(e.numinfor,ee.numinfor),'XXXXXXXXXXX'))
                    --          then '<img class="aumenta click imginforme" src="img\ico_notas_simples_adheridas.png" title="Notas Simples Adheridas a la Solicitud" onclick="Mostrar_Filtrado(''INFOREGISTRO_Notas_Simples'',''numinfor'','''+isnull(isnull(e.numinfor,ee.numinfor),'XXXXXXXXXXX')+''')" >'    
                    --          else ''
                    --    end                                
                    --    ,'null en Notas Reg.')
                    --    +@hueco_tr
                    --  end
                    --+'</td>'
                    --end
                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                    +'<td style="width:25%;text-align:left;font-size:0.50vw;vertical-align:top;" name="Solicitante/Contacto/Obs/Tabla Facturación">'
                      +case when isnull(@usuario,0)=0 or 1=0 then '' else 
                            @hueco_tr
                            -------------------------------------------
                            -- Tratamiento de los Email Doc y Email Fac 
                            -------------------------------------------
                            +case when n.codigo is null then '' else 
                                 +'<img class="aumenta" title="Modificar Email de Salidas" src="img\modificar_email_doc_fac.png" style="vertical-align:middle;width:1.5vw;height:auto;cursor:pointer;"'
                                 +' onclick='
                                 +'" var  p='''';'
                                       +' p+=''{texto |Direcciones de Envío Documentos Informe Nº'+isnull(aa.numinfor,'')+'<br><br><br>|Email Documentación:|'+coalesce(aa.email_doc,a.email_doc,'')+'|}'';'
                                       +' p+=''{texto ||Email Factura:|'+coalesce(aa.email_fac,a.email_fac,'')+'|}'';'
                                       +' var e=''WSQL(··TH_Informes_Grabar_Email_Doc_Fac @numinfor   =·'+isnull(e.numinfor,'')+'·'
                                                                                         +', @email_doc=·#parametro_value_1#·'
                                                                                         +', @email_fac=·#parametro_value_2#·'
                                                                                         +', @fk_usuario='+ltrim(str(@usuario))+' ··)''; '
                                       +' Pide_Parametros(p,e);'
                                 +'">' 
                                 +isnull('<span style="color:red;">'+replace(replace(coalesce(aa.email_doc,a.email_doc,''),';;',';'),';','<span style="display:inline-block;width:0.3vw;">,</span>'),'')
                                 +isnull('<br><span style="display:inline-block;width:1.5vw;"></span>'
                                              +replace(replace(coalesce(aa.email_fac,a.email_fac,''),';;',';'),';','<span style="display:inline-block;width:0.3vw;">,</span>'),'')
                            end
                           ---------------------------------------------------------------
                           -- Agregar los ficheros de forma Manual (sólo algunos usuarios)
                           ---------------------------------------------------------------
                           +case when isnull(@usuario,0) not in (1,2,2734,2719) then '' 
                                 when e.estinfor not in ('3','4','5','6','F')   then ''
                                 else '<br>'
                                      -----------------------------------------------------------
                                      +'<img style="padding-left:0px;vertical-align:middle;" class="click" '+dbo.f_SISTEMA_Icono('agregar_documento',24,24)+' '
                                      +' title="Agregar PDFFinal Cliente de forma Manual" '
                                      +' onclick="Show_Capa_Fichero_Grid(''TH_Informes'',''pdffinalcliente'','+format(n.codigo,'#')+')" />' 
                                      + case when n.pdffinalcliente is null then '' else '<img class="click" style="padding-left:3px;vertical-align:middle;" '+dbo.f_SISTEMA_Icono('ver_ficheros',24,24)+' '
                                          +' title="Ver PDFFinal Cliente de forma Manual" '
                                          +' onclick="Show_Lista_Ficheros_Ristra('''+replace(n.pdffinalcliente,';;',';')+''',''TH_Informes'',''pdffinalcliente'','+format(n.codigo,'#')+')"'
                                          +' />'
                                        end
                                      -----------------------------------------------------------
                                      +' <img style="padding-left:10px;vertical-align:middle;" class="click" '+dbo.f_SISTEMA_Icono('agregar_documento',24,24)+' '
                                      +' title="Agregar PDF Documento Tasacion de forma Manual" '
                                      +' onclick="Show_Capa_Fichero_Grid(''TH_Informes'',''docpdf'','+format(n.codigo,'#')+')" />' 
                                      + case when n.docpdf is null then '' else '<img class="click" style="padding-left:3px;vertical-align:middle;" '+dbo.f_SISTEMA_Icono('ver_ficheros',24,24)+' '
                                          +' title="Ver PDF Documento Tasacion" '
                                          +' onclick="Show_Lista_Ficheros_Ristra('''+replace(n.docpdf,';;',';')+''',''TH_Informes'',''docpdf'','+format(n.codigo,'#')+')"'
                                          +' />'
                                        end
                                      -----------------------------------------------------------
                                      +' <img style="padding-left:10px;vertical-align:middle;" class="click" '+dbo.f_SISTEMA_Icono('agregar_documento',24,24)+' '
                                      +' title="Agregar PDF Certificado e forma Manual" '
                                      +' onclick="Show_Capa_Fichero_Grid(''TH_Informes'',''certpdf'','+format(n.codigo,'#')+')" />' 
                                      + case when n.certpdf is null then '' else '<img class="click" style="padding-left:3px;vertical-align:middle;" '+dbo.f_SISTEMA_Icono('ver_ficheros',24,24)+' '
                                          +' title="Ver PDF Certificado subido de forma Manual" '
                                          +' onclick="Show_Lista_Ficheros_Ristra('''+replace(n.certpdf,';;',';')+''',''TH_Informes'',''certpdf'','+format(n.codigo,'#')+')"'
                                          +' />'
                                        end
                                      -----------------------------------------------------------
                                      +'<br>'
                            end
                            ---------------------------------------------------------------
                            +case when 1=2 then '' else 
                                  isnull(
                                     --=====================
                                     -- ZONA DE SOLICITANTE
                                     --=====================
                                     +'<hr style="width:50%;border:solid 0px;border-top:solid 1px #aaa"></hr>'
                                     +'<span style="display:inline-block;color:#a0a;font-size:0.55vw;">'
                                        +case when len(isnull(ltrim(rtrim(s.nomsolic))+' ',''))>50 then left(isnull(ltrim(rtrim(s.nomsolic))+' ',''),50)+'....' else isnull(ltrim(rtrim(s.nomsolic))+' ','') end 
                                        +isnull(ltrim(rtrim(s.apel1sol))+' ','')
                                        +isnull(ltrim(rtrim(s.apel2sol))+' ','')
                                        +isnull(' ('+ltrim(rtrim(s.codigo))+')','')
                                     +'</span>'
                                     --+ dbo.f_SISTEMA_HTML_Expande_Contrae_Div ('datos_solicitante_'+isnull(e.numinfor,ee.numinfor))
                                     --+'<div id="datos_solicitante_'+isnull(e.numinfor,ee.numinfor)+'" style="display:none;">'
                                     +'<br><span style="display:inline-block;color:#a0a;font-size:0.55vw;">'+isnull(ltrim(rtrim(s.nifsolic))+' ','')+'</span>'
                                     +'<br><span style="display:inline-block;color:#a0a;font-size:0.55vw;">'
                                           +isnull(ltrim(rtrim(s.diresoli))+' ','')
                                           +isnull(ltrim(rtrim(s.cpossoli))+'','')
                                           +' '+isnull(ltrim(rtrim(s.deslocal))+' ','')+isnull('('+ltrim(rtrim(ps.desprovi))+')','')
                                     +'</span>'
                                     --+'</div>'
                                     /*
                                     --==================
                                     -- ZONA DE TASADOR
                                     --==================
                                     +'<hr style="width:50%;border:solid 0px;border-top:solid 1px #aaa"></hr>'
                                     +case when isnull(e.codtasad,isnull(ee.codtasad,''))<>'' 
                                           then '<span style="display:inline-block;color:#000;font-size:0.55vw;">'
                                                  +isnull(ltrim(rtrim(ta.nomtasad))+' ','')
                                                  +isnull(ltrim(rtrim(ta.ap1tasad))+' ','')
                                                  +isnull(ltrim(rtrim(ta.ap2tasad))+' ','')
                                                  +isnull(' ['+isnull(e.codtasad,ee.codtasad)+']','')
                                               +'</span>'
                                               +case when isnull(ts.porcentaje_minuta_facturacion,0)!=0 then 
                                                     '<br><span style="color:red">Minuta por %Fact.: '+format(ts.porcentaje_minuta_facturacion,'#,#.0000','de-DE')+'</span>'
                                                     else ''  
                                                end
                                              -- + dbo.f_SISTEMA_HTML_Expande_Contrae_Div ('datos_tasador_'+isnull(e.numinfor,ee.numinfor))
                                              -- +'<div id="datos_tasador_'+isnull(e.numinfor,ee.numinfor)+'" style="display:none;">'
                                                    +'<br><span style="display:inline-block;color:#000;font-size:0.55vw;">'+isnull(ltrim(rtrim(tt.movil))+' ','')+'</span>'
                                                    +'<span style="display:inline-block;color:#000;font-size:0.55vw;">'+isnull(' ('+ltrim(rtrim(mt.email))+')','')+'</span>'
                                                    +'<br>'
                                                    +'<span style="display:inline-block;color:#aa0;font-size:0.55vw;">'
                                                       +isnull(ltrim(rtrim(dt.diretasa))+' ','')+isnull(ltrim(rtrim(dt.codposta))+'','')+' '+isnull(ltrim(rtrim(lt.deslocal))+' ','')+isnull('('+ltrim(rtrim(pt.desprovi))+')','')
                                                    +'</span>'
                                               --+'</div>'
                                           else ''    
                                      end
                                      */
                                      ,'null en Solicitante/Tasador')
                               end
                               --==================
                               -- ZONA DE CONTACTO
                               --==================
                               +case when 1=2 then '' else 
                                      '<table style="border-collapse:collapse;width:100%">'
                                        +'<tr>'
                                          +'<td colspan="2"><hr style="width:50%;border:solid 0px;border-top:solid 1px #ddd;padding:0px;"></hr></td>'
                                        +'</tr>'
                                        +'<tr>'
                                        +'<td style="color:#aaa;font-size:70%;font-weight:normal;width:10%;">Contacto:</td>'
                                        +'<td style="color:#080;font-size:80%;width:auto;">'
                                             +isnull(replace(replace(replace(convert(varchar(max),(select a.items [a] from dbo.f_split(isnull(ltrim(rtrim(isnull(e.contacto,ee.contacto))),'')+isnull(','+ltrim(rtrim(isnull(e.tel1cont,ee.tel1cont))),'')+isnull(','+ltrim(rtrim(isnull(e.tel2cont,ee.tel2cont))),''),',') a where a.items!='' for xml path(''), elements)),'</a><a>',', '),'</a>',''),'><a>',''),'')
                                        +'</td>'
                                        +'</tr>'
                                        +case when isnull((select top 1 ltrim(rtrim(codgrup))+'-'+ltrim(rtrim(x.Desgrupo)) from EXPLOTACION.dbo.taoclientes x (nolock) where x.codentid=isnull(e.codentid,ee.codentid)),'')='' then '' else 
                                             +'<tr>'
                                             +'<td style="color:#aaa;font-size:70%;font-weight:normal;">Grupo:</td>'
                                             +'<td style="color:#080;font-size:80%;">'
                                                 +isnull((select top 1 ltrim(rtrim(codgrup))+'-'+ltrim(rtrim(x.Desgrupo)) from EXPLOTACION.dbo.taoclientes x (nolock) where x.codentid=isnull(e.codentid,ee.codentid)),'')
                                             +'</td>'
                                             +'</tr>'
                                        end
                                        +case when isnull(ltrim(rtrim(isnull(e.textlibr,ee.textlibr)))+' ','')='' then '' else 
                                             +'<tr>'
                                             +'<td style="color:#aaa;font-size:70%;font-weight:normal;">Obs:</td>'
                                             +'<td style="color:#000;font-size:70%;font-weight:normal;">'+isnull(ltrim(rtrim(isnull(e.textlibr,ee.textlibr)))+' ','')+'</td>'
                                             +'</tr>'
                                        end
                                     +'</table>'
                                end
                                --=====================
                                -- ZONA DE FACTURACION
                                --=====================
                                --+case when e.estinfor not in ('3','4','5','6','F')  then '' else 
                                --      '<img class="click" style="width:1.4vw;height;auto" src="img\test_excepcion.png" title="Test de Excepciones de Facturación de un Informe" onclick="WHTML_General(''FACTURACION_Excepciones_Calcular @numinfor=·'+@numinfor+'·, @ver_datos=1, @debug=0'', 1);">' 
                                -- end
                                -- +isnull(@opcionesAbanca,'')
                                ------------------------------------------------------------------
                                +isnull('<table border="1" bordercolor="#dddddd" style="width:70%;border-collapse:collapse;font-size:0.55vw;">'
                                        +case when e.estinfor not in ('3','4','5','6','F') then '' else 
                                              isnull('<tr>'
                                                        +'<td style="width:70%;text-align:right">'
                                                          +'<img class="click" style="vertical-align:middle;width:1vw;height;auto;padding-right:0.5vw"'
                                                              +' src="img\test_excepcion.png"'
                                                              +' title="Test de Excepciones de Facturación de un Informe"'
                                                              +' onclick="WHTML_General(''FACTURACION_Excepciones_Calcular @numinfor=·'+@numinfor+'·, @ver_datos=1, @debug=0'', 1);">' 
                                                          +'<span style="display:inline-block;width:8vw;vertical-align:middle;border:solid 1px transparent">Tarifa</span>'
                                                        +'</td>'
                                                        +'<td style="width:auto;text-align:right;color:#080;">'+isnull('('+@tipo_tarifa_facturacion+') ','')+dbo.fFormato_Money_HTML_Decimales(isnull(@importe_tarifa_facturacion,0),2),2)+' €</td>'
                                                    +'</tr>' 
                                         end
                                        +case when isnull(@bruto  ,0)=0 or e.estinfor not in ('3','4','5','6','F') then '' else isnull('<tr><td style="width:30%;text-align:right">Facturación     </td><td style="text-align:right;color:#080;">'+dbo.fFormato_Money_HTML_Decimales(isnull(@bruto  ,0),2)+' €</td></tr>','') end
                                        +case when e.estinfor not in ('3','4','5','6','F') then '' 
                                                   else isnull('<tr>'
                                                                 +'<td style="text-align:right">'
                                                                    +'<img class="click" style="vertical-align:middle;width:1vw;height;auto;padding-right:0.5vw"'
                                                                        +' src="img\test_excepcion.png"'
                                                                        +' title="Test de Excepciones de Minutación de un Informe"'
                                                                        +' onclick="WHTML_General(''MINUTACION_Excepciones_Calcular @numinfor=·'+@numinfor+'·, @ver_datos=1, @debug=0'', 1);">' 
                                                                    +'<span style="display:inline-block;width:5vw;vertical-align:middle;border:solid 1px transparent;">Minuta</span>'
                                                                    +isnull('<span style="display:inline-block;width:3vw;vertical-align:middle;border:solid 1px transparent;">('+CORITEL.dbo.f_MINUTA_TARIFADA(@numinfor,null)+')</span>','')
                                                                 +'</td>'
                                                                 +'<td style="text-align:right;color:#800;">'+format(isnull(@minutas,0),'#,0.00','de-DE')+' €</td>'
                                                              +'</tr>','') end
                                        
                                        +case when isnull(@rappel ,0)=0 or e.estinfor not in ('3','4','5','6','F') then '' else isnull('<tr><td style="width:30%;text-align:right">Rappel          </td><td style="text-align:right;color:#800;">'+dbo.fFormato_Money_HTML_Decimales(isnull(@rappel ,0),2)+' €</td></tr>','') end
                                        +case when isnull(@gastos ,0)=0 or e.estinfor not in ('3','4','5','6','F') then '' else isnull('<tr><td style="width:30%;text-align:right">Registro        </td><td style="text-align:right;color:#800;">'+dbo.fFormato_Money_HTML_Decimales(isnull(@gastos ,0),2)+' €</td></tr>','') end
                                        +case when isnull(n.kms_desplazamiento,0)=0                                then '' else isnull('<tr><td style="width:30%;text-align:right">Kilómetros      </td><td style="text-align:right;color:#800;">'+dbo.fFormato_Money_HTML_Decimales(isnull(n.kms_desplazamiento,0),0)+' kms'+case when isnull(n.motivo_kms_desplazamiento,'')='' then '' else isnull('<br>('+n.motivo_kms_desplazamiento+')','') end+'</td></tr>','') end
                                        -----------------       
                                        --BRF (CAX)
                                        -----------------
                                        +case when e.fecalta>=convert(datetime,'01/01/2025') then '' -- Abanca no se trata
                                              when CORITEL.dbo.f_Soy_Caixa_Galicia(@numinfor)='S' and @numinfor='20009490' then '<td style="text-align:right"><a class="click" onclick="Mostrar_Filtrado(''TH_Prefacturas'',''numinfor'','''+@numinfor+''')">Prefactura Abanca</a>'
                                              when CORITEL.dbo.f_Soy_Caixa_Galicia(@numinfor)='S' and exists (select * from CORITEL..th_prefacturas (nolock) f where numinfor=@numinfor)  then
                                               replace(isnull('<tr><td style="30%;text-align:right"><a class="click" onclick="Mostrar_Filtrado(''TH_Prefacturas'',''numinfor'','''+@numinfor+''')">Prefactura Abanca</a></td>'
                                               +'<td style="auto;text-align:right;color:#080;">'+(select ''+str(isnull(codigo,0)) +'$br$Alb '+ str(isnull(numero_albaran,0)) +'$br$Imp '+dbo.fFormato_Money_HTML_Decimales(isnull(totfactu,0),2) from CORITEL..th_prefacturas (nolock) f where numinfor=@numinfor for xml path(''))+'</td></tr>',''),'$br$','<br/>')
                                                +replace(replace(replace(isnull(
                                                +(select '$tr#$td style="30%;text-align:right"@#SBE Prefactura Abanca $br@#'+'$a class="click" onclick="Mostrar_Filtrado(''TH_Prefacturas'',''numinfor'','''+isnull(f.numinfor,'')+''')"#'+ isnull(f.numinfor,'')
                                                        +'$@a#'
                                                        +'$@td#$td style="auto;text-align:right;color:#080;"#'+''+str(isnull(f.codigo,0)) +'$br@#Alb '+ str(isnull(f.numero_albaran,0)) +'$br@#Imp '+ dbo.fFormato_Money_HTML_Decimales(isnull(f.totfactu,0),2)+
                                                        +' $@td#$@tr#'
                                                 from CORITEL..th_prefacturas (nolock) f
                                                 where f.numinfor=@numinfor
                                                   and exists( select * 
                                                               from CORITEL..TSG_bienes_encargo        tsgBE     (nolock) 
                                                                 left join CORITEL..TSG_encargos       tsgE      (nolock) on      tsgE.clave_solicitud=tsgBE.clave_solicitud  
                                                                 left join CORITEL..TSG_bienes_encargo tsgBE_act (nolock) on tsgBE_act.clave_solicitud= tsgE.ref_act  
                                                               where tsgBE.numinfor=@numinfor
                                                                 and tsgE.subtipo_informe='SBE')
                                                for xml path(''))
                                                ,'')
                                                ,'$','<'),'@','/'),'#','>')
                                              else ''   
                                         end
                                         +'</table>','')
                             +@hueco_tr
                      end
                    +'</td>'

                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                    /*
                    +'<td style="width:10%;text-align:left;font-size:70%;vertical-align:top;" name="Entidad/Oficina/Dpto/Pedido por" >'
                      +case when isnull(@usuario,0)=0 or 1=2 then '' 
                            else isnull(
                            --=========================================
                            -- ZONA DE ENTIDAD/OFICINA/DPTO/PEDIDO POR
                            --=========================================
                            +'<a>'
                               +case when len(isnull(ltrim(rtrim(c.desentid))+' ',''))>20 
                                     then left(isnull(ltrim(rtrim(c.desentid))+' ',''),20)+'....' 
                                     else isnull(ltrim(rtrim(c.desentid))+' ','') 
                                end +'<a style="color:#BC141A;font-size:125%;font-weight:bold;"> ['+isnull(ltrim(rtrim(c.codentid)),'')+']</a>'
                            +'</a>'
                            + dbo.f_SISTEMA_HTML_Expande_Contrae_Div ('datos_entidad_'+isnull(e.numinfor,ee.numinfor))
                            +'<div id="datos_entidad_'+isnull(e.numinfor,ee.numinfor)+'" style="display:none;">'
                               +'<a>'
                               +        case when len(isnull(ltrim(rtrim(o.desofici))+' ',''))>20 
                                             then left(isnull(ltrim(rtrim(o.desofici))+' ',''),20)+'....' 
                                             else isnull(ltrim(rtrim(o.desofici))+' ','') 
                                        end +'<a style="color:#BC141A;"> ['+isnull(ltrim(rtrim(o.desofici)),'')+']</a>'
                               +'<br/>'+case when len(isnull(ltrim(rtrim(d.desdepar))+' ',''))>20 
                                             then left(isnull(ltrim(rtrim(d.desdepar))+' ',''),20)+'....' 
                                             else isnull(ltrim(rtrim(d.desdepar))+' ','') 
                                        end +'<a style="color:#BC141A;"> ['+isnull(ltrim(rtrim(d.desdepar)),'')+']</a>'
                               +'</a>'
                            +'</div>'
                            +'<br/>'+isnull('<a style="color:#0a0;">'+ltrim(rtrim(isnull(e.pedidpor,ee.pedidpor)))+'</a>','')
                            ,'null en Entidad/Oficina/Dpto/Pedido') 
                      end
                    +'</td>'
                    */
                    ---------------------------------------------------------
                    --#######################################################
                    ---------------------------------------------------------
                +'</tr>'
                +'</table>'
      from TH_Informes n (nolock)
      outer apply (select top 1 * from CORITEL.dbo.taoencar            e (nolock) where  e.numinfor=n.numinfor                     ) [e]    
      outer apply (select top 1 * from CORITEL.dbo.taoencar_cee       ee (nolock) where ee.numinfor=n.numinfor                     ) [ee]
      outer apply (select top 1 * from CORITEL.dbo.th_encargoadicional a (nolock) where  a.numinfor=n.numinfor                     ) [a]
      outer apply (select top 1 * from CORITEL.dbo.taoprovi           pe (nolock) where pe.codprovi=isnull(e.codprovi,ee.codprovi) ) [pe]
      outer apply (select top 1 * from CORITEL.dbo.taosolic            s (nolock) where  s.codsolic=isnull(e.codsolic,ee.codsolic) ) [s]
      outer apply (select top 1 * from CORITEL.dbo.taoprovi           ps (nolock) where ps.codprovi=s.codprovi                     ) [ps]
      outer apply (select top 1 * from CORITEL.dbo.taotasad           ta (nolock) where ta.codtasad=isnull(e.codtasad,ee.codtasad) ) [ta]
      outer apply (select top 1 * from TH_Tasadores                   ts (nolock) where ts.codtasad=isnull(e.codtasad,ee.codtasad) ) [ts]
      outer apply (select top 1 * from CORITEL.dbo.th_tasmail         mt (nolock) where mt.codtasad=isnull(e.codtasad,ee.codtasad) ) [mt]
      outer apply (select top 1 * from CORITEL.dbo.th_movta           tt (nolock) where tt.codtasad=isnull(e.codtasad,ee.codtasad) ) [tt]
      outer apply (select top 1 * from CORITEL.dbo.taoditas           dt (nolock) where dt.codtasad=isnull(e.codtasad,ee.codtasad) and dt.nudirect=(select max(tx.nudirect) from CORITEL.dbo.taoditas (nolock) tx where tx.codtasad=isnull(e.codtasad,ee.codtasad)) ) [dt]
      outer apply (select top 1 * from CORITEL.dbo.taolocal           lt with(nolock index(PK_taolocal)) where lt.codlocal=dt.codlocal ) [lt]
      outer apply (select top 1 * from CORITEL.dbo.taoprovi           pt (nolock) where pt.codprovi=lt.codprovi                    ) [pt]
      outer apply (select top 1 * from TH_Informes_Pago_Anticipado    aa (nolock) where aa.numinfor=n.numinfor                     ) [aa]
      where n.codigo=@codigo

      return isnull(@r,'')    

end

GO
