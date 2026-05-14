SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

 @datos=·<root><p><c>tabla_asociada</c><v>TH_Presupuestos_[V20250226204547680]</v></p><p><c>semillapresupuesto</c><v>DF9B5F51-DBC9-48B6-B0B0-9CFCC8B47628</v></p><p><c>rpersona</c><v>1</v></p><p><c>rempresa</c><v>0</v></p><p><c>nombresolicitante</c><v>Jose Domingo</v></p><p><c>apellidossolicitante</c><v>Dominguez Campos</v></p><p><c>dnisolicitante</c><v>0881259R</v></p><p><c>emailsolicitante</c><v>jd.dominguez@zarentia.es</v></p><p><c>telefonosolicitante</c><v>649418333</v></p><p><c>calle_sol</c><v>Avenida de los Arces</v></p><p><c>numerocalle_sol</c><v>11</v></p><p><c>portal_sol</c><v>D</v></p><p><c>escalera_sol</c><v></v></p><p><c>piso_sol</c><v>1</v></p><p><c>letra_sol</c><v>B</v></p><p><c>anexo_sol</c><v></v></p><p><c>codigopostal_sol</c><v>28037</v></p><p><c>municipio_sol</c><v>37657</v></p><p><c>otrosolicitantefacturacion</c><v>1</v></p><p><...v></p><p><c>calle</c><v>Cronos</v></p><p><c>numerocalle</c><v>63</v></p><p><c>portal</c><v></v></p><p><c>escalera</c><v></v></p><p><c>piso</c><v>3</v></p><p><c>letra</c><v>3</v></p><p><c>anexo</c><v></v></p><p><c>codigopostal</c><v>28037</v></p><p><c>municipio</c><v>37657</v></p><p><c>refcatastral</c><v>465465465465</v></p><p><c>regpropiedad</c><v>Madrid 23</v></p><p><c>fincaregistral</c><v>65466</v></p><p><c>idufir</c><v>6546585853</v></p><p><c>nombrecontacto</c><v>José Domingo Dominguez Campos</v></p><p><c>telefonocontacto</c><v>649418333</v></p><p><c>tramitacionurgente</c><v>1</v></p><p><c>mismocontactogestion</c><v>1</v></p><p><c>otrocontactogestion</c><v>1</v></p><p><c>nombrecontactogestion</c><v>Jose Domingo</v></p><p><c>apellidoscontactogestion</c><v>Dominguez Campos</v></p><p><c>dnicontactogestion</c><v>08828922G</v></p><p><c>telefonocontactogestion</c><v>649418333</v></p><p><c>emailcontactogestion</c><v>jd.dominguez@zarentia.es</v></p><p><c>fk_usuario</c><v>1</v></p></root>·

declare @datos varchar(max)='<root><p><c>tabla_asociada</c><v>TH_Presupuestos_[V20250226204547680]</v></p><p><c>semillapresupuesto</c><v>DF9B5F51-DBC9-48B6-B0B0-9CFCC8B47628</v></p><p><c>rpersona</c><v>1</v></p><p><c>rempresa</c><v>0</v></p><p><c>nombresolicitante</c><v>Jose Domingo</v></p><p><c>apellidossolicitante</c><v>Dominguez Campos</v></p><p><c>dnisolicitante</c><v>0881259R</v></p><p><c>emailsolicitante</c><v>jd.dominguez@zarentia.es</v></p><p><c>telefonosolicitante</c><v>649418333</v></p><p><c>calle_sol</c><v>Avenida de los Arces</v></p><p><c>numerocalle_sol</c><v>11</v></p><p><c>portal_sol</c><v>D</v></p><p><c>escalera_sol</c><v></v></p><p><c>piso_sol</c><v>1</v></p><p><c>letra_sol</c><v>B</v></p><p><c>anexo_sol</c><v></v></p><p><c>codigopostal_sol</c><v>28037</v></p><p><c>municipio_sol</c><v>37657</v></p><p><c>otrosolicitantefacturacion</c><v>1</v></p><p><...v></p><p><c>calle</c><v>Cronos</v></p><p><c>numerocalle</c><v>63</v></p><p><c>portal</c><v></v></p><p><c>escalera</c><v></v></p><p><c>piso</c><v>3</v></p><p><c>letra</c><v>3</v></p><p><c>anexo</c><v></v></p><p><c>codigopostal</c><v>28037</v></p><p><c>municipio</c><v>37657</v></p><p><c>refcatastral</c><v>465465465465</v></p><p><c>regpropiedad</c><v>Madrid 23</v></p><p><c>fincaregistral</c><v>65466</v></p><p><c>idufir</c><v>6546585853</v></p><p><c>nombrecontacto</c><v>José Domingo Dominguez Campos</v></p><p><c>telefonocontacto</c><v>649418333</v></p><p><c>tramitacionurgente</c><v>1</v></p><p><c>mismocontactogestion</c><v>1</v></p><p><c>otrocontactogestion</c><v>1</v></p><p><c>nombrecontactogestion</c><v>Jose Domingo</v></p><p><c>apellidoscontactogestion</c><v>Dominguez Campos</v></p><p><c>dnicontactogestion</c><v>08828922G</v></p><p><c>telefonocontactogestion</c><v>649418333</v></p><p><c>emailcontactogestion</c><v>jd.dominguez@zarentia.es</v></p><p><c>fk_usuario</c><v>1</v></p></root>'
exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Grabar
     @datos=@datos
    ,@debug=1

go

select * from TH_Presupuestos_Web p

declare @cod_TH_Presupuestos_Web int=83
declare @datos  varchar(max)
select @datos=p.datos_xml
from TH_Presupuestos_Web p
where p.codigo=@cod_TH_Presupuestos_Web

declare @x1 xml=convert(xml,@datos)

      select  
        [@tipoinmueble]             =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='tipoinmueble'            )
       ,[@finalidad]                =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='finalidad'               )
       ,[@calle]                    =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='calle'                   )
       ,[@numerocalle]              =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='numerocalle'             )
       ,[@portal]                   =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='portal'                  )
       ,[@escalera]                 =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='escalera'                )
       ,[@piso]                     =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='piso'                    )
       ,[@letra]                    =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='letra'                   )
       ,[@anexo]                    =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='anexo'                   )
       ,[@codigopostal]             =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='codigopostal'            )
       ,[@municipio]                =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='municipio'               )
       ,[@superficie]               =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='superficie'              )
       ,[@refcatastral]             =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='refcatastral'            )
       ,[@regpropiedad]             =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='regpropiedad'            )
       ,[@fincaregistral]           =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='fincaregistral'          )
       ,[@idufir]                   =(select top 1 xc.value('v[1]', 'varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='idufir'                  )

*/

ALTER procedure [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Grabar]
 (@datos  varchar(max)
 ,@debug  bit=0
 )

 as 

SET DEADLOCK_PRIORITY 10

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

      set @datos=replace(@datos,'''','´')

      declare @x1 xml=convert(xml,@datos)
      --select xc.value('c[1]', 'varchar(500)'), xc.value('v[1]', 'varchar(max)') from @x1.nodes('/root/p') as xt(xc)

      declare @semillapresupuesto varchar(200)
             ---------------------------------------------------------
             ,@rempresa                       varchar(300)
             ,@rpersona                       varchar(300)
             ,@nombresolicitante              varchar(300)
             ,@apellidossolicitante           varchar(300)
             ,@dnisolicitante                 varchar(300)
             ,@empresasolicitante             varchar(300)
             ,@cifsolicitante                 varchar(300)
             ,@emailsolicitante               varchar(300)
             ,@emaildoc                       varchar(300)
             ,@emailfac                       varchar(300)
             ,@telefonosolicitante            varchar(300)
             ,@calle_sol                      varchar(300)
             ,@numerocalle_sol                varchar(300)
             ,@portal_sol                     varchar(300)
             ,@escalera_sol                   varchar(300)
             ,@piso_sol                       varchar(300)
             ,@letra_sol                      varchar(300)
             ,@anexo_sol                      varchar(300)
             ,@codigopostal_sol               varchar(300)
             ,@municipio_sol                  varchar(300)
             ---------------------------------------------------------
             ,@mismosolicitantefacturacion    varchar(300)
             ,@otrosolicitantefacturacion     varchar(300)
             ,@rempresa_fac                   varchar(300)
             ,@rpersona_fac                   varchar(300)
             ,@nombresolicitante_fac          varchar(300)
             ,@apellidossolicitante_fac       varchar(300)
             ,@dnisolicitante_fac             varchar(300)
             ,@empresasolicitante_fac         varchar(300)
             ,@cifsolicitante_fac             varchar(300)
             ,@emailsolicitante_fac           varchar(300)
             ,@telefonosolicitante_fac        varchar(300)
             ,@calle_fac                      varchar(300)
             ,@numerocalle_fac                varchar(300)
             ,@portal_fac                     varchar(300)
             ,@escalera_fac                   varchar(300)
             ,@piso_fac                       varchar(300)
             ,@letra_fac                      varchar(300)
             ,@anexo_fac                      varchar(300)
             ,@codigopostal_fac               varchar(300)
             ,@municipio_fac                  varchar(300)
             ---------------------------------------------------------
             ,@tipoinmueble                   varchar(300)
             ,@finalidad                      varchar(300)
             ,@calle                          varchar(300)
             ,@numerocalle                    varchar(300)
             ,@portal                         varchar(300)
             ,@escalera                       varchar(300)
             ,@piso                           varchar(300)
             ,@letra                          varchar(300)
             ,@anexo                          varchar(300)
             ,@codigopostal                   varchar(300)
             ,@municipio                      varchar(300)
             ,@superficie                     varchar(300)
             ,@refcatastral                   varchar(300)
             ,@regpropiedad                   varchar(300)
             ,@fincaregistral                 varchar(300)
             ,@idufir                         varchar(300)
             ,@importemanual                  varchar(300)
             ,@importetransferenciavalidado   varchar(300)
             ,@fechatransferenciavalidado     varchar(300)
             ,@conceptotransferenciavalidado     varchar(300)
             ---------------------------------------------------------
             ,@nombrecontacto                 varchar(300)
             ,@telefonocontacto               varchar(300)
             ,@tramitacionurgente             varchar(300)
             ,@mismocontactogestion           varchar(300)
             ,@otrocontactogestion            varchar(300)
             ,@nombrecontactogestion          varchar(300)
             ,@apellidoscontactogestion       varchar(300)
             ,@dnicontactogestion             varchar(300)
             ,@telefonocontactogestion        varchar(300)
             ,@emailcontactogestion           varchar(300)
             ,@aceptaciondatos                varchar(300)
             ,@telefonoverificacion           varchar(300)
             ---------------------------------------------------------
             ,@llaveenvio                     varchar(300)
             ,@fk_usuario                     varchar(300)
             ,@tabla_asociada                 varchar(300)
             ,@tabla_asociada_justificante    varchar(300)
             ,@tabla_asociada_notasimple      varchar(300)
             ,@tabla_asociada_otrosficheros   varchar(300)
             ,@tabla_asociada_transferencia   varchar(300)
             ,@codentid                       varchar(300)

      select @semillapresupuesto=xc.value('v[1]', 'varchar(200)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]', 'varchar(500)')='semillapresupuesto'
      -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      set @rpersona                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='rpersona'                    )
      set @rempresa                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='rempresa'                    )
      set @nombresolicitante           =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='nombresolicitante'           )
      set @apellidossolicitante        =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='apellidossolicitante'        )
      set @dnisolicitante              =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='dnisolicitante'              )
      set @empresasolicitante          =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='empresasolicitante'          )
      set @cifsolicitante              =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='cifsolicitante'              )
      set @emailsolicitante            =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='emailsolicitante'            )
      set @emaildoc                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='emaildoc'                    )
      set @emailfac                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='emailfac'                    )
      set @telefonosolicitante         =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='telefonosolicitante'         )
      set @calle_sol                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='calle_sol'                   )
      set @numerocalle_sol             =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='numerocalle_sol'             )
      set @portal_sol                  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='portal_sol'                  )
      set @escalera_sol                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='escalera_sol'                )
      set @piso_sol                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='piso_sol'                    )
      set @letra_sol                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='letra_sol'                   )
      set @anexo_sol                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='anexo_sol'                   )
      set @codigopostal_sol            =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='codigopostal_sol'            )
      set @municipio_sol               =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='municipio_sol'               )
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      set @mismosolicitantefacturacion =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='mismosolicitantefacturacion' )
      set @otrosolicitantefacturacion  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='otrosolicitantefacturacion'  )
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------       
      set @rempresa_fac                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='rempresa_fac'                )
      set @rpersona_fac                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='rpersona_fac'                )
      set @rempresa_fac                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='rempresa_fac'                )
      set @nombresolicitante_fac       =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='nombresolicitante_fac'       )
      set @apellidossolicitante_fac    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='apellidossolicitante_fac'    )
      set @dnisolicitante_fac          =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='dnisolicitante_fac'          )
      set @empresasolicitante_fac      =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='empresasolicitante_fac'      )
      set @cifsolicitante_fac          =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='cifsolicitante_fac'          )
      set @emailsolicitante_fac        =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='emailsolicitante_fac'        )
      set @telefonosolicitante_fac     =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='telefonosolicitante_fac'     )
      set @calle_fac                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='calle_fac'                   )
      set @numerocalle_fac             =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='numerocalle_fac'             )
      set @portal_fac                  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='portal_fac'                  )
      set @escalera_fac                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='escalera_fac'                )
      set @piso_fac                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='piso_fac'                    )
      set @letra_fac                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='letra_fac'                   )
      set @anexo_fac                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='anexo_fac'                   )
      set @codigopostal_fac            =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='codigopostal_fac'            )
      set @municipio_fac               =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='municipio_fac'               )
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------       
      set @tipoinmueble                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tipoinmueble'                )
      set @finalidad                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='finalidad'                   )
      set @calle                       =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='calle'                       )
      set @numerocalle                 =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='numerocalle'                 )
      set @portal                      =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='portal'                      )
      set @escalera                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='escalera'                    )
      set @piso                        =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='piso'                        )
      set @letra                       =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='letra'                       )
      set @anexo                       =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='anexo'                       )
      set @codigopostal                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='codigopostal'                )
      set @municipio                   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='municipio'                   )
      set @superficie                  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='superficie'                  )
      set @importemanual               =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='importemanual'               )
      set @importetransferenciavalidado=(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='importetransferenciavalidado')
      set @fechatransferenciavalidado  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='fechatransferenciavalidado'  )
      set @conceptotransferenciavalidado=(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='conceptotransferenciavalidado'  )
      
      set @refcatastral                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='refcatastral'                )
      set @regpropiedad                =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='regpropiedad'                )
      set @fincaregistral              =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='fincaregistral'              )
      set @idufir                      =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='idufir'                      )
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      set @nombrecontacto              =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='nombrecontacto'              )
      set @telefonocontacto            =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='telefonocontacto'            )
      set @tramitacionurgente          =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tramitacionurgente'          )
      set @mismocontactogestion        =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='mismocontactogestion'        )
      set @otrocontactogestion         =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='otrocontactogestion'         )
      set @nombrecontactogestion       =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='nombrecontactogestion'       )
      set @apellidoscontactogestion    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='apellidoscontactogestion'    )
      set @dnicontactogestion          =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='dnicontactogestion'          )
      set @telefonocontactogestion     =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='telefonocontactogestion'     )
      set @emailcontactogestion        =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='emailcontactogestion'        )
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------       
      set @aceptaciondatos             =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='aceptaciondatos'             )
      set @telefonoverificacion        =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='telefonoverificacion'        )
      set @llaveenvio                  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='llaveenvio'                  )
      set @fk_usuario                  =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='fk_usuario'                  )
      set @codentid                    =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='codentid'                    )
      set @tabla_asociada              =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tabla_asociada'              )
      set @tabla_asociada_justificante =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tabla_asociada_justificante' )
      set @tabla_asociada_notasimple   =(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tabla_asociada_notasimple'   )
      set @tabla_asociada_otrosficheros=(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tabla_asociada_otrosficheros')
      set @tabla_asociada_transferencia=(select top 1 xc.value('v[1]','varchar(300)') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(100)')='tabla_asociada_transferencia')
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      set @emailsolicitante    =@emaildoc
      set @emailsolicitante_fac=@emailfac
      ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      set @cpaso='Paso 001'
      /*
      if @debug=1
         begin
               select                                                       
                      [@rpersona                ]=@rpersona                 
                     ,[@rempresa                ]=@rempresa                 
                     ,[@nombresolicitante       ]=@nombresolicitante        
                     ,[@apellidossolicitante    ]=@apellidossolicitante     
                     ,[@dnisolicitante          ]=@dnisolicitante           
                     ,[@empresasolicitante      ]=@empresasolicitante       
                     ,[@cifsolicitante          ]=@cifsolicitante           
                     ,[@emailsolicitante        ]=@emailsolicitante         
                     ,[@telefonosolicitante     ]=@telefonosolicitante
                     ,[@calle_sol               ]=@calle_sol
                     ,[@numerocalle_sol         ]=@numerocalle_sol
                     ,[@portal_sol              ]=@portal_sol
                     ,[@escalera_sol            ]=@escalera_sol
                     ,[@piso_sol                ]=@piso_sol
                     ,[@letra_sol               ]=@letra_sol
                     ,[@anexo_sol               ]=@anexo_sol
                     ,[@codigopostal_sol        ]=@codigopostal_sol
                     ,[@municipio_sol           ]=@municipio_sol
                     -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                     ,[@mismosolicitantefacturacion]=@mismosolicitantefacturacion
                     ,[@otrosolicitantefacturacion] =@otrosolicitantefacturacion
                     -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                     ,[@rpersona_fac            ]=@rpersona_fac
                     ,[@rempresa_fac            ]=@rempresa_fac
                     ,[@nombresolicitante_fac   ]=@nombresolicitante_fac
                     ,[@apellidossolicitante_fac]=@apellidossolicitante_fac
                     ,[@dnisolicitante_fac      ]=@dnisolicitante_fac
                     ,[@empresasolicitante_fac  ]=@empresasolicitante_fac
                     ,[@cifsolicitante_fac      ]=@cifsolicitante_fac
                     ,[@emailsolicitante_fac    ]=@emailsolicitante_fac
                     ,[@telefonosolicitante_fac ]=@telefonosolicitante_fac
                     ,[@calle_fac               ]=@calle_fac
                     ,[@numerocalle_fac         ]=@numerocalle_fac
                     ,[@portal_fac              ]=@portal_fac
                     ,[@escalera_fac            ]=@escalera_fac
                     ,[@piso_fac                ]=@piso_fac
                     ,[@letra_fac               ]=@letra_fac
                     ,[@anexo_fac               ]=@anexo_fac
                     ,[@codigopostal_fac        ]=@codigopostal_fac
                     ,[@municipio_fac           ]=@municipio_fac
                     -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                     ,[@tipoinmueble            ]=@tipoinmueble             
                     ,[@finalidad               ]=@finalidad                
                     ,[@calle                   ]=@calle                    
                     ,[@numerocalle             ]=@numerocalle              
                     ,[@portal                  ]=@portal                   
                     ,[@escalera                ]=@escalera                 
                     ,[@piso                    ]=@piso                     
                     ,[@letra                   ]=@letra                    
                     ,[@anexo                   ]=@anexo                    
                     ,[@codigopostal            ]=@codigopostal             
                     ,[@municipio               ]=@municipio                
                     ,[@superficie              ]=@superficie
                     ,[@refcatastral            ]=@refcatastral             
                     ,[@regpropiedad            ]=@regpropiedad             
                     ,[@fincaregistral          ]=@fincaregistral
                     ,[@idufir                  ]=@idufir                   
                     ,[@nombrecontacto          ]=@nombrecontacto           
                     ,[@telefonocontacto        ]=@telefonocontacto         
                     ,[@tramitacionurgente      ]=@tramitacionurgente       
                     ,[@mismocontactogestion    ]=@mismocontactogestion     
                     ,[@otrocontactogestion     ]=@otrocontactogestion      
                     ,[@nombrecontactogestion   ]=@nombrecontactogestion    
                     ,[@apellidoscontactogestion]=@apellidoscontactogestion 
                     ,[@dnicontactogestion      ]=@dnicontactogestion       
                     ,[@telefonocontactogestion ]=@telefonocontactogestion  
                     ,[@emailcontactogestion    ]=@emailcontactogestion     
                     ,[@aceptaciondatos         ]=@aceptaciondatos          
                     ,[@telefonoverificacion    ]=@telefonoverificacion     
                     ,[@llaveenvio              ]=@llaveenvio               
                     ,[@fk_usuario              ]=@fk_usuario
         end
      */

      if isnull(@aceptaciondatos,'0')='0' and @fk_usuario is null
         begin
           select 'OKNORELOAD. Debe aceptar el consentimiento de datos'
           return
         end

      ---------------------------------------------
      -- Ver si ya existe el codigo de presupuesto
      ---------------------------------------------

      declare @cod_TH_Presupuestos_Web int
      declare @llave_envio             varchar(100) 

      select @cod_TH_Presupuestos_Web=w.codigo 
            ,@llave_envio            =llave_envio
      from TH_Presupuestos_Web w 
      where w.codigo_presupuesto=@semillapresupuesto

      if @cod_TH_Presupuestos_Web is null 
         begin
            select 'OKNORELOAD. No se ha registrado su solicitud con el envío del código. Vuelva a intentarlo solicitando una nueva solicitud de SMS por favor.'
            return
         end

      set @cpaso='Paso 002'

      --------------------------------------

      declare @validaciones varchar(max)=''

      -- set @validaciones+='<li>@municipio:'+isnull('['+@municipio+']','null')+'</li>'

      if isnull(@llaveenvio,'')='' and @fk_usuario is null -- Cuando viene de un usuario no se valida la llave
         begin
            set @validaciones+='<li>No se ha informado del código de verificación</li>'
         end

      if isnull(@llaveenvio,'')!='' and @llaveenvio!=isnull(@llave_envio,'XXXXXXXXXX') and @fk_usuario is null -- Cuando viene de un usuario no se valida la llave
         begin
            set @validaciones+='<li>El código de verificación ('+isnull(@llave_envio,'XXXXXXXXXX')+') informado es <b>INCORRECTO</b></li>'
         end

      --------------------------------------
      -- Validación del Fichero DNI
      --------------------------------------

      declare @fichero_dni varchar(max)=''
      if isnull(@tabla_asociada,'')!=''
         begin
            select @fichero_dni+=convert(varchar(100),f.fileId)+';' 
            from SISTEMA_ficheros f (nolock) 
            where f.tabla_asociada=upper(@tabla_asociada)
            order by f.codigo desc
         end

      --------------------------------------
      -- Validación del Fichero Justificante
      --------------------------------------

      declare @fichero_justificante varchar(max)=''
      if isnull(@tabla_asociada_justificante,'')!=''
         begin
            select @fichero_justificante+=convert(varchar(100),f.fileId)+';' 
            from SISTEMA_ficheros f (nolock) 
            where f.tabla_asociada=upper(@tabla_asociada_justificante)
            order by f.codigo desc
         end

      --------------------------------------
      -- Validación del Fichero Nota Simple
      --------------------------------------

      declare @fichero_notasimple varchar(max)=''
      if isnull(@tabla_asociada_notasimple,'')!=''
         begin
            select @fichero_notasimple+=convert(varchar(100),f.fileId)+';' 
            from SISTEMA_ficheros f (nolock) 
            where f.tabla_asociada=upper(@tabla_asociada_notasimple)
            order by f.codigo desc
         end

      --------------------------------------
      -- Validación de Otros Ficheros
      --------------------------------------

      declare @fichero_otrosficheros varchar(max)=''
      if isnull(@tabla_asociada_otrosficheros,'')!=''
         begin
            select @fichero_otrosficheros+=convert(varchar(100),f.fileId)+';' 
            from SISTEMA_ficheros f (nolock) 
            where f.tabla_asociada=upper(@tabla_asociada_otrosficheros)
            order by f.codigo desc
         end

      ---------------------------------------
      -- Validación del Fichero Transferencia
      ---------------------------------------

      declare @fichero_transferencia varchar(max)=''
      if isnull(@tabla_asociada_transferencia,'')!=''
         begin
            select @fichero_transferencia+=convert(varchar(100),f.fileId)+';'  
            from SISTEMA_ficheros f (nolock) 
            where f.tabla_asociada=upper(@tabla_asociada_transferencia)
            order by f.codigo desc
         end

      --------------------------------------
      -- Validación del Solicitante
      --------------------------------------

      if @rpersona='1'
         begin
            if isnull(@nombresolicitante,'')=''
               begin
                  set @validaciones+='<li>El dato de NOMBRE del solicitante debe estar informado.</li>'
               end
            if isnull(@apellidossolicitante,'')=''
               begin
                  set @validaciones+='<li>El dato de APELLIDOS del solicitante debe estar informado</li>'
               end
         if isnull(@dnisolicitante,'')=''
               begin
               if(@codentid!='PR1' AND @codentid!='PR2')  
                  begin
                     set @validaciones+='<li>El dato de DNI del solicitante o el fichero con el DNI deben estar informados</li>'
                  end

               end
             else
               begin
                  if dbo.DNI_Formato_Valido (@dnisolicitante)=0
                     begin
                        set @validaciones+='<li>El dato de DNI/NIE del solicitante tiene caracteres inválidos</li>'
                     end
               end
         end
      -------------------------------------------------------------
      if @rempresa='1'
         begin
            if isnull(@empresasolicitante,'')=''
               begin
                  set @validaciones+='<li>El dato de EMPRESA del solicitante debe estar informado</li>'
               end
            if isnull(@cifsolicitante,'')=''
               begin
                  set @validaciones+='<li>El dato de CIF del solicitante debe estar informado</li>'
               end
         end
      -------------------------------------------------------------
      if isnull(@emailsolicitante,'')=''
         begin
            set @validaciones+='<li>El dato de EMAIL del solicitante debe estar informado</li>'
         end
       else
         begin
           if dbo.Valida_Email(@emailsolicitante)=0
              begin
                 set @validaciones+='<li>El dato de EMAIL del solicitante tiene un formato incorrecto</li>'
              end
         end
      -------------------------------------------------------------
      if isnull(@calle_sol,'')=''
         begin
            set @validaciones+='<li>El dato de CALLE del solicitante debe estar informado</li>'
         end
      -------------------------------------------------------------
      if isnull(@numerocalle_sol,'')=''
         begin
            set @validaciones+='<li>El dato de Nº de CALLE del solicitante debe estar informado</li>'
         end
      -------------------------------------------------------------
      if isnull(@codigopostal_sol,'')=''
         begin
            set @validaciones+='<li>El dato de Código Postal del solicitante debe estar informado</li>'
         end
      -------------------------------------------------------------
      if isnull(@municipio_sol,'-1')='-1' or isnull(@municipio,'')=''
         begin
            set @validaciones+='<li>El dato de MUNICIPIO del solicitante debe estar informado</li>'
         end
      -------------------------------------------------------------
      set @cpaso='Paso 003'

      ---------------------------------------------
      -- Validación del Solicitante de Facturacion
      ---------------------------------------------

      if isnull(@otrosolicitantefacturacion,'0')='1'
         begin
            if @rpersona_fac='1'
               begin
                  if isnull(@nombresolicitante_fac,'')=''
                     begin
                        set @validaciones+='<li>El dato de NOMBRE de persona de Facturación debe estar informado.</li>'
                     end
                  if isnull(@apellidossolicitante_fac,'')=''
                     begin
                        set @validaciones+='<li>El dato de APELLIDOS de persona de Facturación debe estar informado</li>'
                     end
                  if isnull(@dnisolicitante_fac,'')=''
                     begin
                        set @validaciones+='<li>El dato de DNI de persona de Facturación debe estar informado</li>'
                     end
                  else 
                     if dbo.DNI_Formato_Valido (@dnisolicitante_fac)=0
                        begin
                           set @validaciones+='<li>El dato de DNI/NIE del solicitante de Facturación tiene caracteres inválidos</li>'
                        end
               end

            if @rempresa_fac='1'
               begin
                  if isnull(@empresasolicitante_fac,'')=''
                     begin
                        set @validaciones+='<li>El dato de EMPRESA de Facturación debe estar informado</li>'
                     end
                  if isnull(@cifsolicitante_fac,'')=''
                     begin
                        set @validaciones+='<li>El dato de CIF de EMPRESA Facturación debe estar informado</li>'
                     end
               end

            if isnull(@emailsolicitante_fac,'')=''
               begin
                  set @validaciones+='<li>El dato de EMAIL de EMPRESA/PERSONA de Facturación debe estar informado</li>'
               end
             else
               begin
                 if dbo.Valida_Email(@emailsolicitante_fac)=0
                    begin
                       set @validaciones+='<li>El dato de EMAIL de EMPRESA/PERSONA tiene un formato incorrecto</li>'
                    end
               end

            if isnull(@calle_fac,'')=''
               begin
                  set @validaciones+='<li>El dato de CALLE de EMPRESA/PERSONA de Facturación debe estar informado</li>'
               end

            if isnull(@numerocalle_fac,'')=''
               begin
                  set @validaciones+='<li>El dato de Nº de CALLE de EMPRESA/PERSONA de Facturación debe estar informado</li>'
               end

            if isnull(@codigopostal_fac,'')=''
               begin
                  set @validaciones+='<li>El dato de Código Postal de EMPRESA/PERSONA de Facturación debe estar informado</li>'
               end

            if isnull(@municipio_fac,'-1')='-1' or isnull(@municipio,'')=''
               begin
                  set @validaciones+='<li>El dato de MUNICIPIO de EMPRESA/PERSONA de Facturación debe estar informado</li>'
               end

         end

      set @cpaso='Paso 004'

      ----------------------------
      -- Validación del Inmueble
      ----------------------------

      if isnull(@tipoinmueble,'0')='0'
         begin
            set @validaciones+='<li>El dato de TIPO DE INMUEBLE debe estar informado</li>'
         end

      if isnull(@finalidad,'0')='0'
         begin
            set @validaciones+='<li>El dato de TIPO DE FINALIDAD debe estar informado</li>'
         end

      if isnull(@calle,'')=''
         begin
            set @validaciones+='<li>El dato de CALLE del Inmueble debe estar informado</li>'
         end

      if isnull(@numerocalle,'')=''
         begin
            set @validaciones+='<li>El dato de Nº de CALLE del Inmueble debe estar informado</li>'
         end

      if isnull(@codigopostal,'')=''
         begin
            set @validaciones+='<li>El dato de Código Postal del Inmueble debe estar informado</li>'
         end

      if isnull(@municipio,'-1')='-1' or isnull(@municipio,'')=''
         begin
            set @validaciones+='<li>El dato de MUNICIPIO del Inmueble debe estar informado</li>'
         end

      if isnull(@nombrecontacto,'')=''
         begin
            set @validaciones+='<li>El dato de NOMBRE de CONTACTO de VISITA debe estar informado</li>'
         end

      if isnull(@telefonocontacto,'')=''
         begin
            set @validaciones+='<li>El dato de TELEFONO de CONTACTO de VISITA debe estar informado</li>'
         end

      if @otrocontactogestion='1'
         begin
            if isnull(@nombrecontactogestion,'')=''
               begin
                  set @validaciones+='<li>El dato de NOMBRE del CONTACTO de GESTIÓN debe estar informado</li>'
               end

            if isnull(@dnicontactogestion,'')=''
               begin
                  set @validaciones+='<li>El dato de DNI del CONTACTO de GESTIÓN debe estar informado</li>'
               end
             else
               if dbo.DNI_Formato_Valido (@dnicontactogestion)=0
                  begin
                     set @validaciones+='<li>El dato de DNI/NIE del CONTACTO de GESTION tiene caracteres inválidos</li>'
                  end
             --else
             --  begin
             --     if dbo.[DNI_con_DC] (@dnicontactogestion)!=@dnicontactogestion
             --        begin
             --           if dbo.THERION_Validar_CIF_Europeo (null, @dnicontactogestion) =0
             --              begin
             --                set @validaciones+='<li>El dato de DNI/NIE del solicitante de Facturación es inválido</li>'
             --              end
             --        end
             --  end

            if isnull(@telefonocontactogestion,'')=''
               begin
                  set @validaciones+='<li>El dato de TELEFONO del CONTACTO de GESTIÓN debe estar informado</li>'
               end
            if isnull(@emailcontactogestion,'')=''
               begin
                  set @validaciones+='<li>El dato de EMAIL del CONTACTO de GESTIÓN debe estar informado</li>'
               end
             else
               begin
                 if dbo.Valida_Email(@emailcontactogestion)=0
                    begin
                       set @validaciones+='<li>El dato de EMAIL del CONTACTO de GESTIÓN tiene un formato incorrecto</li>'
                    end
               end
         end
      if (isnull(@importemanual,'')='')
         begin
            set @validaciones+='<li>El dato de IMPORTE PRESUPUESTO debe estar informado</li>'
         end

      set @cpaso='Paso 005'

      if isnull(@idufir,'')=''
         begin
           if len(ltrim(rtrim(@idufir)))>14 
              begin
                 set @validaciones+='<li>Compruebe el dato del IDUFIR, no tiene un formato correcto</li>'
              end
          if (select count(*) 
              from dbo.f_lista_caracteres (@idufir) r
              left outer join dbo.f_lista_caracteres ('1234567890') n on n.items=r.items
              where n.i is null)>0
              begin
                 set @validaciones+='<li>Compruebe el dato del IDUFIR, sólo puede contener caracters numéricos</li>'
              end
         end
      
      ------------------------------------------------------

      if isnull(@fichero_transferencia,'')!=''
         begin
           ----------------------------
           if @importetransferenciavalidado is null or @fechatransferenciavalidado is null or @conceptotransferenciavalidado is null
              begin
                 set @validaciones+='<li>Es necesario validar el justificante de transferencia</li>'
              end
            else
              begin
                 set @importetransferenciavalidado=replace(@importetransferenciavalidado,',','.')
                 ------------------------------------------------------------------------------
                 -- Validar el importe de la transferencia si hay justificante de transferencia
                 ------------------------------------------------------------------------------
                 begin try
                       declare @verificar_importetransferenciavalidado decimal(19,2)
                       set @verificar_importetransferenciavalidado =convert(decimal(19,2),@importetransferenciavalidado)
                       if @verificar_importetransferenciavalidado<=0
                          begin
                             set @validaciones+='<li>Es necesario validar el importe del justificante de transferencia</li>'
                          end
                 end try
                 begin catch
                       set @validaciones+='<li>Es necesario validar el importe del justificante de transferencia</li>'
                 end catch
                 -----------------------
                 -- Agregado por Fabrizio
                 -----------------------
                 ------------------------------------------------------------------------------
                 -- Validar el concepto de la transferencia si hay justificante de transferencia
                 ------------------------------------------------------------------------------
                 begin try
                       declare @verificar_conceptotransferenciavalidado varchar(100)
                       set @verificar_conceptotransferenciavalidado = @conceptotransferenciavalidado
                       if ISNULL(@verificar_conceptotransferenciavalidado,'')=''
                          begin
                             set @validaciones+='<li>Es necesario validar el concepto del justificante de transferencia</li>'
                          end
                 end try
                 begin catch
                       set @validaciones+='<li>Es necesario validar el concepto del justificante de transferencia</li>'
                 end catch
                 ------------------------------------------------------------------------------
                 -- Validar la fecha de la transferencia si hay justificante de transferencia
                 ------------------------------------------------------------------------------
                 begin try
                       declare @verificar_fechatransferenciavalidado datetime
                       set @verificar_fechatransferenciavalidado =convert(datetime,@fechatransferenciavalidado,121)
                 end try
                 begin catch
                       set @validaciones+='<li>La fecha de validación de transferencia es un dato incorrecto o requerido</li>'
                 end catch
                 ---------------------------- 
              end
         end
    
      --------------------------------------

      declare @js varchar(max)=''

      if @validaciones!=''   -- Validaciones incorrectas
         begin
            set @validaciones='<p style=''font-size:1vw;color:red;font-weight:bold''><u>Se han detectado los siguientes errores:</u></p>'
                             +'<ul style=''font-size:0.75vw;color:red;font-weight:normal''>'
                             +@validaciones
                             +'</ul>'
                             +'<p style=''font-size:0.75vw;color:black;font-weight:bold''>Corríjalos y vuelva a enviar</p>'

            set @js='listavalidaciones.innerHTML="'+@validaciones+'";'
                   +'seccionvalidacion.style.display='''';'
            select 'OKNORELOAD'
            +replace('[INIEVAL]'+isnull(@js,'')+'[FINEVAL]','[INIEVAL][FINEVAL]','')
            return
         end
      else           -- Validaciones Correctas -> Grabar datos
         begin
           -----------------------------------
           declare @importe_presupuesto_manual decimal(19,2)

           if ltrim(rtrim(isnull(@importemanual,'')))!=''
              begin
                set @importe_presupuesto_manual=convert(decimal(19,2),replace(@importemanual,',','.'))
              end

           declare @importe_transferencia_validado decimal(19,2)
           if ltrim(rtrim(isnull(@importetransferenciavalidado,'')))!=''
              begin
                set @importe_transferencia_validado=convert(decimal(19,2),replace(@importetransferenciavalidado,',','.'))
              end

           -----------------------------------

           declare @afectados int
           declare @informar  varchar(max)='Registro OK'
           
           update p
              set p.datos_xml               =@datos
                 ,p.rpersona                =replace(@rpersona,'_AMPERSAN_','&')
                 ,p.rempresa                =replace(@rempresa,'_AMPERSAN_','&')
                 ,p.nombresolicitante       =replace(@nombresolicitante,'_AMPERSAN_','&')
                 ,p.apellidossolicitante    =replace(@apellidossolicitante,'_AMPERSAN_','&')
                 ,p.dnisolicitante          =replace(@dnisolicitante,'_AMPERSAN_','&')
                 ,p.empresasolicitante      =replace(@empresasolicitante,'_AMPERSAN_','&')
                 ,p.cifsolicitante          =replace(@cifsolicitante,'_AMPERSAN_','&')
                 ,p.emailsolicitante        =replace(@emailsolicitante,'_AMPERSAN_','&')
                 ,p.telefonosolicitante     =replace(@telefonosolicitante,'_AMPERSAN_','&')
                 ,p.calle_sol               =replace(@calle_sol,'_AMPERSAN_','&')
                 ,p.numerocalle_sol         =replace(@numerocalle_sol,'_AMPERSAN_','&')
                 ,p.portal_sol              =replace(@portal_sol,'_AMPERSAN_','&')
                 ,p.escalera_sol            =replace(@escalera_sol,'_AMPERSAN_','&')
                 ,p.piso_sol                =replace(@piso_sol,'_AMPERSAN_','&')
                 ,p.letra_sol               =replace(@letra_sol,'_AMPERSAN_','&')
                 ,p.anexo_sol               =replace(@anexo_sol,'_AMPERSAN_','&')
                 ,p.codigopostal_sol        =replace(@codigopostal_sol,'_AMPERSAN_','&')
                 ,p.municipio_sol           =replace(@municipio_sol,'_AMPERSAN_','&')
                 -------------------------------------------------------------------------------
                 ,p.mismosolicitantefacturacion=replace(@mismosolicitantefacturacion,'_AMPERSAN_','&')
                 ,p.otrosolicitantefacturacion	=replace(@otrosolicitantefacturacion ,'_AMPERSAN_','&')
                 -------------------------------------------------------------------------------
                 ,p.rpersona_fac              =replace(@rpersona_fac            ,'_AMPERSAN_','&')
                 ,p.rempresa_fac              =replace(@rempresa_fac            ,'_AMPERSAN_','&')
                 ,p.nombresolicitante_fac     =replace(@nombresolicitante_fac   ,'_AMPERSAN_','&')
                 ,p.apellidossolicitante_fac  =replace(@apellidossolicitante_fac,'_AMPERSAN_','&')
                 ,p.dnisolicitante_fac        =replace(@dnisolicitante_fac      ,'_AMPERSAN_','&')
                 ,p.empresasolicitante_fac    =replace(@empresasolicitante_fac  ,'_AMPERSAN_','&')
                 ,p.cifsolicitante_fac        =replace(@cifsolicitante_fac      ,'_AMPERSAN_','&')
                 ,p.emailsolicitante_fac      =replace(@emailsolicitante_fac    ,'_AMPERSAN_','&')
                 ,p.telefonosolicitante_fac   =replace(@telefonosolicitante_fac ,'_AMPERSAN_','&')
                 ,p.calle_fac                 =replace(@calle_fac               ,'_AMPERSAN_'  ,'&')
                 ,p.numerocalle_fac           =replace(@numerocalle_fac         ,'_AMPERSAN_','&')
                 ,p.portal_fac                =replace(@portal_fac              ,'_AMPERSAN_','&')
                 ,p.escalera_fac              =replace(@escalera_fac            ,'_AMPERSAN_','&')
                 ,p.piso_fac                  =replace(@piso_fac                ,'_AMPERSAN_','&')
                 ,p.letra_fac                 =replace(@letra_fac               ,'_AMPERSAN_','&')
                 ,p.anexo_fac                 =replace(@anexo_fac               ,'_AMPERSAN_','&')
                 ,p.codigopostal_fac          =replace(@codigopostal_fac        ,'_AMPERSAN_','&')
                 ,p.municipio_fac             =replace(@municipio_fac           ,'_AMPERSAN_','&')
                 -------------------------------------------------------------------------------
                 ,p.tipoinmueble              =replace(@tipoinmueble   ,'_AMPERSAN_','&')
                 ,p.finalidad                 =replace(@finalidad      ,'_AMPERSAN_','&')
                 ,p.calle                     =replace(@calle          ,'_AMPERSAN_','&')
                 ,p.numerocalle               =replace(@numerocalle    ,'_AMPERSAN_','&')
                 ,p.portal                    =replace(@portal         ,'_AMPERSAN_','&')
                 ,p.escalera                  =replace(@escalera       ,'_AMPERSAN_','&')
                 ,p.piso                      =replace(@piso           ,'_AMPERSAN_','&')
                 ,p.letra                     =replace(@letra          ,'_AMPERSAN_','&')
                 ,p.anexo                     =replace(@anexo          ,'_AMPERSAN_','&')
                 ,p.codigopostal              =replace(@codigopostal   ,'_AMPERSAN_','&')
                 ,p.municipio                 =replace(@municipio      ,'_AMPERSAN_','&')
                 ,p.superficie                =replace(@superficie     ,'_AMPERSAN_','&')
                 ,p.refcatastral              =replace(@refcatastral   ,'_AMPERSAN_','&')
                 ,p.regpropiedad              =replace(@regpropiedad   ,'_AMPERSAN_','&')             
                 ,p.fincaregistral            =replace(@fincaregistral ,'_AMPERSAN_','&')
                 ,p.idufir                    =replace(@idufir         ,'_AMPERSAN_','&')
                 -------------------------------------------------------------------------------
                 ,p.nombrecontacto            =replace(@nombrecontacto          ,'_AMPERSAN_','&')
                 ,p.telefonocontacto          =replace(@telefonocontacto        ,'_AMPERSAN_','&')
                 ,p.tramitacionurgente        =replace(@tramitacionurgente      ,'_AMPERSAN_','&')
                 ,p.mismocontactogestion      =replace(@mismocontactogestion    ,'_AMPERSAN_','&')
                 ,p.otrocontactogestion       =replace(@otrocontactogestion     ,'_AMPERSAN_','&')
                 -------------------------------------------------------------------------------
                 ,p.nombrecontactogestion     =replace(@nombrecontactogestion   ,'_AMPERSAN_','&')
                 ,p.apellidoscontactogestion  =replace(@apellidoscontactogestion,'_AMPERSAN_','&')
                 ,p.dnicontactogestion        =replace(@dnicontactogestion      ,'_AMPERSAN_','&')
                 ,p.telefonocontactogestion   =replace(@telefonocontactogestion ,'_AMPERSAN_','&')
                 ,p.emailcontactogestion      =replace(@emailcontactogestion    ,'_AMPERSAN_','&')
                 -------------------------------------------------------------------------------
                 ,p.aceptaciondatos           =replace(@aceptaciondatos     ,'_AMPERSAN_','&')
                 ,p.telefono_llave_envio      =replace(@telefonoverificacion,'_AMPERSAN_','&')
                 ,p.llave_envio               =replace(@llaveenvio          ,'_AMPERSAN_','&')               
                 ,p.fk_usuarios               =convert(int,@fk_usuario)
                 -------------------------------------------------------------------------------
                 ,p.fichero_dni               =@fichero_dni
                 ,p.fichero_justificante      =@fichero_justificante
                 ,p.fichero_notasimple        =@fichero_notasimple
                 ,p.fichero_otrosficheros     =@fichero_otrosficheros
                 ,p.fichero_transferencia     =@fichero_transferencia
                 ,p.importe_presupuesto_manual= @importe_presupuesto_manual
                 -------------------------------------------------------------------------------
                 ,p.chk_conciliada_transferencia  =case when isnull(@fichero_transferencia,'')!='' then 1                                                 else null end  
                 ,p.fecha_conciliada_transferencia=case when isnull(@fichero_transferencia,'')!='' then getdate()                                         else null end
                 ,p.usuario_concilia_transferencia=case when isnull(@fichero_transferencia,'')!='' then us.descripcion                                    else null end
                 ,p.importe_concilia_transferencia=case when isnull(@fichero_transferencia,'')!='' then @importe_transferencia_validado                   else null end
                 ,p.referencia_transferencia         =case when isnull(@fichero_transferencia,'')!='' then @conceptotransferenciavalidado                               else null end
                 ,p.fecha_pago_transferencia      =case when isnull(@fichero_transferencia,'')!='' then convert(datetime,@fechatransferenciavalidado,121) else null end
                 ,p.importe_pagado                =case when isnull(@fichero_transferencia,'')!='' then @importe_transferencia_validado                   else null end
                 ,p.chk_pagado_transferencia      =case when isnull(@fichero_transferencia,'')!='' then 1                                                 else null end
                 -------------------------------------------------------------------------------

            from TH_Presupuestos_Web p
            outer apply (select top 1 us.descripcion from usuarios us (nolock) where exists (select us.codigo intersect select convert(int,@fk_usuario)) ) us
            where p.codigo=@cod_TH_Presupuestos_Web
            set @afectados=@@rowcount

            -- alter table TH_Presupuestos_Web alter column emailcontactogestion varchar(300)

            if @afectados=0
               begin
                  set @validaciones='<p style=''font-size:1vw;color:red;font-weight:bold''><u>Se han detectado los siguientes errores:</u></p>'
                                   +'<ul style=''font-size:0.75vw;color:red;font-weight:normal''>'
                                   +'<li>Ha habido un problema en el registro de su solicitud</li>'
                                   +'</ul>'
                                   +'<p style=''font-size:0.75vw;color:black;font-weight:bold''>Vuelva a enviar por favor</p>'

                  set @js='listavalidaciones.innerHTML="'+@validaciones+'";'
                         +'seccionvalidacion.style.display='''';'
                  select 'OKNORELOAD'
                  +replace('[INIEVAL]'+isnull(@js,'')+'[FINEVAL]','[INIEVAL][FINEVAL]','')
                  return
               end
            -------------------------------------
            -------------------------------------
            set @validaciones='<p style=''font-size:1vw;color:green;font-weight:bold''><u>Registro de la Solicitud CORRECTO</u></p>'
                             +'<ul style=''font-size:0.75vw;color:green;font-weight:normal''>'
                             +'<li>En breve recibirá un correo electronico donde tendrá acceso al presupuesto en la dirección <b>'+@emailsolicitante+'</b></li>'
                         --  +'<li>El Presupuesto generado es el Nº <b>'+format(@cod_TH_Presupuestos_Web,'#,0','de-DE')+'</b></li>'
                             +'<li>El código de Presupuesto queda registrado con el Código Interno Nº <b>'+@semillapresupuesto+'</b></li>'
                             +'#mostrarnumeroinforme#'    
                             +'<li>Para solicitar un nuevo presupuesto haga click '
                                   +'<img id=''nuevopresupuesto'''
                                       +' class=''acciones'''
                                       +' src=''imgEXT/Repetir_Verificar_Informe_TH.png'''
                                       +' title=''Solicitar nuevo presupuesto'''
                                       +' onclick=''window.location.reload();''/>'
                             +'</li>'
                             +'</ul>'
            ---------------------------------------
            set @js=  'listavalidaciones.innerHTML="'+@validaciones+'";'
                     +'seccionvalidacion.style.display='''';'
                     ---------------------------------------
                     +'rpersona.disabled=true;'
                     +'fichero_dni.disabled=true;'
                     +'rempresa.disabled=true;'
                     +'nombresolicitante.readOnly=true;'
                     +'apellidossolicitante.readOnly=true;'
                     +'dnisolicitante.readOnly=true;'
                     +'empresasolicitante.readOnly=true;'
                     +'cifsolicitante.readOnly=true;'
                     +'emailsolicitante.readOnly=true;'
                     +'telefonosolicitante.readOnly=true;'
                     +'calle_sol.readOnly=true;'
                     +'numerocalle_sol.readOnly=true;'
                     +'portal_sol.readOnly=true;'
                     +'escalera_sol.readOnly=true;'
                     +'piso_sol.readOnly=true;'
                     +'letra_sol.readOnly=true;'
                     +'anexo_sol.readOnly=true;'
                     +'codigopostal_sol.readOnly=true;'
                     +'municipio_sol.readOnly=true;'
                     +'sch_municipio_sol.readOnly=true;'       -- Corresponde al desplegable Auto
            ---------------------------------------
            set @js+='mismosolicitantefacturacion.disabled=true;'
                     +'otrosolicitantefacturacion.disabled=true;'
            ---------------------------------------
            set @js+='rpersona_fac.disabled=true;'
                     +'rempresa_fac.disabled=true;'
                     +'nombresolicitante_fac.readOnly=true;'
                     +'apellidossolicitante_fac.readOnly=true;'
                     +'dnisolicitante_fac.readOnly=true;'
                     +'empresasolicitante_fac.readOnly=true;'
                     +'cifsolicitante_fac.readOnly=true;'
                     +'emailsolicitante_fac.readOnly=true;'
                     +'telefonosolicitante_fac.readOnly=true;'
                     +'calle_fac.readOnly=true;'
                     +'numerocalle_fac.readOnly=true;'
                     +'portal_fac.readOnly=true;'
                     +'escalera_fac.readOnly=true;'
                     +'piso_fac.readOnly=true;'
                     +'letra_fac.readOnly=true;'
                     +'anexo_fac.readOnly=true;'
                     +'codigopostal_fac.readOnly=true;'
                     +'municipio_fac.readOnly=true;'
                     +'sch_municipio_fac.readOnly=true;'       -- Corresponde al desplegable Auto
            ---------------------------------------
            set @js+= 'tipoinmueble.disabled=true;'
                     +'finalidad.disabled=true;'
                     +'calle.readOnly=true;'
                     +'numerocalle.readOnly=true;'
                     +'portal.readOnly=true;'
                     +'escalera.readOnly=true;'
                     +'piso.readOnly=true;'
                     +'letra.readOnly=true;'
                     +'anexo.readOnly=true;'
                     +'codigopostal.readOnly=true;'
                     +'municipio.readOnly=true;'
                     +'sch_municipio.readOnly=true;'       -- Corresponde al desplegable Auto
            ---------------------------------------
            set @js+= 'superficie.readOnly=true;'
                     +'regpropiedad.readOnly=true;'
                     +'fincaregistral.readOnly=true;'
                     +'refcatastral.readOnly=true;'
                     +'idufir.readOnly=true;'
            ---------------------------------------
            set @js+= 'nombrecontacto.readOnly=true;'
                     +'telefonocontacto.readOnly=true;'
                     +'tramitacionurgente.disabled=true;'
                     +'mismocontactogestion.disabled=true;'
                     +'otrocontactogestion.disabled=true;'
                     +'nombrecontactogestion.readOnly=true;'
                     +'apellidoscontactogestion.readOnly=true;'
                     +'dnicontactogestion.readOnly=true;'
                     +'telefonocontactogestion.readOnly=true;'
                     +'emailcontactogestion.readOnly=true;'
            ---------------------------------------
            if @fk_usuario is null
               begin
                  set @js+= 'seccionverificacion.style.display=''none'';' 
                           +'aceptaciondatos.disabled     =true;'
                           +'prefijo.disabled             =true;'
                           +'telefonoverificacion.readOnly=true;'
                           +'llaveenvio.readOnly          =true;'
                       
               end
            ---------------------------------------
            set @js+='secciongrabacion.style.display =''none'';'

            set @cpaso='Paso 006'

            declare @numinfor varchar(10)

            -- #################################################
            -- #################################################

            if 1=1   -- Llave de Grabacion
               begin
                   -----------------------
                   -- Generar el Informe
                   -----------------------
                   declare @resultado varchar(500)
                   exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Generar_Informe 
                         @cod_TH_Presupuestos_Web=@cod_TH_Presupuestos_Web
                        ,@codentid               =@codentid
                        ,@debug                  =0
                        ,@resultado              =@resultado output
                   
                   if @resultado!='OK'
                      begin
                        set @resultado='Generación Informe => '+@resultado
                        raiserror(@resultado,16,1,0)
                      end
                   set @cpaso='Paso 007'

                   -----------------------
                   -- Cálcular la Tarifa
                   -----------------------

                   declare @importe_pago_base	 decimal(19,2)
                          ,@importe_tarificado decimal(19,2)
                          ,@porcentaje_iva	    decimal(19,2)
                          ,@importe_pago_total	decimal(19,2)
                   
                   -- select * from TH_Presupuestos_Web_Tarifas
                   
                   set @importe_pago_base=null
                  
                   select @importe_pago_base =case when w.importe_presupuesto_manual is not null then w.importe_presupuesto_manual else isnull([tar].tarifa,[tarbase].tarifa) end
                         ,@importe_tarificado=isnull([tar].tarifa,[tarbase].tarifa)
                   from TH_Presupuestos_Web w
                   inner join CORITEL.dbo.taoencar e (nolock) on e.numinfor=w.numinfor
                   inner join TH_Entidades         c (nolock) on c.codentid=e.codentid
                   inner join TH_Objetos           o (nolock) on o.codobjet=e.codobjet
                   outer apply (select top 1 [tarifa]=t.importe_sin_iva
                                from TH_Presupuestos_Web_Tarifas t (nolock)
                                where t.fk_TH_Entidades=c.codigo
                                  and t.fk_TH_Objetos  =o.codigo
                                  and isnull(w.superficie,0) between isnull(t.superficie_desde,0) and isnull(t.superficie_hasta,20000000)
                                ) [tar]
                   outer apply (select top 1 [tarifa]=400.00) [tarbase]
                   where w.codigo=@cod_TH_Presupuestos_Web
                  
                   ----------------------------------------------------------------
                   -- Calcular el importe según tarifa y grabar en el presupuesto
                   ----------------------------------------------------------------
                  
                   set @porcentaje_iva    =21.00
                   select @porcentaje_iva=iva.iva
                   from INE_CRUDO_MUNICIPIO i (nolock) 
                   inner join CORITEL.dbo.taoprovi p (nolock) on p.codprovi=i.CPRO
                   outer apply (select top 1 [iva]=i.porcenta from CORITEL.dbo.taoimpue i (nolock) where i.codimpue=p.codimpue) [iva]
                   where i.codigo=@municipio

                   if @porcentaje_iva is null
                      begin
                         set @porcentaje_iva    =21.00
                      end
                  
                   ----------------------------------------------------------------------
                  
                   set @importe_pago_total=convert(decimal(19,2),@importe_pago_base*(1.00+(@porcentaje_iva/100.00)))
                  
                   update w
                      set w.importe_pago_base =@importe_pago_base
                         ,w.porcentaje_iva    =@porcentaje_iva
                         ,w.importe_pago_total=@importe_pago_total
                         ,w.importe_tarificado=@importe_tarificado
                   from TH_Presupuestos_Web w
                   where w.codigo=@cod_TH_Presupuestos_Web

                   -----------------------------------------------------------------------

                   /*  -- Para reajustar el IVA
                    
                   update w set 
                          w.importe_pago_total=convert(decimal(19,2),w.importe_pago_base *(1.00+(iva.iva/100.00)))
                         ,w.porcentaje_iva    =iva.iva
                   from TH_Presupuestos_Web w
                   inner join INE_CRUDO_MUNICIPIO i (nolock) on i.codigo=w.municipio
                   inner join CORITEL.dbo.taoprovi  p (nolock) on p.codprovi=i.CPRO
                   outer apply (select top 1 [iva]=i.porcenta from CORITEL.dbo.taoimpue i (nolock) where i.codimpue=p.codimpue) [iva]
                   where w.codigo=8378

                   */

                   -----------------------------------------------------------------------
                   -- Quitar la marca de presupuesto manual si coincide con la tarifa
                   -----------------------------------------------------------------------
                  
                   update w
                      set w.importe_presupuesto_manual=null
                   from TH_Presupuestos_Web w
                   where w.codigo=@cod_TH_Presupuestos_Web
                    and exists (select w.importe_pago_base intersect select w.importe_tarificado)
                  
                   -----------------------------------------------------------------------
                   -- Quitar la marca de presupuesto para importe_presupuesto_manual=null
                   -----------------------------------------------------------------------
                  
                   delete c
                   from TH_Presupuestos_Web w
                   inner join CORITEL.dbo.taoencar e on e.numinfor=w.numinfor
                   inner join CORITEL.dbo.taoencar_clasificacion c (nolock) on c.numinfor=e.numinfor and c.codclasif='0035'
                   where w.codigo=@cod_TH_Presupuestos_Web
                     and w.importe_presupuesto_manual is null
                  
                   -------------------------------------
                   -- Generar el PDF del presupuesto
                   -------------------------------------
                  
                   if exists (select * 
                              from TH_Entidades e (nolock)
                              where e.codentid=@codentid 
                                and (   e.fk_usuario_comercial is null 
                                     or exists (select e.chk_generar_pdf_presupuesto intersect select 1)
                                    )  
                              )  -- Tiene un comercial asignado => no se genera documento de presupuesto salvo que tenga flag de generacion
                      begin
                         declare @resultado_PDF  varchar(500)
                         exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Generar_PDF 
                              @cod_TH_Presupuestos_Web=@cod_TH_Presupuestos_Web
                             ,@ensilencio             =1
                             ,@resultado_PDF          =@resultado_PDF output
                         
                         if @resultado_PDF!='OK'
                            begin
                              set @resultado_PDF='Generación PDF => '+@resultado_PDF
                              raiserror(@resultado_PDF,16,1,0)
                            end
                         set @cpaso='Paso 008'
                      end
                  
                   -------------------------------
                   -- Registrar la Operacion TPV
                   -------------------------------
                  
                   declare @fecha_operacion_TPV     datetime=getdate()
                   declare @fecha_fin_operacion_TPV datetime=dateadd(month,1,@fecha_operacion_TPV)
                   declare @minutos                 int
                  
                   set @minutos=datediff(minute,@fecha_operacion_TPV,@fecha_fin_operacion_TPV)
                  
                   declare @pedido   varchar(15)
                   declare @precio   varchar(100)
                   declare @producto varchar(100)='Presupuesto TH Nº '+@pedido
                  
                   select @pedido  =p.numinfor
                         ,@precio  =format(isnull(p.importe_pago_total,484.00)*100.00,'0')
                         ,@producto='Presupuesto TH Nº '+p.numinfor
                   from TH_Presupuestos_Web p
                   where p.codigo=@cod_TH_Presupuestos_Web
                   
                   ------------------------------------------
                  
                   declare @token               varchar(1000)
                   select @token=CLR_UTILS.dbo.TokenTpv('123@456$789¿Ñ?sistemAsolaR', @minutos, @pedido, @precio, @producto)
                   declare @url_TPV varchar(1000)='https://app.tasacioneshipotecarias.com/tpv-test/pago?token='+@token
                  
                   --print @url_TPV
                  
                   update p 
                      set p.operacion_TPV                 =@url_TPV
                         ,p.fecha_operacion_TPV           =@fecha_operacion_TPV
                         ,p.minutos_vigencia_operacion_TPV=@minutos
                         ,p.contador_TPV                  =0  
                   from TH_Presupuestos_Web p
                   where p.codigo=@cod_TH_Presupuestos_Web
                   set @cpaso='Paso 009'
                  
                   -------------------------------------
                   -- Generar las coincidencias
                   -------------------------------------
                  
                   exec TH_Informes_Acceso_Externo_Buscar_Coincidencias_Procesar 
                        @debug                 =0
                       ,@fk_TH_Presupuestos_Web=@cod_TH_Presupuestos_Web
                       ,@en_silencio           =1
                   set @cpaso='Paso 010'

                   if exists (select * 
                              from TH_Entidades e (nolock)
                              where e.codentid=@codentid 
                                and (   e.fk_usuario_comercial is null 
                                     or exists (select e.chk_generar_pdf_presupuesto intersect select 1) 
                                    )  
                              )  -- Tiene un comercial asignado => no se genera documento de presupuesto salvo que tenga flag de generacion
                      begin
                         -------------------------------------
                         -- Enviar el Correo para la Descarga
                         -------------------------------------
                         declare @resultado_EMAIL varchar(500)
                         exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Enviar_Email_Cliente
                               @cod_TH_Presupuestos_Web=@cod_TH_Presupuestos_Web
                           -- ,@emailobligado          ='jd.dominguez@zarentia.es'
                              ,@nota_adicional         =null
                              ,@en_silencio            =1
                              ,@debug                  =0
                              ,@resultado_EMAIL        =@resultado_EMAIL output
                         
                         if @resultado_EMAIL!='OK'
                            begin
                              set @resultado_EMAIL='Generación Email => '+@resultado_EMAIL
                              raiserror(@resultado_EMAIL,16,1,0)
                            end
                         
                         set @cpaso='Paso 011'
                      end
                   -------------------------------
               end
             else    -- Llave de Grabacion cerrada => se muestra elk último numero de informe
               begin
                  select @numinfor=p.numinfor from TH_Presupuestos_Web p order by p.codigo desc
               end

            -- #################################################
            -- #################################################

            if @fk_usuario is not null
               begin
                  select @numinfor=p.numinfor from TH_Presupuestos_Web p where p.codigo=@cod_TH_Presupuestos_Web
                  set @js=replace(isnull(@js,''),'#mostrarnumeroinforme#','<li>El Nº de Informe Generado es <b>'+isnull(@numinfor,'')+'</b></li>')
               end
             else
               begin
                  set @js=replace(isnull(@js,''),'#mostrarnumeroinforme#','')
               end
            
            set @cpaso='Paso 012'

            ------------------------------

            select 'OKNORELOAD'
                   +replace('[INIEVAL]'+isnull(@js,'')+'[FINEVAL]','[INIEVAL][FINEVAL]','')

        end

end try begin catch
      
      while @@trancount>0 begin rollback end
      declare @p_error varchar(2000)
          set @p_error= 'ERROR EN EL SISTEMA DE DATOS.'+char(13)
                       +'Paso => '+@cpaso+char(13)
                       +isnull(convert(varchar(300),ERROR_MESSAGE()),'')+char(13)
                       +'Informática Recibirá un Correo informando del mismo para solucionar el problema.'+char(13)
      declare @error_email varchar(max)

      set @error_email= 
                       +'NºErr: '+isnull(convert(varchar(300),ERROR_NUMBER()),'')+char(13)+char(13)
                       +'Proc.: '+@prbbdd+char(13)+char(13)
                       +'Paso => '+@cpaso+char(13)
                       +'Línea: '+isnull(convert(varchar(300),ERROR_LINE()),'')+char(13)+char(13)
                       +'Error: '+isnull(convert(varchar(300),ERROR_MESSAGE()),'')+char(13)+char(13)

      set @error_email=replace(replace(@error_email,char(13),'<br/>'),char(10),'<br/>')
      exec Email_Error_Sistema null, @error_email
      
      --------------------------------------------------------------------
      select 'OKNORELOAD. ERROR: '+@p_error

end catch

end

--select fichero_transferencia, chk_pagado_transferencia, chk_pagado_transferencia from TH_Presupuestos_Web p where p.codigo=8448
GO
