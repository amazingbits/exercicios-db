-- 51. Vendas com total bruto e rank desc por total.
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY VEN.ven_id, VEN.ven_data
    )
SELECT 
	ven_id, 
    ven_data, 
    total_bruto,
    RANK() OVER (ORDER BY total_bruto DESC) AS posicao
FROM venda_total;

-- 52. Por vendedor, soma acumulada do total (por data).
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data
    )
SELECT 
	FUN.fun_nome, 
    VET.ven_id, 
    VET.ven_data, 
    VET.total_bruto,
    SUM(VET.total_bruto) OVER (
        						PARTITION BY VET.ven_fun_id
                                ORDER BY VET.ven_data, VET.ven_id
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    						  ) AS acumulado
FROM venda_total VET
INNER JOIN tb_funcionario FUN ON (FUN.fun_id = VET.ven_fun_id)
ORDER BY FUN.fun_nome, VET.ven_data;
-- Usa a window function SUM(...) OVER para calcular a soma acumulada do total_bruto
-- por vendedor (PARTITION BY ven_fun_id). Dentro de cada vendedor, ordena por data e
-- id de venda (ORDER BY ven_data, ven_id) para ter ordem estável em dias com várias vendas.
-- A moldura ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW define um acumulado
-- linha a linha, desde a primeira venda do vendedor até a linha atual.
-- A CTE 'venda_total' consolida o total por venda, evitando duplicidade de itens.

-- 53. Média móvel de 3 vendas (por vendedor).
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data
    )
SELECT 
	FUN.fun_nome, 
    VET.ven_id, 
    VET.ven_data, 
    VET.total_bruto,
    AVG(VET.total_bruto) OVER 
    	(
            PARTITION BY VET.ven_fun_id 
            ORDER BY VET.ven_data, VET.ven_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS media_movel_3_ultimas_vendas
FROM venda_total VET
JOIN tb_funcionario FUN ON (FUN.fun_id = VET.ven_fun_id)
ORDER BY FUN.fun_nome, VET.ven_data;
-- Window function AVG(...) OVER considerando o total bruto das últimas duas vendas mais a venda atual

-- 54. Por cliente, quartis (NTILE(4)) por valor da venda.
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_cli_id,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY VEN.ven_id, VEN.ven_cli_id
    )
SELECT 
	CLI.cli_razao_social, 
    VET.ven_id, 
    VET.total_bruto,
    NTILE(4) OVER (PARTITION BY VET.ven_cli_id ORDER BY VET.total_bruto) AS quartil
FROM venda_total VET
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VET.ven_cli_id);
-- A ideia dessa window function NTILE(...) OVER nesse caso é pegar todos o total bruto de todas as vendas e separar em 4 grupos 
-- baseados no valor. Com isso, por exemplo, posso ter uma média de valor que cada cliente costuma gastar em vendas. Ex: o cliente que faz 
-- várias compras pequenas, o cliente que faz poucas compras grandes, etc.

-- 55. Dois itens mais caros de cada venda.
WITH itens AS 
    (
      SELECT 
        	VEI.vei_id, 
        	VEI.vei_ven_id,
            (VEI.vei_quantidade * VEI.vei_preco_unit) AS valor_item,
            ROW_NUMBER() OVER (PARTITION BY VEI.vei_ven_id ORDER BY (VEI.vei_quantidade * VEI.vei_preco_unit) DESC) AS ordem
      FROM tb_venda_item VEI
    )
SELECT * 
FROM itens 
WHERE ordem <= 2;

-- 56. Para cada produto: pro_preco e preco_medio_categoria.
SELECT 
	PRO.pro_id, 
    PRO.pro_nome, 
    PRO.pro_preco, 
    PRC.prc_nome,
    AVG(PRO.pro_preco) OVER (PARTITION BY PRO.pro_prc_id) AS preco_medio_categoria
FROM tb_produto PRO
INNER JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id);

-- 57. Para cada forma de pagamento, participação (%) no total faturado.
SELECT 
	PAF.paf_descricao AS forma,
    SUM(PAG.pag_valor) AS total_recebido,
    CONCAT(ROUND(
        (SUM(PAG.pag_valor) / SUM(SUM(PAG.pag_valor)) OVER ()) * 100
    , 2), '%') AS participacao_pct
FROM tb_pagamento PAG
INNER JOIN tb_pagamento_forma PAF ON (PAF.paf_id = PAG.pag_paf_id)
INNER JOIN tb_venda VEN ON (VEN.ven_id = PAG.pag_ven_id)
WHERE VEN.ven_status = 'FATURADA'
GROUP BY PAF.paf_descricao;

-- 58. Diferença entre venda atual e anterior (por vendedor).
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data
    )
SELECT 
	FUN.fun_nome, 
    VET.ven_id, 
    VET.ven_data, 
    VET.total_bruto,
    (VET.total_bruto - LAG(VET.total_bruto) OVER (PARTITION BY VET.ven_fun_id ORDER BY VET.ven_data, VET.ven_id)) AS delta_vs_anterior
FROM venda_total VET
INNER JOIN tb_funcionario FUN ON (FUN.fun_id = VET.ven_fun_id)
ORDER BY FUN.fun_nome, VET.ven_data;
-- LAG pega o registro anterior, ou seja, o total bruto anterior.
-- A fórmula é total bruto atual menos total bruto da linha anterior (LAG) separado por vendedor

-- 59. Mediana aproximada por vendedor (aprox via PERCENT_RANK() ~0.5).
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_fun_id, 
        	VEN.ven_data
    ),
rankeada AS 
    (
      SELECT *, PERCENT_RANK() OVER (PARTITION BY ven_fun_id ORDER BY total_bruto, ven_id) AS pr
      FROM venda_total
    ),
aprox AS 
    (
      SELECT *, ROW_NUMBER() OVER (PARTITION BY ven_fun_id ORDER BY ABS(pr - 0.5), total_bruto, ven_id) AS rn
      FROM rankeada
    )
SELECT 
	FUN.fun_nome, 
    APR.ven_id, 
    APR.total_bruto AS mediana_aproximada
FROM aprox APR
INNER JOIN tb_funcionario FUN ON (FUN.fun_id = APR.ven_fun_id)
WHERE APR.rn = 1;
-- Encontra, para cada vendedor, a venda cujo total_bruto está mais próxima do percentil 50 (mediana).
-- Usa PERCENT_RANK() por vendedor para obter a posição percentual (0..1) e escolhe a linha mais perto de 0,5.
-- É "aproximada" porque, com N par, a mediana exata seria a média dos dois centrais e 0,5 pode não existir exatamente.

-- 60. Por cliente: maior venda e flag se a última também foi a maior.
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_cli_id, 
        	VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_cli_id, 
        	VEN.ven_data
    ),
ultima_venda AS 
    (
      SELECT 
        	VET.*,
            ROW_NUMBER() OVER (PARTITION BY VET.ven_cli_id ORDER BY VET.ven_data, VET.ven_id DESC) AS rn_ult,
            MAX(VET.total_bruto) OVER (PARTITION BY VET.ven_cli_id) AS max_cliente
      FROM venda_total VET
    )
SELECT 
	CLI.cli_razao_social,
    MAX(CASE WHEN rn_ult = 1 THEN total_bruto END) AS ultima_venda,
    MAX(max_cliente) AS maior_venda,
    CASE 
        WHEN 
            MAX(CASE WHEN rn_ult = 1 THEN total_bruto END) = MAX(max_cliente) 
        THEN 1 
        ELSE 0 
    END AS ultima_foi_maior
FROM ultima_venda ULT
INNER JOIN tb_cliente CLI ON (CLI.cli_id = ULT.ven_cli_id)
GROUP BY CLI.cli_razao_social;