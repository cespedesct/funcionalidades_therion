USE [ETHER]
GO

/****** Object:  UserDefinedFunction [dbo].[Unidad_Informacion_Informe_Identificacion]    Script Date: 16/03/2026 11:11:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- select * from TH_Informes (nolock) where numinfor in ('26004262','26004261','26004260','26004259')
-- select dbo.Unidad_Informacion_Informe_Identificacion (1109988, 1, 0, '200`x')
-- select * from TH_Informes where numinfor='20031635'
-- select * from CORITEL.dbo.taoencar where numinfor='20031540'
-- select dbo.Unidad_Informacion_Informe_Identificacion (1131593, 1, 0, '200px')
-- select dbo.Unidad_Informacion_Informe_Identificacion (1383737, 1, 0, '600px')
-- select dbo.Unidad_Informacion_Informe_Identificacion (1131426, 1, 0, '200px')

CREATE function [dbo].[Unidad_Informacion_Informe_Identificacion]
                ( @codigo   int 
																 ,@usuario  int 
																 ,@reducido bit 
																 ,@ancho    varchar(100))
returns varchar(max)
as
	 begin
		 
		 declare @usarI                       bit=case when @usuario=1 then 0 else 1	end --select * from usuarios where descripcion like '%Borja%'
	         ,@restringido                 bit=case when isnull(@usuario, 0)=1 then 1 else 0 end
		        ,@acc_geotest                 bit=0
          ,@acc_vaciar_estructura       bit=0
          ,@acc_ver_prioridad           bit=0
          ,@acc_provision               bit=0
		        ,@acc_blockchain              bit=0
		        ,@acc_minutado_actualizacion  bit=0
          ,@acc_enviar_email_supervisor bit=0
          ,@acc_rechazar_gestion        bit=0
          ,@acc_version_supersit        bit=0
          ,@acc_forzar_minutacion       bit=0
		        ,@numinfor                    varchar(10)
		        ,@num_sms                     int=0
          ,@num_antecedentes            int=0
		        ,@num_inc                     int=0
		        ,@num_rel                     int=0
		        ,@num_blockchain              int=0
		        ,@num_anexos                  int=0
          ,@fecalta                     datetime
          ,@fecsuper                    datetime
          ,@fecsalid                    datetime
          ,@fecdeven                    datetime
          ,@fecrecen                    datetime
          ,@fecemimi                    datetime
          ,@fecemifa                    datetime
          ,@codtasad                    varchar(10)=''
          ,@emailtasador                varchar(500)=''
          ,@moviltasador                varchar(60)=''
          ,@tasador                     varchar(200)=''
          ,@referenc                    varchar(200)=''
		        ,@codclase                    varchar(10)=''
		        ,@codobjet                    varchar(10)=''
          ,@desobjet                    varchar(100)=''
		        ,@codestad                    varchar(10)=''
          ,@desestad                    varchar(100)=''
          ,@codentid                    varchar(10)=''
		        ,@codfinal                    varchar(10)=''
          ,@desfinal                    varchar(100)=''
          ,@codprovi                    varchar(10)=''
          ,@pisoobje                    varchar(100)=''
          ,@deslocal                    varchar(250)=''
          ,@metodo_valoracion           varchar(250)=''
          ,@numfinc1                    varchar(100)=''
          ,@grupo                       varchar(100)=''
          ,@cod_supervisor              varchar(25)
		        ,@fichero_vinculado           varchar(max)=''
		        ,@fk_TH_Entidades             int=0
		    --  ,@semilla_cer                 varchar(200)=''
	         ,@numcerti                    varchar(10)=''
		    --  ,@semilla_doc                 varchar(200)=''
	         ,@rutaimgpagina               varchar(500)=''
		        ,@sphera_swirl                bit=0
		        ,@valor_tasacion              decimal(19, 2)
          ,@ico_separador               varchar(max)
		 
   declare @direccion_informe             varchar(1000)
          ,@valor_referencia              decimal(19, 2)
          ,@margen_referencia             decimal(19, 2)
          ,@menor_referencia              decimal(19, 2)
          ,@mayor_referencia              decimal(19, 2)
          ,@fecha_limite_entrega          datetime
          ,@fecha_limite_entrega_forzada  bit
          ,@SIVASA_estado                 varchar(200)
          ,@color_limite_entrega          varchar(50)
          ,@estinfor                      varchar(2)
          ,@imagen_corto                  varchar(max)
          ,@desprovi                      varchar(150)
          ,@cod_region                    int
          ,@fk_TH_Delegaciones            int
          ,@Delegacion                    varchar(150)
          ,@nombre_supervisor             varchar(200)
          ,@email_supervisor              varchar(200)
          ,@fk_TH_Tasadores               int
          ,@latitud                       varchar(100)
          ,@longitud                      varchar(100)
          ,@latitud_decimal               decimal(19,15)
          ,@longitud_decimal              decimal(19,15)

		 declare @actualizacion                 bit=0
		        ,@numinfor_origen_actualizacion varchar(10)
		        ,@tasador_origen_actualizacion  varchar(10)
		        ,@tasador_actualizacion         varchar(10)
          ,@permite_desclonacion          bit=0
          ,@informe_de_pruebas            bit=0
          ,@informe_chk_tasador           bit=0

		 declare @hist_fac int=0;

		 declare @pdffinalcliente bit
	         ,@docword         bit
	         ,@docpdf          bit
          ,@fecmodif        datetime
          ,@fecha_firma_digital datetime
          ,@firmado_digital bit
          ,@motivo_no_autorizado varchar(max)
          ,@error_firma_digital  varchar(max)
          ,@como_firma      varchar(100)

		
		  declare @codigoAutofacturacion  int
	   declare @EstadoAutofacturacion  varchar(200)
	   declare @lista_PE varchar(max)	
		
		if isnull(@usuario, 0)!=0
			   begin

         set @lista_PE=replace(replace(replace(
         (select distinct [a]=ae.codigo_control
          from SISTEMA_Accesos_Especiales ae (nolock)
          inner join usuarios us (nolock) on us.codigo=@usuario
          where exists (select us.chk_administrador intersect select @usuario)
            or  exists (select ua.fk_SISTEMA_Accesos_Especiales, ua.fk_usuarios 
                        from SISTEMA_Accesos_Especiales_usuarios_autorizados ua (nolock)
                        intersect 
                        select ae.codigo,@usuario
                       )
          for xml path(''), elements),'</a><a>',']['),'</a>',']'),'<a>','[')

         -----------------------------
         -----------------------------

         -- set @ico_separador='<img style="padding-right:2px;padding-left:2px;vertical-align:middle;" '+dbo.f_SISTEMA_Icono('separador', 16, 16)+' />'

         select @numinfor            =isnull(n.numinfor,'')
					          ,@codclase            =v.codclase
					          ,@codentid            =v.codentid
               ,@codtasad            =v.codtasad
               ,@tasador             =(select top 1 rtrim(isnull(t.nomtasad, ''))+' '+rtrim(isnull(t.ap1tasad, ''))+' '+rtrim(isnull(t.ap2tasad, '')) from CORITEL.dbo.taotasad t (nolock) where t.codtasad=v.codtasad)
               ,@referenc            =v.referenc
               ,@fecalta             =v.fecalta
               ,@fecsuper            =v.fecsuper
               ,@fecsalid            =v.fecsalid
               ,@fecdeven            =v.fecdeven
               ,@fecrecen            =v.fecrecen
               ,@fecemimi            =v.fecemimi
               ,@fecemifa            =v.fecemifa
               ,@codestad            =v.codestad
               ,@desestad            =(select top 1 ltrim(rtrim(e.desestad)) from CORITEL.dbo.taoestad e (nolock) where e.codestad=v.codestad)
					          ,@codfinal            =v.codfinal
               ,@desfinal            =(select top 1 ltrim(rtrim(f.desfinal)) from CORITEL.dbo.taofinal f (nolock) where f.codfinal=v.codfinal)
					          ,@codobjet            =v.codobjet
               ,@desobjet            =(select top 1 ltrim(rtrim(o.desobjet)) from CORITEL.dbo.taoobjet o (nolock) where o.codobjet=v.codobjet)
               ,@metodo_valoracion   =(select top 1 ltrim(rtrim(o.descripcion)) from ETHER.dbo.TH_Metodo_Valoracion o (nolock) where o.codigo=n.fk_TH_Metodo_Valoracion)
               ,@pisoobje            =v.pisoobje
               ,@deslocal            =v.deslocal
               ,@codprovi            =v.codprovi
               ,@numfinc1            =v.numfinc1
               ,@grupo               =v.grupo
               ,@cod_supervisor      =coalesce(v.usfirma,v.ussuperv)
					          ,@num_sms             =(select count(*) from TH_SMS                             s (nolock) where s.fk_TH_Informes=n.codigo)
               ,@num_antecedentes    =(select count(*) from SERVIHABITAT_Solicitudes_Documentacion_Recibida d where d.fk_SERVIHABITAT_Solicitudes=( select top 1 s.codigo from SERVIHABITAT_Solicitudes s (nolock) where s.numinfor=n.numinfor))
               ,@num_inc             =(select count(*) from CORITEL.dbo.taoincid               i (nolock) where i.numinfor      =n.numinfor)
               ,@num_anexos          =(select count(*) from DBSGD.dbo.th_cabfi                 i (nolock) where i.numinfor      =n.numinfor)
               ,@num_rel             =(select count(*) from CORITEL.dbo.f_Expedientes_Relacionados (n.numinfor))
               ,@num_blockchain      =(select count(*) from TH_Informes_BlockChain_Solicitudes t(nolock) where t.numinfor = n.numinfor)
               ,@fk_TH_Entidades     =n.fk_TH_Entidades
               ,@valor_tasacion      =case	when v.estinfor in('3', '4', '5', '6','F') then CORITEL.dbo.f_VALOR_TASACION(n.numinfor)	else 0	end
               ,@valor_referencia    =isnull(n.valor_tasacion_referenciado_cliente  ,    0)
               ,@margen_referencia   =isnull(n.margen_aceptado_referenciado_cliente, 7.00)
               ,@menor_referencia    =isnull(n.valor_tasacion_referenciado_cliente  ,    0)*(1.00-(isnull(n.margen_aceptado_referenciado_cliente, 7.00)/100.00))
               ,@mayor_referencia    =isnull(n.valor_tasacion_referenciado_cliente  ,    0)*(1.00+(isnull(n.margen_aceptado_referenciado_cliente, 7.00)/100.00))
               ,@fecha_limite_entrega=a.fecha_limite_entrega 
               ,@fecha_limite_entrega_forzada=case when right(convert(varchar(100),a.fecha_limite_entrega,121),12)='00:00:00.000' then 1 else 0 end
					          ,@color_limite_entrega=case when v.estinfor = 'X' then 'black'
                                           when v.estinfor = 'F' then 'orange'
												                               when a.fecha_limite_entrega is null then '#aaa'
												                               when v.estinfor in('1', '2', '3') then case when datediff(hh, getdate(), a.fecha_limite_entrega)< 0 then '#A93226'
																							                                                                when datediff(hh, getdate(), a.fecha_limite_entrega)<36 then '#F1C40F'
																							                                                                when datediff(hh, getdate(), a.fecha_limite_entrega)>36 then '#117A65'
																							                                                                else '#aaa'
																						                                                            end
												                               else 'purple'
							                               end
               ,@SIVASA_estado        =CORITEL.dbo.f_SIVASA_estado(n.numinfor) 
					          ,@hist_fac             =(select top 1 codigo from TH_Facturacion_Historico h (nolock) where h.numinfor=n.numinfor)
               ,@estinfor             =isnull(v.estinfor, 'X')
               ,@direccion_informe    =isnull(dbo.TH_Informes_Direccion_para_Google(n.numinfor) ,'')
               ,@numinfor_origen_actualizacion=(select top 1 ac.nuencori	from CORITEL.dbo.taoactua ac (nolock)	where ac.numinfor=n.numinfor	order by ac.nuencori desc)
               ,@numcerti             =(select top 1 d.numcerti	from DBSGD.dbo.th_certi d(nolock)	where d.numinfor=n.numinfor	order by d.numcerti desc)
               ,@fk_TH_Delegaciones   =n.fk_TH_Delegaciones
               ,@informe_de_pruebas   =case when exists (select * from CORITEL.dbo.taoencar_clasificacion cl (nolock) where cl.numinfor=n.numinfor and cl.codclasif='0008' and isnull(cl.anulado,0)=0) then 1 else 0 end
               ,@informe_chk_tasador  =case when exists (select * from CORITEL.dbo.taoencar_clasificacion cl (nolock) where cl.numinfor=n.numinfor and cl.codclasif='0009' and isnull(cl.anulado,0)=0) then 1 else 0 end
						    from TH_Informes n (nolock)
							        inner join CORITEL.dbo.vTaoencar           v (nolock) on  v.numinfor  =n.numinfor
               inner join CORITEL.dbo.th_encargoadicional a (nolock) on  a.numinfor  =n.numinfor
						    where n.codigo=@codigo

          /* Modifcado por jorge Datos Autofacturación */
		   
		        select top 1 @codigoAutofacturacion=a.codigo 
                     ,@EstadoAutofacturacion =b.descripcion  
          from TH_AutoFacturacion a (nolock) 
          inner join [TH_AutoFacturacion_Estados] b (nolock) on a.fk_codigoEstado =b.codigo
			       where a.numinfor =@numinfor 
          order by a.codigo desc
		  
		        -------------------------------
          -- Ver si permite desclonacion                       
          -------------------------------

          if exists(select e.numinfor 
                    from CORITEL.dbo.taoencar e (nolock) 
                    where e.numinfor=@numinfor 
                      and e.estinfor not in ('3','4','F')  -- Se permiten desclonar los exentos de factura
                      and isnull((select top 1 i.fecini from CORITEL.dbo.taoincid i (nolock) inner join CORITEL.dbo.taocodin c (nolock) on c.numinfor=e.numinfor and c.fecincid=i.fecini and c.codincid in ('CLO') order by i.fecini desc),'')
                        > isnull((select top 1 i.fecini from CORITEL.dbo.taoincid i (nolock) inner join CORITEL.dbo.taocodin c (nolock) on c.numinfor=e.numinfor and c.fecincid=i.fecini and c.codincid in ('DES') order by i.fecini desc),'')
                   )
             begin
                set @permite_desclonacion=1
             end

          ----------------------
				      set @rutaimgpagina=dbo.f_Parametro_SISTEMA('rutaimgpagina');
				      if right(@rutaimgpagina, 1) != '\'
             begin
					           set @rutaimgpagina+='\';
            end
          -------------------------------------------------------
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
          -------------------------------------------------------
          select @imagen_corto=
                case when en.fichero_imagen_pagina is not null 
                     then ' src="'+@rutaimgpagina+en.fichero_imagen_pagina+'"' 
                     else ' src=""' 
                end
          from TH_Entidades en (nolock) 
          where en.codentid=@codentid
          -------------------------------------------------------
          select @desprovi=ltrim(rtrim(pe.desprovi)) from CORITEL.dbo.taoprovi pe (nolock) where pe.codprovi=@codprovi
          -------------------------------------------------------
			       select @cod_region=pr.cod_region 
          from  provincias  pr (nolock) 
			       left outer join regiones rg (nolock) on rg.codigo=pr.cod_region
          where pr.codigo_ine=@codprovi
          -------------------------------------------------------
          select @nombre_supervisor=ltrim(rtrim(uf.desusuar))
                ,@email_supervisor =ltrim(rtrim(uf.email))
          from CORITEL.dbo.taousuar uf (nolock) 
          where uf.codusuar=@cod_supervisor
          ----------------------------------------
          select @fk_TH_Tasadores=ts.codigo 
                ,@como_firma     =case when     exists (select ltrim(rtrim(isnull(ts.pin_signatur,''))) intersect select '') then 'Local o Signat. Manual'
                                       when not exists (select ltrim(rtrim(isnull(ts.pin_signatur,''))) intersect select '') then  -- Tiene Pin
                                              case when exists (select ts.firmar_automaticamente_siempre intersect select 1)  then 'Signat. Autom. Siempre'
                                                   when exists (select ts.chk_firma_automatica_siempre   intersect select 1)  then 'Signat. Autom. Siempre'
                                                   when exists (select ts.chk_firma_automatica           intersect select 1)  then 'Signat. Autom. solo Cambios'
                                                   else 'Signat. Manual'
                                               end
                                       else 'Sin Control Modo Firma'
                                    end
          from TH_Tasadores ts (nolock) 
          where ts.codtasad=@codtasad
          --select ts.pin_signatur, ts.firmar_automaticamente_siempre, ts.chk_firma_automatica_siempre, ts.chk_firma_automatica from TH_Tasadores ts (nolock) where ts.codtasad='08059'
          ----------------------------------------
          select @Delegacion=dt.descripcion from TH_Delegaciones dt (nolock) where dt.codigo=@fk_TH_Delegaciones
          ----------------------------------------
          select @emailtasador=replace(replace(lower(isnull((select top 1 m.email from CORITEL.dbo.th_tasmail m (nolock) where m.codtasad=@codtasad and ltrim(rtrim(isnull(m.email, ''))) != ''), '')), ';', '; '), '  ', ' ')
          ----------------------------------------
          select @moviltasador=(select top 1 m.movil from CORITEL.dbo.th_movta m (nolock) where m.codtasad=@codtasad)
          ---------------------------------------
          select @latitud          =g.latitud
                ,@longitud         =g.longitud
                ,@latitud_decimal  =g.latitud_decimal
                ,@longitud_decimal =g.longitud_decimal
          from CORITEL.dbo.taoencar_gps  g (nolock) 
          where g.numinfor=@numinfor
          ---------------------------------------
          declare @bloqueado bit
                 ,@asignable bit
                 ,@usuario_TH bit
                 ,@usuario_gestor_encargado bit

          if @estinfor in ('0')
             begin
                set @bloqueado=0; if exists (select * from CORITEL.dbo.taoencar_clasificacion cl (nolock) where cl.numinfor=@numinfor and cl.codclasif='0027' and isnull(cl.anulado,0)=0) set @bloqueado=1
                set @asignable=0; if exists (select * from CORITEL.dbo.taoencar_clasificacion cl (nolock) where cl.numinfor=@numinfor and cl.codclasif='0028' and isnull(cl.anulado,0)=0) set @asignable=1
                set @usuario_TH=0; if exists (select * from ETHER.dbo.usuarios u (nolock) inner join CORITEL.dbo.taousuar (nolock) tu on u.cod_usuario_TH = tu.codusuar where u.codigo = @usuario ) set @usuario_TH=1
                set @usuario_gestor_encargado=0; if exists (select * from ETHER.dbo.usuarios u (nolock) inner join CORITEL.dbo.taousuar (nolock) tu on u.cod_usuario_TH = tu.codusuar 
                    inner join CORITEL.dbo.th_gestor_encargo (nolock) ge on ge.numinfor = @numinfor and ge.codusuar = tu.codusuar where u.codigo = @usuario ) set @usuario_gestor_encargado =1
             end

          set @color_limite_entrega='#AAAAAA'
				      if @estinfor not in ('0', '1', '2', '3', 'X')
					        begin
						          declare @fecSuper datetime=CORITEL.dbo.f_Primera_Fecha_Supervision_INFORME(@numinfor)
						          set @color_limite_entrega=case when datediff(hh, @fecSuper, @fecha_limite_entrega) <  0 then '#A93226'
													                                  when datediff(hh, @fecSuper, @fecha_limite_entrega) < 36 then '#F1C40F'
													                                  when datediff(hh, @fecSuper, @fecha_limite_entrega) > 36 then '#117A65'
													                                  else '#AAAAAA'
												                              end;
                
				         end

				      if @estinfor in ('3')
					        begin
                --if dbo.f_SISTEMA_Accesos_Especiales ('31',@usuario)=1 begin set @asignable=1 end
                set @asignable=case when charindex('[ACC005]', @lista_PE)>0 then 1 else 0 end
				         end

				     -- set @acc_geotest                =dbo.f_SISTEMA_Accesos_Especiales('ACC005', @usuario)
				     -- set @acc_blockchain             =dbo.f_SISTEMA_Accesos_Especiales('ACC011', @usuario)
				     -- set @acc_minutado_actualizacion =dbo.f_SISTEMA_Accesos_Especiales('ACC014', @usuario)
         -- set @acc_ver_prioridad          =dbo.f_SISTEMA_Accesos_Especiales('ACC017', @usuario)
         -- set @acc_provision              =dbo.f_SISTEMA_Accesos_Especiales('30'    , @usuario)
         -- set @acc_enviar_email_supervisor=dbo.f_SISTEMA_Accesos_Especiales('ACC018', @usuario)
         -- set @acc_rechazar_gestion       =dbo.f_SISTEMA_Accesos_Especiales('27'    , @usuario)
         -- set @acc_vaciar_estructura      =dbo.f_SISTEMA_Accesos_Especiales('ACC022', @usuario)
         -- set @acc_version_supersit       =dbo.f_SISTEMA_Accesos_Especiales('28'    , @usuario)
         -- set @acc_forzar_minutacion      =dbo.f_SISTEMA_Accesos_Especiales('32'    , @usuario)

         --select * from SISTEMA_Accesos_Especiales

				     set @acc_geotest                =case when charindex('[ACC005]', @lista_PE)>0 then 1 else 0 end
				     set @acc_blockchain             =case when charindex('[ACC011]', @lista_PE)>0 then 1 else 0 end
				     set @acc_minutado_actualizacion =case when charindex('[ACC014]', @lista_PE)>0 then 1 else 0 end
         set @acc_ver_prioridad          =case when charindex('[ACC017]', @lista_PE)>0 then 1 else 0 end
         set @acc_provision              =case when charindex('[30]'    , @lista_PE)>0 then 1 else 0 end
         set @acc_enviar_email_supervisor=case when charindex('[ACC018]', @lista_PE)>0 then 1 else 0 end
         set @acc_rechazar_gestion       =case when charindex('[27]'    , @lista_PE)>0 then 1 else 0 end
         set @acc_vaciar_estructura      =case when charindex('[ACC022]', @lista_PE)>0 then 1 else 0 end
         set @acc_version_supersit       =case when charindex('[28]'    , @lista_PE)>0 then 1 else 0 end
         set @acc_forzar_minutacion      =case when charindex('[32]'    , @lista_PE)>0 then 1 else 0 end

         
				     if @numinfor_origen_actualizacion is not null
					       begin
 						       set @actualizacion=1
				       end

		    end
		 -------------------------
   -------------------------

		 set @ancho=isnull(@ancho,'20%');

		 declare @r varchar(max);

		 select @r=
      '<td style="width:'+@ancho+';text-align:left;vertical-align:top;padding-left:0.5vw;" name="Inf./Alta/Datos Admin.">'
				  +case	when isnull(@usuario, 0)=0 then ''	else 
      +'<hr style="width:100%;border:solid 0px;border-top:solid 1px transparent;padding:0px;">'						
						--===================
						-- INFORME y ESTADOS
						--===================
						+case when 1=2 then '' else 
              '<span style="display:inline-block;width:5vw;cursor:pointer;color:#BC141A;font-size:1.1vw;font-weight:bold;vertical-align:middle;" '
								     +' onclick="WHTML_General(''TH_Informes_HTML_Mostrar_Ficha ·'+@numinfor+'·,'+format(@usuario,'0')+''',1);"'
								     +' title="Datos Administrativos" >'+@numinfor+'</span>'
             +case when @codclase='700' 
                   then '<img class="imginforme" style="padding-left:0.5vw;" src="img\ico_informe_cee.png" title="Informe de Certificación Energética" >'
						             else ''
					         end
             +'<span style="display:inline-block;width:5vw;font-size:0.65vw;font-weight:bold;vertical-align:middle;" '
								     +' title="Datos Administrativos" >'+format(@fecalta,'dd/MM/yy HH:mm')+'</span>'
					        ---------------------------------------------------------------
             +case when 1=2 then '' else
                   '<table class="subtabla"  title="Fecha de Alta/Codigo Interno">'
                         +'<tr><td>'+isnull('('+format(@fecalta,'dd/MM/yyyy HH:mm:ss')+')','')+'</td></tr>'
                         +'<tr><td>'+isnull('('+format(n.codigo,'#,0','de-DE')+')', '')+'</td></tr>'
                  +'</table>'
             end
             ---------------------------------------------------------------
             +case when 1=2 then '' else
                   '<table class="subtabla" style="width:80px" >'
                         +'<tr><td style="text-align:center;">'+isnull('<img style="vertical-align:middle;width:95%;" '+@imagen_corto+' >','')+'</td></tr>'
                         +'<tr><td style="text-align:center;color:#977;font-size:130%;font-weight:bold"><span title="Corto">'+isnull(''+@codentid+'', '')+'</span></td></tr>'
                  +'</table>'
             end
             ---------------------------------------------------------------
             +case when 1=2 then '' else 
				               '<img class="imginforme" src="img\ico_th_informe_ubicacion.png" style="cursor:default" title="'+isnull(dbo.TH_Informes_Direccion_Completa(@numinfor),'')+'" >'
              end
	            ---------------------------------------------------------------
	            +case when 1=2 then '' else 
                   case when e.estinfor in ('3','4','5','6','F') and e.fecsuper>=CONVERT(datetime,'01/08/2021',103) and not exists( select * from EXPLOTACION.dbo.InclusionParrafoCovid (nolock) where numinfor=e.numinfor) then
                   		    '<img class="aumenta click imginforme" src="img\ico_informe_concovid.png" title="Permitir Generar Documento informe"'  
				                    +' onclick=" var p='''';'
				                              +' p+=''{confirmacion|Esta accion permitirá generar el informe pese a que tenga el parrafo covid '+@numinfor+'|||'';'
				                              +' var e=''WSQL(··MarcarDesmarcarInformeSalidaConParrafocovid 0, ·'+@numinfor+  '·' + ',' +'·' + e.estinfor + '·'+ ',·' + CONVERT(varchar,e.fecsuper,120) + '·'  + ' ··)''; '
				                              +' Pide_Parametros(p,e);'
				                              +'"'
					                     +'>'
									               else '' 
                   end
             end
             ---------------------------------------------------------------
        		   +case when 1=2 then '' else 
                   case when e.estinfor in ('3','4','5','6','F') and e.fecsuper>=CONVERT(datetime,'01/08/2021',103) and exists (select * from EXPLOTACION.dbo.InclusionParrafoCovid (nolock) where numinfor =e.numinfor) then   
		                            '<img class="aumenta click imginforme" src="img\ico_informe_sincovid.png" title="Cancelar permiso Generar Documento informe"'  
				                         +' onclick=" var p='''';'
				                                   +' p+=''{confirmacion|Esta accion cancelará el permiso para que se genere el informe con parrafo covid '+@numinfor+'|||'';'
				                                   +' var e=''WSQL(··MarcarDesmarcarInformeSalidaConParrafocovid 1, ·'+@numinfor+  '·' + ',' +'·' + e.estinfor + '·'+ ',·' + CONVERT(varchar,e.fecsuper,120) + '·'  + ' ··)''; '
				                                   +' Pide_Parametros(p,e);'
				                                   +'"'
					                          +'>'
									              else '' 
                   end
              end
             +case when 1=2 then '' else 
                  ---------------------------------------------------------------
                  '<span style="display:inline-block;color:#1F618D" title="Localidad Ubicación">'+(isnull(ltrim(rtrim(@deslocal)), ''))+'</span>'
                 +'<span style="display:inline-block;color:#F161D8" title="Provincia Ubicación">'+(isnull(@desprovi, ''))+'</span>'
              end
             ---------------------------------------------------------------
             +case when 1=2 then '' else 
                   case when @fecha_limite_entrega is not null 
                        then '<span style="display:inline-block;color:#999;font-size:0.6vw;padding-left:4px;padding-right:4px;vertical-align:middle;">Lím. Entrega:</span>'
										                  +isnull('<span class="resaltado_general" style="background:'+@color_limite_entrega+''+case when @fecha_limite_entrega_forzada=1 then ';border:solid 3px #a00;' else '' end+';vertical-align:middle"'
                                     +' title="Fecha Límite de Entrega"'
				                                 +' onclick=" var  p='''';'
				                                           +' p+=''{fecha|Cambiar Fecha Entrega '+@numinfor+'|Fecha de Entrega|'+isnull(left(dbo.fFecha_Hora(@fecha_limite_entrega),10),'')+'|| [font-family:Roboto Condensed][font-size:80%]#obligatorio#}'';'
				                                           +' var e=''WSQL(··TH_Informes_Cambiar_Fecha_Entrega @numinfor=·'+@numinfor+'·, @fecha_entrega=·#parametro_value_1#·, @usuario='+convert(varchar, @usuario)+'  ··)''; '
				                                           +' Pide_Parametros(p,e);"'
                                     +'>'
                                     +format(@fecha_limite_entrega,'dd/MM/yy HH:mm')
                                     +'</span>', '')+char(10)
			                     else ''
		                 end
              end
              -------------------------------------------------------------------------------- 
              -- Prioridad
              -------------------------------------------------------------------------------- 
              +case when 1=2 then '' else 
                    case when @estinfor in ('0','1','2','3') then
                        '<img class="aumenta click imginforme" src="img\ico_prioridad'+convert(varchar,isnull(CORITEL.dbo.F_VALOR_PRIORIDAD(@numinfor),6))+'.png" '
                        +' style="'+case when a.valor_prioridad is not null then 'border:solid 2px #888;' else '' end
                                   +case when @acc_ver_prioridad=0 then ';cursor:default' else ' ' end
                                   +'"'
                        +' title="Prioridad de Supervisión '+case when a.valor_prioridad is not null then '(FORZADO MANUALMENTE)' else '' end
                        +case when @acc_ver_prioridad=0 then '' else ' del Informe (Click para cambiar la Prioridad).' end
                        +case when a.notas_valor_prioridad is not null 
                              then '&#10;Notas:&#10;'+replace(replace(a.notas_valor_prioridad,'_#10#_','&#10;'),'_#13#_','&#10;')
                              else '' 
                         end
                        +'"'
                        +case when @acc_ver_prioridad=0 then '' else
                               ' onclick="Pide_Parametros( '''
				                          +'{numero|Asignación de Nueva Prioridad al Informe '+@numinfor+'|Prioridad (1 al 6, 0-Auto)|'+convert(varchar,isnull(CORITEL.dbo.F_VALOR_PRIORIDAD(@numinfor),6))+'#obligatorio#}'
                              +'{textarea||Notas al Supervisor|'+isnull(a.notas_valor_prioridad,'')+'}'
                              +' '',''WSQL(··TH_Informes_Marcar_Prioridad @numinfor=·'+@numinfor+'·, @prioridad=#parametro_value_1#, @notas_valor_prioridad=·#parametro_value_2#·, @usuario_envia='+convert(varchar,@usuario)+' ··)'');"'
                         end
				                    +' />'
                         else ''
                   end
              end
              -------------------------------------------------------------------------------- 
              +case when 1=2 then '' else
                    case when @estinfor not in ('3','4','5','6','F') then ''
                         when @latitud is not null 
                         then  '<img class="aumenta click imginforme" src="img\ico_gpsmorado.png" style="width:32px;height:auto;" '
                                       +' title="Geolocalizado por tasador. Accede al Mapa para ver Geoposición"'
                                       +' onclick="Mapa('''+convert(varchar(100),@latitud_decimal)+'###'+convert(varchar(100),@longitud_decimal)+''','''','+ltrim(str(n.codigo))+'); ">'
                              +'<span style="display:inline-block;width:4.5vw;vertical-align:middle;border:solid 0px black;word-break:break-all;font-size:0.45vw;" title="GPS Tasador">'
                                +isnull(convert(varchar(100),@latitud_decimal ),'')+'<br>'+isnull(convert(varchar(100),@longitud_decimal),'')
                              +'</span>'
                        else   
                              '<span style="display:inline-block;width:4.5vw;color:red;vertical-align:middle;word-break:break-all;font-size:0.45vw;" >No GEOLOCALIZADO por TASADOR</span>'
                    end
               end
              -------------------------------------------------------------------------------- 
              +case when 1=2 then '' else
                    '<img class="aumenta click imginforme" src="img\ico_gpsverde.png"'
                             +' style="width:32px;height:auto;"'
                             +' title="'+case when n.latitud is not null then 'Geolocalizado, acceso nueva geolocalización' else 'SIN GEOLOCALIZAR. Acceso a Geolocalización ' end+'"'
                             +  case when n.latitud is not null 
                                     then ' onclick="Mapa('''+convert(varchar(100),n.latitud)+'###'+convert(varchar(100),n.longitud)+''',''TH_Informes###'+isnull(@direccion_informe,'')+''','+ltrim(str(n.codigo))+')"'
                                     else ' onclick="Mapa('''+isnull(@direccion_informe,'')+''',''TH_Informes'''+','+ltrim(str(n.codigo))+')"'
                                end
                    +'>'
               end
              -------------------------------------------------------------------------------- 
						 end
     -- ===================================
		   -- Objeto + Finalidad + Estadp
		   -- ===================================
     +'<br>'
     +'<span style="display:inline-block;width:10vw;color:#1F618D;font-size:0.65vw;font-weight:bold;padding-left:0px;vertical-align:middle;word-break:break-all;border:solid 1px transparent">'
     +isnull(ltrim(rtrim(@desobjet)), '')+' <font style="font-size:0.45vw">('+coalesce(@codobjet,'')+')</font></span>'
					-- ============== Vaciar Estructura =================
					+case	when @estinfor not in ('0')   then ''
           when @acc_vaciar_estructura=0 then ''
           when dbo.TH_Informes_tiene_datos_tecnicos (@numinfor)=0 then ''
           else '<img class="aumenta click imginforme" style="padding-left:0.5vw;" src="img\ico_vaciarestructurainforme.png" '
						         +' title="Vaciar los datos técnicos de la Tasación"'
				           +' onclick=" var p='''';'
				                     +' p+=''{confirmacion|Vaciar los Datos Técnicos del Encargo '+@numinfor+'|||'';'
				                     +' var e=''WSQL(··TH_Informes_Borrar_Estructura_y_Datos_Tecnicos @numinfor=·'+@numinfor+'· ··)''; '
				                     +' Pide_Parametros(p,e);'
				                     +'"'
						                +'"'
						         +'>'
			   end
					-- ============== Cambio de Objeto =================
					+case	when @estinfor in ('0','1') or (@estinfor in ('0', '1', '2') and isnull(@codtasad, 'XXXXX')='28500') then
            '<img class="aumenta click imginforme" style="padding-left:0.5vw;" src="img\ico_cambiar_objeto_informe.png" '
						     +' title="Cambiar el Objeto de la Tasación"'
						     +' onclick=" var  p='''';'
						              +' p+=''{combo|Cambio de Objeto ('+rtrim(isnull(@codobjet, ''))+'-'+rtrim(isnull(@desobjet, ''))+') del Encargo '+@numinfor+'|Nuevo Objeto||TH_Objetos|isnull(chk_disponible,0)=1}'';'
						              +' var e=''WSQL(··TH_Informes_Cambiar_Objeto @numinfor=·'+@numinfor+'· , @codigo_TH_Objetos=#parametro_value_1#, @forzado=0 ··)''; '
						              +' Pide_Parametros(p,e);'
						              +'"'
						     +'>'
								   else ''
			   end
		   -------------  
		   -- Finalidad
		   -------------
     +'<span style="display:inline-block;width:0.2vw;"></span>'
		   +'<span style="display:inline-block;width:12vw;color:#1F618D;font-size:0.65vw;font-weight:bold;padding-left:3px;vertical-align:middle;word-break:break-all;border:solid 1px transparent">'
        +isnull(@desfinal+' <font style="font-size:0.45vw">('+@codfinal+')</font>', '')+'</span>'
		   ----------
		   -- Estado
		   ----------
     +'<span style="display:inline-block;width:0.2vw;"></span>'
     +'<span style="display:inline-block;width:6vw;color:#1F618D;font-size:0.65vw;;font-weight:bold;padding-left:3px;vertical-align:middle;word-break:break-all;border:solid 1px transparent">'
        +isnull(@desestad+' <font style="font-size:0.45vw">('+@codestad+')</font>', '')+'</span>'
     -- ===================================
     -- ========== REFERENCIA =============
     -- ===================================
     +'<br>'
     +'<span style="color:#999;font-size:0.55vw;padding-right:4px;vertical-align:middle;">Ref.:</span>'
     +'<span style="display:inline-block;width:15vw;border:solid 0px #000;font-weight:normal;font-size:0.65vw;vertical-align:middle;word-break:break-all;"> '
		   +case when isnull(ltrim(rtrim(@referenc)),'')='' then 'Sin Referencia' else ltrim(rtrim(@referenc)) end+'</span>'
				 -- ===================================
     -- ============== GRUPOS =============
     -- ===================================
				 +case when isnull(@grupo, '')='' then ''
					      else '<span style="color:#a90;font-size:90%;padding-left:4px;cursor:pointer;vertical-align:middle;"'
				             +' title="Nº de Informes del Grupo. Click -> Acceder a los Informes del Grupo" '
				             +' onclick="Mostrar_Filtrado_2(''TH_Informes'',''numinfor in (select numinfor from CORITEL.dbo.vTaoencar e where e.grupo in ((select ex.grupo from TH_Informes ix (nolock), CORITEL.dbo.vTaoencar ex where ex.numinfor=ix.numinfor and ix.codigo='+ltrim(str(n.codigo))+'))) '')">'
                 +'Grupo<font style="padding-left:5px;font-weight:bold;">'+isnull(@grupo, '')+'</font>'
       				           +'<font style="padding-left:5px;font-weight:normal;">('+ltrim(str((select count(*) from CORITEL.dbo.taoencar ex (nolock) where ex.grupo=@grupo)))+' Inf.)</font>'
				           +'</span>'
				  end
     -- ===================================
		   -- === Prueba o Chek de Pruebas ======
     -- ===================================
		   +isnull(case when @informe_de_pruebas =1 then '<span style="padding-left:4px"></span><span style="vertical-align:middle;color:#fff;background:rgba(180,0,0,0.5);font-weight:bold;">Inf.Pruebas</span>' else '' end, '')
     +isnull(case when @informe_chk_tasador=1 then '<span style="padding-left:4px"></span><span style="vertical-align:middle;color:#fff;background:rgba(180,0,0,0.5);font-size:100%;font-weight:bold;">Inf.Check Tasador</span>' else '' end, '')
     -- ==============================
     -- ============== ESTADO ========
     -- ==============================
			  +'<br>'
			  +'<span style="display:inline-block;width:15vw;font-size:0.7vw;font-weight:bold;vertical-align:middle;word-break:break-all;border:solid 1px transparent;'
				   +case when @estinfor in ('F')             then 'color:#E12AFB;background:#FEE685;padding:2px;'
             when @estinfor in ('4','5','6','F') then 'color:#070;'
					        when @estinfor in ('0','3')         then 'color:#700;'
					        when @estinfor in ('X')             then 'color:#777;'
					        when @estinfor in ('1','2')         then 'color:#007;'
					        else 'color:#777;'
				    end
				   +'" title="Estado Actual del Informe">'+dbo.TH_Informes_Texto_Estado (@numinfor)
     +'</span>'
				 -- =====================================
     -- ===== Rechazo Tasador Demo ==========  
     -- =====================================
				 +case when @estinfor='2' --and isnull(@codtasad,'XXXXX')='28500' --and isnull(@usuario,0)=1  (se elimina la condicion de DEMO)
				       then '<img class="aumenta click imginforme" src="img\ico_rechazar_tasador_demo.png" '
				            +' title="Rechazar el encargo"'
				            +' onclick=" var p='''';'
				                      +' p+=''{confirmacion|Rechazar el Encargo '+@numinfor+'|||'';'
				                      +' var e=''WSQL(··TH_Informes_Rechazar_Tasador_Demo ·'+@numinfor+'· ··)''; '
				                      +' Pide_Parametros(p,e);'
				                      +'"'
				            +'>'
					      else ''
				  end
		   -- ==============================
     -- ======= Desbloqueos ==========
     -- ==============================
     -- ---------------------------------------------------------------
     -- Acciones en el estinfor='0' -> Asignable y bloqueo por gestión
     -- ---------------------------------------------------------------
     +case when @estinfor='0' then
                  case when @usuario_TH = 0 then ''
                      when @usuario_gestor_encargado = 1 then 
                      '<img class="aumenta click imginforme" style="padding-left:0.5vw;;vertical-align:middle" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAulJREFUSImtlU9oXFUUxn/ffe/N2D+6sAELNYqKaBZFQ11YhFZbBV3ITN4zoLgQJFTagkVwLXEhVnAhWc7SNmD7khdtFkWp0GZRLN0IpUWQFgWlaiwuDOnMvDf3uLAT3iTtpBM9q3vO/c73nfPeufeKktnkpMsvXZrA+yM4d/PfoBnwl0nvVWdnLzOgqey0x8Y+Q3pLUIuybKEbbybJ487seJTnL2h+fnkQgbC7aNVqO016EmkCs09aSXKutxRViih6BlhYTXJXAgrDfYLz3vtRpCUHZ7p73vvnkS6EQXBxEPIeATPbBuyW9EU0NPShGo18pbs43ibpIaXpzQ0LALhOZ8qH4cP54uJBYKqdJEcwk8H1QYlXOEuLTicIQsxG5Ny9t9oaNrMHZFY174uNCKx04OFHYLSSZYe7sUqWvQ/QjuMpB1//pw4qW7Z8JbOkWa8/Vga0arWdwJ5gaOibjQj0noMkGcVsxuAY0hXMngLeJgj2V9P0ykYEQoA8jvcYvCbYbnCfkzzeP4K0ZFCR95PtOP5Tzn0ZzcwM1IlaY2NvIr3hzD7qOPd7IG037z/F7CpSgtTsyTD7Ccn34QwEJ6LZ2aMAoaR3V10B1+zAgb354uL3wOXoxo3dOnu2Z4JsfPz+oih2hc3mgk6fbpX32vX60+bcyqA4wK2+X9Ro5EjLwJrRtPHxIPf+W3MuLjZtml7vE7n1AGus2axiFsr7aYPh/11A8/PLBh8YTOD9ofXw4XqA21k1y+aAubvBDizQrtd3SXqx6+fS9OYs++VO+MH/QRC8g1R4uGbODYfSq/3ggwuYjYRF0ajOzaWSTuD9E/3gocGOVpIcXctjDzpYe6CkrTp16m+AUPqhDSP9BNSO42clbb1DtYdNGi75EfBHJcte6oZacXxd0q+lrEBmJ6Ms+xggrGTZd30KOFN28jh+zuD1ngrhauTcy0rTpdt20Ie8x26Rfy64x6TyC/co8HPk3CtK099W5/0Da84hp86BnKAAAAAASUVORK5CYII=" '
                             +' title="DESOCUPAR encargo. Pulsar Click para desocupar encargo" '
				                         +' onclick=" var  p='''';'
				                         +' p+=''{confirmacion|OCUPACIÓN de Encargo '+@numinfor+'|||'';'
				                         +' var e=''WSQL(··TH_Informes_Asignar_Gestor ·'+@numinfor+'·,'+ltrim(str(@usuario))+' ··)''; '
				                         +' Pide_Parametros(p,e);'
				                         +'">'
                      else '<img class="aumenta click imginforme" style="padding-left:0.5vw;;vertical-align:middle" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAvpJREFUSImtlVFom2UUhp/z/f/SiXXgeuFAqzAR7UWZpUXadMQkKuqgDExTFC8EKQwdOIRdy7wQJ3gh9Uov1YJLE6rsQpQ1zYpJKip4syHIxgTHVIqC29qma77XC01Msiwx1XP1f+e8//ueczjn+4wGO6ET7mx5eBZ0DGzjL68k6XeTvbp8cPocPZo1HpKl7DuCF0x2OD+ZWqn5Y6vZBwJvH/VHIonTY1PrvQiEdZJSZljwEGJWTm8ly7mzdZRAKHK9sjUGrLQj6irgcEmgZDAicc0bZ+oxrzhmX21Y9eteyJsEDBsATXizj69G1l7/duzIjVosXs4NmHRvOTqzsWMBALPqnCm4b09l4CVgLl7KHnOYebjSK3HNXO1DRrWqMJRpSI47AJxp0KO7TL4PY3snAv+0SPxgMLI8kT5a8+Un0scBEsWFOWSf/6cKdt1+/VNQKllcvL8RECtlhnEW+6Nv7YudCDTtQayUHQkga9KHcnYebwcwveicf2xpfOb8jgWSxVxM+GnM7UMkML0rqWLmHOg42BLSmqFP8pPpniqxeHnheRPPOekN88EvPvD7PO5tZ7ogkQLbbM5Il4T5W1MqMDiVj06fBAhN7pWWK+Di6DfvPbpna+A74JwqeycKiUTTBD1ZyuzdduFo5LfdK58dOlRpjMWLmYeNoD4oDuRa75e/l2y93WimM5lgC7dU9f6ZzTvX57u1yHUDtNrm/tv6gBDn55EN/u8Cp8em1g17zbybxVVf7oYPuwHaWT6aWgQW/w22Z4HEamZUVXu87gjcfGE89dOt8D23CLkj4LadcdHMBp001Qneu4C3oRsK389H0wvO6xTiwU7wELg7Wc6dvClR6R6kmxfK1F+cPHwVYMvr+9DZUCcBi3+ZGyegv13QSUdF4yhqF/DrcnT6iZonUcpeAbvcgAnAMsvR1JsAYeFgarVDAmcaD4lyblLSsy2YC6pUnyokZq61raADeZMlyrlJpA9Au8E1vnD7QT8q9E8XHpn5ufW/PwGXKC8iwO0Z8AAAAABJRU5ErkJggg=="'
                             +' title="OCUPAR encargo. Pulsar Click para ocupar encargo" '
				                         +' onclick=" var  p='''';'
				                         +' p+=''{confirmacion|OCUPACIÓN de Encargo '+@numinfor+'|||'';'
				                         +' var e=''WSQL(··TH_Informes_Asignar_Gestor ·'+@numinfor+'·,'+ltrim(str(@usuario))+' ··)''; '
				                         +' Pide_Parametros(p,e);'
				                         +'">'
                 end
                +case when @bloqueado is null then ''
                     when @bloqueado=1 then 
                      '<img class="aumenta click imginforme" src="img\ico_informebloqueado.png" '
                     +' title="Informe Bloqueado por Gestión. Pulsar Click para Liberar" '
				                 +' onclick=" var  p='''';'
				                 +' p+=''{confirmacion|LIBERAR el Informe '+@numinfor+'|||'';'
				                 +' var e=''WSQL(··TH_Informes_Bloquear_Gestion ·'+@numinfor+'· ··)''; '
				                 +' Pide_Parametros(p,e);'
				                 +'">'
                     when @bloqueado=0 then 
                       '<img class="aumenta click imginforme" src="img\ico_informedesbloqueado.png" '
                          +' title="Informe Liberado por Gestión. Pulsar Click para Bloquear" '
				                                           +' onclick=" var  p='''';'
				                                           +' p+=''{confirmacion|BLOQUEAR el Informe '+@numinfor+'|||'';'
				                                           +' var e=''WSQL(··TH_Informes_Bloquear_Gestion ·'+@numinfor+'· ··)''; '
				                                           +' Pide_Parametros(p,e);'
				                                           +'">'
                     else ''
                end
               +case when @asignable is null then ''
                     when @bloqueado=1       then '' 
                     when @asignable=1 then 
                          '<img class="aumenta click imginforme" style="padding-left:0.5vw;;vertical-align:middle" src="img\ico_informeasignable.png" '
                             +' title="Informe ASIGNABLE por Gestión. Pulsar Click para BLOQUEAR Asignación" '
				                         +' onclick=" var  p='''';'
				                         +' p+=''{confirmacion|Bloquear ASIGNACION para Informe '+@numinfor+'|||'';'
				                         +' var e=''WSQL(··TH_Informes_Asignable_Gestion ·'+@numinfor+'· ··)''; '
				                         +' Pide_Parametros(p,e);'
				                         +'">'
                     when @asignable=0 then 
                          '<img class="aumenta click imginforme" style="padding-left:0.5vw;;vertical-align:middle" src="img\ico_informenoasignable.png" '
                             +' title="Informe BLOQUEADO PARA Asignación. Pulsar Click para PERMITIR Asignación"'
	 		                         +' onclick=" var  p='''';'
				                         +' p+=''{confirmacion|PERMITIR ASIGNACION para Informe '+@numinfor+'|||'';'
				                         +' var e=''WSQL(··TH_Informes_Asignable_Gestion ·'+@numinfor+'· ··)''; '
				                         +' Pide_Parametros(p,e);'
				                         +'">'
                     else ''
                end
           else ''
      end
		   -- ==============================
     -- ======= Asignacion ===========
     -- ==============================
     +case when ((@estinfor in ('0') and @bloqueado=0 and @asignable=1) or (@estinfor in ('3'))) and @usuario_gestor_encargado=1 then
            '<img class="aumenta click imginforme" style="padding-left:0.5vw;;" src="img\ico_asignaciontasador.png" '
           +' title="Asignación de Tasador al Informe"'
           +' onclick="Pide_Parametros( '''
				       +'{combo|Asignación Tasador al Informe<br>'+@numinfor+isnull('<br>'+isnull(' - '+ltrim(rtrim(@deslocal)), ''), '')+isnull('<br>'+@desprovi, '')+'|Tasador (por compatibilidad)||TH_Tasadores|dbo.TH_Tasadores_Compatible_Informe ((select numinfor from TH_Informes s (nolock) where s.codigo='+ltrim(str(@codigo))+'), codtasad)=1 order by idoneidad [style font-family:monospace;font-size:60%;width:500px;]|||}'
				       +'{combo||Tasador (general)||TH_Tasadores|1=2 order by codtasad [style font-family:monospace;font-size:60%;width:500px;]|||}'
           +' '',''WSQL(··TH_Informes_Asignar_Tasador ·'+@numinfor+'·, #parametro_value_1#, #parametro_value_2# '+case when @estinfor='3' then ', @forzado=1' else '' end+' ··)'');"'
				       +' />'
          else ''
      end
		   -- =================================
     -- ====== Asignacion por Mapa ======
     -- =================================
     +case when @estinfor in ('0') and @bloqueado=0 and @asignable=1 and n.latitud is not null 
           then '<img class="aumenta click imginforme" src="img\ico_gpsmorado.png" style="width:32px;height:32px;" title="Asignar por Mapa Geolocalización Informe '+@numinfor+'" '
                +' onclick="'
                +' var va=1;'
                +' if (document.getElementById(''con_1_0'')) {document.getElementById(''con_1_0'').innerHTML='''';}'
																+' WHTML_General(''GEOLOCALIZACION_Geolocalizar_Google_Buscar'
                      +' @codigo   ='+ltrim(str(n.codigo))
                      +',@direccion='+case when isnull(@direccion_informe,'')     ='' then 'null' else '·'+isnull(            @direccion_informe  ,'')+'·' end
																				  +',@piso     ='+case when isnull(ltrim(rtrim(@pisoobje)),'')='' then 'null' else '·'+isnull(ltrim(rtrim(@pisoobje         )),'')+'·' end
																				  +',@finca    ='+case when isnull(ltrim(rtrim(@numfinc1)),'')='' then 'null' else '·'+isnull(ltrim(rtrim(@numfinc1         )),'')+'·' end
																				  +',@lat      ='+isnull('·'+replace(isnull(@latitud ,n.latitud ), ',', '.')+'·', 'null')
																				  +',@lng      ='+isnull('·'+replace(isnull(@longitud,n.longitud), ',', '.')+'·', 'null')
                      +',@usuario  ='+ltrim(str(@usuario))
																				  +',@numinfor ='+isnull('·'+@numinfor+'·', 'null')
																				  +' '',1);'
																+' var ta=window.setInterval(function()'
                +'{if (document.getElementById(''carga_mapa_'+ltrim(str(n.codigo))+'''))'
                +'  {$(''#carga_mapa_'+ltrim(str(n.codigo))+''').click();window.clearInterval(ta)}'
                +' else {va++; if (va>30) {window.clearInterval(ta)} } }, 100)" />'
           else ''
      end
		   -- ==============================
     -- ======= Rechazo    ===========
     -- ==============================
     +case when @acc_rechazar_gestion=1 and @estinfor in ('3','4','5','6','F') and @codtasad not in ('28500')
            then  '<img class="aumenta click imginforme"  src="img\ico_rechazoporgestion.png" '
                 +' title="Rechazar Informe por Gestión."'
                 +' onclick="Pide_Parametros( '''
                 +'{confirmacion|Rechazo Informe por Gestión||}'
                 +' '',''WSQL(··TH_Informes_Rechazar_por_Gestion @numinfor=·'+@numinfor+'·, @usuario='+format(@usuario,'#')+' ··)'');"'
				             +' />'
            else '' 
      end
		   -- ==============================
     -- ======= Anulación  ===========
     -- ==============================
		    +case when ( @estinfor in ('0','1','2') and exists (select * from usuarios u (nolock) where u.codigo=@usuario and u.login='dc2589') )
              or ( @estinfor in ('5')         and exists (select * from dbo.TH_Informes_Historia_Clonacion (@numinfor) ) )
            then '<img class="aumenta click imginforme" src="img\ico_anular_informe.png" '
		                  +' title="Anular el encargo"'
		                  +' onclick=" var p=''''; p+=''{confirmacion|Anular el Encargo '+@numinfor+'|||''; var e=''WSQL(··TH_Informes_Anular ·'+@numinfor+'· ··)''; Pide_Parametros(p,e);"'
                +' >'
			         else ''
		     end
     -- ==================================================
		   -- ============== ESTADO DE FACTURACION =============
     -- ==================================================
		   +'<br>'
     +isnull('<span style="display:inline-block;width:15vw;vertical-align:middle;color:#0aa;font-size:0.65vw;font-weight:bold;word-break:break-all;border:solid 1px transparent;">'
            +case when isnull(@fecemifa,'')!=''          then 'Facturado el <i>('+format(@fecemifa,'dd/MM/yy HH:mm')+')</i>'
          					   when e.carfactu='X'                    then 'Exento Factura'
					             when @estinfor='5'                     then 'Exento Factura'
	          				   when exists (select * 
                               from CORITEL.dbo.Facturacion_Historico h(nolock)	
                               where h.numinfor=@numinfor 
                                 and isnull(h.bruto,0)!=0 
                                 and isnull(h.factura, '')!=''
                               )                         then 'Provisionado'
					             when @estinfor in ('0', '1', '2', '3') then case when isnull(a.importe_provision,0)!=0 then 'Provisionado' else 'Sin Prov. Fondos' end
					             else                                        'Pte. Facturar'
				         end
             +isnull(case when isnull(@codigoAutofacturacion,0)>0 
                          then'<font style="vertical-align:middle;padding-left:4px;font-size:0.50vw;">AutoFact. ('+@EstadoAutofacturacion+')'+'</font>' 
                          else '' 
                     end,'' 
                    )
             +'</span>'
             , '')
		   -- =======================
     -- ====== Provisión ======
     -- =======================
     +case when @acc_provision=1 then
            +case when exists (select pw.chk_conciliada_transferencia intersect select 1) then '' 
                  else '<img class="aumenta" style="padding-left:0.5vw;vertical-align:middle;cursor:pointer;width:1.3vw;height:auto;" src="img\informar_provision.png" title="Informar del Importe de Provisión "'
                          +' onclick="Pide_Parametros( ''{numero|Provisión Informe '+@numinfor+'|Importe Provisión|'+isnull(format(a.importe_provision,'#.00','de-DE'),'')+'#obligatorio#}{texto||Ordenante|'+isnull(a.ordenante_provision,'')+'}'' ,''WSQL(··TH_Informes_Infomar_Provision @numinfor=·'+@numinfor+'·, @importe=·#parametro_value_1#·, @ordenante=·#parametro_value_2#·, @usuario='+convert(varchar,@usuario)+' ··)'');"'
				                   +' >'
             end
            +isnull('<span style="padding-left:0.5vw;;vertical-align:middle">('+format(a.importe_provision,'#,0.00','de-DE')+')</span>','')
            +isnull('<span style="padding-left:0.5vw;;vertical-align:middle;font-size:0.50vw;">- Ordenante: '+a.ordenante_provision+'</span>','')
            +case when pw.codigo is not null 
                  then '<img  class="aumenta" src="imgEXT/ico_presupuesto.png" style="cursor:pointer;display:inline-block;width:1.3vw;height:auto;padding-left:0.5vw;vertical-align:middle;"'
                           +' title="Ir al Registro del Presupuesto"'
                           +' onclick="Mostrar_Filtrado_2(''TH_Presupuestos_Web'',''codigo='+format(pw.codigo,'0')+''')">'
                  else ''  
             end
            else ''
      end
				------------------------------------------  
    -- Esta parte la anulo porque no es un sitio que proceda tenerlo aquí. (Domingo)
    -- Si alguien tiene que tocar esta funcion, antes me lo tiene que comunicar. Es muy delicada.
				/*
    +case when @SIVASA_estado!='' and @estinfor in ('4','5','6','F') 
          then '<span class="click" title="'+@SIVASA_estado+'" style="padding-left:5px;padding-right:5px;vertical-align:middle;height:24px;"'
                +' onclick="WSQL('' select ·Estado: '+@SIVASA_estado+'· ''); ">SIV</span>'
   	      else '' 
     end
    */
     -----------------------
     +case when 1=1 then '' else 
           isnull('<span style=";vertical-align:middle;color:#E74C3C;padding-left:0.2vw;">'+(n.lote_svh)+'</span>','')  
     end
     -----------------------
     -- Solicitudes por Web
     -----------------------
     +case when 3=3 then '' else 
           +case when isnull(a.chk_urgente,0)=0              and 1=2 then '' else '<img style="vertical-align:middle;width:1.8vw;height:auto;padding-left:0.2vw;" src="imgTHERION\sello_urgente.png" title="Informe Solicitado como Urgente"/>' end
           +case when isnull(a.chk_solicitar_ns,0)=0         and 1=2 then '' else '<img style="vertical-align:middle;width:1.5vw;height:auto;padding-left:0.2vw;" src="imgTHERION\sello_solicitud_ns.png" title="Autorizado a Solicitar Nota Simple"/>' end
           +case when isnull(a.referencia_catastral_1,'')='' and 1=2 then '' else '<br><span style="vertical-align:middle;">Ref.Cat. 1: '+isnull(a.referencia_catastral_1,'XXXXXXXXXXXXXXXXXXXXXXXXXX')+'</span>' end
           +case when isnull(a.referencia_catastral_2,'')='' and 1=2 then '' else '<br><span style="vertical-align:middle;">Ref.Cat. 2: '+isnull(a.referencia_catastral_2,'XXXXXXXXXXXXXXXXXXXXXXXXXX')+'</span>' end
     end
		 -- ================================================
   -- ======= VALORES DE TASACION REFERENCIAS ========
   -- ================================================
   +case when 1=2 then '' else 
         --------------------------------------------------
		       case when @valor_referencia!=0 
              then '<br>'
                  +'<table class="tabla_grid" style="margin-top:5px;width:100%;border:solid 0px #000">'
		                +'<tr>'
                  +'<td style="width:27%;text-align:center">'
									               +'<span style="font-size:70%;color:#2471A3;padding-right:5px;vertical-align:middle;">Valor Refer.</span>'
									               +'<span class="resaltado_general" style="color:#fff;background:#EB984E;vertical-align:middle;"'
                          +' title="Valor Referenciado por Cliente.'+char(10)
									                         +'Fecha de este valor: '+isnull(convert(varchar(10), n.fecha_tasacion_referenciado_cliente, 103), 'No informado')+'.'+char(10)
									                         +'Tipo: '+isnull(n.tipo_tasacion_referenciado_cliente, 'No informado')+'.'+char(10)
									                         +'Tasadora: '+isnull(n.tasadora_tasacion_referenciado_cliente, 'No informada')+'.'+char(10)
									                         +'Margen permitido: [-'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(@margen_referencia, 0), 2)
		                                +'% y +'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(@margen_referencia, 0), 2)+'%]'+char(10)
		                                +'Intervalo permitido: ['+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(@menor_referencia, 0), 2)+' - '+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(@mayor_referencia, 0), 2)+']'
                                 +'">'
                          +format(isnull(@valor_referencia,0), '#,0.00','de-DE')
                        +'</span>'
				               +'</td>'
				               +case when @estinfor in ('3', '4', '5', '6','F') and isnull(@valor_tasacion, 0)!=0 and isnull(@valor_referencia, 0)!=0 
                         then case	when (abs(@valor_tasacion-@valor_referencia)/@valor_referencia)*100 > @margen_referencia or 1=2 -- Siempre abierto (cuando existe valor referenciado y valor valorado)
																                   then '<td style="width:auto;text-align:center">'
																									                   +'<span style="font-size:70%;color:#2471A3;padding-right:5px;vertical-align:middle;">%Dif.</span>'
																									                   +'<span class="resaltado_general" style="color:#fff;background:#C0392B;vertical-align:middle;" >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(((isnull(@valor_tasacion, 0)-isnull(@valor_referencia, 0))/isnull(@valor_referencia, 0))*100, 2)+' %</span>'
																									                   +'<img class="aumenta click imginforme" src="img\ico_comentario_diferencia.png" style="padding-left:0.5vw;vertical-align:middle;"'
                       				                     +' title="Escribir Comentario para la Revisión"'
				                                            +' onclick=" var  p='''';'
				                                                      +' p+=''{textarea|Comentario Diferencia Informe '+@numinfor+'|Comentario||}'';'
				                                                      +' p+=''{combo||Seleccionar Motivo|'+isnull(ltrim(str(n.fk_TH_Infomes_Motivos_Diferencia_Valor)), '')+'|TH_Infomes_Motivos_Diferencia_Valor| [font-family:Roboto Condensed][font-size:70%]#obligatorio#}'';'
				                                                      +' p+=''{textarea||Justificación Valor para Cliente|'+isnull(n.comentario_justificacion_valor, '')+'|}'';'
				                                                      +' var e=''WSQL(··TH_Informes_Insertar_Comentario_Diferencia @numinfor=·'+@numinfor+'·, @comentario=·#parametro_value_1#·, @TH_Infomes_Motivos_Diferencia_Valor=·#parametro_value_2#·, @justificacion=·#parametro_value_3#·, @usuario='+convert(varchar, @usuario)+'  ··)''; '
				                                                      +' Pide_Parametros(p,e);" >'
				                                        +case when isnull(n.comentarios_diferencia_tasacion_referencia_cliente, '') != '' or isnull(n.comentario_justificacion_valor, '') != '' 
                                                  then '<img class="aumenta click imginforme" style="padding-left:0.5vw;" src="img\ico_comentario_diferencia_ver.png"'
				                                                      +' title="Ver Comentarios para la Revisión"'
				                                                      +' onclick="WHTML_General('' TH_Informes_Ver_Comentario_Diferencia @numinfor=·'+@numinfor+'· '',1);"'
				                                                      +' >'
    					                                         else ''
				                                         end
				                                    +'</td>'
																                   else '<td style="width:auto"></td>'
											                   end
					                    else '<td style="width:auto" ></td>'
				                end
                    +'</tr>'
			                 +'</table>'
			           else ''
		       end
   end

		 -- ================================================
   -- ======= VALORES DE TASACION y METODO ===========
   -- ================================================
   +case when @estinfor in ('3','4','5','6','F') then      
              '<br>'
             +'<span style="display:inline-block;width:3vw;font-size:0.55vw;color:#2471A3;padding-right:5px;vertical-align:middle;word-break:break-all;">Val.Tasac.</span>'
			          +'<span class="resaltado_general"'
               +' style="display:inline-block;width:6vw;font-size:0.75vw;color:#080;background:transparent;vertical-align:middle;word-break:break-all;text-align:right;"'
               +' title="Valor de la Tasación">'+isnull(format(@valor_tasacion, '#,0.00','de-DE')+' €','')+'</span>'
             +'<span style="font-size:0.55vw;color:#2471A3;padding-left:3px;vertical-align:middle;">'+isnull('('+@metodo_valoracion+')','')+'</span>'
         else ''
		  end
				-- =============================
    -- =========== GESTOR ==========
    -- =============================
				+case when 1=2 then '' else 
              '<br>'
			  +'<span style="vertical-align:middle;display:inline-block;width:13vw;word-break:break-all;color:#DC7633;font-size:0.65vw;padding-left:0px;border:solid 1px transparent"> '
		      +isnull( (select u.descripcion from CORITEL.dbo.th_gestor_encargo (nolock) ge inner join usuarios (nolock) u on ge.codusuar = u.cod_usuario_TH where ge.numinfor = @numinfor)
              ,'Sin gestor asignado')     
			  +' </span>'
				 end
				 +case when 1=2 then '' else 
          ---------------------------------------------------------
				      -- =========== Minutar como Actualización ===============  
          ---------------------------------------------------------
				      +case when @codobjet  ='10042'  then '' -- RICS
                when isnull(@fecemimi,'')!='' and isnull(n.chk_minuta_forzada,0)=1   then '' -- Minuta adelantada
                when @estinfor in ('0', '1', '2', '3')	
                 and isnull(@codtasad,'XXXXX')!='28500'
							          and @acc_minutado_actualizacion=1 
                then --@ico_separador
                    +'<img class="aumenta click imginforme" src="img\'
																	         +case when n.chk_minutar_como_actualizacion = 1                            then 'ico_minutado_como_actualizacion.png"'
																		              when n.chk_minutar_como_actualizacion = 0                            then 'ico_no_minutado_como_actualizacion.png"'
																		              when n.chk_minutar_como_actualizacion is null and @actualizacion = 0 then 'ico_no_minutado_como_actualizacion.png"'
																		              when n.chk_minutar_como_actualizacion is null and @actualizacion = 1 then 'ico_minutado_como_actualizacion.png"'
																		              else                                                                      'ico_no_minutado_como_actualizacion.png"'
																	          end
				                 +' title="Estado de Minuta como Actualización: '+case when n.chk_minutar_como_actualizacion = 1                            then 'ACTIVADO. Pulsar para Desactivar'
					                                                                      when n.chk_minutar_como_actualizacion = 0                            then 'DESACTIVADO. Pulsar para Activar'
					                                                                      when n.chk_minutar_como_actualizacion is null and @actualizacion = 0 then 'DESACTIVADO. Pulsar para Activar'
					                                                                      when n.chk_minutar_como_actualizacion is null and @actualizacion = 1 then 'ACTIVADO. Pulsar para Desactivar'
					                                                                      else                                                                      'DESACTIVADO. Pulsar para desactivar'
				                                                                  end+' "'
				                 +' onclick=" var p='''';'
				                           +' p+=''{confirmacion|'+case when n.chk_minutar_como_actualizacion = 1 then 'DESACTIVAR Minutar por Actualización'
					                                                       when n.chk_minutar_como_actualizacion = 0 then 'ACTIVAR Minutar por Actualización'
					                                                       when n.chk_minutar_como_actualizacion is null and @actualizacion = 0 then 'ACTIVAR Minutar por Actualización'
					                                                       when n.chk_minutar_como_actualizacion is null and @actualizacion = 1 then 'DESACTIVAR Minutar por Actualización'
					                                                       else 'ACTIVAR Minutar por Actualización'
				                                                   end+' el obligado de minutar como actualizacion '+@numinfor+'|||'';'
                               +' var e=''WSQL(··TH_Informes_Cambiar_Minutar_por_Actualizacion ·'+@numinfor+'· ··)''; '+' Pide_Parametros(p,e);'+'"'
				                 +' >'
					           else ''
				       end
          -----------------------------------------------------------------------------
				      -- ============== Forzar la Minuta en estado no Supervisado =================  
          -----------------------------------------------------------------------------
				      +case when @estinfor not in ('0','1','2','3','4','5','6','F')	then ''              -- No Está anulado o Supervisado -> se minuta de forma normal
                when @codobjet ='10042'                             then ''                  -- RICS
                when @acc_forzar_minutacion=0                       then ''
                when isnull(@fecemimi,'')!='' and isnull(n.chk_minuta_forzada,0)=0 then ''   -- Está minutado -> no forzado
                when isnull(@fecemimi,'')!='' and isnull(n.chk_minuta_forzada,0)=1           -- Minuta adelantada (importe) y generada
                     then 
                        case when n.importe_minuta_forzada is not null then
                             +'<span class="resaltado_general" style="color:#fff;background:#27AE60" '
                             +' title="Minuta Adelantada" ' 
                             +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.importe_minuta_forzada,0),2)+' €</span>' 
                             +'<span style=";vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha Minuta">('+left(dbo.fFecha_Hora(@fecemimi),10)+') </span>' 
                             when n.porcentaje_minuta_forzada is not null then
                             +'<span class="resaltado_general" style="color:#fff;background:#27AE60" '
                             +' title="Minuta Adelantada por %" ' 
                             +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada,0),2)+' %</span>' 
                             +'<span style="vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha Minuta">('+left(dbo.fFecha_Hora(@fecemimi),10)+') </span>' 
                             else ''
                        end
                else 
                     '<img class="aumenta click imginforme" style="padding-left:0.5vw;" src="img\'+case when isnull(n.chk_minuta_forzada,0)=0 then 'ico_forzadominutacion' else 'ico_noforzadominutacion' end+'.png" '
				                      +' title="'+case when isnull(n.chk_minuta_forzada,0)=0 then 'Pulsar para FORZAR la Minutación en la siguiente operación de Cálculo de Minutas'
					                                      else 'Pulsar para QUITAR FORZADO de la Minutación en la siguiente operación de Cálculo de Minutas'
				                                  end+' "'
				                 +' onclick=" var p='''';'
				                           +' p+=''{confirmacion|'+case when isnull(n.chk_minuta_forzada,0)=0 then 'FORZAR la Minutación ' else 'ELIMINAR FORZADO de la Minutación' end+' Inf. '+@numinfor+'|||'';'
                               +' var e=''WSQL(··TH_Informes_Forzar_Minutacion @numinfor=·'+@numinfor+'·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);"'
				                 +'>'
                     +case when isnull(n.chk_minuta_forzada,0)=0 then '' 
                           when n.importe_minuta_forzada is not null or n.porcentaje_minuta_forzada is not null then 
                                  '<span class="resaltado_general" style="vertical-align:middle;padding-left:0.5vw;color:#fff;background:#EB984E" '
                                 +' title="Cambiar el importe de la Minuta" ' 
				                             +' onclick=" var p='''';'
				                                       +' p+=''{numero|Cambiar el Importe de la Minuta Inf. '+@numinfor+'||'+replace(dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.importe_minuta_forzada,0),2),'.',',')+''';'
                                           +' var e=''WSQL(··TH_Informes_Forzar_Minutacion @numinfor=·'+@numinfor+'·, @importe_minuta_forzada=·#parametro_value_1#·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);'+'"'
                                +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.importe_minuta_forzada,0),2)+' €</span>' 
                                +'<span style="vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha que se asignó la minutación forzada">('+left(dbo.fFecha_Hora(n.fecha_orden_minuta_forzada),16)+') </span>' 
                                +'<span class="resaltado_general" style="color:#fff;background:#EB984E" '
                                 +' title="Cambiar el % adicional sobre Minuta Tarifada" ' 
				                             +' onclick=" var p='''';'
				                                       +' p+=''{numero|Cambiar el % sobre Minuta Tarifada Inf. '+@numinfor+'||'+replace(dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada,0),2),'.',',')+''';'
                                           +' var e=''WSQL(··TH_Informes_Forzar_Minutacion @numinfor=·'+@numinfor+'·, @porcentaje_minuta_forzada=·#parametro_value_1#·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);'+'"'
                                +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada,0),2)+' %</span>' 
                                +'<span style=";vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha que se asignó la minutación forzada">('+left(dbo.fFecha_Hora(n.fecha_orden_minuta_forzada),16)+') </span>' 
                           else ''
                      end
				       end
				  end
   -- =======================
		 -- ======== TASADOR ======
   -- =======================
		 +case when 1=2 then ''
         when @estinfor not in ('2', '3', '4', '5', '6', 'F') 
         then '<br><span style="vertical-align:middle;display:inline-block;width:13vw;word-break:break-all;color:#1F618D;font-size:0.65vw;padding-left:0px;border:solid 1px transparent"></span>'
			      else '<br>'
		          -- ============== Datos del Tasador =================  
            +'<a style="vertical-align:middle;display:inline-block;width:13vw;word-break:break-all;color:#1F618D;font-size:0.65vw;padding-left:0px;border:solid 1px transparent" title="Enviar Email" href="mailto:'+@emailtasador+'?Subject=Encargo_'+@numinfor+'" >'+isnull(@tasador,'')+'('+rtrim(isnull(@codtasad,''))+') (tas)</a>'
            +'<span style="vertical-align:middle;display:inline-block;width:4vw;word-break:break-all;color:#755;padding-left:3px;font-size:0.55vw;font-style:italic;border:solid 1px transparent" title="Teléfono Móvil Tasador">'+rtrim(isnull(@moviltasador, ''))+'</span>'
         		 +case when isnull(@fecdeven,'')!='' 
                  then '<span style="vertical-align:middle;display:inline-block;width:6vw;word-break:break-all;color:#755;padding-left:5px;font-size:0.50vw;border:solid 1px transparent"'
                        +' title="Fecha de Devolución del Informe">(Entrega '+format(@fecdeven,'dd/MM/yy HH:mm')+')</span>'
		                      +isnull('<span style="vertical-align:middle;display:inline-block;width:5vw;color:#a00;padding-left:3px;font-size:80%;font-style:italic;;border:solid 1px transparent"'
                               +' title="Días del Informe en Tasador" >('+format(convert(decimal(19, 2), dbo.f_Horas_Laborables(@fecrecen,@fecdeven,@cod_region, @fk_TH_Tasadores, 1, 1, 1)/24.00),'#,0.00' )+' días en tas.)</span>', '')
			               when isnull(@fecrecen,'')!= '' 
                  then '<span style="vertical-align:middle;display:inline-block;width:5vw;word-break:break-all;color:#755;padding-left:5px;font-size:0.50vw;border:solid 1px transparent" title="Fecha de Envío del Informe al Tasador">'+rtrim(isnull(left(dbo.fFecha_Hora(@fecrecen), 16), ''))+'</span>'
		                    +isnull('<span style="color:#a00;padding-left:3px;font-size:0.50vw;font-style:italic;vertical-align:middle;border:solid 1px transparent" title="Días del Informe en Tasador" >('+dbo.fFormato_Money_HTML_Decimales(convert(decimal(19, 2), dbo.f_Horas_Laborables(@fecrecen, getdate(), @cod_region, @fk_TH_Tasadores, 1, 1, 1)/24.00), 2)+' días)</span>', '')
			               else ''
		            end
				        -- ============== Renviar al Tasador =================  
				        +case when @estinfor not in ('1','2') or isnull(@codtasad,'XXXXX')='28500' then ''
				              else '<img class="aumenta click imginforme" style="padding-left:0.5vw;" src="img\ico_reenviarencargotasador.png" '
				                  +' title="Reenviar el Encardo al tasador asignado"'
				                  +' onclick=" var p='''';'
				                            +' p+=''{confirmacion|Reenviar el Encargo '+@numinfor+'|||'';'
				                            +' var e=''WSQL(··TH_Informes_FTWEB_Reenviar_al_Tasador ·'+@numinfor+'· ··)''; '
				                            +' Pide_Parametros(p,e);'
				                            +'"'
				                  +'>'
				         end
             +'<span style="vertical-align:middle;display:inline-block;width:6vw;word-break:break-all;color:#755;padding-left:3px;font-size:0.50vw;border:solid 1px transparent" title="Modelo de Firma Digital">'+isnull(' => '+@como_firma,'')+'</span>'
		  end
   -- =============================
		 -- ====== TASADOR COLABORADOR ==
   -- =============================
		 +case when 1=2 then '' 
         when @estinfor not in ('2', '3', '4', '5', '6', 'F') then ''
         when (select count(*) from CORITEL.dbo.taorexta x (nolock) where x.numinfor=@numinfor)=0 then ''
			      else '<br>'
		         +isnull( 
            (select top 1 
             +'<a style="vertical-align:middle;display:inline-block;width:13vw;word-break:break-all;color:#1F618D;font-size:0.65vw;padding-left:0px;border:solid 1px transparent;background:#C39BD3" title="Enviar Email al colaborador"'
               +' href="mailto:'+replace(replace(lower(isnull((select top 1 m.email 
                                                               from CORITEL.dbo.th_tasmail m (nolock) 
                                                               where m.codtasad=tx.codtasad and ltrim(rtrim(isnull(m.email, ''))) != ''), '')), ';', '; '), '  ', ' ')+'?Subject=Encargo_'+@numinfor+'" >'
		              +rtrim(isnull(tx.nomtasad, ''))+' '+rtrim(isnull(tx.ap1tasad, ''))+' '+rtrim(isnull(tx.ap2tasad, ''))
             +' ('+rtrim(isnull(tx.codtasad,''))+') (colaborador)</a>'
             +'<span style="vertical-align:middle;display:inline-block;width:4vw;word-break:break-all;color:#755;padding-left:3px;font-size:0.55vw;font-style:italic;" title="Teléfono Móvil Tasador">('+rtrim(isnull((select top 1 m.movil from CORITEL.dbo.th_movta m (nolock) where m.codtasad=tx.codtasad), ''))+')</span>'
             from CORITEL.dbo.taorexta x (nolock) 
             inner join CORITEL.dbo.taotasad tx (nolock) on tx.codtasad=x.codtasad
             where x.numinfor=@numinfor
             ),'')
				      -- ============== Forzar la Minuta en estado no Supervisado del colaborador =================  
				      +case when @estinfor not in ('0','1','2','3','4','5','6','F')	then ''              -- No Está anulado o Supervisado -> se minuta de forma normal
                when @codobjet ='10042'                             then ''                  -- RICS
                when @acc_forzar_minutacion=0                       then ''
                when isnull(@fecemimi,'')!='' and isnull(n.chk_minuta_forzada_colaborador,0)=0 then ''   -- Está minutado -> no forzado
                when isnull(@fecemimi,'')!='' and isnull(n.chk_minuta_forzada_colaborador,0)=1           -- Minuta adelantada (importe) y generada
                     then 
                        case when n.importe_minuta_forzada_colaborador is not null then
                             +'<span class="resaltado_general" style="color:#fff;background:#27AE60" '
                             +' title="Minuta Adelantada" ' 
                             +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.importe_minuta_forzada_colaborador,0),2)+' €</span>' 
                             +'<span style=";vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha Minuta">('+left(dbo.fFecha_Hora(@fecemimi),10)+') </span>' 
                             when n.porcentaje_minuta_forzada_colaborador is not null or n.porcentaje_minuta_forzada_colaborador_facturacion is not null then
                             
                             +'<span class="resaltado_general" style="color:#fff;background:#27AE60" '
                             +' title="Minuta Adelantada por %" ' 
                             +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada_colaborador,0),2)+' %</span>' 

                             +'<span class="resaltado_general" style="color:#fff;background:#27AE60" '
                             +' title="Minuta Adelantada por % s./Facturación" ' 
                             +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada_colaborador_facturacion,0),2)+' %</span>' 

                             +'<span style=";vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha Minuta">('+left(dbo.fFecha_Hora(@fecemimi),10)+') </span>' 
                             else ''
                        end
                else 
                     '<img class="aumenta click imginforme" src="img\'+case when isnull(n.chk_minuta_forzada_colaborador,0)=0 then 'ico_forzadominutacion' else 'ico_noforzadominutacion' end+'.png" '
				                      +' title="'+case when isnull(n.chk_minuta_forzada_colaborador,0)=0 then 'Pulsar para FORZAR la Minutación en la siguiente operación de Cálculo de Minutas'
					                                      else 'Pulsar para QUITAR FORZADO de la Minutación en la siguiente operación de Cálculo de Minutas'
				                                  end+' "'
				                 +' onclick=" var p='''';'
				                           +' p+=''{confirmacion|'+case when isnull(n.chk_minuta_forzada_colaborador,0)=0 then 'COLABORADOR-FORZAR la Minutación ' else 'COLABORADOR-ELIMINAR FORZADO de la Minutación' end+' Inf. '+@numinfor+'|||'';'
                               +' var e=''WSQL(··TH_Informes_Forzar_Minutacion_colaborador @numinfor=·'+@numinfor+'·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);"'
				                 +'>'
                     +case when isnull(n.chk_minuta_forzada_colaborador,0)=0 then '' 
                           when    n.importe_minuta_forzada_colaborador                is not null 
                                or n.porcentaje_minuta_forzada_colaborador             is not null 
                                or n.porcentaje_minuta_forzada_colaborador_facturacion is not null 
                                then 
                                ----------------------------------------------------------------------------
                                  '<span class="resaltado_general" style="color:#fff;background:#EB984E" '
                                 +' title="Cambiar el importe de la Minuta" ' 
				                             +' onclick=" var p='''';'
				                                       +' p+=''{numero|Cambiar Importe Minuta Colab. Inf. '+@numinfor+'||'+replace(dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.importe_minuta_forzada_colaborador,0),2),'.',',')+''';'
                                           +' var e=''WSQL(··TH_Informes_Forzar_Minutacion_colaborador @numinfor=·'+@numinfor+'·, @importe_minuta_forzada=·#parametro_value_1#·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);'+'"'
                                +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.importe_minuta_forzada_colaborador,0),2)+' €</span>' 
                                ----------------------------------------------------------------------------
                                +'<span style=";vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha que se asignó la minutación forzada">('+left(dbo.fFecha_Hora(n.fecha_orden_minuta_forzada_colaborador),16)+') </span>' 
                                ----------------------------------------------------------------------------
                                +'<span class="resaltado_general" style="color:#fff;background:#EB984E" '
                                 +' title="Cambiar el %adicional sobre Minuta Tarifada" ' 
				                             +' onclick=" var p='''';'
				                                       +' p+=''{numero|Cambiar el % sobre Minuta Tarifada (Colab.) Inf. '+@numinfor+'||'+replace(dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada_colaborador,0),2),'.',',')+''';'
                                           +' var e=''WSQL(··TH_Informes_Forzar_Minutacion_colaborador @numinfor=·'+@numinfor+'·, @porcentaje_minuta_forzada=·#parametro_value_1#·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);'+'"'
                                +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada_colaborador,0),2)+' %</span>' 
                                ----------------------------------------------------------------------------
                                +'<span style="display:inline-block;width:0.4vw;text-align:center">|</span>'
                                ----------------------------------------------------------------------------
                                +'<span class="resaltado_general" style="color:#fff;background:#85C1E9" '
                                 +' title="Cambiar el % sobre Facturación" ' 
				                             +' onclick=" var p='''';'
                                           +' p+=''{numero|Cambiar el % s/Fact. Tarifada (Colab.) Inf. '+@numinfor+'||'+replace(dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada_colaborador_facturacion,0),2),'.',',')+''';'
                                           +' var e=''WSQL(··TH_Informes_Forzar_Minutacion_colaborador @numinfor=·'+@numinfor+'·, @porcentaje_minuta_forzada_facturacion=·#parametro_value_1#·, @usuario='+isnull(format(@usuario,'#'),'null')+' ··)'';  Pide_Parametros(p,e);'+'"'
                                +' >'+dbo.fFormato_Money_HTML_Decimales_ver_cero(isnull(n.porcentaje_minuta_forzada_colaborador_facturacion,0),2)+' %</span>' 
                                ----------------------------------------------------------------------------
                                +'<span style=";vertical-align:middle;padding-left:4px;font-size:70%" title="Fecha que se asignó la minutación forzada del Colaborador">('+left(dbo.fFecha_Hora(n.fecha_orden_minuta_forzada_colaborador),16)+') </span>' 

                           else ''
                      end
				       end
		  end
		 -- ======================================================
   -- ============== SUPERVISOR (usfirma/ussuperv) =========
   -- ======================================================
		 +case when 1=2 or @estinfor not in ('3', '4', '5', '6', 'F') then ''
			      when @cod_supervisor is null then ''
         else '<br>'
   		        +'<span style="vertical-align:middle;display:inline-block;width:13vw;word-break:break-all;color:#28B463;padding-left:0px;font-size:0.65vw;border:solid 1px transparent" title="Supervisor">'+rtrim(isnull(@nombre_supervisor, ''))+' (superv.)</span>'
             +'<span style="vertical-align:middle;display:inline-block;width:4vw;word-break:break-all;color:#755;padding-left:3px;font-size:0.55vw;font-style:italic;border:solid 1px transparent">'
                  ----------------------------------------
                  +case when @acc_enviar_email_supervisor=1 and @estinfor in ('3','4','5','6','F') 
                         then  '<img class="aumenta click imginforme" style="padding-left:0.5vw;;" src="img\ico_svhenviaremail.png" '
                              +' title="Enviar Información por Email al Supervisor del Informe."'
                              +' onclick="Pide_Parametros( '''
                              +'{textarea|Enviar Información por Email al Supervisor Inf. '+@numinfor+'<br>('+isnull((select ltrim(rtrim(u.email)) 
                                                                                                                      from CORITEL.dbo.taoencar x (nolock) 
                                                                                                                      inner join CORITEL.dbo.taousuar u (nolock) on u.codusuar=@cod_supervisor
                                                                                                                      where x.numinfor=@numinfor),'')+')|Información al Supervisor|#obligatorio#}'
                              +' '',''WSQL(··TH_Informes_Mandar_Email_Supervisor @numinfor=·'+@numinfor+'·, @texto_email=·#parametro_value_1#·, @usuario_envia='+convert(varchar,@usuario)+' ··)'');"'
				                          +' />'
                         else '' 
                   end
                  ----------------------------------------
                  +case when a.emails_supervisor is null then '' 
                        else   '<img class="aumenta click imginforme" style="padding-left:0.5vw;" src="img\ico_vermailsupervisor.png" '
                              +' title="Nº Email mandados al Supervisor. Click Accede a lista de envíos"'
                              +' onclick="WHTML_General('' TH_Informes_Ver_Email_Enviados_Supervisor @codigo='+convert(varchar,n.codigo)+', @debug=0 '',1);"'
                              +' />'
                              +'<span class="resaltado_general" style="cursor:default" >'+format((select count(*) from dbo.f_split(isnull(a.emails_supervisor,'X'),'{nuevo_email}')),'0,0','de-DE')+'</span>'
                   end
             +'</span>'
		           +case when isnull(@fecsuper,'')!='' 
                   then '<span style="vertical-align:middle;display:inline-block;width:7vw;word-break:break-all;color:#755;padding-left:5px;font-size:0.50vw;border:solid 1px transparent"'
                         +'>Supervisado el '+format(@fecsuper,'dd/MM/yy HH:mm:ss')+'</span>'
         		        else isnull('<span style="vertical-align:middle;display:inline-block;width:6vw;word-break:break-all;color:#755;padding-left:5px;font-size:0.50vw;font-style:normal;border:solid 1px transparent"> Recepción el '+isnull(format(@fecdeven,'dd/MM/yy HH:mm'), '')+'</span>'
                              +'<span style="vertical-align:middle;display:inline-block;width:6vw;font-style:italic;word-break:break-all;color:#a00;padding-left:3px;font-size:0.50vw;border:solid 1px transparent"'
                              +' >('+format(convert(decimal(19, 2), dbo.f_Horas_Laborables(@fecdeven,getdate(),@cod_region,@fk_TH_Tasadores,1,1,1)/24.00), '#,0.00')+' días pte. superv.)'
                              +'</span>', '')
		            end
		  end
  	--	 -- ============== SUPERVISOR (usfirma) =============
  	--	 +case when 1=2 or @estinfor not in ('3', '4', '5', '6', 'F') then ''
   --        when @cod_supervisor is null then ''
  	--		      else '<br/>'
   --  		        +'<a style="color:#1F618D;padding-left:0px;font-size:80%" title="Enviar Email"'+isnull(' href="mailto:'+replace(replace(lower(@email_supervisor), ';', '; '), '  ', ' ')+'?Subject=Encargo_'+@numinfor+'"','')+' >'+rtrim(isnull(@nombre_supervisor, ''))+'</a>'
   --            +'<span style="color:#aaa;padding-left:4px;font-size:80%">(firma)</span>'
  	--	  end
		 ---------------------------------------------------
		 -- ==============================
   -- ======= Datos PDF Final ======
   -- ==============================
   +'<br>'
   +'<span style="display:inline-block;color:#1F618D;font-size:0.60vw;vertical-align:middle;width:10vw;border:solid 1px transparent">'
         +case when @estinfor not in ('4', '5', '6', 'F') or @fecmodif is null then '' else 
               '<b>PDF Generado</b> <i> el '+format(@fecmodif,'dd/MM/yyyy HH:mm:ss')+'</i>'
          end
   +'</span>'
   +'<span style="display:inline-block;color:#1F618D;font-size:0.60vw;vertical-align:middle;width:8vw;border:solid 1px transparent">'
		       +case when isnull(@fecsalid,'')='' or @estinfor not in ('4', '5', '6', 'F') then ''
			            else '<b>Fecha Salida</b> <i> '+format(@fecsalid,'dd/MM/yy HH:mm')+'</i>'
		        end
   +'</span>'
   +'<span style="display:inline-block;color:#1F618D;font-size:0.60vw;vertical-align:middle;width:18vw;border:solid 4px transparent">'
		       +case when @estinfor not in ('4', '5', '6', 'F') then ''
			            else '<b>F.Dig.&nbsp;</b>'
		             -- ==============================
               -- ======= Estado de la Firma ===
               -- ==============================
               +isnull('<span style="display:inline-block;width:auto;color:#070;font-size:120%;vertical-align:middle;">'+dbo.FIRMA_TASADOR (@numinfor)+'</span>','')
               +'<span style="display:inline-block;width:0.5vw"></span>'
               +case when @firmado_digital=1 and charindex('(6)',dbo.FIRMA_TASADOR (@numinfor))>0 then 
                      '<span style="display:inline-block;width:auto;color:#000;font-size:100%;vertical-align:middle;"> >= el <font style="font-size:120%;color:#000;" title="Fecha Firma Digital Tasador">'+format(@fecha_firma_digital,'dd/MM/yyyy HH:mm:ss')+'</font></span>'
                     when @firmado_digital=1 and charindex('(4)',dbo.FIRMA_TASADOR (@numinfor))>0 then 
                      '<span style="display:inline-block;width:auto;color:#000;font-size:100%;vertical-align:middle;"> >= el <font style="font-size:120%;color:#000;" title="Fecha Firma Digital Tasador">'+format(@fecha_firma_digital,'dd/MM/yyyy HH:mm:ss')+'</font></span>'
                     when @firmado_digital=1 and charindex('(3)',dbo.FIRMA_TASADOR (@numinfor))>0 then 
                      '<span style="display:inline-block;width:auto;color:#000;font-size:100%;vertical-align:middle;"> >= forzada el <font style="font-size:120%;color:#000;" title="Fecha Firma Digital Tasador">'+format(@fecha_firma_digital,'dd/MM/yyyy HH:mm:ss')+'</font></span>'
                     when  @motivo_no_autorizado is not null then
                      '<span style="display:inline-block;width:auto;color:#700;font-size:100%;vertical-align:middle;"> >= Firma Digital Rechazada el <font style="font-size:120%;color:#000;" title="Rechazo Firma Digital Tasador">'+isnull(format(@fecha_firma_digital,'dd/MM/yyyy HH:mm:ss'),'')+'</font></span>'
                     else ''
                end

               +isnull('<span style="display:inline-block;width:auto;background:red;color:white;font-size:100%;vertical-align:middle;padding-top:0px">Detectado: '+dbo.FIRMA_TASADOR_Cambios_Detectados (@numinfor)+'</span>','')

		        end
   +'</span>'


   -- ============== Historial del Clonacion ================= 
   +isnull(dbo.TH_Informes_Tabla_Historia_Clonacion (@numinfor, @usuario),'')
   -- ================================================
end

+'</td>'
from TH_Informes n (nolock)
inner join CORITEL.dbo.vTaoencar            e (nolock) on  e.numinfor=n.numinfor
inner join CORITEL.dbo.th_encargoadicional  a (nolock) on  a.numinfor=n.numinfor
outer apply (select top 1 pw.codigo 
                         ,pw.chk_conciliada_transferencia  
                         ,pw.TPV_Ds_Response
             from TH_Presupuestos_Web pw (nolock) 
             where pw.numinfor=n.numinfor
            ) pw
where n.codigo = @codigo
		 
--return (isnull(@r, '<td style="width:'+convert(varchar, @ancho)+';text-align:left" name="Inf./Alta/Datos Admin." acceso="1">'+@numinfor+'</td>'));
return isnull(@r, 'null')

 --return @r

end

GO


