SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Editar_DNI_Solicitante] 
       ( @cod_TH_Presupuestos_Web UNIQUEIDENTIFIER 
       ,@dni_actualizado         varchar(20)
       ,@usuario                 int)
  
as
begin	

   begin try
         


               ------------------------------------------
            -- Actualizar DNI en tabla TH_Presupuestos_Web
               ------------------------------------------
         update presupuestos_Web
            set presupuestos_Web.dnisolicitante=@dni_actualizado
            from TH_Presupuestos_Web presupuestos_Web
            WHERE presupuestos_Web.codigo_presupuesto=@cod_TH_Presupuestos_Web
                 ------------------------------------------
              -- Actualizar DNI en tabla taosolic
                 ------------------------------------------
        DECLARE @codsolic varchar(10) = (
            SELECT DISTINCT t.codsolic
            FROM TH_Presupuestos_Web pw
            INNER JOIN CORITEL.dbo.taoencar t ON pw.numinfor = t.numinfor
            WHERE pw.codigo_presupuesto = @cod_TH_Presupuestos_Web
         )

         IF @codsolic IS NOT NULL
         BEGIN
            UPDATE CORITEL.dbo.taosolic 
            SET nifsolic = @dni_actualizado
            WHERE codsolic = @codsolic
         END
         select 'OK'

      
        

    end try
    begin catch
          select 'ERROR: ('+@dni_actualizado+') '+error_message()
    end catch

end
GO
