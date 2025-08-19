# ERP Vidraçaria – Treinamento SQL (MariaDB/MySQL)
 
Ao todo são **80 exercícios**, de **8 níveis** (10 por nível), cobrindo `SELECT`, `JOIN`, `GROUP BY`, `HAVING`, **subqueries**, **CTEs**, **window functions**, `EXISTS`, `UNION`, **pivot simples** e **boas práticas**.

> **Stack:** MariaDB 10.11 + PhpMyAdmin (via Docker).  
> **Datas atemporais:** os inserts usam `CURDATE()`/`NOW()` com `INTERVAL`.

---

## 🚀 Como rodar

1) **Pré-requisitos**
- Docker e Docker Compose instalados.


2) **Subir ambiente**
```bash
docker-compose up -d
```

3) **Acessar**

- PhpMyAdmin: http://localhost:8080
- Server: mariadb
- Usuário: user
- Senha: user123
- Banco: db_empresa001

> Para resetar o banco (reimportar init.sql):
```bash
docker-compose down -v
docker-compose up -d
```

## 🧱 Modelo (principais tabelas)

- tb_cliente_tipo (clt_): PF / PJ
- tb_cliente (cli_): clientes com CPF/CNPJ
- tb_cargo (car_), tb_funcionario (fun_)
- tb_produto_categoria (prc_), tb_unidade_medida (umd_), tb_produto (pro_)
- tb_estoque (est_)
- tb_fornecedor (for_), tb_compra (com_), tb_compra_item (coi_)
- tb_orcamento (orc_), tb_orcamento_item (ori_)
- tb_venda (ven_), tb_venda_item (vei_)
- tb_pagamento_forma (paf_), tb_pagamento (pag_)

---


## Nível 1 — Básico (1 a 10)

1) Liste todos os clientes (todas as colunas).
2) Liste cli_id, cli_razao_social, cli_data_cadastro ordenando por cli_data_cadastro desc.
3) Conte quantos clientes são Pessoa Física e quantos são Pessoa Jurídica (GROUP BY cli_tipo).
4) Liste pro_nome e pro_preco dos produtos ativos (pro_ativo = 1).
5) Liste pro_nome e o nome da categoria (prc_nome) de cada produto.
6) Liste todas as formas de pagamento cadastradas.
7) Liste fun_nome, car_nome e fun_admissao de todos os funcionários.
8) Liste fornecedores cujo for_cadastro foi há mais de 300 dias.
9) Liste clientes cadastrados nos últimos 60 dias.
10) Liste os 10 produtos mais caros (por pro_preco desc).


## Nível 2 — Filtros & Ordenação (11 a 20)

11) Produtos da categoria "Espelho" com pro_preco entre 100 e 300 (inclusive).
12) Clientes PJ com CNPJ não nulo, ordenados por cli_fantasia (alfabético).
13) Vendas FATURADAS dos últimos 45 dias mostrando ven_id, ven_data, cli_razao_social.
14) Orçamentos APROVADO com orc_validade >= CURDATE().
15) Itens de venda com vei_quantidade > 2, exibindo valor_item = vei_quantidade * vei_preco_unit.
16) Compras do fornecedor "Alumínios & Ferragens" (com_id, com_data, com_observacao).
17) Produtos cujo pro_nome contém "Porta" ou "Janela".
18) Clientes cujo e-mail termina com "@empresa.com".
19) Orçamentos com status CANCELADO ou ABERTO nos últimos 60 dias.
20) Estoques com est_quantidade < 30.


## Nível 3 — JOINs essenciais (21 a 30)

21) Vendas com nome do cliente e do vendedor (JOIN tb_venda, tb_cliente, tb_funcionario).
22) Itens de venda com pro_nome, prc_nome (categoria) e umd_sigla (unidade).
23) Compras com for_nome e a quantidade total de itens por compra.
24) Orçamentos com a quantidade de itens por orçamento e o orc_status.
25) Produtos com quantidade em estoque e o nome da categoria.
26) Vendas com valor bruto por ven_id: SUM(vei_quantidade * vei_preco_unit).
27) Vendas com valor líquido (valor bruto menos ven_desconto).
28) Pagamentos com forma de pagamento, ven_id e cli_razao_social.
29) Clientes PJ e a quantidade de vendas de cada um (mesmo que zero; LEFT JOIN).
30) Vendedores com o total vendido (somatório do valor bruto de vendas FATURADA).


## Nível 4 — Agregações & HAVING (31 a 40)

31) Categorias com a média de preço dos produtos (AVG(pro_preco)), da maior para a menor.
32) Produtos com pro_preco acima da média de sua categoria (HAVING).
33) Clientes com mais de 2 vendas nos últimos 120 dias.
34) Vendedores cujo ticket médio (média por venda) > 900 nos últimos 90 dias.
35) Compras cujo total (SUM(coi_quantidade * coi_custo_unit)) seja > 3.000.
36) Top 5 produtos por valor vendido nos últimos 120 dias.
37) Top 5 produtos por quantidade vendida no mesmo período.
38) Top 3 clientes por valor total faturado (somar vendas FATURADA).
39) Total de descontos concedidos por vendedor nos últimos 90 dias.
40) Ticket médio por forma de pagamento nas vendas FATURADA dos últimos 60 dias.


## Nível 5 — Subqueries & CTEs (41 a 50)

41) Produtos cujo pro_preco é maior que a média geral de preços (subquery).
42) Clientes que nunca realizaram compras (NOT IN ou NOT EXISTS contra tb_venda).
43) Vendas cujo valor total é acima do ticket médio geral (subquery do ticket).
44) Para cada categoria, o produto mais caro (subquery correlacionada).
45) CTE para total por venda e filtrar apenas as > 1.500.
46) CTE para total comprado por fornecedor; mostre fornecedores com > 5.000.
47) CTE para saldo teórico de estoque por produto: saldo = estoque_atual - vendidos(120d) + comprados(120d).
48) Clientes cuja maior venda seja > 1.300.
49) Clientes cuja média por venda seja > 800 nos últimos 60 dias.
50) Produtos que nunca apareceram em orçamentos (NOT EXISTS com tb_orcamento_item).


## Nível 6 — Window Functions (51 a 60)

51) Vendas com total bruto e rank decrescente por total (RANK() ou DENSE_RANK()).
52) Para cada vendedor, vendas com soma acumulada do total (SUM(...) OVER (PARTITION BY ven_fun_id ORDER BY ven_data)).
53) Média móvel de 3 vendas (por vendedor) do total por venda.
54) Para cada cliente, classificar vendas em quartis por valor (NTILE(4)).
55) Dois itens mais caros de cada venda (ROW_NUMBER() particionado por vei_ven_id; manter apenas <= 2).
56) Para cada produto, pro_preco e preco_medio_categoria (média por categoria via window PARTITION BY categoria).
57) Para cada forma de pagamento, participação (%) no total faturado (SUM(...) OVER ()). 
58) Para cada vendedor, diferença entre a venda atual e a anterior (LAG()/LEAD()).
59) Mediana aproximada por vendedor via PERCENT_RANK() ou NTILE e explique a aproximação.
60) Para cada cliente, maior venda e um flag indicando se a última venda foi também a maior.


## Nível 7 — Técnicas avançadas (61 a 70)

61) Pivot simples: total faturado por forma de pagamento em colunas (PIX, CRÉDITO, DÉBITO, BOLETO, DINHEIRO) usando SUM(CASE WHEN ...).
62) Compare total de vendas dos últimos 30 dias vs 30 dias anteriores (duas CTEs + JOIN).
63) Produtos líderes: representam > 15% do faturamento total.
64) Ranking de clientes por LTV (soma de tudo que já comprou), do maior para o menor.
65) Orçamentos aprovados que viraram venda (JOIN tb_orcamento → tb_venda).
66) Itens de venda que não constavam no orçamento associado (quando ven_orc_id não é NULL).
67) Margem bruta estimada por venda usando custo do último coi_custo_unit conhecido por produto (subquery para custo).
68) Vendas com pagamento parcial (soma dos pagamentos < total da venda).
69) UNION entre clientes PF e PJ padronizando em nome_exibicao (PF: cli_razao_social; PJ: COALESCE(cli_fantasia, cli_razao_social)).
70) Produtos com baixa rotação (não vendidos nos últimos 90 dias).


## Nível 8 — Desafios (71 a 80)

71) Carrinho ideal por venda: para cada ven_id, gerar qtd_itens, qtd_categorias, ticket_medio_item, percentual_acessorios (participação da categoria Acessórios no valor).
72) Cesta de produtos: pares de produtos que aparecem juntos em pelo menos 3 vendas (self-join em tb_venda_item).
73) Conversão: taxa de orçamentos aprovados que viraram venda por vendedor.
74) Sazonalidade: total vendido por semana dos últimos 12 meses e a média por semana.
75) Efeito desconto: relação entre % desconto médio e ticket médio por vendedor; observe correlação aproximada (normalização simples).
76) Mix por categoria (PJ): participação de cada categoria no faturamento dos clientes PJ.
77) Preço × Rotatividade: produtos acima da média de preço da categoria e acima da mediana de quantidade vendida (últimos 120 dias).
78) RFM (PF): classifique Recência, Frequência e Valor (1–5 via NTILE) e gere um score combinado.
79) Esteira compra→venda: relacione compras (últimos 30 dias) e vendas do mesmo pro_id, calculando lead time médio.
80) Break-even estimado (60 dias): total_liquido = total_bruto - ven_desconto; estime custo pelo último coi_custo_unit; indique acima/abaixo do break-even com margem de 20%.