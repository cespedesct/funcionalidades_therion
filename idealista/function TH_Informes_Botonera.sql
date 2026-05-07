SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[TH_Informes_Botonera]
                ( @codigo   int 
																 ,@usuario  int 
                )
returns varchar(max)
as
	 begin

     declare @botonera varchar(max)=''
   
     declare @numinfor             varchar(10)
            ,@direccion_informe    varchar(1000)
            ,@estinfor             varchar(10)
            ,@numcerti             varchar(10)=''
            ,@numfinc1             varchar(100)=''
            ,@pisoobje             varchar(100)=''
            ,@acc_geotest          bit=0
            ,@latitud              varchar(100)
            ,@longitud             varchar(100)
            ,@restringido          bit=case when isnull(@usuario, 0)=1 then 1 else 0 end
            ,@acc_version_supersit bit=0
   
     select @numinfor         =isnull(n.numinfor,'')
           ,@estinfor         =v.estinfor
           ,@direccion_informe=isnull(dbo.TH_Informes_Direccion_para_Google(n.numinfor) ,'')
           ,@pisoobje         =v.pisoobje
           ,@numfinc1         =v.numfinc1
           ,@numcerti         =(select top 1 d.numcerti	from DBSGD.dbo.th_certi d(nolock)	where d.numinfor=n.numinfor	order by d.numcerti desc)
   		from TH_Informes n (nolock)
   							inner join CORITEL.dbo.vTaoencar           v (nolock) on  v.numinfor  =n.numinfor
          inner join CORITEL.dbo.th_encargoadicional a (nolock) on  a.numinfor  =n.numinfor
   		where n.codigo=@codigo
   
     ------------------------------------------------------------------------------
   
     set @acc_geotest         =dbo.f_SISTEMA_Accesos_Especiales('ACC005', @usuario)
     set @acc_version_supersit=dbo.f_SISTEMA_Accesos_Especiales('28', @usuario)
   
   		declare @pdffinalcliente bit
   	        ,@docword         bit
   	        ,@docpdf          bit
            ,@fecmodif        datetime
            ,@fecha_firma_digital datetime
            ,@firmado_digital bit
            ,@motivo_no_autorizado varchar(max)
      ------------------------------------------------
      select  @pdffinalcliente     =case when d.pdffinalcliente is not null then 1 else 0 end
   	         ,@docword             =case when d.docword         is not null then 1 else 0 end
   	         ,@docpdf              =case when d.docpdf          is not null then 1 else 0 end
             ,@fecmodif            =d.fecmodif
             ,@fecha_firma_digital =fd.fecha_firma
             ,@firmado_digital     =case when fd.codigo is null then 0 
                                         when fd.autorizado=0 then 0 
                                         when fd.autorizado=1 and fd.fecha_firma is not null then 1 
                                         else 0
                                    end 
             ,@motivo_no_autorizado=case when fd.codigo is null then null 
                                         when fd.autorizado=0 then fd.motivo_noautorizado
                                         else null
                                    end
      from DBSGD.dbo.th_docum d (nolock) 
      outer apply (select top 1 [fecha_firma]        =fd.fecha_firma 
                               ,[autorizado]         =fd.autorizado 
                               ,[motivo_noautorizado]=fd.motivo_no_autorizado
                               ,[codigo]             =fd.codigo 
                   from DBSGD.dbo.th_docum_firmas_digitales fd (nolock) 
                   where fd.codigo_th_docum=d.codigo
                  ) [fd]
      where  d.numinfor=@numinfor
   
      ------------------------------------------------
      select @latitud          =g.latitud
            ,@longitud         =g.longitud
      from CORITEL.dbo.taoencar_gps  g (nolock) 
      where g.numinfor=@numinfor
      ------------------------------------------------
      
      select @botonera+=

      --================================================
      -- ZONA DE ICONOS DEL INFORME
      --================================================
   
   		 ---------------------------------------------------		
   		 +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px;">'						
   		 ---------------------------------------------------		
   	  +'<img class="aumenta click imginforme" src="img\ico_informe_log.png"          title="Ver Log Inf. Nº '+@numinfor+'"                           onclick="WHTML_General(''TH_Informes_HTML_Mostral_Historial ·'+@numinfor+'· '',1);" >'
   	  +'<img class="aumenta click imginforme" src="img\ico_informe_logtecnico.png"   title="Ver Log Técn. Inf. Nº '+@numinfor+'"                     onclick="WHTML_General(''TH_Informes_HTML_Log_Tecnico ·'+@numinfor+'· '',1);" >'
   	  +'<img class="aumenta click imginforme" src="img\ico_historia_supervision.png" title="Ver Versiones e Hist. Supervisión Inf. Nº '+@numinfor+'" onclick="WHTML_General(''TH_Informes_HTML_Mostrar_Versiones ·'+@numinfor+'· '',1);" >'
   	  +'<img class="aumenta click imginforme" src="img\ico_informe_coincidente.png"  title="Ver Posibles Coincidentes Inf. Nº '+@numinfor+'"         onclick="WHTML_General(''TH_Informes_HTML_Mostrar_Coincidencias ·'+@numinfor+'· '',1);" >'
   -- +'<img class="aumenta click imginforme" src="img\ico_informe_anexos.png"       title="Acceso Ficheros Anexos Inf.'+@numinfor+'"                onclick="WHTML_General(''TH_Informes_HTML_Ver_Galeria ·'+@numinfor+'· '',1);" >'
      ----------------------------------------------------          
      +case when exists (select * from ETHER.dbo.TH_Informes_Incidencias_Tecnicas it (nolock) where it.fk_TH_Informes=@codigo) 
            then '<img class="aumenta click imginforme" src="img\ico_informe_validacionestecnicas.png" title="Ver Validaciones Técnicas Inf. Nº '+@numinfor+'" onclick="WHTML_General(''CORITEL.dbo.SUPERSIT_Informacion_Validaciones_Tecnicas ·'+@numinfor+'·,1 '',1);" >'
            else ''
   		  end
      ----------------------------------------------------
   		 +case when @pdffinalcliente=1  then '<img class="aumenta click imginforme" src="img\ico_verpdffinalinforme.png" title="Ver PDF Final Informe '+@numinfor	+'" onclick="WHTML_General('' TH_Descarga_fichero_pdffinalcliente @numinfor=·'+@numinfor+'· '',0);" >' else '' end
   	  +case when @docword=1          then '<img class="aumenta click imginforme" src="img\ico_verdocinforme.png"      title="Ver DOC Informe '      +@numinfor	+'" onclick="WHTML_General('' TH_Descarga_fichero_word @numinfor=·'+@numinfor+'· '',0);" >' else '' end
   	  +case when @docpdf=1           then '<img class="aumenta click imginforme" src="img\ico_verpdfinforme.png"      title="Ver PDF Informe '      +@numinfor	+'" onclick="WHTML_General('' TH_Descarga_fichero_informe_pdf @numinfor=·'+@numinfor+'· '',0);" >'  else '' end
   	  ---------------------------------  
   	  +case when @numcerti is null then ''
   			      when @estinfor in ('4', '5', '6', 'F')
      		    then '<img class="aumenta click imginforme" src="img\ico_verdoccertificado.png" title="Archivo Word último Certificado '+@numinfor	+'" onclick="WHTML_General(''TH_Descarga_certificado @numinfor=·'+@numinfor+'·'',0);" >'
   			      else ''
       end
      ---------------------------------  
      +case when @estinfor in ('X', '0', '1', '2') then ''
            else '<img class="aumenta click imginforme" src="img\ico_imprimirinforme.png" title="Nueva Orden de Generación/Impresión" '
   		           +' onclick="var p=''{texto|Nueva Orden Generacion|Informe|'+@numinfor+'||}'';'
   		                        +' var e=''WSQL(··TH_Informes_Generar_Orden ·#parametro_value_1#· ··)''; '
   		                        +' Pide_Parametros(p,e);'
   		                        +'" >'
       end
       +isnull(case	when @numinfor is not null and isnull(@estinfor, 'Z') in ('3', '4', '5', '6', 'F') or @usuario=1 
                    then '<img class="aumenta click imginforme" src="img\ico_verinforme.png" title="Ver Informe Nº '+@numinfor	+'" onclick="WHTML_General(''TH_Informes_HTML_Ver_Informe ·'+@numinfor+'· '',1);" >'
   		          end, '')
       ----------------------------------	  
       +case when @acc_geotest=0 and 1=2 then ''
   	         else  '<img class="aumenta click imginforme" src="img\ico_geolocalizar.png" title="Acceso al Sistema de GeoAsignación para '+@numinfor+'" '
                  +' onclick="'
                  +' var va=1;'
                  +' if (document.getElementById(''con_1_0'')) {document.getElementById(''con_1_0'').innerHTML='''';}'
   														 +' WHTML_General(''GEOLOCALIZACION_Geolocalizar_Google_Buscar'
                        +' @codigo   ='+ltrim(str(n.codigo))
                        +',@direccion='+case when isnull(@direccion_informe,'')     ='' then 'null' else '·'+isnull(            @direccion_informe,'')+'·' end
   																				 +',@piso     ='+case when isnull(ltrim(rtrim(@pisoobje)),'')='' then 'null' else '·'+isnull(ltrim(rtrim(@pisoobje))       ,'')+'·' end
   																				 +',@finca    ='+case when isnull(ltrim(rtrim(@numfinc1)),'')='' then 'null' else '·'+isnull(ltrim(rtrim(@numfinc1))       ,'')+'·' end
   																				 +',@lat      ='+isnull('·'+replace(isnull(@latitud ,n.latitud ), ',', '.')+'·', 'null')
   																				 +',@lng      ='+isnull('·'+replace(isnull(@longitud,n.longitud), ',', '.')+'·', 'null')
                        +',@usuario  ='+ltrim(str(@usuario))
   																				 +',@numinfor ='+isnull('·'+@numinfor+'·', 'null')
   																				 +' '',1);'
   														 +' var ta=window.setInterval(function()'
                  +'{if (document.getElementById(''carga_mapa_'+ltrim(str(n.codigo))+'''))'
                  +' {$(''#carga_mapa_'+ltrim(str(n.codigo))+''').click();window.clearInterval(ta)}'
                  +' else {va++; if (va>30) {window.clearInterval(ta)} } }, 100);'
                +'"'
               +' >'
        end
       +case when @acc_geotest=0 then ''
             when @estinfor not in ('3','4','5','6','F') then ''
             when @usuario not in (1, 3159, 3053,3204,3191) then ''
   	         else  '<img class="aumenta click imginforme" src="img\idealista_acceso.png" title="Acceso al Sistema de Testigos para '+@numinfor+'" '
                  +' onclick="'
                  +' var va=1;'
                  +' if (document.getElementById(''con_1_0'')) {document.getElementById(''con_1_0'').innerHTML='''';}'
   														 +' WHTML_General(''IDEALISTA_Mapa @numinfor ='+isnull('·'+@numinfor+'·','null')+',@usuario ='+format(@usuario,'0')+' '',1);'
                +'"'
               +' >'
        end
       ----------------------------------
       +case when @restringido=1 
             then '<img class="aumenta click imginforme" src="img\ico_documento_resumen.png" title="Acceso Ficha Resumen de '+@numinfor+'" onclick="WHTML_General(''TH_Informes_HTML_Ficha_Resumen ·'+@numinfor+'· '',0);">'
             else ''
        end
       ----------------------------------
       +case when @restringido=1 
             then  '<img class="aumenta click imginforme" src="img\ico_documento_grafico.png" title="Acceso Ficha Documental de '+@numinfor+'" onclick="WHTML_General(''TH_Informes_HTML_Galeria_Documental ·'+@numinfor+'· '',1);">'
   	         else ''
        end
       +'<img class="aumenta click imginforme" src="img\ico_ftpweb.png" title="Acceso a los registros de FTPWEB"  onclick="Mostrar_Filtrado_2(''TH_Informes_FTWEB'','' charindex(·'+@numinfor+'·,coalesce(tbp.lista_numinfor_TAS,tbp.lista_numinfor_THO,tbp.numinfor))>0 '')" >'
       --------------------
       -- Version SuperSit
       --------------------

   				+case when @acc_version_supersit=1
             then '<img class="aumenta click imginforme" src="img\ver_informe_html.png" title="Ver Informe en Modo SuperSit" ' 
                      +' onclick="window.open(''https://app.tasacioneshipotecarias.com/visorInformes/visorInformes.aspx?INF='+@numinfor+''',''VISOR'',''resizable,width=900,height=1200'');"'
                   +'>'
             else '' 
        end 
        +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px;">'						
   from TH_Informes n (nolock)
   inner join CORITEL.dbo.vTaoencar e (nolock) on  e.numinfor=n.numinfor
   where n.codigo = @codigo

   return @botonera

end
GO
