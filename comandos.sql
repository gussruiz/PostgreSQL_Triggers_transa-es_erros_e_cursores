-- aula 1

CREATE TABLE aluno (
    id SERIAL PRIMARY KEY,
	primeiro_nome VARCHAR(255) NOT NULL,
	ultimo_nome VARCHAR(255) NOT NULL,
	data_nascimento DATE NOT NULL
);

CREATE TABLE categoria (
    id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE curso (
    id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	categoria_id INTEGER NOT NULL REFERENCES categoria(id)
);

CREATE TABLE aluno_curso (
	aluno_id INTEGER NOT NULL REFERENCES aluno(id),
	curso_id INTEGER NOT NULL REFERENCES curso(id),
	PRIMARY KEY (aluno_id, curso_id)
);

create table instrutor(
	id serial primary key,
	nome varchar(255) not null,
	salario decimal(10, 2)
);

create or replace function cria_curso(nome_curso varchar, nome_categoria varchar) returns void as $$
	declare
		id_categoria integer;
	begin
		select id into id_categoria from categoria where nome = nome_categoria;
		
		if not found then
			insert into categoria(nome) values (nome_categoria) returning id into id_categoria;
		end if;
		
		insert into curso(nome, categoria_id) values (nome_curso, id_categoria);
	end;
$$ language plpgsql;

select cria_curso('PHP', 'Programação');

select * from curso;
select * from categoria;

select cria_curso('Java', 'Programação');

select * from curso;
select * from categoria;

create table log_instrutores(
	id serial primary key,
	informacao varchar(255),
	momento_criacao timestamp default current_timestamp
);

create or replace function cria_instrutor () returns trigger as $$
	declare
		media_salarial decimal;
		instrutores_recebem_menos integer default 0;
		total_instrutores integer default 0;
		salario decimal;
		percentual decimal(5, 2);
	begin
		select avg(instrutor.salario) into media_salarial from instrutor where id <> new.id;

		if new.salario > media_salarial then
			insert into log_instrutores (informacao) values (new.nome || 'recebe acima da média');
		end if;
		
		for salario in select instrutor.salario from instrutor where id <> new.id loop
			total_instrutores := total_instrutores + 1;
			
			if new.salario > salario then
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			end if;
		end loop;
		
		percentual = instrutores_recebem_menos::decimal / total_instrutores::decimal * 100;
			
		insert into log_instrutores (informacao) 
			values (new.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');

		return new;
	end;
$$ language plpgsql;

create trigger cria_log_instrutor after insert or update on instrutor
	for each row execute function cria_instrutor();

select * from instrutor;

select * from log_instrutores;

insert into instrutor (nome, salario) values ('Outra Pessoa De Novo', 600);

-- aula 2

-- foram feitos alterações no cod anterior sobre transações

begin
insert into instrutor (nome, salario) values ('Maria', 700);
rollback;

-- aula 3

create or replace function cria_instrutor () returns trigger as $$
	declare
		media_salarial decimal;
		instrutores_recebem_menos integer default 0;
		total_instrutores integer default 0;
		salario decimal;
		percentual decimal(5, 2);
	begin
		select avg(instrutor.salario) into media_salarial from instrutor where id <> new.id;

		if new.salario > media_salarial then
			insert into log_instrutores (informacao) values (new.nome || 'recebe acima da média');
		end if;
		
		for salario in select instrutor.salario from instrutor where id <> new.id loop
			total_instrutores := total_instrutores + 1;
			
			if new.salario > salario then
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			end if;
		end loop;
		
		percentual = instrutores_recebem_menos::decimal / total_instrutores::decimal * 100;
			
		insert into log_instrutores (informacao, teste) 
			values (new.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');

		return new;
		exception 
			when undefined_column then 
				raise notice 'Algo de errado não está certo';
				return new;
	end;
$$ language plpgsql;


insert into instrutor (nome, salario) values ('João', 10000);
select * from log_instrutores;
select * from instrutor;

create or replace function cria_instrutor () returns trigger as $$
	declare
		media_salarial decimal;
		instrutores_recebem_menos integer default 0;
		total_instrutores integer default 0;
		salario decimal;
		percentual decimal(5, 2);
	begin
		select avg(instrutor.salario) into media_salarial from instrutor where id <> new.id;

		if new.salario > media_salarial then
			insert into log_instrutores (informacao) values (new.nome || 'recebe acima da média');
		end if;
		
		for salario in select instrutor.salario from instrutor where id <> new.id loop
			total_instrutores := total_instrutores + 1;
			
			if new.salario > salario then
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			end if;
		end loop;
		
		percentual = instrutores_recebem_menos::decimal / total_instrutores::decimal * 100;
			
		insert into log_instrutores (informacao, teste) 
			values (new.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');

		return new;
		exception 
			when undefined_column then 
				raise notice 'Algo de errado não está certo';
				raise exception 'Erro complicado de resolver'; 
				return new;
	end;
$$ language plpgsql;


insert into instrutor (nome, salario) values ('Grabiel', 300);

drop trigger cria_log_instrutor on instrutor;


create trigger cria_log_instrutor before insert or update on instrutor
	for each row execute function cria_instrutor();
	
create or replace function cria_instrutor () returns trigger as $$
	declare
		media_salarial decimal;
		instrutores_recebem_menos integer default 0;
		total_instrutores integer default 0;
		salario decimal;
		percentual decimal(5, 2);
	begin
		select avg(instrutor.salario) into media_salarial from instrutor where id <> new.id;

		if new.salario > media_salarial then
			insert into log_instrutores (informacao) values (new.nome || 'recebe acima da média');
		end if;
		
		for salario in select instrutor.salario from instrutor where id <> new.id loop
			total_instrutores := total_instrutores + 1;
			
			if new.salario > salario then
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			end if;
		end loop;
		
		percentual = instrutores_recebem_menos::decimal / total_instrutores::decimal * 100;
		assert percentual < 100::decimal, 'Instrutores novos não podem receber mais do que todos os antigos';
		
		insert into log_instrutores (informacao) 
			values (new.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');

		return new;
	end;
$$ language plpgsql;

insert into instrutor (nome, salario) values ('Grabiel', 2000);

select * from log_instrutores;
select * from instrutor;
insert into instrutor (nome, salario) values ('Grabiel', 11000);


-- aula 4