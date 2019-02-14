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

