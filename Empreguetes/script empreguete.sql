CREATE TABLE CATEGORIA_CLIENTE
(
  ID_CATEGORIA   SERIAL UNIQUE PRIMARY KEY,
  NOME_CATEGORIA VARCHAR(100) NOT NULL,
  DESCONTO       FLOAT        NOT NULL
);

CREATE TABLE CLIENTE
(
  ID_CLIENTE           SERIAL UNIQUE PRIMARY KEY,
  NOME_CLIENTE         VARCHAR(200) NOT NULL,
  TELEFONE             VARCHAR(30)  NOT NULL,
  CATEGORIA_CLIENTE INT REFERENCES CATEGORIA_CLIENTE (ID_CATEGORIA)

);

CREATE TABLE FUNCIONARIO
(
  ID_FUNCIONARIO   SERIAL UNIQUE PRIMARY KEY,
  NOME_FUNCIONARIO VARCHAR(200) NOT NULL,
  ENDERECO         VARCHAR(200) NOT NULL,
  TELEFONE         VARCHAR(30)  NOT NULL
);

CREATE TABLE DIARISTA
(
  ID_DIARISTA   SERIAL UNIQUE PRIMARY KEY,
  NOME_DIARISTA VARCHAR(200) NOT NULL,
  ENDERECO      VARCHAR(200) NOT NULL,
  TELEFONE      VARCHAR(30)  NOT NULL
);

CREATE TABLE SERVICOS
(
  ID_SERVICO    SERIAL UNIQUE PRIMARY KEY,
  NOME_SERVICO  VARCHAR(100) NOT NULL,
  VALOR_SERVICO FLOAT        NOT NULL

);

CREATE TABLE ORDEM_DE_SERVICO
(
  ID_ORDEM_DE_SERVICO    SERIAL UNIQUE PRIMARY KEY,
  CLIENTE        INT REFERENCES CLIENTE (ID_CLIENTE),
  FUNCIONARIO    INT REFERENCES FUNCIONARIO (ID_FUNCIONARIO),
  DIARISTA INT REFERENCES DIARISTA(ID_DIARISTA),
  DATA_SOLICITACAO              DATE  NOT NULL,
  HORA_SOLICITACAO              TIME  NOT NULL,
  SERVICO INT REFERENCES SERVICOS(ID_SERVICO),
  VALOR_TOTAL FLOAT NOT NULL
);


CREATE TABLE DIARISTA_SERVICO
(
  ID_DIARISTA INT REFERENCES DIARISTA (ID_DIARISTA),
  ID_SERVICO  INT REFERENCES SERVICOS (ID_SERVICO)
);


---------------------------------------------------Povoamento-----------------------------------------------------------

INSERT INTO CATEGORIA_CLIENTE(NOME_CATEGORIA, DESCONTO)
VALUES ('BRONZE', 0.1);
INSERT INTO CATEGORIA_CLIENTE(NOME_CATEGORIA, DESCONTO)
VALUES ('PRATA', 0.3);
INSERT INTO CATEGORIA_CLIENTE(NOME_CATEGORIA, DESCONTO)
VALUES ('OURO', 0.5);

INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, CATEGORIA_CLIENTE)
VALUES ('eqweq', '', null);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, CATEGORIA_CLIENTE)
VALUES ('PEDRO', '998657901', 2);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, CATEGORIA_CLIENTE)
VALUES ('RICARDO', '5132715375', 3);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, CATEGORIA_CLIENTE)
VALUES ('CONCEIÇÃO', '1231242615', 2);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, CATEGORIA_CLIENTE)
VALUES ('EDSON', '1312213333', 3);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, CATEGORIA_CLIENTE)
VALUES ('PAULO', '145345552', 1);

INSERT INTO FUNCIONARIO(NOME_FUNCIONARIO, ENDERECO, TELEFONE)
VALUES ('Hidel', 'AVENIDA MIGUEL ROSA', '');
INSERT INTO FUNCIONARIO(NOME_FUNCIONARIO, ENDERECO, TELEFONE)
VALUES ('PABLO', 'AVENIDA FREI SERAFIM', '87876311312');
INSERT INTO FUNCIONARIO(NOME_FUNCIONARIO, ENDERECO, TELEFONE)
VALUES ('CHICO', 'RUA TERESINHA', '9876546889');
INSERT INTO FUNCIONARIO(NOME_FUNCIONARIO, ENDERECO, TELEFONE)
VALUES ('WANESSA', 'AVENIDA PIREZ DE CASTRO', '9897909876');
INSERT INTO FUNCIONARIO(NOME_FUNCIONARIO, ENDERECO, TELEFONE)
VALUES ('DEBORA', 'RUA 100', '8798731132');
INSERT INTO FUNCIONARIO(NOME_FUNCIONARIO, ENDERECO, TELEFONE)
VALUES ('JUVENAL', 'RUA 90', '9876588990');

INSERT INTO DIARISTA(NOME_DIARISTA, ENDERECO, TELEFONE)
VALUES ('MARIA', 'BAIRRO FLORES', '123123877');
INSERT INTO DIARISTA(NOME_DIARISTA, ENDERECO, TELEFONE)
VALUES ('JOANA', 'BAIRRO ININGA', '323131311');
INSERT INTO DIARISTA(NOME_DIARISTA, ENDERECO, TELEFONE)
VALUES ('HELCIO', 'BAIRRO PORTO ALEGRE', '0869909888');
INSERT INTO DIARISTA(NOME_DIARISTA, ENDERECO, TELEFONE)
VALUES ('JESSICA', 'BAIRRO HORTO', '445323113');
INSERT INTO DIARISTA(NOME_DIARISTA, ENDERECO, TELEFONE)
VALUES ('BRUNO', 'BAIRRO DIRCEU', '123123877');

INSERT INTO SERVICOS VALUES (DEFAULT,'VARRER ',20.00);
INSERT INTO SERVICOS VALUES (DEFAULT,'LAVAR',20.00);
INSERT INTO SERVICOS VALUES (DEFAULT,'COZINHAR',30.00);
INSERT INTO SERVICOS VALUES (DEFAULT,'PASSAR',50.00);
INSERT INTO SERVICOS VALUES (DEFAULT,'SERVICO COMPLETO',110.00);

INSERT INTO DIARISTA_SERVICO VALUES (2,8);


-------------------------------------------------- Funções -------------------------------------------------------------
  ---> Inserir
CREATE OR REPLACE FUNCTION INSERIR(TABELA TEXT, VALOR TEXT)
  RETURNS VOID AS
$$
DECLARE
  COMANDO TEXT;

BEGIN

  COMANDO := 'INSERT INTO ' || $1 || ' VALUES(DEFAULT,' || $2 || ');';

  EXECUTE COMANDO;
END;

$$ LANGUAGE plpgsql;
------------------------------------------------------------------------------------------------------------------------
select inserir('funcionario', ''''' ,''rua 18'',''9886788776''');
------------------------------------------------------------------------------------------------------------------------
--->Update
drop function atualizar(tabela text, campo text, valorantigo text);
------------------------------------------------------------------------------------------------------------------------
create or replace function atualizar(tabela text, campo text,valornovo text,condicao text,valor_condicao text)
  returns void as
$$
declare
  comando TEXT;

begin

  comando := 'UPDATE ' || tabela || ' SET '  || $2 || ' = ' ||$3 ||' where ' || $4 || ' = ' || valor_condicao;
  execute comando;

end;
$$ language plpgsql;
------------------------------------------------------------------------------------------------------------------------
select atualizar('funcionario','nome_funcionario','''junior''','id_funcionario','5');
------------------------------------------------------------------------------------------------------------------------
--->Delete

create or replace function deletar(tabela text,campo text,valor text)
returns void as $$
  declare
    comando text;
    begin
    comando:= 'delete from ' ||$1|| ' where ' ||$2|| '= '''||$3||'''';

    execute comando;
  end;
  $$ language plpgsql;
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-----Criar ordem de servico

create or replace function criar_ordem_de_servico(NOME_CLIENTE_V varchar(100),NOME_FUNCIONARIO_V varchar(100),
NOME_DIARISTA_V varchar(100),DATA date,HORA time,NOME_SERVICO_V VARCHAR(100)) returns void as $$
  declare
    var_id_cliente int;
    var_id_categoria_cliente int;
    var_id_funcionario int;
    var_id_diarista int;
    var_id_servico int;
    var_valor_servico float;
    var_valor_servico_com_desconto float;
    var_valor_desconto float;


  begin

    SELECT ID_CLIENTE,CATEGORIA_CLIENTE INTO var_id_cliente,var_id_categoria_cliente
    FROM CLIENTE WHERE NOME_CLIENTE_V ILIKE NOME_CLIENTE;
    SELECT DESCONTO INTO var_valor_desconto FROM CATEGORIA_CLIENTE WHERE ID_CATEGORIA = var_id_categoria_cliente;
    SELECT ID_FUNCIONARIO INTO var_id_funcionario FROM FUNCIONARIO WHERE NOME_FUNCIONARIO_V ILIKE NOME_FUNCIONARIO;
    SELECT ID_SERVICO,VALOR_SERVICO INTO var_id_servico,var_valor_servico FROM SERVICOS WHERE NOME_SERVICO_V ILIKE NOME_SERVICO;

    SELECT ID_DIARISTA INTO var_id_diarista FROM DIARISTA WHERE NOME_DIARISTA_V ILIKE NOME_DIARISTA;

    var_valor_servico_com_desconto:= var_valor_servico - (var_valor_servico*var_valor_desconto);

    INSERT INTO ORDEM_DE_SERVICO VALUES (DEFAULT,var_id_cliente,var_id_funcionario,var_id_diarista,DATA,HORA,var_id_servico,
                                         var_valor_servico_com_desconto);

  end;
  $$ LANGUAGE plpgsql;

select criar_ordem_de_servico('edson','pablo','maria','12-12-2018','12:30','COZINHAR');
---------------------------------------------Trigger--------------------------------------------------------------------

----- feedback
CREATE TRIGGER TGR_FEEDBACK_OPERACAO
  AFTER INSERT OR
  UPDATE OR DELETE
  ON funcionario
  FOR EACH ROW EXECUTE PROCEDURE FEEDBACK_OPERACAO();

CREATE OR REPLACE FUNCTION FEEDBACK_OPERACAO() RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  IF (TG_OP = 'INSERT')
  THEN
    RAISE NOTICE 'INSERCAO FEITA COM SUCESSO!';
  END IF;
  IF (TG_OP = 'UPDATE')
  THEN
    RAISE NOTICE 'ALTERACAO FEITA COM SUCESSO!';
  END IF;
  IF (TG_OP = 'DELETE')
  THEN
    RAISE NOTICE 'DELETADO COM SUCESSO!';
  END IF;
  RETURN NULL ;
END;
$$
LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------------------------------
-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE CATEGORIA CLIENTE
create or replace function notvaluesnullcategoriacliente()
returns trigger as $$
  begin
    if new.NOME_CATEGORIA is null  or new.NOME_CATEGORIA = '' then
    raise exception 'Nome da categoria está vazio ou nulo';
    end if ;

    if new.DESCONTO is null  or new.DESCONTO = '' then
    raise exception 'Desconto está vazio ou nulo';
    end if ;
    return null;
  end;

  $$language plpgsql;

create  trigger notnullcategoriacliente before insert or update on CATEGORIA_CLIENTE  FOR EACH ROW
EXECUTE PROCEDURE notvaluesnullcategoriacliente();

-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE CLIENTE
create or replace function notvaluesnullcliente()
returns trigger as $$
  begin
    if new.NOME_CLIENTE is null  or new.NOME_CLIENTE = '' then
    raise exception 'Nome está vazio ou nulo';
    end if ;

    if new.TELEFONE is null  or new.TELEFONE = '' then
    raise exception 'Telefone está vazio ou nulo';
    end if ;

    if new.CATEGORIA_CLIENTE is null  or new.CATEGORIA_CLIENTE = '' then
    raise exception 'Categoria do cliente está vazio ou nulo';
    end if ;


    return null;
  end;

  $$language plpgsql;

create  trigger notnullcliente before insert or update on CLIENTE  FOR EACH ROW EXECUTE PROCEDURE notvaluesnullcliente();

-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE DIARISTA
create or replace function notvaluesnulldiarista()
returns trigger as $$
  begin
    if new.NOME_DIARISTA is null  or new.NOME_DIARISTA = '' then
    raise exception 'Nome está vazio ou nulo';
    end if ;

    if new.ENDERECO is null  or new.ENDERECO = '' then
    raise exception 'Endereco está vazio ou nulo';
    end if ;

    if new.TELEFONE is null  or new.TELEFONE = '' then
    raise exception 'Telefone está vazio ou nulo';
    end if ;

    return null;
  end;
  $$language plpgsql;

create  trigger notnulldiarista before insert or update on DIARISTA  FOR EACH ROW EXECUTE PROCEDURE notvaluesnulldiarista();
----------------------------------------------------------------------------------------------------------------------------
-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE DIARISTA SERVICO
---AJEITAR
create or replace function notvaluesnulldiaristaservico()
returns trigger as $$
  begin
    if new.id_diarista is null  or new.id_diarista = '' then
    raise exception 'Id diarista está vazio ou nulo';
    end if ;

    if new.id_servico is null  or new.id_servico = '' then
    raise exception 'Id servico está vazio ou nulo';
    end if ;

    return null;
  end;

  $$language plpgsql;

create  trigger notnulldiaristaservico before insert or update on DIARISTA_SERVICO  FOR EACH ROW
EXECUTE PROCEDURE notvaluesnulldiaristaservico();

-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE FUNCIONARIOS
create or replace function notvaluesnullfuncionario()
returns trigger as $$
  begin
    if new.NOME_FUNCIONARIO is null  or new.NOME_FUNCIONARIO = '' then
    raise exception 'Nome está vazio ou nulo';
    end if ;

    if new.ENDERECO is null  or new.ENDERECO = '' then
    raise exception 'Endereco está vazio ou nulo';
    end if ;

    if new.TELEFONE is null  or new.TELEFONE = '' then
    raise exception 'Telefone está vazio ou nulo';
    end if ;
    return null;
  end;

  $$language plpgsql;

create  trigger notnullfunc before insert or update on funcionario  FOR EACH ROW EXECUTE PROCEDURE notvaluesnullfuncionario();


-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE FUNCIONARIOS
create or replace function notvaluesnullservico()
returns trigger as $$
  begin
    if new.NOME_SERVICO is null  or new.NOME_SERVICO = '' then
    raise exception 'Nome está vazio ou nulo';
    end if ;

    if new.VALOR is null  or new.VALOR = '' then
    raise exception 'Valor está vazio ou nulo';
    end if ;

    if new.VALOR <= 0 then
    raise exception 'Valor está negativo';
    end if ;

    return null;
  end;

  $$language plpgsql;

create  trigger notnullservico before insert or update on SERVICOS  FOR EACH ROW EXECUTE PROCEDURE notvaluesnullservico();

drop trigger notnulldiaristaservico ON DIARISTA_SERVICO
---->>>Duplicidade de dados
-->Cliente
CREATE TRIGGER duplicidade
  BEFORE INSERT OR UPDATE
  ON CLIENTE
  FOR EACH ROW EXECUTE PROCEDURE duplicidade();
CREATE OR REPLACE FUNCTION duplicidade()
  RETURNS TRIGGER AS $$
begin
  IF EXISTS(SELECT *
            FROM CLIENTE
            WHERE NOME_CLIENTE = NEW.NOME_CLIENTE
              AND TELEFONE = NEW.TELEFONE
              AND ID_CATEGORIA_CLIENTE = NEW.ID_CATEGORIA_CLIENTE)
  THEN
    RAISE EXCEPTION 'Atenção!Cliente já cadastrado';
  end if;
  RETURN NEW;
end;
$$
language plpgsql;

-->Funcionario
CREATE TRIGGER duplicidade_func
  BEFORE INSERT OR UPDATE
  ON FUNCIONARIO
  FOR EACH ROW EXECUTE PROCEDURE duplicidade_func();
CREATE OR REPLACE FUNCTION duplicidade_func()
  RETURNS TRIGGER AS $$
begin
  IF EXISTS(SELECT *
            FROM FUNCIONARIO
            WHERE NOME_FUNCIONARIO = NEW.NOME_FUNCIONARIO
              AND ENDERECO = NEW.ENDERECO
              AND TELEFONE = NEW.TELEFONE)
  THEN
    RAISE EXCEPTION 'Atenção!Funcionario já cadastrado';
  end if;
  RETURN NEW;
end;
$$
language plpgsql;
-->Diarista
CREATE TRIGGER duplicidade_diar
  BEFORE INSERT OR UPDATE
  ON DIARISTA
  FOR EACH ROW EXECUTE PROCEDURE duplicidade_diar();
CREATE OR REPLACE FUNCTION duplicidade_diar()
  RETURNS TRIGGER AS $$
begin
  IF EXISTS(SELECT *
            FROM DIARISTA
            WHERE NOME_DIARISTA = NEW.NOME_DIARISTA
              AND ENDERECO = NEW.ENDERECO
              AND TELEFONE = NEW.TELEFONE)
  THEN
    RAISE EXCEPTION 'Atenção!Diarista já cadastrado';
  end if;
  RETURN NEW;
end;
$$
language plpgsql;
-->Servicos
CREATE TRIGGER duplicidade_serv
  BEFORE INSERT OR UPDATE
  ON SERVICOS
  FOR EACH ROW EXECUTE PROCEDURE duplicidade_serv();
CREATE OR REPLACE FUNCTION duplicidade_serv()
  RETURNS TRIGGER AS $$
begin
  IF EXISTS(SELECT *
            FROM SERVICOS
            WHERE NOME_SERVICO = NEW.NOME_SERVICO
              AND VALOR_SERVICO = NEW.VALOR_SERVICO)
  THEN
    RAISE EXCEPTION 'Atenção!Serviço já cadastrado';
  end if;
  RETURN NEW;
end;
$$
language plpgsql;

-->Categorias
CREATE TRIGGER duplicidade_cat
  BEFORE INSERT OR UPDATE
  ON CATEGORIA_CLIENTE
  FOR EACH ROW EXECUTE PROCEDURE duplicidade_cat();
CREATE OR REPLACE FUNCTION duplicidade_cat()
  RETURNS TRIGGER AS $$
begin
  IF EXISTS(SELECT *
            FROM CATEGORIA_CLIENTE
            WHERE NOME_CATEGORIA = NEW.NOME_CATEGORIA
              AND DESCONTO = NEW.DESCONTO)
  THEN
    RAISE EXCEPTION 'Atenção!Categoria já cadastrada';
  end if;
  RETURN NEW;
end;
$$
language plpgsql;

SELECT * FROM FUNCIONARIO;
----------------------------------------------teste função inserir------------------------------------------------------
select inserir('funcionario', ''''' ,''rua 18'',''98867887731231''');
select inserir('categoria_cliente', '''platina3'',''90''');
select inserir('cliente', '''henrique'',''9098877889'',''1''');
select inserir('diarista', '''paula'',''bairro dirceu'',''1234567777''');
select inserir('servicos', '''lavar roupa'',''25''');

insert into FUNCIONARIO values (default,'','rua20','65767565765');

select deletar('funcionario','nome_funcionario','');
------------------------------------------------------------------------------------------------------------------------

