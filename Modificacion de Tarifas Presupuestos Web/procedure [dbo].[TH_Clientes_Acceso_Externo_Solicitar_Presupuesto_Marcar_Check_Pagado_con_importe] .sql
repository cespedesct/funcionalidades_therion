SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Check_Pagado_con_importe] 
        @cod_TH_Presupuestos_Web int 
       ,@importe                 decimal(19,2)
       ,@conceptotransferencia   varchar(max)
       ,@fechatranferencia       varchar(10)
       ,@usuario                 int
as
begin	
   begin try

         if @cod_TH_Presupuestos_Web is not null
            begin
               update l
                  set l.chk_conciliada_transferencia  =1
                     ,l.fecha_conciliada_transferencia=getdate()
                     ,l.usuario_concilia_transferencia=us.descripcion
                     ,l.importe_concilia_transferencia=@importe
                     ,l.fecha_pago_transferencia      =convert(datetime,@fechatranferencia,121)
                     ,l.importe_pagado                =@importe
                     ,l.referencia_transferencia         =@conceptotransferencia
		             from TH_Presupuestos_Web l
               outer apply (select top 1 us.descripcion from usuarios us (nolock) where us.codigo=@usuario) us
               where l.codigo=@cod_TH_Presupuestos_Web
               
               update i
                  set i.usuario_check_provision=us.descripcion
		             from TH_Presupuestos_Web l
               inner join TH_Informes i on i.numinfor=l.numinfor
               outer apply (select top 1 us.descripcion from usuarios us (nolock) where us.codigo=@usuario) us
               where l.codigo=@cod_TH_Presupuestos_Web
                 and not exists (select i.usuario_check_provision intersect select us.descripcion)
               
               update i
                  set i.importe_provision=@importe
		             from TH_Presupuestos_Web l
               inner join TH_Informes i on i.numinfor=l.numinfor
               outer apply (select top 1 us.descripcion from usuarios us (nolock) where us.codigo=@usuario) us
               where l.codigo=@cod_TH_Presupuestos_Web
                 and not exists (select i.importe_provision intersect select @importe)

               select 'OK'

            end
          else
            begin
                  -----------------------
                  -- Modificado por Fabrizio
                  -----------------------
               select 'OKNORELOAD'
                     +'[INIEVAL]'
                       +'importetransferenciavalidado.value='+replace(isnull(format(@importe,'#.##','de-DE'),''),',','.')+';'
                       +'fechatransferenciavalidado.value="'+isnull(@fechatranferencia,'')+'";'
                       +'conceptotransferenciavalidado.value="'+isnull(@conceptotransferencia,'')+'";'
                       +'var aCapaLevantada;'
                       +'var aCapas=document.getElementsByClassName(''capalevantadaiframe'');'
                       +'for (var i=0; i<aCapas.length; i++) {aCapaLevantada=aCapas[i]}'
                       +'document.body.removeChild(aCapaLevantada);'
                     +'[FINEVAL]'
            end

    end try
    begin catch
          select 'ERROR: '+error_message()
    end catch

end



GO
