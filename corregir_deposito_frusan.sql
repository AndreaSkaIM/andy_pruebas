SELECT  id,cod_deposito 

-- update ventas 
SET cod_deposito = cod_empresa 
-- select id,cod_empresa,cod_deposito,tipo_comprobante from ventas
WHERE tipo_comprobante IN ('RE','FA','NC','IR')
-- and cod_empresa=2 
AND cod_deposito<> cod_empresa

SELECT tipo_comprobante,cod_empresa -- ,cod_Deposito
, COUNT(1)
FROM ventas WHERE  tipo_comprobante IN ('FA','RE')
GROUP BY tipo_comprobante,cod_empresa -- ,cod_Deposito
