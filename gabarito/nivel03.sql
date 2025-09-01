-- 21. Vendas com nome do cliente e do vendedor.
SELECT 
	VEN.ven_id, 
    VEN.ven_data, 
    CLI.cli_razao_social AS cliente, 
    FUN.fun_nome AS vendedor, 
    VEN.ven_status
FROM tb_venda VEN
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VEN.ven_cli_id)
INNER JOIN tb_funcionario FUN ON (FUN.fun_id = VEN.ven_fun_id);

-- 22. Itens de venda com pro_nome, prc_nome e umd_sigla.
SELECT 
	VEI.vei_ven_id, 
    PRO.pro_nome, 
    PRC.prc_nome, 
    UME.umd_sigla,
    VEI.vei_quantidade, 
    VEI.vei_preco_unit
FROM tb_venda_item VEI
INNER JOIN tb_produto PRO ON (PRO.pro_id = VEI.vei_pro_id)
INNER JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id)
INNER JOIN tb_unidade_medida UME ON (UME.umd_id = PRO.pro_umd_id);

-- 23. Compras com for_nome e quantidade total de itens.
SELECT 
	COM.com_id, 
    COM.com_data, 
    FRN.for_nome,
    SUM(COI.coi_quantidade) AS total_itens
FROM tb_compra COM
INNER JOIN tb_fornecedor FRN ON (FRN.for_id = COM.com_for_id)
INNER JOIN tb_compra_item COI ON (COI.coi_com_id = COM.com_id)
GROUP BY COM.com_id, COM.com_data, FRN.for_nome;

-- 24. Orçamentos com quantidade de itens e status.
SELECT 
	ORC.orc_id, 
    ORC.orc_data, 
    ORC.orc_status,
    COUNT(ORI.ori_id) AS itens
FROM tb_orcamento ORC
LEFT JOIN tb_orcamento_item ORI ON (ORI.ori_orc_id = ORC.orc_id)
GROUP BY ORC.orc_id, ORC.orc_data, ORC.orc_status;
-- Obs: o LEFT JOIN é usado nesse caso porque eu quero que ele traga inclusive orçamentos com zero itens, caso haja.

-- 25. Produtos com quantidade em estoque e nome da categoria.
SELECT 
	PRO.pro_id, 
    PRO.pro_nome, 
    PRC.prc_nome, 
    COALESCE(EST.est_quantidade,0) AS estoque
FROM tb_produto PRO
JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id)
LEFT JOIN tb_estoque EST ON (EST.est_pro_id = PRO.pro_id);
-- LEFT JOIN: garante que todos os produtos apareçam mesmo sem registro em tb_estoque;
--            quando não houver correspondência, as colunas de EST virão como NULL.
-- COALESCE(EST.est_quantidade, 0): função escalar que substitui NULL por 0.
--            Como est_quantidade é NOT NULL, o NULL só ocorre se não houver linha em tb_estoque.

-- 26. Vendas com valor bruto por ven_id.
SELECT 
	vei_ven_id AS ven_id,
    SUM(vei_quantidade * vei_preco_unit) AS total_bruto
FROM tb_venda_item
GROUP BY vei_ven_id;

-- 27. Vendas com valor líquido (bruto - ven_desconto).
-- Criei um CTA para trazer o total bruto de cada venda realizada
WITH valor_total_vendas AS 
(
  SELECT 
    	vei_ven_id AS ven_id,
        SUM(vei_quantidade * vei_preco_unit) AS total_bruto
  FROM tb_venda_item
  GROUP BY vei_ven_id
)
-- Um select usando o CTA criado pra calcular o total líquido de cada venda a partir do valor bruto
SELECT 
	VEN.ven_id, 
    VEN.ven_data, 
    VTV.total_bruto,
    (VTV.total_bruto - VEN.ven_desconto) AS total_liquido
FROM tb_venda VEN
INNER JOIN valor_total_vendas VTV ON (VTV.ven_id = VEN.ven_id);

-- 28. Pagamentos com forma, ven_id e cli_razao_social.
SELECT 
	PAG.pag_id, 
    PAG.pag_data, 
    PAG.pag_valor, 
    PAF.paf_descricao AS forma,
    VEN.ven_id, 
    CLI.cli_razao_social
FROM tb_pagamento PAG
INNER JOIN tb_pagamento_forma PAF ON (PAF.paf_id = PAG.pag_paf_id)
INNER JOIN tb_venda VEN ON (VEN.ven_id = PAG.pag_ven_id)
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VEN.ven_cli_id);

-- 29. Clientes PJ e quantidade de vendas (incluindo zero).
SELECT 
	CLI.cli_id, 
    COALESCE(CLI.cli_fantasia, CLI.cli_razao_social) AS cliente_pj,
    COUNT(VEN.ven_id) AS qtd_vendas
FROM tb_cliente CLI
LEFT JOIN tb_venda VEN ON (VEN.ven_cli_id = CLI.cli_id)
WHERE CLI.cli_tipo = 2
GROUP BY 
	CLI.cli_id, 
  cliente_pj;

-- 30. Vendedores com total vendido (somatório do bruto das vendas FATURADA).
WITH valor_total_vendas AS 
(
  SELECT 
    	vei_ven_id AS ven_id,
        SUM(vei_quantidade * vei_preco_unit) AS total_bruto
  FROM tb_venda_item
  GROUP BY vei_ven_id
)
SELECT 
	FUN.fun_id, 
    FUN.fun_nome,
    SUM(VTV.total_bruto) AS total_vendido
FROM tb_venda VEN
INNER JOIN valor_total_vendas VTV ON (VTV.ven_id = VEN.ven_id)
INNER JOIN tb_funcionario FUN ON (FUN.fun_id = VEN.ven_fun_id)
WHERE VEN.ven_status = 'FATURADA'
GROUP BY FUN.fun_id, FUN.fun_nome
ORDER BY total_vendido DESC;