USE sistec_base;
SELECT 
  c.fecha,
  p.nombre,
  c.tipo_comprobante AS 'T.Compr',
  c.tipo_factura AS 'T.Fac',
  c.numero,
  c.importe_total,
  c.detalle,
  e.nombre_1 
FROM
  compras c 
  JOIN proveedores p 
    ON c.cod_proveedor = p.cod_proveedor 
  JOIN empresas e 
    ON e.cod_empresa = c.cod_empresa 
WHERE MONTH(fecha) >= 09 
  AND YEAR(fecha) = 2021 
  AND p.nombre LIKE '%rey%' 
ORDER BY c.cod_proveedor ASC,
  fecha ASC 