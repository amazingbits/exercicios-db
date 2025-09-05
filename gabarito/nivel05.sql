-- 41. Produtos com preço > média geral.
SELECT 
	pro_id, 
    pro_nome, 
    pro_preco
FROM tb_produto
WHERE pro_preco > (SELECT AVG(pro_preco) FROM tb_produto);

-- 42. Clientes que nunca realizaram compras (vendas).
SELECT 
	CLI.cli_id, 
    COALESCE(CLI.cli_fantasia, CLI.cli_razao_social)
FROM tb_cliente CLI
WHERE NOT EXISTS (
  SELECT 1
  FROM tb_venda VEN
  WHERE VEN.ven_cli_id = CLI.cli_id
);

-- 43. Vendas com total acima do ticket médio geral (FATURADA).
WITH venda_total AS 
	(
      SELECT 
            VEN.ven_id,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      WHERE VEN.ven_status = 'FATURADA'
      GROUP BY VEN.ven_id
	),
media AS (
  SELECT AVG(total_bruto) AS ticket_medio FROM venda_total
)
SELECT 
	VEN.ven_id, 
    VEN.ven_data, 
    VET.total_bruto
FROM tb_venda VEN
INNER JOIN venda_total VET ON (VET.ven_id = VEN.ven_id)
CROSS JOIN media MED
WHERE VET.total_bruto > MED.ticket_medio
AND VEN.ven_status = 'FATURADA';
-- Obs: Usei o CROSS JOIN com a CTE media (que retorna 1 linha) para anexar o ticket_medio a todas as linhas e poder compará-lo no WHERE

-- 44. Para cada categoria, o produto mais caro.
SELECT 
	PRC.prc_nome categoria,
    PRO.pro_preco preco,
    PRO.pro_id produto_id,
    PRO.pro_nome produto
FROM tb_produto PRO
INNER JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id)
WHERE PRO.pro_preco = (
  SELECT MAX(PRO2.pro_preco) FROM tb_produto PRO2
  WHERE PRO2.pro_prc_id = PRO.pro_prc_id
);

-- 45. CTE total por venda; apenas > 1.500.
WITH total_venda AS 
(
  SELECT 
    	VEI.vei_ven_id AS ven_id,
        SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
  FROM tb_venda_item VEI
  GROUP BY VEI.vei_ven_id
)
SELECT 
	VEN.ven_id, 
    VEN.ven_data, 
    TOV.total_bruto
FROM tb_venda VEN
JOIN total_venda TOV ON (TOV.ven_id = VEN.ven_id)
WHERE TOV.total_bruto > 1500
ORDER BY TOV.total_bruto DESC;

-- 46. CTE total comprado por fornecedor; > 5.000.
WITH total_fornecedor AS
(
	SELECT 
    	COM.com_for_id AS for_id,
    	SUM(COI.coi_quantidade * COI.coi_custo_unit) AS total_comprado
    FROM tb_compra COM
    INNER JOIN tb_compra_item COI ON (COI.coi_com_id = COM.com_id)
    GROUP BY COM.com_for_id
)
SELECT 
	FRN.for_id, 
    FRN.for_nome, 
    TOF.total_comprado
FROM total_fornecedor TOF
INNER JOIN tb_fornecedor FRN ON (FRN.for_id = TOF.for_id)
WHERE TOF.total_comprado > 5000
ORDER BY TOF.total_comprado DESC;

-- 47. CTE saldo teórico: estoque_atual - vendidos(120d) + comprados(120d).
-- Crio uma variável e atribuo a ela a data de 120 dias atrás (opcional)
SET @120d = (CURDATE() - INTERVAL 120 DAY);

-- Crio um CTE listando a quantidade de produtos vendidos nos últimos 120 dias
WITH vendidos AS 
	(
      SELECT 
            VEI.vei_pro_id AS pro_id, 
            SUM(VEI.vei_quantidade) AS qtd_vendida_120d
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      WHERE VEN.ven_status = 'FATURADA'
      AND VEN.ven_data >= @120d
      GROUP BY VEI.vei_pro_id
	),
-- Um CTE listando a quantidade de produtos comprados nos últimos 120 dias
comprados AS 
    (
      SELECT 
            COI.coi_pro_id AS pro_id, 
            SUM(COI.coi_quantidade) AS qtd_comprada_120d
      FROM tb_compra COM
      INNER JOIN tb_compra_item COI ON (COI.coi_com_id = COM.com_id)
      WHERE COM.com_data >= @120d
      GROUP BY COI.coi_pro_id
    )
SELECT 
	PRO.pro_id, 
    PRO.pro_nome,
    COALESCE(EST.est_quantidade,0) AS estoque_atual,
    COALESCE(VEN.qtd_vendida_120d,0) AS vendidos_120d,
    COALESCE(COM.qtd_comprada_120d,0) AS comprados_120d,
    (COALESCE(EST.est_quantidade,0) - COALESCE(VEN.qtd_vendida_120d,0) + COALESCE(COM.qtd_comprada_120d,0)) AS saldo_teorico
FROM tb_produto PRO
LEFT JOIN tb_estoque EST ON (EST.est_pro_id = PRO.pro_id)
LEFT JOIN vendidos VEN ON (VEN.pro_id = PRO.pro_id)
LEFT JOIN comprados COM ON (COM.pro_id = PRO.pro_id);

-- 48. Clientes cuja maior venda > 1.300.
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_cli_id,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_cli_id
    )
SELECT 
	CLI.cli_id, 
    CLI.cli_razao_social, 
    MAX(VET.total_bruto) AS maior_venda
FROM venda_total VET
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VET.ven_cli_id)
GROUP BY 
	CLI.cli_id, 
    CLI.cli_razao_social
HAVING MAX(VET.total_bruto) > 1300;

-- 49. Clientes com média por venda > 800 (últimos 60 dias; FATURADA).
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_cli_id,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_liq_base
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      WHERE VEN.ven_status = 'FATURADA'
      AND VEN.ven_data >= (CURDATE() - INTERVAL 60 DAY)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_cli_id
    )
SELECT 
	CLI.cli_id, 
    CLI.cli_razao_social,
    AVG(VET.total_liq_base) AS media_por_venda
FROM venda_total VET
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VET.ven_cli_id)
GROUP BY CLI.cli_id, CLI.cli_razao_social
HAVING AVG(VET.total_liq_base) > 800;

-- 50. Produtos que nunca apareceram em orçamentos.
SELECT 
	PRO.pro_id, 
    PRO.pro_nome
FROM tb_produto PRO
WHERE NOT EXISTS 
    (
      SELECT 1 FROM tb_orcamento_item ORI
      WHERE ORI.ori_pro_id = PRO.pro_id
    );