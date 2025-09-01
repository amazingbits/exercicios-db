-- 1. Liste todos os clientes (todas as colunas).
SELECT * FROM tb_cliente;

-- 2. Liste cli_id, cli_razao_social, cli_data_cadastro ordenando por cli_data_cadastro desc.
SELECT 
	CLI.cli_id,
    CLI.cli_razao_social,
    CLI.cli_data_cadastro
FROM tb_cliente CLI
ORDER BY CLI.cli_data_cadastro DESC;

-- 3. Conte quantos clientes são Pessoa Física e quantos são Pessoa Jurídica (GROUP BY cli_tipo).
SELECT 
	CLT.clt_descricao,
    COUNT(*) AS clt_quantidade
FROM tb_cliente CLI
INNER JOIN tb_cliente_tipo CLT ON (CLI.cli_tipo = CLT.clt_id)
GROUP BY CLT.clt_descricao;

-- 4. pro_nome e pro_preco dos produtos ativos.
SELECT pro_nome, pro_preco
FROM tb_produto
WHERE pro_ativo = 1;

-- 5. pro_nome e prc_nome (categoria) de cada produto.
SELECT PRO.pro_nome, PRC.prc_nome
FROM tb_produto PRO
JOIN tb_produto_categoria PRC ON (PRO.pro_prc_id = PRC.prc_id);

-- 6. Todas as formas de pagamento.
SELECT * FROM tb_pagamento_forma;

-- 7. fun_nome, car_nome e fun_admissao dos funcionários.
SELECT FUN.fun_nome, CAR.car_nome, FUN.fun_admissao
FROM tb_funcionario FUN
JOIN tb_cargo CAR ON (CAR.car_id = FUN.fun_car_id);

-- 8. Fornecedores cadastrados há mais de 300 dias.
SELECT *
FROM tb_fornecedor
WHERE for_cadastro <= (CURDATE() - INTERVAL 300 DAY);

-- 9. Clientes cadastrados nos últimos 60 dias.
SELECT *
FROM tb_cliente
WHERE cli_data_cadastro >= (CURDATE() - INTERVAL 60 DAY);

-- 10. 10 produtos mais caros.
SELECT pro_nome, pro_preco
FROM tb_produto
ORDER BY pro_preco DESC
LIMIT 10;