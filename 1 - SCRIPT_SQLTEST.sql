/*

  Com base no modelo acima, escreva um comando SQL que liste a quantidade de registros por Status com sua descrição.

 */

  SELECT 

	  TblProcesso.nroProcesso,
	  TblStatus.idStatus,
	  TblStatus.dsStatus 
	  
  FROM [Testing_Juridico_PedroPriuli].[dbo].[tb_Processo] TblProcesso WITH(NOLOCK)   
  INNER JOIN [Testing_Juridico_PedroPriuli].[dbo].[tb_Andamento] TblAndamento WITH(NOLOCK) on(TblAndamento.idProcesso = TblProcesso.idProcesso)
  INNER JOIN [Testing_Juridico_PedroPriuli].[dbo].[tb_Status] TblStatus WITH(NOLOCK) on(TblProcesso.idStatus = TblStatus.idStatus)
  
  

/*
construa um comando SQL que liste a MAIOR data de andamento por número de processo, 
com processos encerrados no ano de 2013.

*/


SELECT 
	 Max(TblAndamento.dtAndamento) as [Maior data andamento]
FROM [Testing_Juridico_PedroPriuli].[dbo].[tb_Andamento] TblAndamento WITH(NOLOCK) 
	 INNER JOIN [Testing_Juridico_PedroPriuli].[dbo].[tb_Processo] TblProcesso WITH(NOLOCK) ON (TblProcesso.idProcesso = TblAndamento.idProcesso)
WHERE YEAR(TblProcesso.DtEncerramento) = '2013'


/*

construa um comando SQL que liste a quantidade de Data de Encerramento agrupada por ela mesma com a quantidade da contagem seja maior que 5.

*/

SELECT 
	Count(TblProcesso.DtEncerramento) as [total encerramento], 
	TblProcesso.DtEncerramento
FROM [Testing_Juridico_PedroPriuli].[dbo].[tb_Processo] TblProcesso
group by TblProcesso.DtEncerramento
HAVING count(TblProcesso.DtEncerramento) > 5


/*

Possuímos um número de identificação do processo, onde o mesmo contém 12 caracteres com zero à esquerda, 
contudo nosso modelo e dados ele é apresentado como bigint. Como fazer para apresenta-lo com 12 caracteres considerando os zeros a esquerda?

 */

 SELECT DISTINCT FORMAT(nroProcesso,'000000000000') AS [Numero do processo] FROM tb_Processo