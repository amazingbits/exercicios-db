-- 11. Espelho com preço entre 100 e 300.
SELECT PRO.pro_nome, PRO.pro_preco
FROM tb_produto PRO
JOIN tb_produto_categoria PRC ON (PRC.prc_id = PRO.pro_prc_id)
WHERE PRC.prc_nome = 'Espelho'
AND PRO.pro_preco BETWEEN 100 AND 300;

-- 12. Clientes PJ com CNPJ não nulo, ordenados por fantasia.
SELECT 
	cli_id, 
    cli_fantasia, 
    cli_razao_social, 
    cli_cnpj
FROM tb_cliente
WHERE cli_tipo = 2
AND cli_cnpj IS NOT NULL
ORDER BY cli_fantasia;

-- 13. Vendas FATURADAS dos últimos 45 dias mostrando ven_id, ven_data, cli_razao_social.
SELECT 
	VEN.ven_id, 
    VEN.ven_data, 
    CLI.cli_razao_social
FROM tb_venda VEN
INNER JOIN tb_cliente CLI ON (CLI.cli_id = VEN.ven_cli_id)
WHERE 
	VEN.ven_status = 'FATURADA'
  	AND VEN.ven_data >= (CURDATE() - INTERVAL 45 DAY)
ORDER BY VEN.ven_data DESC;

-- 14. Orçamentos APROVADO com validade >= hoje.
SELECT *
FROM tb_orcamento
WHERE orc_status = 'APROVADO'
AND orc_validade >= CURDATE();

-- 15. Itens de venda com vei_quantidade > 2, exibindo valor_item = vei_quantidade * vei_preco_unit.
SELECT 
    vei_id, vei_ven_id, 
    vei_pro_id, vei_quantidade, 
    vei_preco_unit,
    (vei_quantidade * vei_preco_unit) AS valor_item
FROM tb_venda_item
WHERE vei_quantidade > 2;

-- 16. Compras do fornecedor "Alumínios & Ferragens".
SELECT 
	COM.com_id, 
    COM.com_data, 
    COM.com_observacao
FROM tb_compra COM
JOIN tb_fornecedor FRN ON (FRN.for_id = COM.com_for_id)
WHERE FRN.for_nome = 'Alumínios & Ferragens';

-- 17. Produtos cujo nome contém "Porta" OU "Janela".
SELECT *
FROM tb_produto
WHERE pro_nome LIKE '%Porta%'
OR pro_nome LIKE '%Janela%';

-- 18. Clientes cujo e-mail termina com "@empresa.com".
SELECT *
FROM tb_cliente
WHERE cli_email LIKE '%@empresa.com';

-- 19. Orçamentos CANCELADO ou ABERTO nos últimos 60 dias.
SELECT *
FROM tb_orcamento
WHERE orc_status IN ('CANCELADO','ABERTO')
AND orc_data >= (CURDATE() - INTERVAL 60 DAY);

-- 20. Estoques com quantidade < 30.
SELECT *
FROM tb_estoque
WHERE est_quantidade < 30;