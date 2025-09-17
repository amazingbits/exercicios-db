-- 61. Pivot simples: total por forma de pagamento (FATURADA).
WITH base AS (
  SELECT 
    	PAF.paf_descricao AS forma_pagamento, 
    	PAG.pag_valor
  FROM tb_pagamento PAG
  INNER JOIN tb_pagamento_forma PAF ON (PAF.paf_id = PAG.pag_paf_id)
  INNER JOIN tb_venda VEN ON (VEN.ven_id = PAG.pag_ven_id)
  WHERE VEN.ven_status = 'FATURADA'
)
SELECT
  COALESCE(SUM(CASE WHEN forma_pagamento = 'PIX'            THEN pag_valor END),0) AS PIX,
  COALESCE(SUM(CASE WHEN forma_pagamento = 'Cartão Crédito' THEN pag_valor END),0) AS CARTAO_CREDITO,
  COALESCE(SUM(CASE WHEN forma_pagamento = 'Cartão Débito'  THEN pag_valor END),0) AS CARTAO_DEBITO,
  COALESCE(SUM(CASE WHEN forma_pagamento = 'Boleto'         THEN pag_valor END),0) AS BOLETO,
  COALESCE(SUM(CASE WHEN forma_pagamento = 'Dinheiro'       THEN pag_valor END),0) AS DINHEIRO
FROM base;
-- Operação PIVOT: transforma valores distintos de uma coluna em colunas,
-- aplicando uma agregação (ex.: SUM) sobre as linhas correspondentes.
-- Aqui: formas de pagamento viram colunas (PIX, Cartão, etc.) e somamos pag_valor.
-- Obs.: COALESCE garante 0 para formas sem ocorrências.

-- 62. Total últimos 30 dias vs 30 anteriores (FATURADA).
WITH venda_total AS 
    (
      SELECT 
            VEN.ven_id, 
            VEN.ven_data,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_liq_base
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      WHERE VEN.ven_status = 'FATURADA'
        AND VEN.ven_data >= (CURDATE() - INTERVAL 60 DAY)
      GROUP BY 
            VEN.ven_id, 
            VEN.ven_data
    ),
ult_30 AS 
    (
      SELECT SUM(total_liq_base) AS total_ult_30
      FROM venda_total
      WHERE ven_data >= (CURDATE() - INTERVAL 30 DAY)
    ),
ant_30 AS 
    (
      SELECT SUM(total_liq_base) AS total_ant_30
      FROM venda_total
      WHERE ven_data < (CURDATE() - INTERVAL 30 DAY)
        AND ven_data >= (CURDATE() - INTERVAL 60 DAY)
    )
SELECT 
	ULT.total_ult_30, 
    ANT.total_ant_30,
    (ULT.total_ult_30 - ANT.total_ant_30) AS dif,
    CASE WHEN ANT.total_ant_30 > 0 THEN ((ULT.total_ult_30 - ANT.total_ant_30)/ANT.total_ant_30)*100 END AS dif_pct
FROM ult_30 ULT 
CROSS JOIN ant_30 ANT;

-- 63. Produtos líderes: > 15% do faturamento total (FATURADA).
WITH total_por_produto AS 
    (
      SELECT 
        	PRO.pro_id, 
        	PRO.pro_nome,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_prod
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      INNER JOIN tb_produto PRO ON (PRO.pro_id = VEI.vei_pro_id)
      WHERE VEN.ven_status = 'FATURADA'
      GROUP BY 
        	PRO.pro_id, 
        	PRO.pro_nome
    ),
total_geral AS 
    (
      SELECT SUM(total_prod) AS tg FROM total_por_produto
    )
SELECT 
	PPR.pro_id, 
    PPR.pro_nome, 
    PPR.total_prod,
    (PPR.total_prod / TGE.tg) * 100 AS participacao_pct
FROM total_por_produto PPR 
CROSS JOIN total_geral TGE
WHERE (PPR.total_prod / TGE.tg) > 0.15
ORDER BY participacao_pct DESC;

-- 64. Ranking de clientes por LTV (soma do FATURADO).
WITH venda_total AS (
  SELECT 
    VEN.ven_id,
    VEN.ven_cli_id,
    SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto,
    COALESCE(VEN.ven_desconto, 0) AS desconto_venda
  FROM tb_venda VEN
  JOIN tb_venda_item VEI ON VEI.vei_ven_id = VEN.ven_id
  WHERE VEN.ven_status = 'FATURADA'
  GROUP BY VEN.ven_id, VEN.ven_cli_id, VEN.ven_desconto
)
SELECT
  CLI.cli_id,
  CLI.cli_razao_social,
  SUM(VET.total_bruto - VET.desconto_venda) AS ltv,
  RANK() OVER (ORDER BY SUM(VET.total_bruto - VET.desconto_venda) DESC) AS pos
FROM venda_total VET
JOIN tb_cliente CLI ON CLI.cli_id = VET.ven_cli_id
GROUP BY CLI.cli_id, CLI.cli_razao_social
ORDER BY ltv DESC;
-- LTV = Lifetime value = Valor que o cliente gera ao longo de todo o relacionamento
-- Ou seja, nesse caso, o total líquido (considerando descontos) que o cliente gastou

-- 65. Orçamentos aprovados que viraram venda.
SELECT 
	ORC.orc_id, 
    ORC.orc_data, 
    VEN.ven_id, 
    VEN.ven_data
FROM tb_orcamento ORC
INNER JOIN tb_venda VEN ON (VEN.ven_orc_id = ORC.orc_id)
WHERE ORC.orc_status = 'APROVADO';

-- 66. Itens de venda que não estavam no orçamento associado (ven_orc_id NOT NULL).
SELECT 
	VEN.ven_id, 
    PRO.pro_nome, 
    VEI.vei_quantidade, 
    VEI.vei_preco_unit
FROM tb_venda VEN
INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
INNER JOIN tb_produto PRO ON (PRO.pro_id = VEI.vei_pro_id)
LEFT JOIN tb_orcamento_item ORI ON 
	(
        ORI.ori_orc_id = VEN.ven_orc_id 
        AND ORI.ori_pro_id = VEI.vei_pro_id
    )
WHERE VEN.ven_orc_id IS NOT NULL
  AND ORI.ori_id IS NULL;

-- 67. Margem bruta estimada por venda usando último custo conhecido por produto.
SELECT 
	VEN.ven_id, 
  VEN.ven_data,
  SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto,
  SUM(
    VEI.vei_quantidade *
    (VEI.vei_preco_unit - (
      SELECT COI.coi_custo_unit
      FROM tb_compra_item COI
      INNER JOIN tb_compra COM ON (COM.com_id = COI.coi_com_id)
      WHERE COI.coi_pro_id = VEI.vei_pro_id
        AND COM.com_data <= VEN.ven_data
      ORDER BY 
        COM.com_data DESC, 
        COI.coi_id DESC
      LIMIT 1
    ))
  ) AS margem_bruta_estimada
FROM tb_venda VEN
INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
GROUP BY 
	VEN.ven_id, 
    VEN.ven_data
ORDER BY VEN.ven_data;

-- 68. Vendas com pagamento parcial (soma pagamentos < total da venda).
WITH venda_total AS 
    (
      SELECT 
        	VEN.ven_id, 
        	VEN.ven_data, 
        	VEN.ven_desconto,
            SUM(VEI.vei_quantidade * VEI.vei_preco_unit) AS total_bruto
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      GROUP BY 
        	VEN.ven_id, 
        	VEN.ven_data, 
        	VEN.ven_desconto
    ),
pagamento AS 
    (
      SELECT 
        	pag_ven_id AS ven_id, 
        	SUM(pag_valor) AS total_pago
      FROM tb_pagamento
      GROUP BY pag_ven_id
    )
SELECT 
	VEN.ven_id, 
    VEN.ven_data,
    (VET.total_bruto - VEN.ven_desconto) AS total_liquido,
    COALESCE(PAG.total_pago, 0) AS total_pago
FROM tb_venda VEN
INNER JOIN venda_total VET ON (VET.ven_id = VEN.ven_id)
LEFT JOIN pagamento PAG ON (PAG.ven_id = VEN.ven_id)
WHERE COALESCE(PAG.total_pago, 0) < (VET.total_bruto - VEN.ven_desconto);

-- 69. UNION PF x PJ padronizando nome_exibicao.
SELECT 
	cli_id, 
    'PF' AS tipo, 
    cli_razao_social AS nome_exibicao
FROM tb_cliente
WHERE cli_tipo = 1
UNION ALL
SELECT 
	cli_id, 
    'PJ' AS tipo, 
    COALESCE(cli_fantasia, cli_razao_social) AS nome_exibicao
FROM tb_cliente
WHERE cli_tipo = 2;

-- 70. Produtos com baixa rotação (não vendidos nos últimos 90 dias; FATURADA).
SELECT 
	PRO.pro_id, 
    PRO.pro_nome
FROM tb_produto PRO
WHERE NOT EXISTS 
    (
      SELECT 1
      FROM tb_venda VEN
      INNER JOIN tb_venda_item VEI ON (VEI.vei_ven_id = VEN.ven_id)
      WHERE VEN.ven_status = 'FATURADA'
        AND VEN.ven_data >= (CURDATE() - INTERVAL 90 DAY)
        AND VEI.vei_pro_id = PRO.pro_id
    );