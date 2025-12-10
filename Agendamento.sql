/*
## 🔹 3. Agendamento

**RB11** – Todo **agendamento** deve conter: data, hora e status (agendado, realizado, cancelado).

**RB12** – Um mesmo paciente pode ter **vários agendamentos** (exames distintos ou reagendamentos).

**RB13** – O sistema deve validar conflito de horário (não permitir dois exames no mesmo horário e local).

**RB14** – O agendamento pode ser cancelado antes da realização; o motivo deve ser informado (ausência, erro de sistema, recusa etc.).
*/
declare
  -- Parametros
  p_id_paciente tb_paciente_teste_naty.id_paciente%type;

  -- Array
  type v_exames is varray(10) of number;
  type v_datas is varray(10) of date;

  p_id_exame       v_exames;
  p_dt_agendamento v_datas;

  -- Variaveis auxiliar
  v_validacao       varchar2(1);
  v_validacao_date  varchar2(1);
  v_nome_exame      tb_exame_teste_naty.nome%type;
  v_nome_paciente   tb_paciente_teste_naty.nome%type;
  v_dt_agendamento  date;
  v_seq_agendamento number;

begin
  -- Inicialização dos arrays
  p_dt_agendamento := v_datas();
  p_id_exame       := v_exames();

  -- Definindo quantidade do array
  p_id_exame.extend(2);
  p_dt_agendamento.extend(2);

  -- Valores dos parametros
  p_id_paciente := 1;

  p_id_exame(1) := 1;
  p_id_exame(2) := 2;

  p_dt_agendamento(1) := to_date('12/12/2025 14:56:00',
                                 'dd/mm/yyyy hh24:mi:ss');
  p_dt_agendamento(2) := to_date('26/12/2025 08:30:00',
                                 'dd/mm/yyyy hh24:mi:ss');

  -- Informa nome do paciente
  begin
    select p.nome
      into v_nome_paciente
      from tb_paciente_teste_naty p
     where p.id_paciente = p_id_paciente;
  exception
    when no_data_found then
      dbms_output.put_line('Paciente nao cadastrado no sistema.');
    when others then
      dbms_output.put_line('Erro ao pesquisar nome do paciente. Erro: ' ||
                           sqlerrm);
  end;

  for i in 1 .. p_id_exame.count loop
  
    -- Informar nome do exame
    begin
      select e.nome
        into v_nome_exame
        from tb_exame_teste_naty e
       where e.id_exame = p_id_exame(i);
    exception
      when no_data_found then
        v_nome_exame := null;
      when others then
        v_nome_exame := null;
        dbms_output.put_line('Erro ao pesquisar nome do exame. Erro: ' ||
                             sqlerrm);
    end;
  
    -- Verificar se exame ja estar agendado
    begin
      select 'S', to_char(age.dt_realizacao, 'dd/mm/yyyy')
        into v_validacao, v_dt_agendamento
        from tb_agendamento_teste_naty age
       where age.id_paciente = p_id_paciente
         and age.id_exame = p_id_exame(i)
         and age.dt_realizacao = p_dt_agendamento(i);
    exception
      when no_data_found then
        v_validacao := 'N';
      when others then
        dbms_output.put_line('Erro ao verificar agendamento. Erro: ' ||
                             sqlerrm);
    end;
  
    if v_validacao = 'S' then
      dbms_output.put_line('Exame ' || v_nome_exame ||
                           ' já está agendado para a data: ' ||
                           v_dt_agendamento);
    else
      -- Verifica se existe algum exame agendado para a data informada
      begin
        select 'S'
          into v_validacao_date
          from tb_agendamento_teste_naty agt
         where agt.id_paciente = p_id_paciente
           and agt.dt_realizacao = p_dt_agendamento(i);
      exception
        when no_data_found then
          v_validacao_date := 'N';
        when others then
          v_validacao_date := 'N';
          dbms_output.put_line('Erro ao validar data existente de agendamento. Erro: ' ||
                               sqlerrm);
      end;
    
      if v_validacao_date = 'S' then
        dbms_output.put_line('Já existe exames agendados para a data/hora informada. Por gentileza, informar nova data ou remarcar exame agendado.');
      else
        -- Gera id de agendamento
        begin
          select max(ge.id_agendamento) + 1
            into v_seq_agendamento
            from tb_agendamento_teste_naty ge;
        exception
          when no_data_found then
            v_seq_agendamento := 1;
          when others then
            dbms_output.put_line('Erro ao pesquisar sequencia de agendamentos. Erro: ' ||
                                 sqlerrm);
        end;
      
        begin
          insert into tb_agendamento_teste_naty
          values
            (v_seq_agendamento,
             p_dt_agendamento(i),
             'Agendado',
             p_id_paciente,
             p_id_exame(i));
        
          commit;
          dbms_output.put_line('---- Dados do agendamento ----');
          dbms_output.put_line('Exame: ' || v_nome_exame);
          dbms_output.put_line('Paciente: ' || v_nome_paciente);
          dbms_output.put_line('Data do agendamento: ' ||
                               p_dt_agendamento(i));
          dbms_output.put_line('');
        
        exception
          when others then
            rollback;
            dbms_output.put_line('Erro ao concluir agendamento. Erro: ' ||
                                 sqlerrm);
        end;
      end if;
    end if;
  end loop;
end;

--select *  from tb_agendamento_teste_naty
