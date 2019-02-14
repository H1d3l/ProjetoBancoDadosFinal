drop schema shema_empreguete_new cascade ;
create schema shema_empreguete_new;

CREATE TABLE CATEGORIA_CLIENTE
(
  ID_CATEGORIA   SERIAL UNIQUE PRIMARY KEY,
  NOME_CATEGORIA VARCHAR(100) NOT NULL,
  DESCONTO       FLOAT        NOT NULL
);

CREATE TABLE CLIENTE
(
  ID_CLIENTE        SERIAL UNIQUE PRIMARY KEY,
  NOME_CLIENTE      VARCHAR(200) NOT NULL,
  TELEFONE          VARCHAR(30)  NOT NULL,
  ID_CATEGORIA_CLIENTE INT REFERENCES CATEGORIA_CLIENTE (ID_CATEGORIA)
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
  ID_ORDEM_DE_SERVICO SERIAL UNIQUE PRIMARY KEY,
  ID_CLIENTE             INT REFERENCES CLIENTE (ID_CLIENTE),
  ID_FUNCIONARIO         INT REFERENCES FUNCIONARIO (ID_FUNCIONARIO),
  ID_DIARISTA            INT REFERENCES DIARISTA (ID_DIARISTA),
  DATA                DATE  NOT NULL,
  HORA                TIME  NOT NULL,
  VALOR_TOTAL         FLOAT NOT NULL,
  STATUS              VARCHAR(100)
);

CREATE TABLE ITEM_ORDEM_DE_SERVICO
(
  ID_ITEM_ORDEM_DE_SERVICO SERIAL UNIQUE PRIMARY KEY,
  ID_ORDEM_DE_SERVICO         INT REFERENCES ORDEM_DE_SERVICO (ID_ORDEM_DE_SERVICO),
  ID_SERVICO                  INT REFERENCES SERVICOS (ID_SERVICO),
  VALOR                    INT NOT NULL
);

-------------------------------------------------- Funções Genericas----------------------------------------------------
  ---> Inserir
CREATE OR REPLACE FUNCTION INSERIR(TABELA TEXT, VALOR TEXT)
  RETURNS VOID AS
$$
DECLARE
  COMANDO TEXT;
BEGIN
  COMANDO := 'INSERT INTO ' || $1 || ' VALUES(DEFAULT,' || $2 ||');';
  EXECUTE COMANDO;

END;
$$ LANGUAGE plpgsql;
------------------------------------------------------------------------------------------------------------------------
--->Update
------------------------------------------------------------------------------------------------------------------------
create or replace function atualizar(tabela text, campo text, valornovo text, condicao text, valor_condicao text)
  returns void as
$$
declare
  comando TEXT;
begin

  IF(NOT EXISTS(SELECT * FROM CLIENTE WHERE campo ILIKE valor_condicao) OR valor_condicao  IS NULL) THEN
    RAISE 'CLIENTE % NÃO EXISTE NESTE BANCO DE DADOS',valor_condicao;

    ELSIF (NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE campo ILIKE valor_condicao) OR valor_condicao IS NULL) THEN
    RAISE 'FUNCIONARIO % NÃO EXISTE,NESTE BANCO DE DADOS', valor_condicao;

    ELSIF(NOT EXISTS(SELECT * FROM DIARISTA WHERE campo ILIKE valor_condicao) OR valor_condicao IS NULL) THEN
    RAISE 'DIARISTA % NÃO EXISTE, NESTE BANCO DE DADOS', valor_condicao;

    ELSIF(NOT EXISTS(SELECT * FROM SERVICOS WHERE campo ILIKE valor_condicao) OR valor_condicao IS NULL) THEN
    RAISE 'SERVICO % NÃO EXISTE,NESTE BANCO DE DADOS', valor_condicao;
    END IF;

  comando := 'UPDATE ' || tabela || ' SET ' || $2 || ' = ' || $3 || 'where ' || $4 || ' = ' || valor_condicao;
  execute comando;


end;
$$ language plpgsql;
------------------------------------------------------------------------------------------------------------------------

--->Delete
create or replace function deletar(tabela text, campo text, valor text) returns void as
$$
declare
  comando text := 'delete from ' || $1 || ' where ' || $2 || '=''' || $3 || '''';

begin
   IF(NOT EXISTS(SELECT * FROM CLIENTE WHERE campo ILIKE valor) OR valor  IS NULL) THEN
    RAISE 'CLIENTE % NÃO EXISTE NESTE BANCO DE DADOS',valor;

    ELSIF (NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE campo ILIKE valor) OR valor IS NULL) THEN
    RAISE 'FUNCIONARIO % NÃO EXISTE,NESTE BANCO DE DADOS', valor;

    ELSIF(NOT EXISTS(SELECT * FROM DIARISTA WHERE campo ILIKE valor) OR valor IS NULL) THEN
    RAISE 'DIARISTA % NÃO EXISTE, NESTE BANCO DE DADOS', valor;

    ELSIF(NOT EXISTS(SELECT * FROM SERVICOS WHERE campo ILIKE valor) OR valor IS NULL) THEN
    RAISE 'SERVICO % NÃO EXISTE,NESTE BANCO DE DADOS', valor;
    END IF;

  execute comando;


end;
$$ language plpgsql;
------------------------------------------------------------------------------------------------------------------------


--------------> CRIAR ORDEM DE SERVIÇO:
CREATE OR REPLACE FUNCTION criar_ordem_de_servico (ID_ORDEM_SERV INT ,NOME_CLI VARCHAR(100), NOME_FUN VARCHAR(100),NOME_DIA VARCHAR(100),
DATA date,HORA time,NOME_SERV VARCHAR(100)) RETURNS TEXT AS
$$

  DECLARE
  var_id_cliente INT;
  var_id_categoria INT;
  var_id_funcionario INT;
  var_id_diarista INT;
  var_id_servico INT;
  var_valor_servico FLOAT;
  var_valor_desconto FLOAT;
  preco_total FLOAT;

  BEGIN
    IF(NOT EXISTS(SELECT * FROM CLIENTE WHERE NOME_CLIENTE ILIKE NOME_CLI) OR NOME_CLI  IS NULL) THEN
    RAISE 'CLIENTE % NÃO EXISTENTE, CADASTRE PRIMEIRO O CLIENTE',NOME_CLI;

    ELSIF (NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE NOME_FUNCIONARIO ILIKE NOME_FUN) OR NOME_FUN IS NULL) THEN
    RAISE 'FUNCIONARIO % NÃO EXISTENTE, CADASTRE PRIMEIRO O/A FUNCIONARIO', NOME_FUN;

    ELSIF(NOT EXISTS(SELECT * FROM DIARISTA WHERE NOME_DIARISTA ILIKE NOME_DIA) OR NOME_DIA IS NULL) THEN
    RAISE 'DIARISTA % NÃO EXISTENTE, CADASTRE PRIMEIRO O/A DIARISTA', NOME_DIA;

    ELSIF(NOT EXISTS(SELECT * FROM SERVICOS WHERE NOME_SERVICO ILIKE NOME_SERV) OR NOME_SERV IS NULL) THEN
    RAISE 'SERVICO % NÃO EXISTENTE, CADASTRE PRIMEIRO O SERVICO', NOME_SERV;

    ELSEIF DATA<CURRENT_DATE THEN RAISE 'A DATA NAO PODE SER INFERIOR A DATA DE HOJE';

    END IF;

    SELECT ID_CLIENTE, ID_CATEGORIA_CLIENTE INTO var_id_cliente, var_id_categoria FROM CLIENTE WHERE NOME_CLIENTE ILIKE NOME_CLI;

    SELECT ID_FUNCIONARIO INTO var_id_funcionario FROM FUNCIONARIO WHERE NOME_FUNCIONARIO ILIKE NOME_FUN;

    SELECT ID_DIARISTA INTO var_id_diarista FROM DIARISTA WHERE NOME_DIARISTA ILIKE NOME_DIA;

    SELECT ID_SERVICO, VALOR_SERVICO INTO var_id_servico, var_valor_servico FROM SERVICOS WHERE NOME_SERVICO ILIKE NOME_SERV;

    SELECT DESCONTO INTO var_valor_desconto FROM CATEGORIA_CLIENTE WHERE ID_CATEGORIA = var_id_categoria;

    preco_total:= var_valor_servico - (var_valor_servico*var_valor_desconto);


      IF (NOME_CLI IS NOT NULL AND NOME_FUN IS NOT NULL AND NOME_SERV IS NOT NULL) THEN
        IF (EXISTS(SELECT * FROM ORDEM_DE_SERVICO WHERE ID_ORDEM_DE_SERVICO=ID_ORDEM_SERV)) THEN

          INSERT INTO ITEM_ORDEM_DE_SERVICO VALUES(DEFAULT,ID_ORDEM_SERV,var_id_servico,var_valor_servico);

          UPDATE ORDEM_DE_SERVICO SET VALOR_TOTAL = (SELECT SUM(VALOR)-(SUM(VALOR)*var_valor_desconto) FROM ITEM_ORDEM_DE_SERVICO WHERE ID_ORDEM_SERV
            = ID_ORDEM_DE_SERVICO) WHERE ID_ORDEM_DE_SERVICO = ID_ORDEM_SERV;
          RETURN 'MAIS UM SERVICO ADICIONADO A ORDEM DE SERVICO';
        ELSE
          INSERT INTO ORDEM_DE_SERVICO VALUES($1,var_id_cliente,var_id_funcionario,var_id_diarista,DATA,HORA,var_valor_servico,'AGENDADO');
          INSERT INTO ITEM_ORDEM_DE_SERVICO VALUES(DEFAULT,$1,var_id_servico,var_valor_servico);
          RETURN 'SOLICITACAO DA ORDEM DE SERVICO INICIADO';
        END IF;
      ELSE
        RAISE 'VERIFIQUE OS CAMPOS INSERIDOS';
     END IF;

  END;

$$LANGUAGE plpgsql;


---------------------------------------------Trigger--------------------------------------------------------------------
  -------------------------------------------feedback-------------------------------------------------------------------

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
  RETURN NULL;
END;
$$
  LANGUAGE plpgsql;
CREATE TRIGGER TGR_FEEDBACK_OPERACAO  AFTER INSERT OR UPDATE OR DELETE ON funcionario FOR EACH ROW
EXECUTE PROCEDURE FEEDBACK_OPERACAO();
------------------------------------------------------------------------------------------------------------------------
-->Descontos

CREATE OR REPLACE FUNCTION valor_negativo() RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  IF (TG_TABLE_NAME = 'CATEGORIA_CLIENTE' or TG_TABLE_NAME =
                                             'categoria_cliente')
  THEN
    IF NEW.DESCONTO < 0
    then
      RAISE EXCEPTION 'VOCE NÃO PODE INSERIR QUANTIDADE MENOR QUE 0';
    END IF;
  END IF;
  RETURN NEW;
END;
$$
  LANGUAGE plpgsql;
CREATE TRIGGER valor_negativo BEFORE INSERT OR UPDATE ON CATEGORIA_CLIENTE FOR EACH ROW EXECUTE PROCEDURE valor_negativo();


--------------> VERIFICAR DISPONIBILIDADE DE DIARISTA:
CREATE OR REPLACE FUNCTION verifica_disponibilidade() RETURNS TRIGGER AS
$$
BEGIN
  IF (EXISTS(SELECT *
             FROM ordem_de_servico
             WHERE ID_ORDEM_DE_SERVICO <> new.ID_ORDEM_DE_SERVICO
               AND id_diarista = NEW.id_diarista
               AND data = NEW.data
               AND hora = NEW.hora
               and status = 'AGENDADO')) THEN
    RAISE EXCEPTION 'Diarista não disponível para essa data neste horário!';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifica_disponibilidade BEFORE INSERT OR UPDATE ON ordem_de_servico FOR EACH ROW
EXECUTE PROCEDURE verifica_disponibilidade();

------------------------------------------> CANCELAR SOLICITAÇÃO DE SERVIÇO:
CREATE OR REPLACE FUNCTION cancelar_ordem_de_servico(id_ordem_servico INT)
  RETURNS VOID AS
$$
DECLARE
  retornar TEXT;
BEGIN
  IF (NOT EXISTS(SELECT *
                 FROM ORDEM_DE_SERVICO
                 WHERE id_ordem_de_servico = $1)) THEN
    RAISE 'ORDEM DE SERVICO NÃO REGISTRADA NO SISTEMA, CONFIRA SE TODOS OS DADOS ESTÃO CORRETOS';
  ELSIF (EXISTS(SELECT *
                FROM ORDEM_DE_SERVICO
                WHERE id_ordem_de_servico = $1
                  AND STATUS = 'REALIZADO')) THEN
    RAISE 'SERVICO JÁ REALIZADO!';
  END IF;
  SELECT alterar_status('CANCELADO', $1) INTO retornar;
END;
$$ LANGUAGE 'plpgsql';


--------------> ALTERAR STATUS DA SOLICITAÇÃO DE SERVIÇO:
CREATE OR REPLACE FUNCTION alterar_status(status TEXT, id_alterar INT)
  RETURNS VOID AS
$$
BEGIN
  IF (NOT EXISTS(SELECT *
                 FROM ORDEM_DE_SERVICO
                 WHERE ID_ORDEM_DE_SERVICO = $2)) THEN
    RAISE 'ESTE REGISTRO NAO EXISTE, FAVOR CONFERIR OS DADOS';
  ELSIF ($1 NOT LIKE 'AGENDADO' AND $1 NOT LIKE 'REALIZADO' AND $1 NOT
    LIKE 'CANCELADO') THEN
    RAISE 'STATUS INVALIDO';
  END IF;
  UPDATE ORDEM_DE_SERVICO
  SET STATUS = $1
  WHERE ID_ORDEM_DE_SERVICO = $2;
END;
$$ LANGUAGE 'plpgsql';


--------------> VERIFICAR DUPLICIDADE GENÉRICO:
CREATE OR REPLACE FUNCTION verifica_duplicidade()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_TABLE_NAME = 'diarista') THEN
    IF EXISTS(SELECT *
              FROM DIARISTA
              WHERE NOME_DIARISTA =
                    NEW.NOME_DIARISTA
                AND ENDERECO = NEW.ENDERECO
                AND TELEFONE =
                    NEW.TELEFONE) THEN
      RAISE EXCEPTION 'Diarista já cadastrado!';
    END IF;
  ELSIF (TG_TABLE_NAME = 'categoria_cliente') THEN
    IF EXISTS(SELECT *
              FROM CATEGORIA_CLIENTE
              WHERE NOME_CATEGORIA = NEW.NOME_CATEGORIA
                AND DESCONTO = NEW.DESCONTO)
    THEN
      RAISE EXCEPTION 'Categoria já cadastrada!';
    END IF;
  ELSIF (TG_TABLE_NAME = 'servicos') THEN
    IF EXISTS(SELECT *
              FROM SERVICOS
              WHERE NOME_SERVICO =
                    NEW.NOME_SERVICO
                AND VALOR_SERVICO = NEW.VALOR_SERVICO) THEN
      RAISE EXCEPTION 'Serviço já cadastrado!';
    END IF;
  ELSIF (TG_TABLE_NAME = 'funcionario') THEN
    IF EXISTS(SELECT *
              FROM FUNCIONARIO
              WHERE NOME_FUNCIONARIO = NEW.NOME_FUNCIONARIO
                AND ENDERECO =
                    NEW.ENDERECO
                AND TELEFONE = NEW.TELEFONE) THEN
      RAISE EXCEPTION 'Funcionario já cadastrado!';
    END IF;
  ELSIF (TG_TABLE_NAME = 'cliente') THEN
    IF EXISTS(SELECT *
              FROM CLIENTE
              WHERE NOME_CLIENTE =
                    NEW.NOME_CLIENTE
                AND TELEFONE = NEW.TELEFONE
                AND ID_CATEGORIA_CLIENTE = NEW.ID_CATEGORIA_CLIENTE) THEN
      RAISE EXCEPTION 'Cliente já cadastrado!';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifica_duplicidade BEFORE INSERT OR UPDATE ON DIARISTA FOR EACH ROW EXECUTE PROCEDURE verifica_duplicidade();
CREATE TRIGGER verifica_duplicidade BEFORE INSERT OR UPDATE ON CLIENTE FOR EACH ROW EXECUTE PROCEDURE verifica_duplicidade();
CREATE TRIGGER verifica_duplicidade BEFORE INSERT OR UPDATE ON FUNCIONARIO FOR EACH ROW EXECUTE PROCEDURE verifica_duplicidade();
CREATE TRIGGER verifica_duplicidade BEFORE INSERT OR UPDATE ON SERVICOS FOR EACH ROW EXECUTE PROCEDURE verifica_duplicidade();
CREATE TRIGGER verifica_duplicidade BEFORE INSERT OR UPDATE ON CATEGORIA_CLIENTE FOR EACH ROW EXECUTE PROCEDURE verifica_duplicidade();

-----------------------------------------------------------------------------------------------------------------------------------

-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE CATEGORIA CLIENTE
--Identificado bug ao tentar verificar valor do desconto.
/*
create or replace function notvaluesnullcategoriacliente()
returns trigger as $$
  begin
    if new.NOME_CATEGORIA is null  or new.NOME_CATEGORIA = '' then
    raise exception 'Nome da categoria está vazio ou nulo';
    end if ;

    if new.DESCONTO is null  or new.DESCONTO = '' then
    raise exception 'Desconto está vazio ou nulo';
    end if ;
    return new;
  end;

  $$language plpgsql;

create  trigger notnullcategoriacliente before insert or update on CATEGORIA_CLIENTE  FOR EACH ROW
EXECUTE PROCEDURE notvaluesnullcategoriacliente();
*/
------------------------------------------------------------------------------------------------------------------------
/*
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

    if new.ID_CATEGORIA_CLIENTE is null  or new.ID_CATEGORIA_CLIENTE = '' then
    raise exception 'Categoria do cliente está vazio ou nulo';
    end if ;


    return new;
  end;

  $$language plpgsql;

create  trigger notnullcliente before insert or update on CLIENTE  FOR EACH ROW EXECUTE PROCEDURE notvaluesnullcliente();
*/
-------------------------------------------------------------------------------------------------------------------------
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

    return new;
  end;
  $$language plpgsql;

create  trigger notnulldiarista before insert or update on DIARISTA  FOR EACH ROW EXECUTE PROCEDURE notvaluesnulldiarista();
----------------------------------------------------------------------------------------------------------------------------
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
    return new;
  end;

  $$language plpgsql;

create  trigger notnullfunc before insert or update on funcionario  FOR EACH ROW EXECUTE PROCEDURE notvaluesnullfuncionario();


-------TRIGGER NAO ACEITA VALORES NULOS OU VAZIOS DE FUNCIONARIOS
--Identificado bug ao tentar verificar valor do servico.
/*
create or replace function notvaluesnullservico()
returns trigger as $$
  begin
    if new.NOME_SERVICO is null  or new.NOME_SERVICO = '' then
    raise exception 'Nome está vazio ou nulo';
    end if ;

    if new.VALOR_SERVICO is null  or new.VALOR_SERVICO = '' then
    raise exception 'Valor está vazio ou nulo';
    end if ;

    return new;
  end;

  $$language plpgsql;

create  trigger notnullservico before insert or update on SERVICOS  FOR EACH ROW EXECUTE PROCEDURE notvaluesnullservico();

*/
----------------------------------------------teste função--------------------------------------------------------------
/*
select inserir('funcionario', '''PABLO'' ,''Rua do sucesso'',''988678877''');
select inserir('funcionario', '''pablo'' ,''rua 18'',''988678877''');
select inserir('categoria_cliente', '''platina4'',''-30''');
select inserir('categoria_cliente', '''platina3'',''90.00''');
select inserir('cliente', '''EDSON'',''9098877889'',''1''');
select inserir('diarista', '''MARIA'',''bairro dirceu'',''1234567777''');
select inserir('servicos', '''LAVAR'',''25.00''');
select atualizar('funcionario', 'nome_funcionario', '''junior''', 'id_funcionario', '5');
select deletar('funcionario', 'nome_funcionario', 'daGoberto5');
select deletar('cliente', 'nome_cliente', 'henrique');


select criar_ordem_de_servico(1,'edson', 'pablo', 'maria', '14-02-2019', '12:30','PASSAR');
select criar_ordem_de_servico(1,'edson', 'pablo', 'maria', '14-02-2019', '12:30','LAVAR');
select criar_ordem_de_servico(1,'edson', 'pablo', 'maria', '12-12-2018', '12:30','VARRER');
select criar_ordem_de_servico(1,'edson', 'pablo', 'maria', '12-12-2018', '12:30','COZINHAR');

select criar_ordem_de_servico(2,'pedro', 'pablo', 'maria', '12-12-2018', '12:30','LAVAR');
select criar_ordem_de_servico(2,'pedro', 'pablo', 'maria', '12-12-2018', '12:30','VARRER');
select criar_ordem_de_servico(2,'pedro', 'pablo', 'maria', '12-12-2019', '11:30','VARRER');
select criar_ordem_de_servico(2,'pedro', 'pablo', 'maria', '12-12-2019', '11:30','LAVAR');
select criar_ordem_de_servico(2,'pedro', 'pablo', 'maria', '12-12-2019', '11:30','COZINHAR');

select criar_ordem_de_servico(3,'JOÃO', 'pablo', 'maria', '12-12-2017', '11:30','PASSAR');
select criar_ordem_de_servico(3,'JOÃO', 'CHICO', 'maria', '12-12-2017', '11:30','VARRER');
select criar_ordem_de_servico(3,'JOÃO', 'pablo', 'maria', '12-12-2017', '11:30','LAVAR');

INSERT INTO CATEGORIA_CLIENTE(NOME_CATEGORIA, DESCONTO)
VALUES (NULL, NULL);
INSERT INTO CATEGORIA_CLIENTE(NOME_CATEGORIA, DESCONTO)
VALUES ('PRATA', 0.3);
INSERT INTO CATEGORIA_CLIENTE(NOME_CATEGORIA, DESCONTO)
VALUES ('OURO', 0.5);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, ID_CATEGORIA_CLIENTE)
VALUES ('JOÃO', '998500295', 1);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, ID_CATEGORIA_CLIENTE)
VALUES ('PEDRO', '998657901', 2);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, ID_CATEGORIA_CLIENTE)
VALUES ('RICARDO', '5132715375', 3);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, ID_CATEGORIA_CLIENTE)
VALUES ('CONCEIÇÃO', '1231242615', 2);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, ID_CATEGORIA_CLIENTE)
VALUES ('EDSON', '1312213333', 3);
INSERT INTO CLIENTE(NOME_CLIENTE, TELEFONE, ID_CATEGORIA_CLIENTE)
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
INSERT INTO SERVICOS
VALUES (DEFAULT, 'VARRER ', 20.00);
INSERT INTO SERVICOS
VALUES (DEFAULT, 'LAVAR', 20.00);
INSERT INTO SERVICOS
VALUES (DEFAULT, 'COZINHAR', 30.00);
INSERT INTO SERVICOS
VALUES (DEFAULT, 'PASSAR', 50.00);
*/