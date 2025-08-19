-- Recria o banco do zero
DROP DATABASE IF EXISTS db_empresa001;
CREATE DATABASE db_empresa001 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_empresa001;

-- ===============================
-- Tabelas de apoio / cadastros
-- ===============================

-- Tipo de Cliente
CREATE TABLE tb_cliente_tipo (
  clt_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  clt_descricao VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO tb_cliente_tipo (clt_descricao) VALUES
  ('Pessoa física'),
  ('Pessoa jurídica');

-- Forma de Pagamento
CREATE TABLE tb_pagamento_forma (
  paf_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  paf_descricao VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO tb_pagamento_forma (paf_descricao) VALUES
  ('Dinheiro'),
  ('Cartão Crédito'),
  ('Cartão Débito'),
  ('PIX'),
  ('Boleto');

-- Cargos
CREATE TABLE tb_cargo (
  car_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  car_nome VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO tb_cargo (car_nome) VALUES
  ('Vendedor'),
  ('Instalador'),
  ('Gerente');

-- Funcionários
CREATE TABLE tb_funcionario (
  fun_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fun_car_id BIGINT UNSIGNED NOT NULL,
  fun_nome VARCHAR(150) NOT NULL,
  fun_email VARCHAR(150),
  fun_admissao DATE NOT NULL DEFAULT (CURDATE() - INTERVAL 365 DAY),
  CONSTRAINT fk_fun_cargo FOREIGN KEY (fun_car_id) REFERENCES tb_cargo(car_id)
) ENGINE=InnoDB;

INSERT INTO tb_funcionario (fun_car_id, fun_nome, fun_email, fun_admissao) VALUES
  (1, 'Carlos Vendedor', 'carlos@empresa.com', CURDATE() - INTERVAL 500 DAY),
  (1, 'Aline Vendedora', 'aline@empresa.com', CURDATE() - INTERVAL 420 DAY),
  (1, 'Rafael Vendedor', 'rafael@empresa.com', CURDATE() - INTERVAL 280 DAY),
  (2, 'Diego Instalador', 'diego@empresa.com', CURDATE() - INTERVAL 300 DAY),
  (2, 'Priscila Instaladora', 'priscila@empresa.com', CURDATE() - INTERVAL 220 DAY),
  (2, 'Bruno Instalador', 'bruno@empresa.com', CURDATE() - INTERVAL 180 DAY),
  (3, 'Fernanda Gerente', 'fernanda@empresa.com', CURDATE() - INTERVAL 600 DAY),
  (3, 'Gustavo Subgerente', 'gustavo@empresa.com', CURDATE() - INTERVAL 400 DAY);

-- Clientes
CREATE TABLE tb_cliente (
  cli_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cli_tipo BIGINT UNSIGNED NOT NULL,
  cli_fantasia VARCHAR(150),
  cli_razao_social VARCHAR(150),
  cli_cnpj VARCHAR(18),
  cli_cpf VARCHAR(14),
  cli_email VARCHAR(150),
  cli_telefone VARCHAR(30),
  cli_data_cadastro DATE NOT NULL DEFAULT (CURDATE()),
  CONSTRAINT fk_cli_tipo FOREIGN KEY (cli_tipo) REFERENCES tb_cliente_tipo(clt_id),
  CONSTRAINT uq_cli_cnpj UNIQUE (cli_cnpj),
  CONSTRAINT uq_cli_cpf UNIQUE (cli_cpf)
) ENGINE=InnoDB;

-- 20 clientes (12 PF, 8 PJ)
INSERT INTO tb_cliente (cli_tipo, cli_fantasia, cli_razao_social, cli_cnpj, cli_cpf, cli_email, cli_telefone, cli_data_cadastro) VALUES
  -- PF
  (1, NULL, 'João da Silva', NULL, '123.456.789-00', 'joao@email.com', '(48) 99999-0001', CURDATE() - INTERVAL 300 DAY),
  (1, NULL, 'Maria Oliveira', NULL, '987.654.321-00', 'maria@email.com', '(48) 99999-0002', CURDATE() - INTERVAL 290 DAY),
  (1, NULL, 'Pedro Santos', NULL, '111.222.333-44', 'pedro@email.com', '(48) 99999-0003', CURDATE() - INTERVAL 200 DAY),
  (1, NULL, 'Ana Costa', NULL, '222.333.444-55', 'ana@email.com', '(48) 99999-0004', CURDATE() - INTERVAL 120 DAY),
  (1, NULL, 'Lucas Rocha', NULL, '333.444.555-66', 'lucas@email.com', '(48) 99999-0005', CURDATE() - INTERVAL 90 DAY),
  (1, NULL, 'Paula Souza', NULL, '444.555.666-77', 'paula@email.com', '(48) 99999-0006', CURDATE() - INTERVAL 60 DAY),
  (1, NULL, 'Ricardo Lima', NULL, '555.666.777-88', 'ricardo@email.com', '(48) 99999-0007', CURDATE() - INTERVAL 45 DAY),
  (1, NULL, 'Juliana Alves', NULL, '666.777.888-99', 'juliana@email.com', '(48) 99999-0008', CURDATE() - INTERVAL 30 DAY),
  (1, NULL, 'Felipe Martins', NULL, '777.888.999-00', 'felipe@email.com', '(48) 99999-0009', CURDATE() - INTERVAL 15 DAY),
  (1, NULL, 'Carolina Dias', NULL, '888.999.000-11', 'carolina@email.com', '(48) 99999-0010', CURDATE() - INTERVAL 7 DAY),
  (1, NULL, 'André Pereira', NULL, '999.000.111-22', 'andre@email.com', '(48) 99999-0011', CURDATE() - INTERVAL 3 DAY),
  (1, NULL, 'Vanessa Nunes', NULL, '000.111.222-33', 'vanessa@email.com', '(48) 99999-0012', CURDATE()),
  -- PJ
  (2, 'Vidros Alpha',      'Vidros Alpha Ltda',      '12.345.678/0001-99', NULL, 'contato@alpha.com', '(48) 3222-1001', CURDATE() - INTERVAL 400 DAY),
  (2, 'Glass Beta',        'Glass Beta ME',          '98.765.432/0001-11', NULL, 'contato@beta.com',  '(48) 3222-1002', CURDATE() - INTERVAL 360 DAY),
  (2, 'Espelharia Gamma',  'Espelhos Gamma EIRELI',  '45.123.789/0001-55', NULL, 'contato@gamma.com', '(48) 3222-1003', CURDATE() - INTERVAL 250 DAY),
  (2, 'Temperados Delta',  'Temperados Delta Ltda',  '11.222.333/0001-44', NULL, 'contato@delta.com', '(48) 3222-1004', CURDATE() - INTERVAL 200 DAY),
  (2, 'Box Banho Epsilon', 'Epsilon Soluções ME',    '22.333.444/0001-77', NULL, 'contato@epsilon.com','(48) 3222-1005', CURDATE() - INTERVAL 150 DAY),
  (2, 'Espelhos Zeta',     'Zeta Glass Ltda',        '33.444.555/0001-88', NULL, 'contato@zeta.com',  '(48) 3222-1006', CURDATE() - INTERVAL 100 DAY),
  (2, 'Janelas Ômega',     'Ômega Alumínios SA',     '44.555.666/0001-99', NULL, 'contato@omega.com', '(48) 3222-1007', CURDATE() - INTERVAL 80 DAY),
  (2, 'Portas Sigma',      'Sigma Esquadrias Ltda',  '55.666.777/0001-00', NULL, 'contato@sigma.com', '(48) 3222-1008', CURDATE() - INTERVAL 40 DAY);

-- Categorias de Produto
CREATE TABLE tb_produto_categoria (
  prc_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  prc_nome VARCHAR(120) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO tb_produto_categoria (prc_nome) VALUES
  ('Vidro Temperado'),
  ('Vidro Laminado'),
  ('Espelho'),
  ('Ferragens'),
  ('Box de Banheiro'),
  ('Janelas'),
  ('Portas'),
  ('Guarda-corpo'),
  ('Acessórios'),
  ('Manutenção');

-- Unidades de Medida
CREATE TABLE tb_unidade_medida (
  umd_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  umd_sigla VARCHAR(10) NOT NULL UNIQUE,
  umd_descricao VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

INSERT INTO tb_unidade_medida (umd_sigla, umd_descricao) VALUES
  ('m2', 'Metro quadrado'),
  ('un', 'Unidade'),
  ('m',  'Metro linear'),
  ('kg', 'Quilograma');

-- Fornecedores
CREATE TABLE tb_fornecedor (
  for_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  for_nome VARCHAR(150) NOT NULL,
  for_cnpj VARCHAR(18) UNIQUE,
  for_email VARCHAR(150),
  for_telefone VARCHAR(30),
  for_cadastro DATE NOT NULL DEFAULT (CURDATE() - INTERVAL 365 DAY)
) ENGINE=InnoDB;

INSERT INTO tb_fornecedor (for_nome, for_cnpj, for_email, for_telefone, for_cadastro) VALUES
  ('Fornecedor Temperados Sul', '10.111.222/0001-33', 'contato@temppersul.com', '(48) 3333-1111', CURDATE() - INTERVAL 600 DAY),
  ('Espelharia Central',        '20.222.333/0001-44', 'contato@espcentral.com', '(48) 3333-2222', CURDATE() - INTERVAL 500 DAY),
  ('Alumínios & Ferragens',     '30.333.444/0001-55', 'contato@aluferr.com',    '(48) 3333-3333', CURDATE() - INTERVAL 450 DAY),
  ('Boxes Premium',             '40.444.555/0001-66', 'contato@boxespremium.com','(48) 3333-4444', CURDATE() - INTERVAL 420 DAY),
  ('Acessórios Vidro Mais',     '50.555.666/0001-77', 'contato@vidromais.com',  '(48) 3333-5555', CURDATE() - INTERVAL 380 DAY);

-- Produtos
CREATE TABLE tb_produto (
  pro_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pro_prc_id BIGINT UNSIGNED NOT NULL,
  pro_umd_id BIGINT UNSIGNED NOT NULL,
  pro_nome VARCHAR(150) NOT NULL,
  pro_codigo VARCHAR(50) NOT NULL UNIQUE,
  pro_preco DECIMAL(10,2) NOT NULL,
  pro_ativo TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_pro_categoria FOREIGN KEY (pro_prc_id) REFERENCES tb_produto_categoria(prc_id),
  CONSTRAINT fk_pro_unidade   FOREIGN KEY (pro_umd_id) REFERENCES tb_unidade_medida(umd_id)
) ENGINE=InnoDB;

INSERT INTO tb_produto (pro_prc_id, pro_umd_id, pro_nome, pro_codigo, pro_preco) VALUES
  (1, 1, 'Vidro Temperado 8mm Incolor',      'VT8INC',   320.00),
  (1, 1, 'Vidro Temperado 8mm Verde',        'VT8VER',   345.00),
  (1, 1, 'Vidro Temperado 10mm Incolor',     'VT10INC',  420.00),
  (2, 1, 'Vidro Laminado 4+4 Incolor',       'VL44INC',  280.00),
  (2, 1, 'Vidro Laminado 6+6 Incolor',       'VL66INC',  390.00),
  (3, 1, 'Espelho Prata 4mm',                'ESP4P',    210.00),
  (3, 1, 'Espelho Bronze 4mm',               'ESP4B',    230.00),
  (4, 2, 'Dobradiça p/ Box Inox',            'FERRDOB',  85.00),
  (4, 2, 'Puxador Tubular 40cm Inox',        'FERRPUX',  120.00),
  (5, 2, 'Kit Box de Correr 2 Folhas 8mm',   'BOX2F',    950.00),
  (6, 2, 'Janela Alumínio Linha 25 (1,20m)', 'JAN25',    680.00),
  (7, 2, 'Porta Temperada Pivotante',        'PORTPIV',  1300.00),
  (8, 1, 'Guarda-corpo Temperado 10mm',      'GCT10',    530.00),
  (9, 2, 'Ventosa Dupla 100kg',              'ACEV100',  190.00),
  (9, 2, 'Silicone Neutro Incolor 280g',     'ACESILI',  35.00),
  (10,2, 'Visita Técnica Manutenção',        'MANVIS',   120.00),
  (10,2, 'Troca de Dobradiça',               'MANTDOB',  160.00),
  (10,2, 'Ajuste de Roldanas',               'MANROL',   140.00);

-- Estoque
CREATE TABLE tb_estoque (
  est_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  est_pro_id BIGINT UNSIGNED NOT NULL,
  est_quantidade INT NOT NULL DEFAULT 0,
  est_ultimo_movimento DATE NOT NULL DEFAULT (CURDATE()),
  CONSTRAINT fk_est_prod FOREIGN KEY (est_pro_id) REFERENCES tb_produto(pro_id),
  CONSTRAINT uq_est_prod UNIQUE (est_pro_id)
) ENGINE=InnoDB;

INSERT INTO tb_estoque (est_pro_id, est_quantidade, est_ultimo_movimento) VALUES
  (1,  80,  CURDATE() - INTERVAL 40 DAY),
  (2,  60,  CURDATE() - INTERVAL 35 DAY),
  (3,  50,  CURDATE() - INTERVAL 32 DAY),
  (4,  70,  CURDATE() - INTERVAL 30 DAY),
  (5,  55,  CURDATE() - INTERVAL 25 DAY),
  (6,  90,  CURDATE() - INTERVAL 20 DAY),
  (7,  65,  CURDATE() - INTERVAL 18 DAY),
  (8,  150, CURDATE() - INTERVAL 15 DAY),
  (9,  120, CURDATE() - INTERVAL 12 DAY),
  (10, 25,  CURDATE() - INTERVAL 10 DAY),
  (11, 22,  CURDATE() - INTERVAL 9 DAY),
  (12, 12,  CURDATE() - INTERVAL 8 DAY),
  (13, 18,  CURDATE() - INTERVAL 7 DAY),
  (14, 30,  CURDATE() - INTERVAL 6 DAY),
  (15, 200, CURDATE() - INTERVAL 5 DAY),
  (16, 40,  CURDATE() - INTERVAL 4 DAY),
  (17, 35,  CURDATE() - INTERVAL 4 DAY);

-- Compras (entrada de estoque)
CREATE TABLE tb_compra (
  com_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  com_for_id BIGINT UNSIGNED NOT NULL,
  com_data DATE NOT NULL DEFAULT (CURDATE()),
  com_observacao VARCHAR(255),
  CONSTRAINT fk_com_for FOREIGN KEY (com_for_id) REFERENCES tb_fornecedor(for_id)
) ENGINE=InnoDB;

CREATE TABLE tb_compra_item (
  coi_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  coi_com_id BIGINT UNSIGNED NOT NULL,
  coi_pro_id BIGINT UNSIGNED NOT NULL,
  coi_quantidade INT NOT NULL,
  coi_custo_unit DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_coi_com FOREIGN KEY (coi_com_id) REFERENCES tb_compra(com_id),
  CONSTRAINT fk_coi_pro FOREIGN KEY (coi_pro_id) REFERENCES tb_produto(pro_id)
) ENGINE=InnoDB;

-- 10 compras distribuídas no tempo
INSERT INTO tb_compra (com_for_id, com_data, com_observacao) VALUES
  (1, CURDATE() - INTERVAL 120 DAY, 'Reposição de temperados'),
  (2, CURDATE() - INTERVAL 95 DAY,  'Lotes de espelhos'),
  (3, CURDATE() - INTERVAL 80 DAY,  'Ferragens variadas'),
  (4, CURDATE() - INTERVAL 75 DAY,  'Kits de box'),
  (1, CURDATE() - INTERVAL 60 DAY,  'Vidro 10mm alta demanda'),
  (2, CURDATE() - INTERVAL 45 DAY,  'Espelho bronze'),
  (3, CURDATE() - INTERVAL 30 DAY,  'Puxadores e dobradiças'),
  (5, CURDATE() - INTERVAL 25 DAY,  'Acessórios'),
  (1, CURDATE() - INTERVAL 15 DAY,  'Temperados incolor'),
  (4, CURDATE() - INTERVAL 10 DAY,  'Kits e roldanas');

INSERT INTO tb_compra_item (coi_com_id, coi_pro_id, coi_quantidade, coi_custo_unit) VALUES
  (1, 1,  40, 260.00), (1, 3,  20, 360.00),
  (2, 6,  50, 160.00), (2, 7,  30, 175.00),
  (3, 8,  60,  65.00), (3, 9,  40,  90.00),
  (4, 10, 10, 780.00),
  (5, 3,  30, 360.00), (5, 13, 10, 420.00),
  (6, 7,  35, 180.00),
  (7, 9,  25,  95.00), (7, 8,  35,  70.00),
  (8, 14, 60, 150.00), (8, 15, 80,  20.00),
  (9, 1,  30, 250.00), (9, 2,  20, 270.00),
  (10,10, 12, 800.00), (10,17, 10, 120.00);

-- Orçamentos
CREATE TABLE tb_orcamento (
  orc_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  orc_cli_id BIGINT UNSIGNED NOT NULL,
  orc_fun_id BIGINT UNSIGNED NOT NULL, -- vendedor responsável
  orc_data DATE NOT NULL DEFAULT (CURDATE()),
  orc_status ENUM('ABERTO','APROVADO','CANCELADO') NOT NULL DEFAULT 'ABERTO',
  orc_validade DATE NOT NULL DEFAULT (CURDATE() + INTERVAL 30 DAY),
  orc_observacao VARCHAR(255),
  CONSTRAINT fk_orc_cli FOREIGN KEY (orc_cli_id) REFERENCES tb_cliente(cli_id),
  CONSTRAINT fk_orc_fun FOREIGN KEY (orc_fun_id) REFERENCES tb_funcionario(fun_id)
) ENGINE=InnoDB;

CREATE TABLE tb_orcamento_item (
  ori_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ori_orc_id BIGINT UNSIGNED NOT NULL,
  ori_pro_id BIGINT UNSIGNED NOT NULL,
  ori_quantidade DECIMAL(10,2) NOT NULL,
  ori_preco_unit DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_ori_orc FOREIGN KEY (ori_orc_id) REFERENCES tb_orcamento(orc_id),
  CONSTRAINT fk_ori_pro FOREIGN KEY (ori_pro_id) REFERENCES tb_produto(pro_id)
) ENGINE=InnoDB;

-- 24 orçamentos com datas distribuídas
INSERT INTO tb_orcamento (orc_cli_id, orc_fun_id, orc_data, orc_status, orc_validade, orc_observacao) VALUES
  (1, 1,  CURDATE() - INTERVAL 150 DAY, 'APROVADO', CURDATE() - INTERVAL 120 DAY, 'Box banheiro incolor'),
  (2, 2,  CURDATE() - INTERVAL 140 DAY, 'CANCELADO',CURDATE() - INTERVAL 110 DAY, 'Espelho corredor'),
  (3, 1,  CURDATE() - INTERVAL 110 DAY, 'APROVADO', CURDATE() - INTERVAL 80 DAY,  'Guarda-corpo'),
  (4, 2,  CURDATE() - INTERVAL 100 DAY, 'ABERTO',   CURDATE() - INTERVAL 70 DAY, 'Vidro laminado'),
  (5, 3,  CURDATE() - INTERVAL 90 DAY,  'APROVADO', CURDATE() - INTERVAL 60 DAY, 'Janela linha 25'),
  (6, 1,  CURDATE() - INTERVAL 80 DAY,  'APROVADO', CURDATE() - INTERVAL 50 DAY, 'Porta pivotante'),
  (7, 2,  CURDATE() - INTERVAL 70 DAY,  'ABERTO',   CURDATE() - INTERVAL 40 DAY, 'Vidro temperado 10mm'),
  (8, 3,  CURDATE() - INTERVAL 65 DAY,  'CANCELADO',CURDATE() - INTERVAL 35 DAY, 'Espelho bronze'),
  (9, 1,  CURDATE() - INTERVAL 60 DAY,  'APROVADO', CURDATE() - INTERVAL 30 DAY, 'Box 2 folhas'),
  (10,2,  CURDATE() - INTERVAL 55 DAY,  'ABERTO',   CURDATE() - INTERVAL 25 DAY, 'Ferragens diversas'),
  (11,1,  CURDATE() - INTERVAL 50 DAY,  'APROVADO', CURDATE() - INTERVAL 20 DAY, 'Guarda-corpo'),
  (12,2,  CURDATE() - INTERVAL 45 DAY,  'CANCELADO',CURDATE() - INTERVAL 15 DAY, 'Espelho 4mm'),
  (13,1,  CURDATE() - INTERVAL 40 DAY,  'APROVADO', CURDATE() - INTERVAL 10 DAY, 'Porta temperada'),
  (14,1,  CURDATE() - INTERVAL 35 DAY,  'ABERTO',   CURDATE() - INTERVAL 5 DAY,  'Box e acessórios'),
  (15,2,  CURDATE() - INTERVAL 30 DAY,  'APROVADO', CURDATE(),                   'Janela + vidro'),
  (16,3,  CURDATE() - INTERVAL 25 DAY,  'APROVADO', CURDATE() + INTERVAL 5 DAY,  'Espelho banheiro'),
  (17,1,  CURDATE() - INTERVAL 22 DAY,  'ABERTO',   CURDATE() + INTERVAL 8 DAY,  'Guarda-corpo escada'),
  (18,2,  CURDATE() - INTERVAL 20 DAY,  'APROVADO', CURDATE() + INTERVAL 10 DAY, 'Kit box'),
  (19,3,  CURDATE() - INTERVAL 18 DAY,  'APROVADO', CURDATE() + INTERVAL 12 DAY, 'Porta pivotante'),
  (20,1,  CURDATE() - INTERVAL 15 DAY,  'ABERTO',   CURDATE() + INTERVAL 15 DAY, 'Espelho grande'),
  (4, 2,  CURDATE() - INTERVAL 12 DAY,  'APROVADO', CURDATE() + INTERVAL 18 DAY, 'Vidro laminado'),
  (5, 1,  CURDATE() - INTERVAL 10 DAY,  'APROVADO', CURDATE() + INTERVAL 20 DAY, 'Janela e ferragens'),
  (6, 2,  CURDATE() - INTERVAL 7 DAY,   'ABERTO',   CURDATE() + INTERVAL 23 DAY, 'Porta + puxador'),
  (7, 3,  CURDATE() - INTERVAL 3 DAY,   'ABERTO',   CURDATE() + INTERVAL 27 DAY, 'Vidro 8mm verde');

-- Itens de orçamento (2~3 por orçamento)
INSERT INTO tb_orcamento_item (ori_orc_id, ori_pro_id, ori_quantidade, ori_preco_unit) VALUES
  (1, 10, 1,   950.00), (1, 8,  2,   85.00),
  (2,  6, 2.5, 210.00),
  (3, 13, 3.2, 530.00),
  (4,  5, 4.1, 390.00),
  (5, 11, 2,   680.00),
  (6, 12, 1,  1300.00), (6, 9, 1, 120.00),
  (7,  3, 2.2, 420.00),
  (8,  7, 3.0, 230.00),
  (9, 10, 1,   950.00), (9, 9, 1, 120.00),
  (10,8,  4,    85.00), (10,9, 2, 120.00),
  (11,13, 2.5, 530.00),
  (12,6,  2.0, 210.00), (12,15,3,  35.00),
  (13,12, 1,  1300.00), (13,8,  2,  85.00),
  (14,10, 1,   950.00), (14,15,2,  35.00),
  (15,11, 1,   680.00), (15,1, 1.5, 320.00),
  (16,6,  2.8, 210.00),
  (17,13, 3.0, 530.00),
  (18,10, 1,   950.00),
  (19,12, 1,  1300.00), (19,9,  1, 120.00),
  (20,6,  4.2, 210.00),
  (21,5,  3.1, 390.00),
  (22,12, 1,  1300.00),
  (23,3,  1.7, 420.00),
  (24,2,  2.3, 345.00);

-- Vendas
CREATE TABLE tb_venda (
  ven_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ven_cli_id BIGINT UNSIGNED NOT NULL,
  ven_fun_id BIGINT UNSIGNED NOT NULL,
  ven_orc_id BIGINT UNSIGNED NULL,
  ven_data DATE NOT NULL DEFAULT (CURDATE()),
  ven_status ENUM('ABERTA','FATURADA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
  ven_desconto DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  ven_observacao VARCHAR(255),
  CONSTRAINT fk_ven_cli FOREIGN KEY (ven_cli_id) REFERENCES tb_cliente(cli_id),
  CONSTRAINT fk_ven_fun FOREIGN KEY (ven_fun_id) REFERENCES tb_funcionario(fun_id),
  CONSTRAINT fk_ven_orc FOREIGN KEY (ven_orc_id) REFERENCES tb_orcamento(orc_id)
) ENGINE=InnoDB;

CREATE TABLE tb_venda_item (
  vei_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vei_ven_id BIGINT UNSIGNED NOT NULL,
  vei_pro_id BIGINT UNSIGNED NOT NULL,
  vei_quantidade DECIMAL(10,2) NOT NULL,
  vei_preco_unit DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_vei_ven FOREIGN KEY (vei_ven_id) REFERENCES tb_venda(ven_id),
  CONSTRAINT fk_vei_pro FOREIGN KEY (vei_pro_id) REFERENCES tb_produto(pro_id)
) ENGINE=InnoDB;

-- 20 vendas distribuídas
INSERT INTO tb_venda (ven_cli_id, ven_fun_id, ven_orc_id, ven_data, ven_status, ven_desconto, ven_observacao) VALUES
  (1, 1,  1,  CURDATE() - INTERVAL 110 DAY, 'FATURADA',  50.00, 'Venda oriunda orçamento #1'),
  (3, 1,  3,  CURDATE() - INTERVAL 98 DAY,  'FATURADA',   0.00, 'Guarda-corpo'),
  (5, 3,  5,  CURDATE() - INTERVAL 85 DAY,  'FATURADA',  20.00, 'Janela'),
  (6, 1,  6,  CURDATE() - INTERVAL 75 DAY,  'FATURADA',   0.00, 'Porta pivotante'),
  (9, 2,  9,  CURDATE() - INTERVAL 55 DAY,  'FATURADA',   0.00, 'Box 2 folhas'),
  (11,1, 11,  CURDATE() - INTERVAL 48 DAY,  'FATURADA',  30.00, 'Guarda-corpo'),
  (13,1, 13,  CURDATE() - INTERVAL 37 DAY,  'FATURADA',   0.00, 'Porta temperada'),
  (15,2, 15,  CURDATE() - INTERVAL 27 DAY,  'FATURADA',  15.00, 'Janela + vidro'),
  (16,1, 16,  CURDATE() - INTERVAL 22 DAY,  'FATURADA',   0.00, 'Espelho banheiro'),
  (18,3, 18,  CURDATE() - INTERVAL 17 DAY,  'FATURADA',   0.00, 'Kit box'),
  (19,1, 19,  CURDATE() - INTERVAL 14 DAY,  'FATURADA',   0.00, 'Porta pivotante'),
  (20,2, NULL, CURDATE() - INTERVAL 12 DAY, 'ABERTA',     0.00, 'Espelho grande sob medida'),
  (4, 2, 21,  CURDATE() - INTERVAL 10 DAY,  'FATURADA',  25.00, 'Vidro laminado'),
  (5, 1, 22,  CURDATE() - INTERVAL 8 DAY,   'FATURADA',   0.00, 'Janela e ferragens'),
  (6, 2, NULL, CURDATE() - INTERVAL 6 DAY,  'ABERTA',     0.00, 'Porta + puxador'),
  (7, 3, NULL, CURDATE() - INTERVAL 5 DAY,  'ABERTA',     0.00, 'Vidro 8mm verde'),
  (8, 1, NULL, CURDATE() - INTERVAL 4 DAY,  'FATURADA',  10.00, 'Espelho grande'),
  (10,1, NULL, CURDATE() - INTERVAL 3 DAY,  'FATURADA',   0.00, 'Ferragens'),
  (12,2, NULL, CURDATE() - INTERVAL 2 DAY,  'FATURADA',   0.00, 'Espelho e silicone'),
  (2,  1, NULL, CURDATE() - INTERVAL 1 DAY, 'FATURADA',   0.00, 'Box + instalação');

-- Itens das vendas (2~4 por venda)
INSERT INTO tb_venda_item (vei_ven_id, vei_pro_id, vei_quantidade, vei_preco_unit) VALUES
  (1, 10, 1,   950.00), (1, 8,  2,   85.00),
  (2, 13, 3.2, 530.00),
  (3, 11, 1,   680.00), (3, 1,  1.2, 320.00),
  (4, 12, 1,  1300.00), (4, 9,  1,  120.00),
  (5, 10, 1,   950.00), (5, 9,  1,  120.00),
  (6, 13, 2.5, 530.00),
  (7, 12, 1,  1300.00), (7, 8,  2,   85.00),
  (8, 11, 1,   680.00), (8, 3,  1.0, 420.00),
  (9, 6,  2.2, 210.00), (9, 15, 3,   35.00),
  (10,10, 1,   950.00),
  (11,12, 1,  1300.00), (11,9,  1,  120.00),
  (12,6,  4.0, 210.00),
  (13,5,  3.1, 390.00),
  (14,12, 1,  1300.00), (14,8,  1,   85.00),
  (15,12, 1,  1300.00), (15,9,  1,  120.00),
  (16,2,  2.0, 345.00), (16,8,  2,   85.00),
  (17,6,  3.5, 210.00), (17,15, 2,   35.00),
  (18,8,  3,    85.00), (18,9,  2,  120.00),
  (19,6,  2.0, 210.00), (19,15, 2,   35.00),
  (20,10, 1,   950.00), (20,16, 1,  120.00);

-- Pagamentos
CREATE TABLE tb_pagamento (
  pag_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pag_ven_id BIGINT UNSIGNED NOT NULL,
  pag_paf_id BIGINT UNSIGNED NOT NULL,
  pag_data DATE NOT NULL DEFAULT (CURDATE()),
  pag_valor DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_pag_ven FOREIGN KEY (pag_ven_id) REFERENCES tb_venda(ven_id),
  CONSTRAINT fk_pag_paf FOREIGN KEY (pag_paf_id) REFERENCES tb_pagamento_forma(paf_id)
) ENGINE=InnoDB;

-- Pagamentos (alguns parcelados, alguns à vista)
INSERT INTO tb_pagamento (pag_ven_id, pag_paf_id, pag_data, pag_valor) VALUES
  (1, 4,  CURDATE() - INTERVAL 109 DAY,  1000.00),
  (2, 2,  CURDATE() - INTERVAL 97 DAY,   1696.00),
  (3, 1,  CURDATE() - INTERVAL 84 DAY,    980.00),
  (4, 2,  CURDATE() - INTERVAL 74 DAY,   1420.00),
  (5, 4,  CURDATE() - INTERVAL 54 DAY,   1070.00),
  (6, 1,  CURDATE() - INTERVAL 47 DAY,   1295.00),
  (7, 2,  CURDATE() - INTERVAL 36 DAY,   1470.00),
  (8, 5,  CURDATE() - INTERVAL 26 DAY,    965.00),
  (9, 1,  CURDATE() - INTERVAL 21 DAY,    665.00),
  (10,4,  CURDATE() - INTERVAL 16 DAY,    950.00),
  (11,2,  CURDATE() - INTERVAL 13 DAY,   1420.00),
  (13,5,  CURDATE() - INTERVAL 9 DAY,    1180.00),
  (14,4,  CURDATE() - INTERVAL 7 DAY,    1385.00),
  (17,1,  CURDATE() - INTERVAL 2 DAY,     805.00),
  (18,2,  CURDATE() - INTERVAL 2 DAY,     495.00),
  (19,4,  CURDATE() - INTERVAL 1 DAY,     520.00),
  (20,4,  CURDATE() - INTERVAL 1 DAY,    1070.00);
