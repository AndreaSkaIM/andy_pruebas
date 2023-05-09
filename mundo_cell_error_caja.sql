SELECT cod_rendicion, COUNT(1)
FROM rendicion
WHERE id_usuario = 51604102
GROUP BY cod_rendicion
HAVING COUNT(1)>1 

 AND fecha > '20230401'
 
 SELECT *  FROM rendicion
WHERE id_usuario = 51604102 AND ISNULL(cod_rendicion)
 
 (SELECT * FROM usuarios)
	//el usuario tiene otras rendiciones-levanto el maximo codigo de rendicion del usurio para la empresa donde esta parado
	SELECT MAX(cod_rendicion) 
	 FROM rendicion WHERE id_usuario = 51604102 AND cod_empresa =  :gi_cod_empresa_activa USING SQLCA;
	IF sqlca.sqlcode <> 0 THEN //#17060 - Sergio 
		ls_mensaje = 'Error al traer el codigo de la rendición' + sqlca.sqlerrtext
		goto proc_fin
	END IF 				

	//recupero el id de dicha rendicion
	SELECT *  FROM rendicion 
	WHERE cod_rendicion = 3666 AND id_usuario = 51604102  AND cod_empresa =  :gi_cod_empresa_activa USING SQLCA;
	IF sqlca.sqlcode <> 0 THEN //#17060 - Sergio 
		ls_mensaje = 'Error al traer el id de la rendición' + sqlca.sqlerrtext
		goto proc_fin
	END IF 
	
	 //#17060 - Sergio - traigo el estado de la rendicion
	SELECT tipo, fecha FROM rendicion 
	WHERE id_usuario = 51604102 AND id = 53188275  AND cod_empresa =  :gi_cod_empresa_activa USING SQLCA;
	
 
SELECT saldo, id  FROM rendicion /*#27949 - Sergio - 20/04/2020 - se recupera el id del saldo anterior*/
WHERE tipo = 'C' AND saldo IS NOT NULL 
AND id_usuario = 51604102 AND id = 53188275  AND cod_empresa =  :gi_cod_empresa_activa  USING SQLCA;


SELECT * FROM rendicion 
WHERE id_rendicion_anterior =53188275
/*
id	id_usuario	fecha	cod_rendicion	cod_moneda	cod_empresa	tag	OBSERVACION	hora	tipo	saldo	estado	id_cierre	fecha_cierre	id_usuario_tesorero	id_rendicion_anterior
53188483	51604102	2023-02-09	3367	1	4	S	\N	10:21:48	I	28040.000000	S	\N	\N	\N	53188275
*/

IF sqlca.sqlcode < 0 THEN // si el igual a 100 entonces el id queda como 0, solamente es error cuando sea menos a cero
	ls_mensaje = 'Error al traer el id de otro usuario' + sqlca.sqlerrtext