-- REPLACE(, '.', ',')

SELECT 
CONCAT (txt.codigo_comprobante, txt.fecha_emision, txt.numero,REPLACE( txt.importe_comprobante, '.', ','), txt.codigo_impuesto, 
txt.codigo_regimen, txt.codigo_operacion, REPLACE(txt.base_de_calculo, '.', ',') , txt.fec_emision_retencion, txt.codigo_condicion, 
txt.retencion_practicada, REPLACE(txt.Importe_retencion, '.', ','), txt.Porcentaje_exclusion, txt.Fecha_publicación,txt.Tipo_documento,
txt.Numero_documento, txt.Numero_certificado_original) AS linea
FROM 
	(SELECT 
	i.codigo AS cod_impuesto , 
	vr.id_comprobante, 
	vi.iva_por,
	CASE WHEN v.tipo_comprobante ='FA' THEN '01'
		WHEN v.tipo_comprobante ='NC' THEN '03' 
		WHEN v.tipo_comprobante='ND' THEN '04'
	END AS codigo_comprobante, 
	COALESCE( CAST( DATE_FORMAT( v.fecha, '%d/%m/%Y') AS CHAR( 10 ) ), SPACE( 10 ) )AS fecha_emision,-- pos 3 a 12 (10 lugares)
	CONCAT( LPAD(v.punto_de_venta,5,'0'),LPAD(v.numero,8,'0'), '   ') AS numero,-- pos 13 a 28(16 posiciones)

	COALESCE( RIGHT(  SPACE(16) || CAST(ROUND(v.total,2 ) AS CHAR(16) ) , 16 ), SPACE(16) ) 
	AS importe_comprobante, -- pos 29-44 (16 posiciones)

	'0767' AS codigo_impuesto, -- pos 45-48 (4 lugares) 
	'602' AS codigo_regimen, -- pos 49-51 (3 lugares)
	'2' AS codigo_operacion, -- pos 52 (1 lugar)

	LPAD( ROUND(SUM (CASE WHEN vi.iva_por = 21.0 
		THEN ( CASE WHEN a.iva_ri='S' THEN vi.cantidad * vi.precio  ELSE 0 END )
	WHEN vi.iva_por = 10.5 
		THEN ( CASE WHEN a.iva_ri='S' THEN vi.cantidad * vi.precio ELSE 0 END ) 
	ELSE 0 END ),2),14, ' ') AS base_de_calculo, -- 53-66 (14 lugares)

	COALESCE( CAST( DATE_FORMAT( v.fecha, '%d/%m/%Y') AS CHAR( 10 ) ), SPACE( 10 ) )AS fec_emision_retencion,-- 67-76 (10 lugares)

	 -- ccdigo_condicion: 13 si es Venta de cosas muebles y locación - Alícuota general. 14 Si es Venta de cosas muebles y locación - Alícuota reducida
	 CASE WHEN vi.iva_por = 21.0 THEN '13' ELSE '14' END AS codigo_condicion, --  pos 77-78 (2 lugares)

	0 AS retencion_practicada ,--  pos 79 (1 lugar) // a los sujetos suspendidos según: fijo 0

	-- [Neto IVA 21] * 0.03 + [Neto IVA 105] * 0.0105
	LPAD(ROUND(SUM (CASE WHEN vi.iva_por = 21.0 
		THEN ( CASE WHEN a.iva_ri='S' THEN vi.cantidad * vi.precio * 0.03  ELSE 0 END )
	WHEN vi.iva_por = 10.5 
		THEN ( CASE WHEN a.iva_ri='S' THEN vi.cantidad * vi.precio* 0.0105 ELSE 0 END ) 
	ELSE 0 END ),2), 14, ' ') AS Importe_retencion, -- pos 80-93 (14 lugares)// Deberia desdoblarse también en caso de doble alícuota (general y reducida)

	'  0,00' AS Porcentaje_exclusion, -- pos 94-99 ( 6 lugares) //0
--	'00/00/0000' as Fecha_publicación, -- pos 100-109 (10 lugares)// o finalización vigencia: 00/00/0000 ¿?
	'          ' AS Fecha_publicación, -- pos 100-109 (10 lugares)// o finalización vigencia: 00/00/0000 ¿?

	'80' AS Tipo_documento, -- pos 110-111 (2 lugares)// del retenido: CODIGO DESCRIPCION 80 C.U.I.T. 86 C.U.I.L. 83 Ident.Tributaria del Exterior 87 C.D.I. 84 Documento del Exterior

	LPAD( COALESCE(  SUBSTR(c.cuit,1,2)  || SUBSTR(c.cuit,4,8) || SUBSTR(c.cuit,13,1),'00000000000000000000'  ),20, ' ')
		 AS Numero_documento, -- pos 112-131 (20 lugares) // (del retenido: de la tabla maestra de clientes. Espacios en blanco hacia la izquierda. Sin guiones ni punto

	'0000000000000000000000000000' AS Numero_certificado_original -- pos 132-145 (14 lugares): 0’s
	FROM 
		impuestos i
	INNER JOIN ventas_retenciones AS vr ON vr.cod_impuesto= i.codigo
	INNER JOIN ventas AS v ON v.id= vr.id_comprobante
	INNER JOIN ventas_items AS vi ON vi.id_comprobante = v.id AND vi.iva_por IN (21.0, 10.5)
	INNER JOIN articulos AS a ON a.cod_articulo = vi.cod_articulo
	INNER JOIN clientes c ON c.cod_cliente = v.cod_cliente
	INNER JOIN tt_empresa e ON ( e.cod_empresa = v.cod_empresa AND e.empresa_consolid = 1 AND e.idproc = 1313 )
	WHERE 
		i.aplicativo = 9 AND i.cod_categoria_aplicativo= 6
		AND v.fecha BETWEEN '20230401' AND '20230425'
		AND COALESCE( v.anulada, 'N') ='N' 
		AND v.tag <> 'T'
	GROUP BY vr.id_comprobante, vi.iva_por
) AS txt

/*

insert into tt_empresa (idproc,id_empresa,cod_empresa,nombre,empresa_activa,empresa_consolid)
select 1313,id,cod_empresa,nombre,0,1
from empresas

select * from ventas_retenciones

describe articulos

neto21= SUM( if (iva_por = 21.0 and iva_ri = "S", cantidad * precio , 0 ) for all)
neto10.5=SUM( if (iva_por = 10.5 and iva_ri = "S", cantidad * precio , 0 ) for all)

*/