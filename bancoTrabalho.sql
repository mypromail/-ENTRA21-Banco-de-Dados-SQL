/*CRIANDO BANCO DO AlugaMais (INSPIRADO EM UMA EMPRESA QUE APARECEU NO SHARK TANK BRASIL)*/
CREATE DATABASE AlugaMais;

/*USANDO O BANCO*/
USE AlugaMais;

/*CRIANDO TABELA DO USUARIO ADMIN*/
CREATE TABLE usuario_admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(255),
    email VARCHAR(255),
    senha VARCHAR(255)
);

/*CRIANDO USUÁRIO E DANDO PERMISSÕES*/
CREATE USER 'admin_AM'@'localhost' IDENTIFIED BY 'aluga_mais_senha_super_forte';
GRANT SELECT, INSERT, UPDATE, DELETE ON AlugaMais.usuario_admin TO 'admin_AM'@'localhost';



/*TABELA DE PRODUTOS*/
CREATE TABLE Produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,
    categoria VARCHAR(255) NOT NULL,
    preco_diaria DECIMAL(10, 2) NOT NULL
);

/*TABELA DE ENTRADA DE ESTOQUE*/
CREATE TABLE EntradasEstoque (
    id_entrada INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    data_entrada DATE NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);

/*TABELA DE SAIDA DE ESTOQUE*/
CREATE TABLE SaidasEstoque (
    id_saida INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    data_saida DATE NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);

/*TABELA DE CLIENTE*/
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome_cliente VARCHAR(255) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    telefone VARCHAR(20) NOT NULL
);

/*TABELA DE CONTRATOS DE ALUGUEL*/
CREATE TABLE ContratosAluguel (
    id_contrato INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

/*TABELA DE ITENS DE CONTRATOS DE ALUGUEL*/
CREATE TABLE ItensContratoAluguel (
    id_contrato INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (id_contrato) REFERENCES ContratosAluguel(id_contrato),
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);

/*TRIGGER'S*/
/*
PARA NÃO CONSEGUIR TIRAR PRODUTO NO ESTOQUE IGUAL A 0, QUE NÃO EXISTAM E QUE NÃO TENHA A QUANTIDADE NECESSÁRIA;
PARA NÃO ENTRAR NO ESTOQUE PRODUTOS QUE NÃO EXISTAM;
*/

/*TRIGGER PARA PREVENIR REMOÇÃO DE PRODUTO IGUAL A 0*/
DELIMITER //
CREATE TRIGGER before_delete_product BEFORE DELETE ON Produtos FOR EACH ROW
BEGIN
    DECLARE saldo_atual INT;

    
    SELECT SUM(quantidade) INTO saldo_atual
    FROM EntradasEstoque
    WHERE id_produto = OLD.id_produto;

    SELECT SUM(quantidade) INTO saldo_atual
    FROM SaidasEstoque
    WHERE id_produto = OLD.id_produto;
	
    /*CHECANDO SE O SALDO DO PRODUTO É IGUAL A 0*/
    IF saldo_atual = 0 THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END;
//
DELIMITER ;

/*TRIGGER PARA PREVENIR ENTRADA DE PRODUTO NO ESTOQUE QUE NÃO EXISTA NA TABELA PRODUTO*/
DELIMITER //
CREATE TRIGGER before_insert_entrada BEFORE INSERT ON EntradasEstoque FOR EACH ROW
BEGIN
	/*CHECANDO SE O PRODUTO ESTÁ CADASTRADO NA TABELA PRODUTOS ANTES DE ENTRAR NO ESTOQUE*/
    IF NOT EXISTS (SELECT 1 FROM Produtos WHERE id_produto = NEW.id_produto) THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END;
//
DELIMITER ;

/*TRIGGER PARA PREVENIR QUE SAIDA DO ESTOQUE NÃO TENHA PRODUTOS EXISTENTES NO ESTOQUE E QUE TENHA SALDO*/
DELIMITER //
CREATE TRIGGER before_insert_saida BEFORE INSERT ON SaidasEstoque FOR EACH ROW
BEGIN
    DECLARE saldo_atual INT;
    /*CHECANDO SE O SALDO DO PRODUTO EXISTE E QUE NÃO É INSUFICIENTE NO ESTOQUE ANTES DE SAIR*/
    IF NOT EXISTS (SELECT 1 FROM Produtos WHERE id_produto = NEW.id_produto) THEN
        SIGNAL SQLSTATE '45000';
    END IF;

    SELECT SUM(quantidade) INTO saldo_atual
    FROM EntradasEstoque
    WHERE id_produto = NEW.id_produto;

    SELECT SUM(quantidade) INTO saldo_atual
    FROM SaidasEstoque
    WHERE id_produto = NEW.id_produto;

    IF NEW.quantidade > saldo_atual THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END;
//
DELIMITER ;


/*----------------------------------------------------------------------------------------*/
/*INSERT'S*/
/*
Produtos
EntradaEstoque
SaidasEstoque
Clientes
ContratosAluguel
ItensContratosAluguel
*/

/*10 INSERT'S PRODUTOS (PENSADO NA QUESTÃO DE OBRAS || CONTÉM TODOS OS PRODUTOS)*/
INSERT INTO Produtos (nome_produto, descricao, categoria, preco_diaria)
VALUES
	('Escavadeira', 'Máquina pesada para escavação', 'Máquinas Pesadas', 200.00),
	('Betoneira', 'Equipamento para preparo de concreto', 'Equipamentos de Concreto', 100.00),
	('Martelo Demolidor', 'Martelo para demolição', 'Ferramentas de Demolição', 10.00),
	('Serra Elétrica', 'Serra para corte', 'Ferramentas Elétricas', 80.00),
	('Compactador de Solo', 'Equipamento para compactação do solo', 'Máquinas Pesadas', 150.00),
	('Gerador Elétrico', 'Gerador portátil para fornecimento de energia', 'Equipamentos Elétricos', 120.00),
	('Caminhão Basculante', 'Veículo para transporte de materiais', 'Veículos de Transporte', 250.00),
	('Placa Vibratória', 'Equipamento para compactação', 'Máquinas Leves', 90.00),
	('Guincho de Coluna', 'Guincho para elevação de cargas', 'Equipamentos de Elevação', 180.00),
	('Escada Telescópica', 'Escada extensível', 'Ferramentas Manuais', 20.00);

/*10 INSERT'S ENTRADAS DE PRODUTOS NO ESTOQUE (CONTÉM TODOS OS PRODUTOS NO ESTOQUE)*/    
INSERT INTO EntradasEstoque (id_produto, quantidade, data_entrada)
VALUES 
	(1, 4, '2023-01-15'),
	(2, 8, '2023-03-17'),
	(3, 10, '2022-08-13'),
	(4, 9, '2023-01-20'),
	(5, 5, '2023-02-25'),
	(6, 6, '2023-01-13'),
	(7, 3, '2023-02-23'),
	(8, 7, '2023-01-12'),
	(9, 6, '2023-03-11'),
	(10, 10, '2023-01-15');

/*10 INSERT'S SAIDAS DE PRODUTOS NO ESTOQUE (CONTÉM TODOS OS PRODUTOS QUE SAIRAM DO ESTOQUE)*/
INSERT INTO SaidasEstoque (id_produto, quantidade, data_saida)
VALUES 
	(1, 2, '2023-01-20'),
	(2, 5, '2023-01-20'),
	(3, 7, '2023-01-20'),
	(4, 3, '2023-01-20'),
	(5, 3, '2023-01-20'),
	(6, 2, '2023-01-20'),
	(7, 4, '2023-01-20'),
	(8, 7, '2023-01-20'),
	(9, 5, '2023-01-20'),
	(10, 6, '2023-01-20');

/*10 INSERT'S CLIENTES (CONTÉM TODOS OS CLIENTES REGISTRADOS || NÃO TENHO CRIATIVIDADE PRA FICTICIOS, ENTÃO NÃO SÃO NOMES COMPLEXOS)*/
INSERT INTO Clientes (nome_cliente, endereco, telefone)
VALUES
    ('Construções ABC', 'Rua das Obras, 123, Centro', '+55 47 99999-9991'),
    ('Engenharia do Gabriel', 'Avenida Brasil, 456, Vila Nova', '+55 47 99999-9992'),
    ('Obras e Projetos JP', 'Travessa das avós, 789, Fortaleza', '+55 47 99999-9993'),
    ('Construtora 123', 'Praça é nossa, 101, Garcia', '+55 47 99999-9994'),
    ('Mega Obras', 'Amazonas, 202, Garcia', '+55 47 99999-9995'),
    ('Projetos & Construções FitFusion', 'Avenida da Engenharia, 303, Itoupava', '+55 47 99999-9996'),
    ('Construtora Sulista', 'Rua dos Cães, 404, Salto', '+55 47 99999-9997'),
    ('Obras do Marcelo', 'Rua Glória, 505, Glória', '+55 47 99999-9998'),
    ('Engenharia do Cão', 'Praça do Garcia, 606, Garcia', '+55 47 99999-9999'),
    ('Construções do Centro', 'Rua João Batista, 707, Centro', '+55 47 99999-9989');
    
/*10 INSERT'S CONTRATOS DE ALUGUEL (CONTÉM TODOS OS CONTRATOS EFETUADOS, ONDE PEGARÁ CLIENTE, PRODUTO, DATA DE INICIO | FIM E O VALOR TOTAL DO DEVEDOR)*/
INSERT INTO ContratosAluguel (id_cliente, data_inicio, data_fim, valor_total)
VALUES 
    (1, '2023-01-01', '2023-02-01', 400.00),
    (2, '2023-02-15', '2023-03-15', 500.00),
    (3, '2023-03-10', '2023-04-10', 70.00),
    (4, '2023-04-05', '2023-05-05', 320.00),
    (5, '2023-05-12', '2023-06-12', 450.00),
    (6, '2023-06-18', '2023-07-18', 240.00),
    (7, '2023-07-22', '2023-08-22', 1000.00),
    (8, '2023-08-30', '2023-09-30', 630.00),
    (9, '2023-09-08', '2023-10-08', 900.00),
    (10, '2023-10-15', '2023-11-15', 120.00);

/*10 INSERT'S ITENS DE CONTRATOS DE ALUGUEL (CONTÉM TODOS OS ITENS QUE FORAM USADOS NOS CONTRATOS, PUXAM O CONTRATO, O PRODUTO E A QUANTIDADE)*/
INSERT INTO ItensContratoAluguel (id_contrato, id_produto, quantidade)
VALUES
    (1, 1, 2),
    (2, 2, 5),
    (3, 3, 7),
    (4, 4, 3),
    (5, 5, 3),
    (6, 6, 2),
    (7, 7, 4),
    (8, 8, 7),
    (9, 9, 5),
    (10, 10, 6);
    

/*SELECT DE TODOS OS PRODUTOS DAS TABELAS (USO BASTANTE NA HORA DE VISUALIZAÇÃO E INSERÇÃO DE CONTEÚDO)*/
SELECT * FROM Produtos;
SELECT * FROM EntradasEstoque;
SELECT * FROM SaidasEstoque;
SELECT * FROM Clientes;
SELECT * FROM ContratosAluguel;
SELECT * FROM ItensContratoAluguel;

/*SELECT PARA PEGAR A QUANTIDADE EM ESTOQUE ONDE PEGA TODAS AS ENTRADAS E DESCONTA AS SAIDAS*/
SELECT P.*, COALESCE(SUM(E.quantidade), 0) AS quantidade_em_estoque FROM Produtos P
LEFT JOIN EntradasEstoque E ON P.id_produto = E.id_produto
LEFT JOIN SaidasEstoque S ON P.id_produto = S.id_produto GROUP BY P.id_produto
HAVING COALESCE(SUM(E.quantidade), 0) - COALESCE(SUM(S.quantidade), 0) > 0;

/*SELECT EM TUDO DA ENTRADA ESTOQUE ENTRE PERIODOS DE DATA (BOA IDEIA PARA FILTRO ENTRE DATAS)*/
SELECT * FROM EntradasEstoque WHERE data_entrada BETWEEN '2023-01-18' AND '2023-01-20';

/*SELECT DAS SAIDAS DO ESTOQUE DO PRODUTO ID 1*/
SELECT * FROM SaidasEstoque WHERE id_produto = 1;

/*
SELECT MAIS DETALHADO PEGA AS ENTRADAS E SAIDAS AO MESMO TEMPO
COM MAIS INFORMAÇÃO ASSIM GERANDO O SALDO TOTAL DO ESTOQUE
*/
SELECT P.id_produto, P.nome_produto, P.descricao, P.categoria, P.preco_diaria,
COALESCE(SUM(E.quantidade), 0) AS total_entradas,
COALESCE(SUM(S.quantidade), 0) AS total_saidas,
COALESCE(SUM(E.quantidade), 0) - COALESCE(SUM(S.quantidade), 0) AS saldo_atual FROM Produtos P
LEFT JOIN EntradasEstoque E ON P.id_produto = E.id_produto
LEFT JOIN SaidasEstoque S ON P.id_produto = S.id_produto GROUP BY P.id_produto;

/*
SELECT EM TODOS OS PRODUTOS QUE ESTÃO ABAIXO DE 5 JUNTANDO
INFORMAÇÕES DO SALDO TOTAL COM A ENTRADA E SAIDA DO ESTOQUE
*/
SELECT P.id_produto, P.nome_produto, P.descricao, P.categoria, P.preco_diaria,
COALESCE(SUM(E.quantidade), 0) - COALESCE(SUM(S.quantidade), 0) AS saldo_atual FROM Produtos P
LEFT JOIN EntradasEstoque E ON P.id_produto = E.id_produto
LEFT JOIN SaidasEstoque S ON P.id_produto = S.id_produto
GROUP BY P.id_produto HAVING saldo_atual < 5;

/*PEGANDO A QUANTIDADE DE SAIDAS DE CADA PRODUTO COM BASE NA SAIDA DE ESTOQUE DE DETERMINADO DIA*/
SELECT id_produto, COUNT(*) AS quantidade_estorno FROM SaidasEstoque WHERE data_saida = '2023-01-20' GROUP BY id_produto;



/*UPDATE NA ENTRADA DE ESTOQUE PARA DIFERENTES PRODUTOS*/
UPDATE EntradasEstoque SET quantidade = 5 WHERE id_produto = 1;
UPDATE EntradasEstoque SET quantidade = 10 WHERE id_produto = 2;
UPDATE EntradasEstoque SET quantidade = 10 WHERE id_produto = 3;
UPDATE EntradasEstoque SET quantidade = 15 WHERE id_produto = 4;
UPDATE EntradasEstoque SET quantidade = 15 WHERE id_produto = 5;
UPDATE EntradasEstoque SET quantidade = 5 WHERE id_produto = 6;
UPDATE EntradasEstoque SET quantidade = 10 WHERE id_produto = 7;
UPDATE EntradasEstoque SET quantidade = 10 WHERE id_produto = 8;
UPDATE EntradasEstoque SET quantidade = 15 WHERE id_produto = 9;
UPDATE EntradasEstoque SET quantidade = 15 WHERE id_produto = 10;

/*DELETANDO PRODUTOS DE DETERMINADAS DATAS*/
DELETE FROM EntradasEstoque WHERE id_produto = 1 AND data_entrada = '2023-01-15';
DELETE FROM SaidasEstoque WHERE id_produto = 1 AND data_saida = '2023-01-20';

/*DELETAR BANCO*/
DROP DATABASE AlugaMais;

/*
-----------------------------------------------------------------------------
								COMENTÁRIO
-----------------------------------------------------------------------------
NÃO TIVE GRANDES DESAFIOS ALÉM DE PENSAR NO QUE FAZER, FOI PENSADO NO INTUI-
TO DE FAZER UM SITE PARA IDEIAS, TALVEZ EU FAÇA DAQUI A POUCO, MAS ME DEU
IDEIAS NA QUESTÃO DE PEGAR PERIODOS, EU JÁ FIZ ALGO PARECIDO, MAS TINHA
FEITO APENAS POR UM DIA ESPECIFICO:

EXEMPLO:
SELECT (ALEATORIO) FROM (ALEATORIO) WHERE DATE = $dateInput

USEI $dateInput PORQUE ESTOU ACOSTUMADO A PROGRAMAR EM PHP O BACK

QUESTÕES DE TRIGGER TAMBÉM TIVE QUE IR ATRÁS DO STACKOVERFLOW E VIDEOS NO
YOUTUBE PARA MELHOR ENTENDIMENTO.

O ESTOQUE TEM GRANDE IMPORTÂNCIA PARA UMA EMPRESA SABER O QUE, QUANTO, PARA
QUEM E PARA QUE É VENDIDO, E O MYSQL ALÉM DE SER PRÁTICO, JÁ QUE É
IGUAL A UM LIVRO PARA LER, É FÁCIL E DE GRANDE ESCALA.

EXPLICAÇÃO DE TABELAS:

CADASTRO PRODUTO -> ENTRADA ESTOQUE -> SAIDA ESTOQUE
CLIENTES VÃO PARA CONTRATOS DE ALUGUEL 
(CONTEM OS CLIENTES E O SALDO DEVEDOR, DATA INICIO E FIM)
E 
ITENS DE CONTRATOS DE ALUGUEL
(PUXAM O CLIENTE E O PRODUTO)
-----------------------------------------------------------------------------
*/