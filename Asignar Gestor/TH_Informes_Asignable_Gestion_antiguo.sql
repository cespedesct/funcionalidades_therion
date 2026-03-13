SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[TH_Informes_Asignable_Gestion] (@numinfor varchar(10))

as

begin

set nocount on

    declare @crlf      varchar(2)=char(13)+char(10)
    declare @salida    varchar(max)=''
           ,@resultado varchar(max)
           ,@error     varchar(max)

    declare @prbbdd varchar(300)  begin try print 1/0 end try begin catch  set @prbbdd=error_procedure() end catch

begin try

       begin tran 
             if exists(select * from CORITEL.dbo.taoencar_clasificacion x where x.numinfor=@numinfor and x.codclasif='0028')
                begin
                   delete x from CORITEL.dbo.taoencar_clasificacion x where x.numinfor=@numinfor and x.codclasif='0028'      
                end
              else 
                begin
                 insert into CORITEL.dbo.taoencar_clasificacion (numinfor, codclasif, anulado, fecalta)
                 select @numinfor, '0028', 0, getdate()
                end
       commit tran

       select 'OK'
       
       return
   
end try

begin catch

    begin try close c deallocate c end try begin catch end catch
    
    while @@trancount>0  begin rollback tran end

    set @resultado='ERROR: ('+isnull(@prbbdd,'')+') '+ERROR_MESSAGE()+' linea '+isnull(convert(varchar(300),ERROR_LINE()),'')
    select @resultado
    return
    
end catch    

end
GO
