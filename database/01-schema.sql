/*
PROJETO: OmniStore
DESCRIÇÃO: Script DDL para criação e estruturação do banco de dados relacional.
AUTOR: Erique Guida
DATA: 2026
*/

--
-- Preparação do Ambiente
--
CREATE DATABASE omni_store;
USE omni_store;

--
-- Infraestrutura Organizacional e RH
--
CREATE TABLE cargo (
	cargoID INT PRIMARY KEY AUTO_INCREMENT,
    nomeCargo VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE regiao (
	regiaoID INT PRIMARY KEY AUTO_INCREMENT,
    nomeRegiao VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE lojaFisica (
	lojaID INT PRIMARY KEY AUTO_INCREMENT,
    regiaoID INT NOT NULL,
    nomeLoja VARCHAR(45) NOT NULL UNIQUE,
    endereco VARCHAR(45) NOT NULL UNIQUE,
	telefoneLoja VARCHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY(regiaoID) REFERENCES regiao(regiaoID)
);

CREATE TABLE departamento (
	departamentoID INT PRIMARY KEY AUTO_INCREMENT,
    lojaID INT NOT NULL,
    nomeDepartamento VARCHAR(45) NOT NULL UNIQUE,
    FOREIGN KEY (lojaID) REFERENCES lojaFisica(lojaID)
);

--
-- Colaboradores da Empresa
--
CREATE TABLE funcionario (
	funcionarioID INT PRIMARY KEY AUTO_INCREMENT,
    cargoID INT NOT NULL,
    departamentoID INT NOT NULL,
    gestorID INT,
    nomeCompleto VARCHAR(100) NOT NULL,
	cpf VARCHAR(11) NOT NULL UNIQUE,
		CONSTRAINT chk_cpf_valido CHECK (cpf REGEXP '^[0-9]{11}$'),
	idColaborador VARCHAR(10) NOT NULL UNIQUE,
	emailCorporativo VARCHAR(45) NOT NULL UNIQUE,
	FOREIGN KEY (cargoID) REFERENCES cargo(cargoID),
	FOREIGN KEY (departamentoID) REFERENCES departamento(departamentoID),
    FOREIGN KEY (gestorID) REFERENCES funcionario(funcionarioID)
);

--
-- Atores Externos
--
CREATE TABLE cliente (
	clienteID INT PRIMARY KEY AUTO_INCREMENT,
    nomeCliente VARCHAR(100) NOT NULL UNIQUE,
    telefoneCliente VARCHAR(11) NOT NULL UNIQUE,
	emailCliente VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE fornecedor (
	fornecedorID INT PRIMARY KEY AUTO_INCREMENT,
    nomeFornecedor VARCHAR(100) NOT NULL UNIQUE,
    telefoneFornecedor VARCHAR(11) NOT NULL UNIQUE,
	emailFornecedor VARCHAR(45) NOT NULL UNIQUE
);

--
-- Catálogo de Produtos e Gestão de Estoque
--
CREATE TABLE categoriaProduto (
	categoriaID INT PRIMARY KEY AUTO_INCREMENT,
    nomeCategoria VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE subcategoriaProduto (
    subcategoriaID INT PRIMARY KEY AUTO_INCREMENT,
    categoriaID INT NOT NULL,
    nomeSubcategoria VARCHAR(45) NOT NULL UNIQUE,
    FOREIGN KEY (categoriaID) REFERENCES categoriaProduto(categoriaID)
);

CREATE TABLE produto (
	produtoID INT PRIMARY KEY AUTO_INCREMENT,
    fornecedorID INT NOT NULL,
    subcategoriaID INT NOT NULL,
    nomeProduto VARCHAR(45) NOT NULL,
    codigoProduto VARCHAR(10) NOT NULL UNIQUE,
    precoCusto DECIMAL(10,2) DEFAULT 0.00 CHECK (precoCusto >= 0),
    precoVenda DECIMAL(10,2) DEFAULT 0.00 CHECK (precoVenda >= 0),
    descricao VARCHAR(150) NOT NULL,
    statusProduto VARCHAR(45) NOT NULL,
    FOREIGN KEY (subcategoriaID) REFERENCES subcategoriaProduto(subcategoriaID),
    FOREIGN KEY (fornecedorID) REFERENCES fornecedor(fornecedorID)
);

CREATE TABLE estoque (
	lojaID INT NOT NULL,
    produtoID INT NOT NULL,
    qtdEstoque INT NOT NULL DEFAULT 0,
		CONSTRAINT chk_qtdPositiva CHECK (qtdEstoque >= 0),
    PRIMARY KEY (lojaID, produtoID),
	FOREIGN KEY (lojaID) REFERENCES lojaFisica(lojaID),
    FOREIGN KEY (produtoID) REFERENCES produto(produtoID)
);

--
-- Comercial, Transações e Vendas
--
CREATE TABLE metodoPagamento(
	metodoID INT PRIMARY KEY AUTO_INCREMENT,
    nomeMetodo VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE vendas (
	vendaID INT PRIMARY KEY AUTO_INCREMENT,
    lojaID INT,
    funcionarioID INT NOT NULL,
    metodoPagamentoID INT NOT NULL,
    clienteID INT NOT NULL,
    dataVenda DATETIME DEFAULT CURRENT_TIMESTAMP,
    valorTotal DECIMAL(10,2) DEFAULT 0.00 CHECK (valorTOTAL >= 0),
    FOREIGN KEY (lojaID) REFERENCES lojaFisica(lojaID),
    FOREIGN KEY (clienteID) REFERENCES cliente(clienteID),
    FOREIGN KEY (funcionarioID) REFERENCES funcionario(funcionarioID),
    FOREIGN KEY (metodoPagamentoID) REFERENCES metodoPagamento(metodoID)
);

CREATE TABLE itensVenda(
	vendaID INT NOT NULL,
    produtoID INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    precoVenda DECIMAL(10,2) DEFAULT 0.00 CHECK (precoVenda >= 0),
    PRIMARY KEY (vendaID, produtoID),
    FOREIGN KEY (vendaID) REFERENCES vendas(vendaID),
    FOREIGN KEY (produtoID) REFERENCES produto(produtoID)
);

--
-- Metas e KPIs
--
CREATE TABLE metas(
	metaID INT PRIMARY KEY AUTO_INCREMENT,
    funcionarioID INT NOT NULL,
    categoriaID INT NOT NULL,
    lojaID INT NOT NULL,
    valorMeta DECIMAL(10,2) DEFAULT 0.00 CHECK (valorMeta >= 0),
    dataInicio DATETIME NOT NULL,
    dataFim DATETIME NOT NULL,
    status VARCHAR(45) NOT NULL,
    FOREIGN KEY (lojaID) REFERENCES lojaFisica(lojaID),
    FOREIGN KEY (funcionarioID) REFERENCES funcionario(funcionarioID),
    FOREIGN KEY (categoriaID) REFERENCES categoriaProduto(categoriaID)
);

--
-- Governança, IA e Auditoria de Pesquisas (Copiloto Text-to-SQL)
--
CREATE TABLE auditoriaConsulta (
    consultaID INT PRIMARY KEY AUTO_INCREMENT,
    funcionarioID INT NOT NULL,
    perguntaTexto TEXT NOT NULL,
    sqlGerado TEXT,
    statusConsulta VARCHAR(30) NOT NULL CHECK (statusConsulta IN ('PERMITIDA', 'NEGADA', 'ERRO', 'SUSPICIOUS_BLOCK')),
    motivoNegativa VARCHAR(255),
    tempoExecucaoMs INT DEFAULT 0 CHECK (tempoExecucaoMs >= 0),
    dataHoraConsulta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (funcionarioID) REFERENCES funcionario(funcionarioID)
);