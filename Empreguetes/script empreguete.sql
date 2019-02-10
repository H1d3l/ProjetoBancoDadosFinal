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
  DATA              DATE  NOT NULL,
  HORA              TIME  NOT NULL,
  SERVICO INT REFERENCES SERVICOS(ID_SERVICO),
  VALOR_TOTAL FLOAT NOT NULL
);

CREATE TABLE ITEM_ORDEM_DE_SERVICO
(
  ID_ITEM_ORDEM_DE_SERVICO SERIAL UNIQUE PRIMARY KEY,
  ORDEM_DE_SERVICO INT REFERENCES ORDEM_DE_SERVICO(ID_ORDEM_DE_SERVICO),
  SERVICO INT REFERENCES SERVICOS(ID_SERVICO),
  VALOR INT NOT NULL

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
VALUES ('JOÃO', '998500295', 1);
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
VALUES ('', 'AVENIDA MIGUEL ROSA', '8798787361');
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

    SELECT ID_DIARISTA INTO var_id_diarista FROM DIARISTA WHERE NOME_DIARISTA_V ILIKE NOME_DIARISTA;

    SELECT ID_SERVICO,VALOR_SERVICO INTO var_id_servico,var_valor_servico FROM SERVICOS WHERE NOME_SERVICO_V ILIKE NOME_SERVICO;

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
-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS
create or replace function notvaluesnull()
returns trigger as $$
  begin
    if new is null  or new = '' then
    raise exception 'CAMPO COM VALOR NULO OU VAZIO';
    end if;
    return null;
  end;

  $$language plpgsql;

create  trigger notnullfunc before insert or update on funcionario  FOR EACH ROW EXECUTE PROCEDURE notvaluesnull();
----------------------------------------------teste função inserir------------------------------------------------------
select inserir('funcionario', ''''' ,''rua 18'',''98867887731231''');
select inserir('categoria_cliente', '''platina3'',''90''');
select inserir('cliente', '''henrique'',''9098877889'',''1''');
select inserir('diarista', '''paula'',''bairro dirceu'',''1234567777''');
select inserir('servicos', '''lavar roupa'',''25''');

insert into FUNCIONARIO values (default,'','rua20','65767565765');

select deletar('funcionario','nome_funcionario','');
------------------------------------------------------------------------------------------------------------------------

