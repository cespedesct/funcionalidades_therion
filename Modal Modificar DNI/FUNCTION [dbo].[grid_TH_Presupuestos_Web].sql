SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[grid_TH_Presupuestos_Web] (@codigo int, @usuario int)

returns VARCHAR(max)
AS

  BEGIN

      set @usuario=isnull(@usuario,0)

      declare @estado_PAGO             varchar(100)
      declare @chk_PAGADO              bit
      declare @chk_CONCILIADO_PAGO     bit
      declare @chk_CONCILIAR_PAGO      bit
      declare @datos_CONCILIACION      varchar(500)
      declare @pagado_por_TPV          bit
      declare @solicitante             varchar(300)
             ,@dnisolicitante          varchar(300)
             ,@cifsolicitante          varchar(300)
             ,@emailsolicitante        varchar(300)
             ,@direccion               varchar(300)
             ,@fecha_alta              varchar(300)
             ,@tipo_inmueble           varchar(300)
             ,@finalidad               varchar(300)
             ,@superficie              varchar(300)
             ,@regpropiedad            varchar(300)
             ,@fincaregistral          varchar(300)
             ,@catastral               varchar(300)
             ,@nombrecontacto          varchar(300)
             ,@telefonocontacto        varchar(300)
             ,@nombrecontactogestion   varchar(300)
             ,@telefonocontactogestion varchar(300)
             ,@emailcontactogestion    varchar(300)
             ,@dnicontactogestion      varchar(300)
             ,@numinfor                varchar(10) 
             ,@lista_mail              varchar(max)
             ,@mismocontactogestion    varchar(3)
             ,@otrocontactogestion     varchar(3)
             ,@fichero_dni             varchar(max)
             ,@actualizar_dni             varchar(max)
             ,@fichero_justificante    varchar(max)
             ,@fichero_notasimple      varchar(max)
             ,@fichero_transferencia   varchar(max)
             ,@chk_es_tasador          bit=0
             ,@chk_es_ext              bit=0
             ,@usuario_asignador       varchar(200)

       declare @importe_pago_base	 decimal(19, 2)
       declare @porcentaje_iva	    decimal(19, 2)
       declare @importe_pago_total	decimal(19, 2)
       declare @dnisolicitante_valido bit=0
       declare @cifsolicitante_valido bit=0

      if @usuario!=0
         begin
             select @estado_PAGO=
                    case when w.chk_pagado_transferencia is not null and w.chk_pagado_transferencia=1 then 'Pagado por Tranferencia<br>'+isnull(format(w.fecha_pago_transferencia,'dd/MM/yyyy'),'No Informado')
                         when w.TPV_Ds_Response is null                                               then '<span style="color:red">Pendiente de Pago</span>'
                         when w.TPV_Ds_Response is not null and w.TPV_Ds_Response=0                   then 'Pagado por TPV'
                                                                                                          +isnull('<br>'+w.TPV_Ds_Date,'')
                                                                                                          +isnull(' '+w.TPV_Ds_Hour,'')
                                                                                                          +isnull('<br>(Aut. '+w.TPV_Ds_AuthorisationCode+')','')
                         when w.TPV_Ds_Response!=0                                                    then 'No Autorizado por TPV ('+convert(varchar,w.TPV_Ds_Response)+')' 
                         else 'Desconocido'
                    end
                   ,@chk_PAGADO=
                    case when w.chk_pagado_transferencia is not null and w.chk_pagado_transferencia=1 then 1
                         when w.TPV_Ds_Response is not null and w.TPV_Ds_Response=0                   then 1
                         else 0
                    end
                   ,@chk_CONCILIADO_PAGO=
                    case when w.TPV_Ds_Response is not null and w.TPV_Ds_Response=0                   then 1
                         when w.chk_pagado_transferencia=1 and exists (select w.chk_conciliada_transferencia intersect select 1) then 1
                         else 0
                    end
                   ,@chk_CONCILIAR_PAGO=
                    case when w.TPV_Ds_Response is not null and w.TPV_Ds_Response=0                   then 0
                         when w.chk_pagado_transferencia=1 and exists (select w.chk_conciliada_transferencia intersect select null) and isnull(w.fichero_transferencia,'')!='' then 1
                         else 0
                    end
                   ,@datos_CONCILIACION=
                    case when w.TPV_Ds_Response is not null and w.TPV_Ds_Response=0                   then ''
                         when w.chk_pagado_transferencia=1 and exists (select w.chk_conciliada_transferencia intersect select 1) 
                              then 'Checking Pago realizado por '+isnull(w.usuario_concilia_transferencia,'No informadp')+' el '+isnull(format(w.fecha_conciliada_transferencia,'dd/MM/yyyy HH:mm:ss'),'desconocida')
                         else ''
                    end
                   ,@solicitante=case when w.rpersona='1' then isnull(w.nombresolicitante,'')+isnull(' '+w.apellidossolicitante,'')
                                      when w.rempresa='1' then isnull(w.empresasolicitante,'')
                                      else 'Desconocido'
                                    end
                   ,@dnisolicitante=case when w.rpersona='1' then isnull(w.dnisolicitante,'')
                                         when w.rempresa='1' then null
                                         else null
                                    end
                   ,@cifsolicitante=case when w.rpersona='1' then null
                                         when w.rempresa='1' then isnull(w.cifsolicitante,'')
                                         else null
                                    end
                   ,@emailsolicitante=w.emailsolicitante
                   ,@direccion  = 
                                  isnull(w.calle,'')
                                 +isnull(', '+w.numerocalle,'')
                                 +case when isnull(w.portal  ,'')!='' then isnull(', Portal '+w.portal,'') else '' end
                                 +case when isnull(w.escalera,'')!='' then isnull(', Esc. '  +w.escalera,'') else '' end
                                 +case when isnull(w.piso    ,'')!='' then isnull(', Piso '  +w.piso,'') else '' end
                                 +case when isnull(w.letra   ,'')!='' then isnull(', Letra ' +w.letra,'') else '' end
                                 +isnull('<br>'+w.codigopostal+'-','')
                                 +isnull('('+replace(replace(mu.NOMBRE,'''','´'),' ',' ')+')', '')
                   ,@tipo_inmueble=case when w.tipoinmueble='80008' then 'Vivienda-Piso'
		                                      when w.tipoinmueble='80012' then 'Vivienda Unifamiliar'
		                                      when w.tipoinmueble='80006' then 'Plaza de Garaje'
		                                      when w.tipoinmueble='80007' then 'Trastero'
		                                      when w.tipoinmueble='80009' then 'Local Comercial'
                                        when w.tipoinmueble='80013' then 'Oficina'
                                        when w.tipoinmueble='80014' then 'Nave Industrial'
                                        when w.tipoinmueble='80010' then 'Edificio'
                                        when w.tipoinmueble='80018' then 'Rústica (Edificaciones)'
                                        when w.tipoinmueble='80017' then 'ILAE'
                                        when w.tipoinmueble='90001' then 'Terrenos'
                                        else 'Desconocido'
                                   end
                   ,@finalidad    =case when w.finalidad='HI' then 'Préstamo Hipotecario'
                                        when w.finalidad='ME' then 'Valor de Mercado'
                                        else 'Desconocido'
                                   end
                   ,@superficie             =w.superficie
                   ,@regpropiedad           =w.regpropiedad
                   ,@fincaregistral         =w.fincaregistral
                   ,@nombrecontacto         =w.nombrecontacto
                   ,@telefonocontacto       =w.telefonocontacto
                   ,@mismocontactogestion   =w.mismocontactogestion
                   ,@otrocontactogestion    =w.otrocontactogestion
                   ,@nombrecontactogestion  =case when w.otrocontactogestion='0' then isnull(w.nombresolicitante,'')+isnull(' '+w.apellidossolicitante,'') else isnull(w.nombrecontactogestion,'')+isnull(' '+w.apellidoscontactogestion,'') end
                   ,@telefonocontactogestion=case when w.otrocontactogestion='0' then w.telefonocontacto else w.telefonocontactogestion end
                   ,@emailcontactogestion   =case when w.otrocontactogestion='0' then w.emailsolicitante else w.emailcontactogestion end
                   ,@dnicontactogestion     =case when w.otrocontactogestion='0' then w.dnisolicitante   else w.dnicontactogestion end
             
                   ,@catastral              =w.refcatastral
                   ,@fecha_alta             =format(w.fecha_registro,'dd/MM/yyyy HH:mm:ss')

                   ,@importe_pago_base	 =isnull(w.importe_pago_base ,400.00)
                   ,@porcentaje_iva	    =isnull(w.porcentaje_iva    ,21.00)
                   ,@importe_pago_total	=isnull(w.importe_pago_total,484.00)
                   ,@numinfor           =isnull(w.numinfor,format(w.codigo,'#,0','de-DE'))
                   ,@fichero_dni         =case when e.estinfor not in ('X','4','5','6','F')
                                               then 
                                                '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_agregar_documento.png"'
                                               +' title="Agregar DNI forma Manual"'
                                               +' onclick="Show_Capa_Fichero_Grid(''TH_Presupuestos_Web'',''fichero_dni'','+format(w.codigo,'0')+')"' 
                                               +' >' 
                                               else ''
                                          end
                                         +case when isnull(w.fichero_dni,'')!='' then
                                                '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_ico_view_files.png"' 
                                                   +' title="Acceso al documento DNI"'          
                                                   +' onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura('''+isnull(w.fichero_dni,'')+''',''TH_Presupuestos_Web'',''fichero_dni'','+format(w.codigo,'0')+')"'
                                                +'>'
                                               else ''
                                          end

                    ,@actualizar_dni         =case when w.dnisolicitante!=''
                                             then 
                                             '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/compras.png"'
                                             +' title="Actualizar DNI del Solicitante"'   
                                              +'onclick="var l =''{confirmacion|Actualizar de Número del DNI del Solicitante del Encargo Nro. '+isnull(w.numinfor,'')+'|||}'';'
                                   
                                            +' l+=''{texto||DNI|'+isnull('','')+'#obligatorio#|}'';'
                                            +' var p=''WSQL(`exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Editar_DNI_Solicitante @cod_TH_Presupuestos_Web=·'+w.codigo_presupuesto+'·,@dni_actualizado=·#parametro_value_1#·,@usuario='+format(@usuario,'0')+'`)'';'
                                         +'Pide_Parametros(l,p);'
                                         +'"'
                                             +' >' 
                                             else ''
                                             end
                                             +case when isnull(w.fichero_dni,'')!='' then
                                                  '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_ico_view_files.png"' 
                                                       +' title="Acceso al documento DNI"'          
                                                       +' onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura('''+isnull(w.fichero_dni,'')+''',''TH_Presupuestos_Web'',''fichero_dni'','+format(w.codigo,'0')+')"'
                                                  +'>'
                                                  else ''
                                             end
                   ,@fichero_justificante=case when e.estinfor not in ('X','4','5','6','F') then
                                                   '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_agregar_documento.png"'
                                                  +' title="Agregar Justificante AUTORIZACION forma Manual"'
                                                  +' onclick="Show_Capa_Fichero_Grid(''TH_Presupuestos_Web'',''fichero_justificante'','+format(w.codigo,'0')+')"'
                                                  +' >' 
                                               else '' 
                                          end
                                         +case when isnull(w.fichero_justificante,'')!='' then
                                                    '<img class="click aumenta"  style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_ico_view_files.png"' 
                                                   +' title="Acceso al documento Justificante" '
                                                   +' onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura(''' + isnull(w.fichero_justificante,'') + ''',''TH_Presupuestos_Web'',''fichero_justificante'','+format(w.codigo,'0')+')" '
                                                   +' >'
                                               else ''
                                          end
                   ,@fichero_transferencia=case when w.chk_pagado_transferencia is not null and w.chk_pagado_transferencia=1 then
                                                case when e.estinfor not in ('X','4','5','6','F') then
                                                         '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_agregar_documento.png" '
                                                        +' title="Agregar JUSTIFICANTE Transferencia" '
                                                        +' onclick="Show_Capa_Fichero_Grid(''TH_Presupuestos_Web'',''fichero_transferencia'','+format(w.codigo,'0')+')" '
                                                        +' >' 
                                                     else '' 
                                                end
                                               +case when isnull(w.fichero_transferencia,'')!='' then
                                                          '<img class="click aumenta"  style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_ico_view_files.png"' 
                                                         +' title="Acceso al documento Justificante de TRANFERENCIA" '
                                                         +' onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura('''+isnull(w.fichero_transferencia,'')+''',''TH_Presupuestos_Web'',''fichero_transferencia'','+format(w.codigo,'0')+')" '
                                                         +'>'
                                                     else ''
                                                end
                                                else ''
                                           end
                   ,@fichero_notasimple   =case when e.estinfor not in ('X','4','5','6','F') then
                                                    '<img class="click aumenta" style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_agregar_documento.png" '
                                                   +' title="Agregar NOTA SIMPLE forma Manual" '
                                                   +' onclick="Show_Capa_Fichero_Grid(''TH_Presupuestos_Web'',''fichero_notasimple'','+format(w.codigo,'0')+')" 
                                                     >' 
                                                else '' 
                                           end
                                          +case when isnull(w.fichero_notasimple,'')!='' then
                                                     '<img class="click aumenta"  style="padding-left:0px;vertical-align:middle;width:1vw;height:auto" src="img/ico_ico_view_files.png"' 
                                                    +'  title="Acceso al documento Nota Simple" '
                                                    +'  onclick="Show_Lista_Ficheros_Ristra_Solo_Lectura('''+isnull(w.fichero_notasimple,'')+''',''TH_Presupuestos_Web'',''fichero_notasimple'','+format(w.codigo,'0')+')" '
                                                    +'>'
                                                else ''
                                           end
                     ,@usuario_asignador=CORITEL.dbo.taoencar_usuario_asignador_tasador(w.numinfor)
             from TH_Presupuestos_Web w (nolock)
             left outer join CORITEL.dbo.taoencar e (nolock) on  e.numinfor=w.numinfor
             left outer join usuarios             u (nolock) on  u.codigo  =w.fk_usuarios
             left outer join INE_CRUDO_MUNICIPIO mu (nolock) on mu.codigo  =convert(int,w.municipio)
             where w.codigo=@codigo
              
             ---------------------------             
             -- Validación de Dni y CIF
             ---------------------------

             if @dnisolicitante is not null
                begin
                  if dbo.DNI_con_DC(@dnisolicitante)=@dnisolicitante
                     begin
                        set @dnisolicitante_valido=1
                     end
                end

             if @cifsolicitante is not null             
                begin
                   if dbo.THERION_Validar_CIF_Europeo ('ES',@cifsolicitante)=1
                      begin
                         set @cifsolicitante_valido=1
                      end
                end

             ------------------------------------
             select @chk_es_tasador=case when left(u.login ,4)='TAS_' then 1 else 0 end
                   ,@chk_es_ext    =case when left(u.login ,4)='EXT_' then 1 else 0 end
             from usuarios u (nolock)
             where u.codigo=@usuario
             ------------------------------------
             select @lista_mail=replace(replace(replace(replace(replace(replace(
             (select [a]=isnull('<span style="vertical-align:middle;display:inline-block;width:45%;border:solid 0px #eee">'+replace(m.destinatarios,';','<br>')+'</span>','')
                        +isnull(' _flecha_ '+format(m.fecha_envio,'dd/MM/yy HH:mm'),' _flecha_ Pte. Enviar')
                        +isnull(' _flecha_ '+m.estado_envio,'')
                        +isnull(' _flecha_ ERROR _flecha_ <span style="color:red">'+m.error_envio+'</span>','')
                        +case when e.estinfor!='0' then '' else 
                        +isnull(' <img class="aumenta" '
                                      +' title="Reenviar el Correo" '
                                      +' style="cursor:pointer;vertical-align:middle;width:0.8vw;height:auto;padding-left:0.1vw" '
                                      +' src="imgEXT/reenviar_email_presupuesto.png" '
                                      +' onclick="var p=''{texto|Reenviar Email Presupuesto Nº '+n.numinfor+'|Email|'+isnull(rtrim(m.destinatarios),'')+'||}'
                                                      +'{combo||Actualizar Email (Solicitante) del Presupuesto y Encargo:|1|Opciones_Si_No|#obligatorio#}'';'
                                                      +' var a=''WSQL(`TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Enviar_Email_Cliente @cod_TH_Presupuestos_Web='+format(n.codigo,'0')+',@emailobligado=·#parametro_value_1#·,@en_silencio=0,@actualizar_email=#parametro_value_2#`)'';'
                                                      +' Pide_Parametros(p,a);'
                                      +' "'
                                 +'>','')
                        end
              from TH_Presupuestos_Web n (nolock)
              left outer join CORITEL.dbo.taoencar e (nolock) on e.numinfor=n.numinfor
              outer apply (select [destinatarios]=e.recipients 
                                 ,[fecha_envio] =e.fecha_envio
                                 ,[mailitem_id] =e.mailitem_id
                                 ,[estado_envio]=e.estado_envio
                                 ,[error_envio] =e.error_envio
                           from dbo.f_split(n.lista_email_enviados,',') l 
                           inner join SISTEMA_email e on e.codigo=convert(int,l.items)
                           where isnull(l.items,'')!=''
                           ) m
              where n.lista_email_enviados is not null
                and n.codigo=@codigo
              for xml path(''), elements),'</span><span>','<br>'),'<span>',''),'</span>',''),'&gt;','>'),'&lt;','<'),'_flecha_','&#8608;')
         end
      ---------------------------------

      declare @sombreado_tr varchar(500)='-webkit-box-shadow: 0px -4px 2px 0px rgba(0,0,0,0.33); box-shadow: 0px -4px 2px 0px rgba(0,0,0,0.33)'

      declare @r varchar(max)
      select @r=
      '<table class="tabla_grid">'
        +'<tr style="'+@sombreado_tr+';'+case when e.estinfor='X' then 'text-decoration:line-through;' else '' end +'">'
            ---------------------------------------
            +'<td style="width:6%;text-align:center" name="Nº Presupuesto">'
               +case when @usuario=0 then ''
                     else 
                     case when @chk_es_tasador=0 and @chk_es_ext=0
                          then '<span class="click" style="cursor:pointer;vertical-align:middle;font-size:0.8vw;'+case when e.estinfor='X' then ';text-decoration-line:line-through;color:gray' else '' end+'"'
                                +' onclick="Mostrar_Filtrado_2(`TH_Informes`,`numinfor=·'+isnull(n.numinfor,'')+'·`)" >'+isnull(n.numinfor,'')+'</span>'
                          else '<span class="click" style="vertical-align:middle;font-size:0.8vw;'+case when e.estinfor='X' then ';text-decoration-line: line-through;color:gray' else '' end+'"  >'+isnull(n.numinfor,'')+'</span>'
                     end
                     +'<span style="vertical-align:middle;font-size:0.55vw;padding-left:0.2vw;">('+format(n.codigo,'#,0','de-DE')+')</span>'
                     +isnull('<br><span style="font-size:0.50vw">'+dbo.TH_Informes_Texto_Estado (n.numinfor)+'</span>','')
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:5%;word-break:break-all;text-align:center" name="Fecha Registro">'
                  +case when @usuario=0 then '' else format(n.fecha_registro,'dd/MM/yyyy<br>HH:mm:ss') end
            +'</td>'
            ----------------------------------------
            +'<td style="width:7%;word-break:break-all" name="Estado de Pago">'
               +case when @usuario=0 then '' 
                     when e.estinfor='X' then '<span style="color:red"><b>RECHAZADO</b></span>'
                     else isnull(@estado_PAGO,'') 
                     +case when @chk_PAGADO=0  then 
                          '<br><br>'
                         +'<img class="aumenta" '
                                +'title="Marcar el Presupuesto como Pagado" '
                                +'style="cursor:pointer;vertical-align:middle;width:1.3vw;height:auto;padding-right:0.3vw" '
                                +'src="imgEXT/presupuesto_pagar.png" '
                                +'onclick="var l =''{fecha|Marcar el Presupuesto '+@numinfor+' como pagado<br><br>|Fecha Pago|'+format(getdate(),'dd/MM/yyyy')+'#obligatorio#|}'';'
                                            +' l+=''{numero||Importe del Pago|'+format(@importe_pago_total,'0.00','de-DE')+'#obligatorio#|}'';'
                                            +' l+=''{texto||Ordenante|'+isnull(@solicitante,'')+'#obligatorio#|}'';'
                                            +' var p=''WSQL(`exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Pagado @cod_TH_Presupuestos_Web='+format(n.codigo,'0')+',@fecha_pago=·#parametro_value_1#·,@importe=·#parametro_value_2#·,@ordenante=·#parametro_value_3#·,@usuario='+format(@usuario,'0')+'`)'';'
                                         +'Pide_Parametros(l,p);'
                                         +'"'
                            +'>'
                         +'<img class="aumenta" '
                                +'title="Rechazar Presupuesto y Anular Informe" '
                                +'style="cursor:pointer;vertical-align:middle;width:1.3vw;height:auto;padding-right:0.3vw" '
                                +'src="imgEXT/rechazar_presupuesto.png" '
                                +'onclick="var l=''{confirmacion|Desestimar el Presupuesto '+@numinfor+'<br><br>||}'';'
                                +'         var p=''WSQL(`exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Rechazar @cod_TH_Presupuestos_Web='+format(n.codigo,'0')+'`)'';'
                                +'         Pide_Parametros(l,p);'
                                +'        "'
                         +'>'
                         +'<img class="aumenta"' 
                                +'title="Generar Nueva Operación TPV" '
                                +'style="cursor:pointer;vertical-align:middle;width:1.3vw;height:auto;padding-right:0.3vw" '
                                +'src="imgEXT/nueva_operacion_TPV.png" '
                                +'onclick="var l=''{confirmacion|Generar nueva Operación TPV '+@numinfor+'<br><br>||}'';'
                                        +' var p=''WSQL(`exec TH_Presupuestos_Web_Nueva_Operacion_TPV @codigo='+format(n.codigo,'0')+'`)'';'
                                        +' Pide_Parametros(l,p);'
                                        +' "'
                          +'>'
                          else '' 
                      end
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:8%;word-break:break-all" name="Inmueble/Finalidad">'
               +case when @usuario=0 then '' else 
                     isnull(@tipo_inmueble,'') 
                    +isnull('<br>'+@finalidad,'')
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:auto;word-break:break-all" name="Entidad/Solicitante<br>Contacto/Contacto Gestión">'
               +case when @usuario=0 then '' else 
                    +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px;">'
                    +isnull('<b>'+c.codentid+'</b> - '+ltrim(rtrim(c.desentid)),'') 
                    +isnull('<br><span title="Solicitante" style="color:black">&#128188;'+@solicitante+'</span>','') 
                    +case when @dnisolicitante is not null then
                          isnull('<span style="color:gray"> ('+@dnisolicitante+')</span>','') 
                          +case when @dnisolicitante_valido=0 then isnull('<br><span style="color:white;background:red;padding:1px;">DNI Inválido</span>','') else '' end
                          else '' 
                     end
                    +case when @cifsolicitante is not null then
                          isnull('<span style="color:gray"> ('+@cifsolicitante+')</span>','') 
                          +case when @cifsolicitante_valido=0 then isnull('<br><span style="color:white;background:red;padding:1px;">CIF Inválido</span>','') else '' end
                          else '' 
                     end
                    +isnull('<br><span title="Contacto" style="color:blue">&#128222;<i>'+@nombrecontacto+isnull(' ('+@telefonocontacto+')','')+'</i></span>','') 
                    +case when @otrocontactogestion='0' then '' 
                          else isnull('<br><span title="Contacto Gestión" style="color:maroon">&#9874;&#65039;<i>'+@nombrecontactogestion+isnull(' ('+@telefonocontactogestion+')','')+'</i></span>','') 
                     end
                    +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:14%;word-break:break-all" name="Direccion">'
               +case when @usuario=0 then '' else 
                    +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                    +isnull(@direccion,'') 
                    +'<br><span style="color:gray">Idufir: </span>'+case when isnull(n.idufir,'')        !='' then isnull('<b>'+n.idufir        +'</b>','') else isnull('<b>No informado</b>','') end   
                    +'<br><span style="color:gray">Finca: </span>' 
                        +case when isnull(n.fincaregistral,'')!='' then 
                              isnull('<b>'+n.fincaregistral+'</b>','') 
                             +case when isnull(n.regpropiedad,'')!='' then isnull(' ('+n.regpropiedad+')','') else '' end
                              else isnull('<b>No informada</b>','') 
                         end   
                    +'<br><span style="color:gray">Ref.Catast.: </span>'+case when isnull(n.refcatastral ,'')!='' then isnull('<b>'+n.refcatastral+'</b>','') else isnull('<b>No informada</b>','') end   
                    +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:13%;word-break:break-all" name="Comercial/Tasador<br>Externo/Gestor">'
               +case when @usuario=0 then '' else 
                     isnull(case when left(u.login,4)='TAS_' then '<span style="font-size:0.8vw;">&#128119;</span>' 
                                 when left(u.login,4)='EXT_' then '<span style="font-size:0.8vw;">&#127968;</span>' 
                                 else '' 
                            end
                            +isnull(u.descripcion,'')
                            +isnull('<br><span style="color:blue"><i>'+api.descripcion+'</i></span>','')
                            ,'<span style="color:blue"><b>WEB</b></span>') 
                     +isnull('<br><span style="color:red">'+@usuario_asignador+'</span>','')
                     +case when n.aviso_sms_tasador_completar is not null then
                           '<hr><span style="font-size:0.60vw;color:red;font-weight:bold;padding-right:0.1vw;">Avisado por SMS Falta Doc. '+format(n.fecha_aviso_tasador_completar,'dd/MM/yy HH:mm')+'</span>'
                          +'<br><span style="font-size:0.50vw;color:#ca6f1e;font-weight:normal;padding-right:0.1vw;"><i>('+n.aviso_sms_tasador_completar+')</i></span>'
                          +'<hr>'
                           else ''  
                      end

                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:3%;text-align:center;vertical-align:top" name="DNi">'
               +case when @usuario=0 then '' else 
                    '<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                    +isnull(@fichero_dni,'') 
                    +isnull(@actualizar_dni,'')
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:3%;text-align:center;vertical-align:top" name="Just.<br>Autor.">'
               +case when @usuario=0 then '' else 
                     '<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                    +isnull(@fichero_justificante,'') 
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:3%;text-align:center;vertical-align:top" name="Just.<br>Trans.">'
               +case when @usuario=0 then '' else 
                     '<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                    +isnull(@fichero_transferencia,'') 
                    +case when @chk_es_tasador=1 or @chk_es_ext=1 then '' 
                          when @chk_CONCILIAR_PAGO=1 then 
                               --'<br><img class="aumenta" '
                               --      +'title="Confirmar Check Pagado" '
                               --      +'style="cursor:pointer;vertical-align:middle;width:1.3vw;height:auto" '
                               --      +'src="img/checkpagado.png" '
                               --      +'onclick="var l =''{confirmacion|Confirmar Checking Pago Informe '+@numinfor+' como pagado<br><br>||}'';'
                               --                  +' var p=''WSQL(`exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Check_Pagado @cod_TH_Presupuestos_Web='+format(n.codigo,'0')+',@usuario='+format(@usuario,'0')+'`)'';'
                               --               +'Pide_Parametros(l,p);'
                               --               +'"'
                               --  +'>'
                               --+case when @usuario!=1 then '' else 
                                   +' <img class="click aumenta" style="width:1.4vw;height:auto" src="img/checkpagado.png" title="Confirmar el Pago" 
                                           onclick="WHTML_General(''TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Check_Pagado_con_PDF @cod_TH_Presupuestos_Web='+format(n.codigo,'0')+',@usuario='+format(@usuario,'0')+''',1);">'
                               -- end

                          else ''
                     end
                  --+case when isnull(@fichero_transferencia,'')!='' and @chk_CONCILIADO_PAGO=1 then 
                    +case when isnull(@fichero_transferencia,'')!='' then 
                          '<br><br><span style="color:green;vertical-align:middle;font-weight:bold" title="'+isnull(@datos_CONCILIACION,'')+'">Check OK</span>'
                          +case when n.importe_concilia_transferencia is null then '' else 
                                '<br><span style="color:green;vertical-align:middle;font-weight:bold;padding-left:0.1vw">('+format(n.importe_concilia_transferencia,'#,0.00','de-DE')+')</span>'
                           end
                          else ''
                     end
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:3%;text-align:center;vertical-align:top" name="Nota<br>Simple">'
               +case when @usuario=0 then '' else 
                     '<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                     +isnull(@fichero_notasimple,'') 
                end
            +'</td>'
            ----------------------------------------
            +'<td style="width:3%;text-align:right;padding-right:0.2vw;" name="Imp.">'
               +case when @usuario=0 then '' else 
                     '<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                     +isnull(format(@importe_pago_base,'#,0.00','de-DE'),'') 
                     +'<br><span style="font-size:0.50vw;">'+isnull(format(@porcentaje_iva,'#,0.00','de-DE')+' % IVA</span>','')
                     +'<br>'
                     +case when n.importe_presupuesto_manual is not null or 1=2 then
                           +'<span style="font-size:0.70vw;color:red;font-weight:bold;padding-right:0.1vw;">(M)</span>'
                           else ''
                      end
                     +isnull('<b>'+format(@importe_pago_total,'#,0.00','de-DE')+'</b>','')
                     +case when n.importe_presupuesto_manual is not null or 1=2 then
                           +isnull('<br>'+format(n.importe_tarificado,'#,0.00','de-DE')+'</b>','')
                           else ''
                      end
                     +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
               end
            +'</td>'
            ----------------------------------------
            +'<td style="width:15%;word-break:break-all ;font-size:0.55vw;" name="Emails">'
               +case when @usuario=0 then '' else 
                    '<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                    +isnull(@lista_mail,'') 
                    +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px">'
                end
            +'</td>'
        +'</tr>'
        +case when isnull(n.rejilla_html_coincidentes,'')!='' and @usuario=1 then
                +'<tr>'
                +'<td colspan="13" ><div id="coincidencias_'+format(n.codigo,'0')+'" style="width:100%">'+isnull(n.rejilla_html_coincidentes,'')+'</div></td>'
                +'</tr>'
              else ''
         end
      +'</table>'
      from TH_Presupuestos_Web n (nolock)
      left outer join CORITEL.dbo.taoencar e (nolock) on e.numinfor=n.numinfor
      left outer join CORITEL.dbo.taoentid c (nolock) on c.codentid=e.codentid
      left outer join usuarios             u (nolock) on u.codigo=n.fk_usuarios
      outer apply (select top 1 x.descripcion from TH_Presupuestos_API x (nolock) where x.codigo=n.fk_TH_Presupuestos_API ) [api]
      where n.codigo=@codigo
      return (@r)

end

GO
