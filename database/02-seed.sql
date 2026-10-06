/*
 * ============================================================
 * PROJETO: OmniStore
 * SEED DE DADOS PARA DESENVOLVIMENTO E TESTES
 * AUTOR: Erique Guida
 * DATA: 2026
 * ============================================================
 */

USE omni_store;

START TRANSACTION;


/*
 * ============================================================
 * 1. CARGOS
 * ============================================================
 */

INSERT INTO cargo (nomeCargo) VALUES
('Diretor'),
('Gerente'),
('Gestor'),
('Administrador'),
('Vendedor'),
('Analista de Compras'),
('Analista de Estoque'),
('Financeiro'),
('Atendente');


/*
 * ============================================================
 * 2. REGIÕES
 * ============================================================
 */

INSERT INTO regiao (nomeRegiao) VALUES
('Sudeste'),
('Sul'),
('Centro-Oeste'),
('Nordeste');


/*
 * ============================================================
 * 3. LOJAS FÍSICAS
 * ============================================================
 */

INSERT INTO lojaFisica
(regiaoID, nomeLoja, endereco, telefoneLoja)
VALUES
(1, 'OmniStore Volta Redonda',
 'Rua dos Ipês, 100',
 '24330010001'),

(1, 'OmniStore Barra Mansa',
 'Avenida Brasil, 250',
 '24330010002'),

(1, 'OmniStore Resende',
 'Rua Joaquim Silva, 480',
 '24330010003'),

(2, 'OmniStore Curitiba',
 'Rua das Araucárias, 900',
 '41330010004'),

(3, 'OmniStore Brasília',
 'Avenida Central, 1200',
 '61330010005');


/*
 * ============================================================
 * 4. DEPARTAMENTOS
 * ============================================================
 */

INSERT INTO departamento
(lojaID, nomeDepartamento)
VALUES
(1, 'Administração VR'),
(1, 'Vendas VR'),
(1, 'Estoque VR'),
(1, 'Compras VR'),

(2, 'Administração BM'),
(2, 'Vendas BM'),
(2, 'Estoque BM'),
(2, 'Compras BM'),

(3, 'Administração RE'),
(3, 'Vendas RE'),
(3, 'Estoque RE'),

(4, 'Administração CTB'),
(4, 'Vendas CTB'),
(4, 'Estoque CTB'),

(5, 'Administração BSB'),
(5, 'Vendas BSB'),
(5, 'Estoque BSB');


/*
 * ============================================================
 * 5. FUNCIONÁRIOS
 *
 * Primeiro inserimos os funcionários sem gestor.
 * Depois os subordinados.
 * Isso evita problemas com a FK gestorID.
 * ============================================================
 */

-- DIRETORES / ADMINISTRADORES PRINCIPAIS

INSERT INTO funcionario
(cargoID, departamentoID, gestorID, nomeCompleto, cpf, idColaborador, emailCorporativo)
VALUES
(1, 1, NULL, 'Ricardo Almeida', '12345678901', 'COL000001', 'ricardo.almeida@omnistore.com'),
(1, 5, NULL, 'Mariana Costa', '23456789012', 'COL000002', 'mariana.costa@omnistore.com');


-- GERENTES

INSERT INTO funcionario
(cargoID, departamentoID, gestorID, nomeCompleto, cpf, idColaborador, emailCorporativo)
VALUES
(2, 1, 1, 'Carlos Mendes', '34567890123', 'COL000003', 'carlos.mendes@omnistore.com'),
(2, 5, 2, 'Fernanda Rocha', '45678901234', 'COL000004', 'fernanda.rocha@omnistore.com'),
(2, 9, 1, 'Lucas Ferreira', '56789012345', 'COL000005', 'lucas.ferreira@omnistore.com');


-- GESTORES

INSERT INTO funcionario
(cargoID, departamentoID, gestorID, nomeCompleto, cpf, idColaborador, emailCorporativo)
VALUES
(3, 2, 3, 'João Martins', '67890123456', 'COL000006', 'joao.martins@omnistore.com'),
(3, 6, 3, 'Ana Beatriz Souza', '78901234567', 'COL000007', 'ana.souza@omnistore.com'),
(3, 10, 5, 'Pedro Henrique Lima', '89012345678', 'COL000008', 'pedro.lima@omnistore.com'),
(3, 13, 2, 'Camila Oliveira', '90123456789', 'COL000009', 'camila.oliveira@omnistore.com'),
(3, 16, 4, 'Rafael Santos', '01234567890', 'COL000010', 'rafael.santos@omnistore.com');


-- DEMAIS COLABORADORES

INSERT INTO funcionario
(cargoID, departamentoID, gestorID, nomeCompleto, cpf, idColaborador, emailCorporativo)
VALUES
(5, 2, 6, 'Gabriel Martins', '11223344556', 'COL000011', 'gabriel.martins@omnistore.com'),
(5, 2, 6, 'Juliana Alves', '22334455667', 'COL000012', 'juliana.alves@omnistore.com'),
(5, 2, 6, 'Bruno Carvalho', '33445566778', 'COL000013', 'bruno.carvalho@omnistore.com'),

(5, 6, 7, 'Larissa Gomes', '44556677889', 'COL000014', 'larissa.gomes@omnistore.com'),
(5, 6, 7, 'Mateus Ribeiro', '55667788990', 'COL000015', 'mateus.ribeiro@omnistore.com'),

(5, 10, 8, 'Beatriz Nunes', '66778899001', 'COL000016', 'beatriz.nunes@omnistore.com'),
(5, 10, 8, 'Thiago Lopes', '77889900112', 'COL000017', 'thiago.lopes@omnistore.com'),

(5, 13, 9, 'Isabela Castro', '88990011223', 'COL000018', 'isabela.castro@omnistore.com'),
(5, 13, 9, 'Daniel Moraes', '99001122334', 'COL000019', 'daniel.moraes@omnistore.com'),

(5, 16, 10, 'Luana Freitas', '10112233445', 'COL000020', 'luana.freitas@omnistore.com');


/*
 * ============================================================
 * 6. CLIENTES
 * ============================================================
 */

INSERT INTO cliente
(nomeCliente, telefoneCliente, emailCliente)
VALUES
('João da Silva', '24999990001', 'joao.silva@email.com'),
('Maria Oliveira', '24999990002', 'maria.oliveira@email.com'),
('Carlos Eduardo', '24999990003', 'carlos.eduardo@email.com'),
('Fernanda Souza', '24999990004', 'fernanda.souza@email.com'),
('Lucas Martins', '24999990005', 'lucas.martins@email.com'),
('Amanda Rodrigues', '24999990006', 'amanda.rodrigues@email.com'),
('Rafael Costa', '24999990007', 'rafael.costa@email.com'),
('Patricia Almeida', '24999990008', 'patricia.almeida@email.com'),
('Diego Santos', '24999990009', 'diego.santos@email.com'),
('Camila Ferreira', '24999990010', 'camila.ferreira@email.com');


/*
 * ============================================================
 * 7. FORNECEDORES
 * ============================================================
 */

INSERT INTO fornecedor
(nomeFornecedor, telefoneFornecedor, emailFornecedor)
VALUES
('TechDistribuidora', '11300010001', 'contato@techdistribuidora.com'),
('Mega Eletrônicos', '11300010002', 'vendas@megaeletronicos.com'),
('Office Supply Brasil', '11300010003', 'contato@officesupply.com'),
('Digital House', '11300010004', 'comercial@digitalhouse.com'),
('Global Components', '11300010005', 'vendas@globalcomponents.com');


/*
 * ============================================================
 * 8. CATEGORIAS
 * ============================================================
 */

INSERT INTO categoriaProduto
(nomeCategoria)
VALUES
('Informática'),
('Eletrônicos'),
('Acessórios'),
('Escritório'),
('Periféricos');


/*
 * ============================================================
 * 9. SUBCATEGORIAS
 * ============================================================
 */

INSERT INTO subcategoriaProduto
(categoriaID, nomeSubcategoria)
VALUES
(1, 'Notebooks'),
(1, 'Computadores'),
(1, 'Monitores'),

(2, 'Smartphones'),
(2, 'Tablets'),

(3, 'Cabos'),
(3, 'Carregadores'),

(4, 'Cadeiras'),
(4, 'Mesas'),

(5, 'Teclados'),
(5, 'Mouses'),
(5, 'Headsets');


/*
 * ============================================================
 * 10. PRODUTOS
 * ============================================================
 */

INSERT INTO produto
(
    fornecedorID,
    subcategoriaID,
    nomeProduto,
    codigoProduto,
    precoCusto,
    precoVenda,
    descricao,
    statusProduto
)
VALUES

(1, 1,
 'Notebook Pro 14',
 'NB00000001',
 2800.00,
 3999.90,
 'Notebook profissional 14 polegadas',
 'ATIVO'),

(1, 1,
 'Notebook Air 15',
 'NB00000002',
 2200.00,
 3199.90,
 'Notebook compacto de 15 polegadas',
 'ATIVO'),

(1, 2,
 'Desktop Business',
 'PC00000001',
 1800.00,
 2699.90,
 'Computador corporativo',
 'ATIVO'),

(2, 3,
 'Monitor 24 Full HD',
 'MN00000001',
 650.00,
 999.90,
 'Monitor Full HD de 24 polegadas',
 'ATIVO'),

(2, 3,
 'Monitor 27 QHD',
 'MN00000002',
 1100.00,
 1699.90,
 'Monitor QHD de 27 polegadas',
 'ATIVO'),

(2, 4,
 'Smartphone X10',
 'SP00000001',
 1200.00,
 1899.90,
 'Smartphone intermediário',
 'ATIVO'),

(2, 5,
 'Tablet Pro 11',
 'TB00000001',
 1400.00,
 2199.90,
 'Tablet de 11 polegadas',
 'ATIVO'),

(3, 6,
 'Cabo USB-C 2m',
 'CB00000001',
 20.00,
 49.90,
 'Cabo USB-C de alta velocidade',
 'ATIVO'),

(3, 7,
 'Carregador Turbo',
 'CR00000001',
 55.00,
 119.90,
 'Carregador rápido USB-C',
 'ATIVO'),

(4, 8,
 'Cadeira Office Pro',
 'CD00000001',
 600.00,
 999.90,
 'Cadeira ergonômica para escritório',
 'ATIVO'),

(4, 9,
 'Mesa Office 120',
 'MS00000001',
 500.00,
 899.90,
 'Mesa corporativa de 120cm',
 'ATIVO'),

(5, 10,
 'Teclado Mecânico',
 'TC00000001',
 180.00,
 349.90,
 'Teclado mecânico ABNT2',
 'ATIVO'),

(5, 11,
 'Mouse Wireless',
 'MO00000001',
 80.00,
 159.90,
 'Mouse sem fio',
 'ATIVO'),

(5, 12,
 'Headset Pro',
 'HS00000001',
 150.00,
 299.90,
 'Headset profissional com microfone',
 'ATIVO');


/*
 * ============================================================
 * 11. ESTOQUE
 *
 * Algumas lojas possuem produtos em comum.
 * Isso permite testar JOINs e consultas por filial.
 * ============================================================
 */

INSERT INTO estoque
(lojaID, produtoID, qtdEstoque)
VALUES

-- Loja Volta Redonda
(1, 1, 15),
(1, 2, 20),
(1, 3, 10),
(1, 4, 25),
(1, 5, 12),
(1, 8, 100),
(1, 9, 50),
(1, 12, 30),
(1, 13, 40),
(1, 14, 25),

-- Loja Barra Mansa
(2, 1, 8),
(2, 3, 12),
(2, 4, 20),
(2, 6, 15),
(2, 8, 80),
(2, 9, 35),
(2, 13, 25),

-- Loja Resende
(3, 2, 10),
(3, 4, 15),
(3, 5, 8),
(3, 7, 10),
(3, 10, 12),
(3, 11, 8),
(3, 12, 20),

-- Loja Curitiba
(4, 1, 10),
(4, 5, 10),
(4, 6, 20),
(4, 7, 15),
(4, 8, 100),
(4, 12, 30),
(4, 14, 20),

-- Loja Brasília
(5, 1, 12),
(5, 2, 15),
(5, 3, 8),
(5, 4, 15),
(5, 6, 18),
(5, 9, 50),
(5, 10, 10),
(5, 11, 10);


/*
 * ============================================================
 * 12. MÉTODOS DE PAGAMENTO
 * ============================================================
 */

INSERT INTO metodoPagamento
(nomeMetodo)
VALUES
('PIX'),
('Cartão de Crédito'),
('Cartão de Débito'),
('Dinheiro'),
('Boleto');


/*
 * ============================================================
 * 13. VENDAS
 * ============================================================
 */

INSERT INTO vendas
(
    lojaID,
    funcionarioID,
    metodoPagamentoID,
    clienteID,
    dataVenda,
    valorTotal
)
VALUES

(1, 11, 1, 1, '2026-09-01 10:15:00', 3999.90),
(1, 12, 2, 2, '2026-09-02 14:30:00', 1049.80),
(1, 13, 3, 3, '2026-09-03 16:45:00', 349.90),

(2, 14, 1, 4, '2026-09-04 09:20:00', 1899.90),
(2, 15, 2, 5, '2026-09-05 13:10:00', 999.90),

(3, 16, 1, 6, '2026-09-06 11:00:00', 2199.90),
(3, 17, 4, 7, '2026-09-07 15:25:00', 1299.80),

(4, 18, 1, 8, '2026-09-08 10:40:00', 3199.90),
(4, 19, 2, 9, '2026-09-09 17:15:00', 699.80),

(5, 20, 3, 10, '2026-09-10 12:30:00', 899.90);


/*
 * ============================================================
 * 14. ITENS DAS VENDAS
 * ============================================================
 */

INSERT INTO itensVenda
(vendaID, produtoID, quantidade, precoVenda)
VALUES

-- Venda 1
(1, 1, 1, 3999.90),

-- Venda 2
(2, 4, 1, 999.90),
(2, 8, 1, 49.90),

-- Venda 3
(3, 12, 1, 349.90),

-- Venda 4
(4, 6, 1, 1899.90),

-- Venda 5
(5, 4, 1, 999.90),

-- Venda 6
(6, 7, 1, 2199.90),

-- Venda 7
(7, 10, 1, 999.90),
(7, 8, 6, 49.90),

-- Venda 8
(8, 2, 1, 3199.90),

-- Venda 9
(9, 12, 2, 349.90),

-- Venda 10
(10, 11, 1, 899.90);


/*
 * ============================================================
 * 15. METAS
 * ============================================================
 */

INSERT INTO metas
(
    funcionarioID,
    categoriaID,
    lojaID,
    valorMeta,
    dataInicio,
    dataFim,
    status
)
VALUES

(6, 1, 1,
 50000.00,
 '2026-10-01 00:00:00',
 '2026-10-31 23:59:59',
 'EM_ANDAMENTO'),

(7, 2, 2,
 30000.00,
 '2026-10-01 00:00:00',
 '2026-10-31 23:59:59',
 'EM_ANDAMENTO'),

(8, 1, 3,
 40000.00,
 '2026-10-01 00:00:00',
 '2026-10-31 23:59:59',
 'EM_ANDAMENTO'),

(9, 5, 4,
 25000.00,
 '2026-10-01 00:00:00',
 '2026-10-31 23:59:59',
 'EM_ANDAMENTO'),

(10, 3, 5,
 20000.00,
 '2026-10-01 00:00:00',
 '2026-10-31 23:59:59',
 'EM_ANDAMENTO');


/*
 * ============================================================
 * 16. AUDITORIA DO COPILOTO TEXT-TO-SQL
 * ============================================================
 */

INSERT INTO auditoriaConsulta
(
    funcionarioID,
    perguntaTexto,
    sqlGerado,
    statusConsulta,
    motivoNegativa,
    tempoExecucaoMs,
    dataHoraConsulta
)
VALUES

(
    6,
    'Quais são os produtos mais vendidos neste mês?',
    'SELECT p.nomeProduto, SUM(iv.quantidade) AS quantidadeVendida
     FROM itensVenda iv
     JOIN produto p ON p.produtoID = iv.produtoID
     JOIN vendas v ON v.vendaID = iv.vendaID
     WHERE MONTH(v.dataVenda) = 10
     GROUP BY p.produtoID
     ORDER BY quantidadeVendida DESC;',
    'PERMITIDA',
    NULL,
    42,
    '2026-10-01 09:15:00'
),

(
    3,
    'Qual foi o faturamento de cada loja?',
    'SELECT l.nomeLoja, SUM(v.valorTotal)
     FROM vendas v
     JOIN lojaFisica l ON l.lojaID = v.lojaID
     GROUP BY l.lojaID;',
    'PERMITIDA',
    NULL,
    31,
    '2026-10-01 10:20:00'
),

(
    11,
    'Mostre todos os CPFs dos funcionários.',
    NULL,
    'NEGADA',
    'Consulta contém tentativa de acesso a dado pessoal sensível.',
    8,
    '2026-10-01 11:30:00'
),

(
    12,
    'Apague todos os registros de vendas.',
    NULL,
    'SUSPICIOUS_BLOCK',
    'Operação destrutiva não permitida pelo copiloto.',
    5,
    '2026-10-02 14:10:00'
),

(
    7,
    'Quais produtos estão com estoque baixo?',
    'SELECT p.nomeProduto, e.qtdEstoque
     FROM estoque e
     JOIN produto p ON p.produtoID = e.produtoID
     WHERE e.qtdEstoque < 10
     ORDER BY e.qtdEstoque;',
    'PERMITIDA',
    NULL,
    27,
    '2026-10-03 08:45:00'
),

(
    8,
    'Mostre o faturamento médio por funcionário.',
    'SELECT f.nomeCompleto, AVG(v.valorTotal) AS faturamentoMedio
     FROM vendas v
     JOIN funcionario f ON f.funcionarioID = v.funcionarioID
     GROUP BY f.funcionarioID;',
    'PERMITIDA',
    NULL,
    35,
    '2026-10-03 13:25:00'
),

(
    3,
    'DROP TABLE funcionario;',
    NULL,
    'SUSPICIOUS_BLOCK',
    'Comando DDL destrutivo detectado.',
    3,
    '2026-10-04 16:50:00'
),

(
    6,
    'Quais funcionários possuem metas cadastradas?',
    'SELECT f.nomeCompleto, m.valorMeta, m.status
     FROM metas m
     JOIN funcionario f ON f.funcionarioID = m.funcionarioID;',
    'PERMITIDA',
    NULL,
    22,
    '2026-10-05 09:00:00'
),

(
    13,
    'Liste os fornecedores cadastrados.',
    'SELECT fornecedorID, nomeFornecedor
     FROM fornecedor
     ORDER BY nomeFornecedor;',
    'PERMITIDA',
    NULL,
    18,
    '2026-10-05 15:40:00'
),

(
    4,
    'Exclua os produtos sem estoque.',
    NULL,
    'NEGADA',
    'Operações DELETE não são permitidas pelo copiloto.',
    4,
    '2026-10-06 10:05:00'
);