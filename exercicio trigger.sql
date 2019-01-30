create table fornecedor(
	cod_fornecedor int not null primary key,
	nome_fornecedor varchar(30),
	endereco_fornecedor varchar(50)
);

create table titulo(
	cod_titulo int not null primary key,
	descr_titulo varchar(50)
);

create table livro(
	cod_livro int not null primary key,
	cod_titulo int references titulo(cod_titulo),
	quant_estoque int,
	valor_unitario float
);

create table pedido(
	cod_pedido int,
	cod_fornecedor int,
	data_pedido date,
	hora_pedido time,
	valor_total_pedido float,
	quant_itens_pedidos int
);

create table item_pedido(
	cod_livro int,
	cod_pedido int,
	quantidade_item int,
	valor_total_item float
);

INSERT INTO fornecedor VALUES (1, 'Fornecedor 1', 'Endereço 1');
INSERT INTO fornecedor VALUES (2, 'Fornecedor 2', 'Endereço 2');
INSERT INTO fornecedor VALUES (3, 'Fornecedor 3', 'Endereço 3');
INSERT INTO fornecedor VALUES (4, 'Fornecedor 4', 'Endereço 4');
INSERT INTO fornecedor VALUES (5, 'Fornecedor 5', 'Endereço 5');
INSERT INTO fornecedor VALUES (6, 'Fornecedor 6', 'Endereço 6');
INSERT INTO fornecedor VALUES (7, 'Fornecedor 7', 'Endereço 7');
INSERT INTO fornecedor VALUES (8, 'Fornecedor 8', 'Endereço 8');

INSERT INTO titulo VALUES (1, 'Titulo 1');
INSERT INTO titulo VALUES (2, 'Titulo 2');
INSERT INTO titulo VALUES (3, 'Titulo 3');
INSERT INTO titulo VALUES (4, 'Titulo 4');
INSERT INTO titulo VALUES (5, 'Titulo 5');
INSERT INTO titulo VALUES (6, 'Titulo 6');

INSERT INTO livro VALUES (1, 1, 10, 10);
INSERT INTO livro VALUES (2, 2, 20, 20);
INSERT INTO livro VALUES (3, 3, 30, 30);
INSERT INTO livro VALUES (4, 4, 40, 40);
INSERT INTO livro VALUES (5, 5, 50, 50);
INSERT INTO livro VALUES (6, 6, 60, 60);

INSERT INTO pedido VALUES (1, 1, '2018-12-04', '2018-12-04 10:40:01.561037', 100, 100);
INSERT INTO pedido VALUES (1, 1, '2018-12-04', '2018-12-04 10:42:27.93924', 100, 100);
INSERT INTO pedido VALUES (2, 2, '2018-12-04', '2018-12-04 10:42:27.93924', 200, 200);
INSERT INTO pedido VALUES (3, 3, '2018-12-04', '2018-12-04 10:42:27.93924', 300, 300);
INSERT INTO pedido VALUES (4, 4, '2018-12-04', '2018-12-04 10:42:27.93924', 400, 400);
INSERT INTO pedido VALUES (5, 5, '2018-12-04', '2018-12-04 10:42:27.93924', 500, 500);
INSERT INTO pedido VALUES (6, 6, '2018-12-04', '2018-12-04 10:42:27.93924', 600, 600);

INSERT INTO item_pedido VALUES (1, 1, 1000, 1000);
INSERT INTO item_pedido VALUES (2, 2, 2000, 2000);
INSERT INTO item_pedido VALUES (3, 3, 3000, 3000);
INSERT INTO item_pedido VALUES (4, 4, 4000, 4000);
INSERT INTO item_pedido VALUES (5, 5, 5000, 5000);
INSERT INTO item_pedido VALUES (6, 6, 6000, 6000);

