-- 31. Categorias com média de preço dos produtos (desc).
SELECT 
	PRC.prc_nome, 
  AVG(PRO.pro_preco) AS preco_medio
FROM tb_produto PRO
INNER JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id)
GROUP BY PRC.prc_nome
ORDER BY preco_medio DESC;

-- 32. Produtos com preço > média da própria categoria.
SELECT 
	PRO.pro_id, 
  PRO.pro_nome, 
  PRO.pro_preco, 
  PRC.prc_nome
FROM tb_produto PRO
JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id)
WHERE PRO.pro_preco > 
	(
      SELECT AVG(PRO2.pro_preco) 
      FROM tb_produto PRO2
      WHERE PRO2.pro_prc_id = PRO.pro_prc_id
	);

-- 33. Clientes com mais de 2 vendas nos últimos 120 dias.
SELECT 
	CLI.cli_id, 
    CLI.cli_razao_social, 
    COUNT(VEN.ven_id) AS qtd_vendas
FROM tb_cliente CLI
INNER JOIN tb_venda VEN ON (VEN.ven_cli_id = CLI.cli_id)
WHERE VEN.ven_data >= (CURDATE() - INTERVAL 120 DAY)
GROUP BY 
	CLI.cli_id, 
    CLI.cli_razao_social
HAVING COUNT(VEN.ven_id) > 2;

-- 34. Vendedores com ticket médio > 900 nos últimos 90 dias.
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      WHERE 
        	VEN.ven_data >= (CURDATE() - INTERVAL 90 DAY)
        	AND VEN.ven_status = 'FATURADA'
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data
    )
SELECT 
	FUN.fun_id, 
    FUN.fun_nome,
    AVG(VET.total_bruto) AS ticket_medio
FROM venda_total VET
JOIN tb_funcionario FUN ON (FUN.fun_id = VET.ven_fun_id)
GROUP BY FUN.fun_id, FUN.fun_nome
HAVING AVG(VET.total_bruto) > 900;

-- 35. Compras cujo total > 3.000.
SELECT 
	COM.com_id, 
    COM.com_data, 
    FRN.for_nome,
    SUM(COI.coi_quantidade * COI.coi_custo_unit) AS total_compra
FROM tb_compra COM
INNER JOIN tb_fornecedor FRN ON (FRN.for_id = COM.com_for_id)
INNER JOIN tb_compra_item COI ON (COI.coi_com_id = COM.com_id)
GROUP BY 
	COM.com_id, 
    COM.com_data, 
    FRN.for_nome
HAVING SUM(COI.coi_quantidade * COI.coi_custo_unit) > 3000;

-- 36. Top 5 produtos por valor vendido (120 dias).
SELECT 
	PRO.pro_id, 
    PRO.pro_nome,
    SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS valor_vendido
FROM tb_venda VEN
INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
INNER JOIN tb_produto PRO ON (PRO.pro_id = VEI.vei_pro_id)
WHERE 
	VEN.ven_status = 'FATURADA'
  	AND VEN.ven_data >= (CURDATE() - INTERVAL 120 DAY)
GROUP BY 
	PRO.pro_id, 
    PRO.pro_nome
ORDER BY valor_vendido DESC
LIMIT 5;

-- 37. Top 5 produtos por quantidade vendida (120 dias).
SELECT 
	PRO.pro_id, 
    PRO.pro_nome,
    SUM(VEI.vei_quantidade) AS qtd_vendida
FROM tb_venda VEN
INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
INNER JOIN tb_produto PRO ON (PRO.pro_id = VEI.vei_pro_id)
WHERE 
	VEN.ven_status = 'FATURADA'
  	AND VEN.ven_data >= (CURDATE() - INTERVAL 120 DAY)
GROUP BY 
	PRO.pro_id, 
    PRO.pro_nome
ORDER BY qtd_vendida DESC
LIMIT 5;

-- 38. Top 3 clientes por valor total faturado (FATURADA).
-- OPÇÃO 1
SELECT 
	CLI.cli_id, 
    COALESCE(CLI.cli_fantasia, CLI.cli_razao_social) AS cliente,
    SUM((VEI.vei_quantidade * VEI.vei_preco_unit) - VEN.ven_desconto) AS valor_total
FROM tb_venda_item VEI
INNER JOIN tb_venda VEN ON (VEI.vei_ven_id = VEN.ven_id)
INNER JOIN tb_cliente CLI ON (VEN.ven_cli_id = CLI.cli_id)
WHERE VEN.ven_status = 'FATURADA'
GROUP BY CLI.cli_id, cliente
ORDER BY valor_total DESC
LIMIT 3;

-- OPÇÃO 2
WITH venda_total AS
(
    SELECT
        VEN.ven_id,
        VEN.ven_cli_id,
        SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
    FROM tb_venda VEN
    INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
    WHERE VEN.ven_status = 'FATURADA'
    GROUP BY VEN.ven_id, VEN.ven_cli_id
)
SELECT
	CLI.cli_id, 
    COALESCE(CLI.cli_fantasia, CLI.cli_razao_social) AS cliente,
    SUM(VET.total_bruto - VEN.ven_desconto) AS total_faturado
FROM venda_total VET
INNER JOIN tb_venda VEN ON (VEN.ven_id = VET.ven_id)
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VEN.ven_cli_id)
GROUP BY CLI.cli_id, CLI.cli_razao_social
ORDER BY total_faturado DESC
LIMIT 3;

-- 39. Total de descontos por vendedor (últimos 90 dias; FATURADA).
SELECT 
	FUN.fun_id, 
    FUN.fun_nome, 
    SUM(VEN.ven_desconto) AS descontos_90d
FROM tb_venda VEN
INNER JOIN tb_funcionario FUN ON (FUN.fun_id = VEN.ven_fun_id)
WHERE VEN.ven_status = 'FATURADA'
AND VEN.ven_data >= (CURDATE() - INTERVAL 90 DAY)
GROUP BY FUN.fun_id, FUN.fun_nome;

-- 40. Ticket médio por forma de pagamento (FATURADA, 60 dias).
WITH venda_total AS 
(
  SELECT 
    VEN.ven_id,
    SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
  FROM tb_venda VEN
  JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
  WHERE VEN.ven_status = 'FATURADA'
  AND VEN.ven_data >= (CURDATE() - INTERVAL 60 DAY)
  GROUP BY VEN.ven_id
)
SELECT 
	PAF.paf_descricao AS forma_pagto,
    AVG(VET.total_bruto - VEN.ven_desconto) AS ticket_medio
FROM tb_pagamento PAG
INNER JOIN tb_pagamento_forma PAF ON (PAF.paf_id = PAG.pag_paf_id)
INNER JOIN tb_venda VEN ON (VEN.ven_id = PAG.pag_ven_id)
INNER JOIN venda_total VET ON (VET.ven_id = VEN.ven_id)
WHERE VEN.ven_status = 'FATURADA'
AND VEN.ven_data >= (CURDATE() - INTERVAL 60 DAY)
GROUP BY PAF.paf_descricao;