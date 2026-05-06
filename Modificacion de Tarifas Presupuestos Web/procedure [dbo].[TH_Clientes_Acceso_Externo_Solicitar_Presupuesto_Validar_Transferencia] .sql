SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Validar_Transferencia @tabla_asociada='TH_Presupuestos_WEB_transferencia_[V20260113202038913]'

ALTER procedure [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Validar_Transferencia] 
      ( @tabla_asociada varchar(500)
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
       ,@paso         char(100)='Sin Iniciar'
       ,@mess         varchar(max)
       ,@npaso        int=0
       ,@fecha_inicio datetime=getdate()
       ,@trancount    int=@@trancount
       ,@traza        varchar(max)

begin try

      set @paso='       '+@prbbdd+' -> Inicio'; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror (@mess,10,1) with nowait

      ------------------------------------------------------------------      
      -- declare @dfecha_aspx datetime=convert(datetime, @fecha_aspx, 121)
      ------------------------------------------------------------------

      declare @fuentecorportativa varchar(200)='Roboto Condensed'
      declare @radius             varchar(80)='1vw 1vw 1vw 1vw'
             ,@sombra             varchar(80)='0px 1px 10px -5px rgba(0,0,0,1)'
             ,@sombra_des         varchar(80)='0px 10px 30px -15px rgba(255,255,255,1)'
       
      declare @html varchar(max)=''

      ----------------------
      -- Cabecera de Página 
      ----------------------
            
      set @html+=
       +'<div id="Principal" style="font-family:'+@fuentecorportativa+';border:solid 0px #a00;width:100%;overflow-y:auto;margin:auto;">'
      
      --#############################################
      -----------------------------------------------
      -- Panel para Editar
      -----------------------------------------------
      --#############################################

      declare @url_fichero         varchar(max)
      declare @extension           varchar(10)
      declare @importe_presupuesto decimal(19,2)
      declare @obj_fichero         varchar(max)
      declare @concepto_transferencia varchar(max)
      declare @fecha_transferencia varchar(10)=format(getdate(),'yyyy-MM-dd')

      select @url_fichero        ='data:application/'+replace(lower([ext].ext),'jpeg','jpg')+';base64,'+dbo.f_BinaryToBase64(f.fileBynari)
            ,@extension          =replace(lower([ext].ext),'jpeg','jpg')
      from SISTEMA_ficheros f (nolock)
      outer apply (select top 1 [ext]=a.items from dbo.f_split(f.fileName,'.') a order by a.i desc) [ext]
      where f.tabla_asociada=@tabla_asociada

      declare @ancho_doc varchar(20)='50vw'
             ,@alto_doc  varchar(20)='80vh'
      if @extension='pdf'
         begin
            set @obj_fichero='<embed style="display:inline-block;width:'+@ancho_doc+';height:'+@alto_doc+'" src="'+@url_fichero+'#toolbar=0&navpanes=0" type="application/'+@extension+'"/>'
         end
      else
        begin
           set @obj_fichero='<img style="display:inline-block;width:'+@ancho_doc+';height:'+@alto_doc+';object-fit:contain" src="'+@url_fichero+'" />'
        end

      if @obj_fichero is null 
         begin
            set @obj_fichero='<div style="font-size:2vw;display:inline-block;width:'+@ancho_doc+';height:'+@alto_doc+';">EL FICHERO DE TRANSFERENCIA NO HA SIDO POSIBLE MOSTRARLO</div>'
         end
      ---------------------------------------------

          declare @grabar_importe_pago varchar(max)=
          ' var errores = [];
                
            if (importetransferencia.value=='''' ) errores.push(''Informar del Importe de la transferencia'');
            if (conceptotransferencia.value=='''') errores.push(''Informar del Concepto de la transferencia'');
            if (fechatransferencia.value=='''' ) errores.push(''Informar de la Fecha de la transferencia'');
            if (errores.length > 0) { alert(errores.join(''\n'')); return }

            var sSQL=''exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Check_Pagado_con_importe'
                     +' @cod_TH_Presupuestos_Web=null,@usuario=null'
                     +',@importe=''+importetransferencia.value+'',@conceptotransferencia=·''+conceptotransferencia.value+''·''+'', @fechatranferencia=·''+fechatransferencia.value+''·'';
            
     
             WSQLExt(sSQL); 
          '

      declare @cancelar_importe_pago varchar(max)=
      ' var aCapaLevantada;
        var aCapas=document.getElementsByClassName(''capale.vantadaiframe'');
        for (var i=0; i<aCapas.length; i++) {aCapaLevantada=aCapas[i]}
        document.body.removeChild(aCapaLevantada);
      '

      declare @html_panel_datos varchar(max)=''
      set @html_panel_datos+=
      +'<div id="panelacciones" style="border:solid 0px #a00;height:100%;width:100%;overflow-y:auto;margin:auto;text-align:left;vertical-align:top">'
          +isnull(@obj_fichero,'')
          +'<div style="vertical-align:top;display:inline-block;width:35%;height:54vh;border:solid 0px red;padding-left:1vw;">'
                +'<br><span style="vertical-align:middle;display:inline-block;width:15vw;padding-right:1vw;font-size:1vw;text-align:right;">Importe Transferencia:</span>'
                +'<input id="importetransferencia" style="vertical-align:middle;display:inline-block;width:10vw;font-size:1vw;text-align:right;height:20px;" type="number" step="0.01" />'
                +'<br><br><span style="display:inline-block;width:15vw;padding-right:1vw;font-size:1vw;text-align:right;">Concepto Transferencia:</span>'
                +'<textarea id="conceptotransferencia" style="min-height:100px;vertical-align:middle;display:inline-block;width:10vw;font-size:1vw;text-align:right;" type="text" /></textarea>'
                +'<br><br><span style="display:inline-block;width:15vw;padding-right:1vw;font-size:1vw;text-align:right;">Fecha Transferencia:</span>'
                +'<input id="fechatransferencia" style="vertical-align:middle;display:inline-block;width:10vw;font-size:1vw;text-align:right;" type="date" value=""/>'
                +'<br><br>'
                +'<section style="display:none">'
                     +'<table>'
                         +'<tr>'
                             +'<td>'   
                                +'<input type="checkbox" id="cuentadestinook" checked style="vertical-align:middle;display:inline-block"/>'
                             +'</td>'
                             +'<td>'
                                +'<span style="display:inline-block;width:30vw;vertical-align:middle;font-size:0.80vw;text-align:center;border:solid 0px #000">'
                                +'Por favor, marque para confirmar que el número de cuenta del justificante corresponde con'
                                +'</span>'
                             +'</td>'
                         +'</tr>'
                         +'<tr>'
                            +'<td></td>'
                            +'<td>'
                               +'<span style="display:inline-block;width:30vw;vertical-align:middle;font-size:0.80vw;text-align:center;border:solid 0px #000">'
                               +'<b>ES45 0049 3754 68 2814274691</b>'
                               +'</span>'
                            +'</td>'
                         +'</tr>'
                         +'<tr>'
                            +'<td></td>'
                            +'<td>'
                               +'<span style="display:inline-block;width:30vw;vertical-align:middle;font-size:0.80vw;text-align:center;border:solid 0px #000">'
                               +'En caso de no coincidir, no se dará por válido el pago'
                               +'</span>'
                            +'</td>'
                         +'</tr>'
                     +'</table>'
                     +'<br><br><br>'
                +'</section>'
                +'<span style="display:inline-block;width:12vw"></span>'
                +'<img class="aumenta" title="Aceptar y Salir" style="vertical-align:middle;cursor:pointer;display:inline-block;width:2vw;height:auto" src="img/ok_transferencia.png" onclick="'+@grabar_importe_pago+'"/>'
                +'<span style="display:inline-block;width:4vw"></span>'
                +'<img class="aumenta" title="Aceptar y Salir" style="vertical-align:middle;cursor:pointer;display:inline-block;width:2vw;height:auto" src="img/ko_transferencia.png" onclick="'+@cancelar_importe_pago+'"/>'
          +'</div>'
      +'</div>'
      +'<img src="img/ok_transferencia.png" style="display:none" onload="importetransferencia.focus();"/>'

      set @html+=@html_panel_datos

      ------------------------------------------------------------------
      ------------------------------------------------------------------

      set @html+=
      +'</div>'

      set @html+=
      +'</html>'


      select '<resultado>OK</resultado>'
            +'<error></error>'
            +'<cssdiv>font-size:1vw;font-family:Arial;background:#ffffff;position:absolute;width:88vw;height:85vh;text-align:center;left:5vw;top:5vh;border:solid 3px #5A99D4; display:table-cell;vertical-align:middle;box-shadow: 0px 0px 15px #5A99D4;</cssdiv>'
            +'<nombre_ventana>Validación del Justificante de Transferencia</nombre_ventana>'
            +'<salida>'+isnull(@html,'No Existen Datos')+'</salida>'
               
end try begin catch
    
    while @@trancount>0 begin rollback end

    declare @p_error varchar(2000)
    set @p_error= 'ERROR EN EL SISTEMA DE DATOS.'+char(13)
                 +'IT Recibirá un Correo informando del mismo para solucionar el problema.'+char(13)

    declare @error_email varchar(max)
    set @error_email= 'NºErr: '+isnull(convert(varchar(300),ERROR_NUMBER()),'')+char(13)+char(13)
                     +'Proc.: '+@prbbdd+char(13)+char(13)
                     +'Línea: '+isnull(convert(varchar(300),ERROR_LINE()),'')+char(13)+char(13)
                     +'Error: '+isnull(convert(varchar(300),ERROR_MESSAGE()),'')+char(13)+char(13)

    set @error_email=replace(replace(@error_email,char(13),'<br/>'),char(10),'<br/>')

    --------------------------------------------------------------------
    --------------------------------------------------------------------
    select ''
          +'<!-- Imagen Cabecera -->' 
          +'<table style="border-collapse:collapse;border:solid #aaa 0px;width:90%;margin:auto">'
          +' <tr style="height:auto;">'
          +'   <td class="normal" style="width:10%;text-align:center;border:solid #aaa 0px"></td>'
          +'   <td class="normal" style="width:auto;text-align:center;border:solid #aaa 0px"><b>ERROR del SISTEMA<b/></td>'
          +' </tr>'
          +'</table>'
          +'<div style="text-align:left;">'+@error_email+'</div>' [innerhtml]
            ,''                                                   [htmliframe]
            ,[urlifram]  ='tickect_'+format(SYSDATETIME(),'yyyyMMddHHmmfffffff')+'.html'

end catch    

end

GO
