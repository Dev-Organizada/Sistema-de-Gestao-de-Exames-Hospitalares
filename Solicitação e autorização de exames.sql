/*
## 🔹 2. Solicitação e autorização de exames

**RB06** – A solicitação de exame é sempre gerada por um médico para um paciente.

**RB07** – Cada solicitação pode conter **um ou mais exames**.

**RB08** – Caso o exame **exija autorização**, o sistema deve registrar:

- Data e hora da solicitação da autorização;
- Número de protocolo da autorização;
- Status (pendente, autorizado, negado).
    
    **RB09** – Se o exame for negado por **carência do convênio**, o sistema deve registrar o motivo e marcar a solicitação como **cancelada**.
    **RB10** – Após a autorização, o exame fica disponível para **agendamento**.   
*/

declare
  -- Parametros
  p_id_medico   tb_medico_teste_naty.id_medico%type;
  p_id_paciente tb_paciente_teste_naty.id_paciente%type;

  -- Criação do vetor de exames
  type v_exames is varray(10) of number;
  p_id_exame v_exames;

  -- Criação do vetor para saber se precisa de autorização
  type v_autorizacao is varray(10) of varchar2(1);
  ve_autorizacao v_autorizacao;

  -- Variaveis de verificação
  medico          varchar2(1);
  paciente        varchar2(1);
  exame           varchar2(1);
  dt_fim_carencia varchar2(50);
  autorizacao     varchar2(1);

  -- Variaveis de sequencia
  v_seq_solicitacao number;
  v_seq_auditoria   number;
  v_seq_autorizacao number;

  --Procedure para validar parametros
  procedure verifica_dados(p_id_medico   number,
                           p_id_paciente number,
                           p_id_exame    v_exames) is
  
  begin
    -- Verificar se medico existe
    begin
      select 'S'
        into medico
        from tb_medico_teste_naty m
       where m.id_medico = p_id_medico;
    exception
      when no_data_found then
        medico := 'N';
    end;
  
    -- Verificar se paciente existe
    begin
      select 'S'
        into paciente
        from tb_paciente_teste_naty p
       where p.id_paciente = p_id_paciente;
    
    exception
      when no_data_found then
        paciente := 'N';
    end;
  
    -- Verifica se tem carencia
    begin
      select to_char(c.dt_contratacao + c.carencia, 'dd/mm/rrrr')
        into dt_fim_carencia
        from tb_convenio_teste_naty c
       where c.id_paciente = p_id_paciente;
    exception
      when no_data_found then
        dt_fim_carencia := null;
    end;
  
    -- Inicializa o array de autorizacao
    ve_autorizacao := v_autorizacao();
  
    -- Cria as posiçoes de acordo com o array de exames
    if p_id_exame.count > 0 then
      ve_autorizacao.extend(p_id_exame.count);
    end if;
  
    -- Verificar se exame existe e se precisa de autorização
    for x in 1 .. p_id_exame.count loop
    
      begin
        select 'S', e.autorizacao
          into exame, ve_autorizacao(x)
          from tb_exame_teste_naty e
         where e.id_exame = p_id_exame(x);
      exception
        when no_data_found then
          exame := 'N';
          ve_autorizacao(x) := 'N';
      end;
    
      if exame = 'N' then
        exit;
      end if;
    
    end loop;
  end;

  -- Procedure de registro de historico
  procedure registra_auditoria(p_acao        number,
                               p_id_paciente number,
                               p_id_exame    number) is
    /* 
      Descrição dos status do historico:
      1 = Pendente
      2 = Autorizado
      3 = Negado
      4 = Cancelado
      5 = Disponivel para agedamento
    */
  
  begin
    -- Criar sequencia para registro do ID da auditoria
    begin
      select nvl(max(a.id_status_ex_pa), 0) + 1
        into v_seq_auditoria
        from au_historico_exame_teste_naty a;
    exception
      when no_data_found then
        v_seq_auditoria := 1;
    end;
  
    if p_acao = 1 then
      begin
        insert into au_historico_exame_teste_naty
        values
          (v_seq_auditoria, p_id_paciente, p_id_exame, sysdate, 'Pendente');
        commit;
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar historico. Erro: ' ||
                               sqlerrm);
      end;
    
    elsif p_acao = 2 then
      begin
        insert into au_historico_exame_teste_naty
        values
          (v_seq_auditoria,
           p_id_paciente,
           p_id_exame,
           sysdate,
           'Autorizado');
        commit;
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar historico. Erro: ' ||
                               sqlerrm);
      end;
    
    elsif p_acao = 3 then
      begin
        insert into au_historico_exame_teste_naty
        values
          (v_seq_auditoria, p_id_paciente, p_id_exame, sysdate, 'Negado');
        commit;
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar historico. Erro: ' ||
                               sqlerrm);
      end;
    
    elsif p_acao = 4 then
      begin
        insert into au_historico_exame_teste_naty
        values
          (v_seq_auditoria,
           p_id_paciente,
           p_id_exame,
           sysdate,
           'Cancelado');
        commit;
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar historico. Erro: ' ||
                               sqlerrm);
      end;
    elsif p_acao = 5 then
      begin
        insert into au_historico_exame_teste_naty
        values
          (v_seq_auditoria,
           p_id_paciente,
           p_id_exame,
           sysdate,
           'Disponivel para agedamento');
        commit;
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar historico. Erro: ' ||
                               sqlerrm);
      end;
    end if;
  end;

  -- Procedure de criação de solicitação
  procedure cria_solicitacao(p_id_paciente number,
                             p_id_medico   number,
                             p_id_exame    v_exames) is
  begin
    -- Criar sequencia para registro do ID da solicitação
    begin
      select nvl(max(s.id_solicitacao), 0) + 1
        into v_seq_solicitacao
        from tb_solicitacao_teste_naty s;
    exception
      when no_data_found then
        v_seq_solicitacao := 1;
    end;
  
    -- Criação da solicitação
    begin
      insert into tb_solicitacao_teste_naty
      values
        (v_seq_solicitacao, p_id_paciente, p_id_medico, sysdate);
    
      commit;
    
    exception
      when others then
        rollback;
        dbms_output.put_line('Erro ao cadastrar solicitação. Erro: ' ||
                             sqlerrm);
    end;
  
    -- Criação dos itens da solicitação  
    for x in 1 .. p_id_exame.count loop
    
      begin
        insert into tb_itens_solicitacao_teste_naty
        values
          (v_seq_solicitacao, p_id_exame(x));
      
        commit;
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao cadastrar itens da solicitação. Erro: ' ||
                               sqlerrm);
      end;
    
    end loop;
  
    -- Registro na tabela de auditoria - Status Pendente
    for x in 1 .. p_id_exame.count loop
      registra_auditoria(1, p_id_paciente, p_id_exame(x));
    end loop;
  end;

  -- Procedure de criação de autorização
  procedure cria_autorizacao(p_acao        number,
                             p_solicitacao number,
                             p_id_exame    number) is
    /*
      1 = Negado
      2 = Autorizado
    */
  begin
  
    begin
      select nvl(max(au.id_autorizacao), 0) + 1
        into v_seq_autorizacao
        from tb_autorizacao_teste_naty au;
    exception
      when no_data_found then
        v_seq_autorizacao := 1;
    end;
  
    if p_acao = 1 then
      begin
      
        insert into tb_autorizacao_teste_naty
        values
          (v_seq_autorizacao,
           sysdate,
           to_number(to_char(sysdate, 'rrrrmmdd')) ||
           ROUND(DBMS_RANDOM.VALUE(1, 100)), -- converter a data atual em numero e concatenar com um numero aleatorio
           'N',
           'Carência de plano',
           p_solicitacao);
      
        commit;
      
        -- Registro na tabela de auditoria - Status Negado
          registra_auditoria(3, p_id_paciente, p_id_exame);

      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar autorização. Erro: ' ||
                               sqlerrm);
      end;
    
    elsif p_acao = 2 then
      begin
        insert into tb_autorizacao_teste_naty
        values
          (v_seq_autorizacao,
           sysdate,
           to_number(to_char(sysdate, 'rrrrmmdd')) ||
           ROUND(DBMS_RANDOM.VALUE(1, 100)), -- converter a data atual em numero e concatenar com um numero aleatorio
           'A',
           null,
           p_solicitacao);
        commit;
      
        -- Registro na tabela de auditoria - Status Autorizado
          registra_auditoria(2, p_id_paciente, p_id_exame);
      
      exception
        when others then
          rollback;
          dbms_output.put_line('Erro ao registrar autorização. Erro: ' ||
                               sqlerrm);
      end;
    end if;
  end;

begin
  -- Parametros
  p_id_medico   := 3;
  p_id_paciente := 1;

  p_id_exame := v_exames(); -- inicializa p vetor
  p_id_exame.extend(2); -- define o tamanho = 2, ou seja, o teste será feito com dois exames em uma solicitação
  
  p_id_exame(1) := 1;
  p_id_exame(2) := 2;

  -- Validar se todos os parametros informados estão cadastrados na base de dados
  verifica_dados(p_id_medico, p_id_paciente, p_id_exame);

  /*
      Se todos os parametros estiverem cadastrados, criar registro na tabela de solicitação e itens e
      incluir status de pendente na tabela de auditoria
  */

  if medico = 'N' or paciente = 'N' or exame = 'N' then
    dbms_output.put_line('Um dos paramtros não está cadastrado na base de dados. Favor verificar!');
  else
    cria_solicitacao(p_id_paciente, p_id_medico, p_id_exame);
  end if;

  -- Pausa a sessão por 5.5 segundos para haver diferença entre os status de pendente e autorizados/negados
  dbms_session.sleep(5.5);

  -- Se exame nao precisar de autorização, deve ser registrado na tabela de historico com DISPONIVEL P/ AGENDAMENTO
  -- Se precisar, deve seguir o fluxo de autrização
  for i in 1 .. ve_autorizacao.count loop
    if ve_autorizacao(i) = 'N' then
      -- Registro na tabela de auditoria - Status DISPONIVEL P/ AGENDAMENTO
      registra_auditoria(5, p_id_paciente, p_id_exame(i));
    else
      -- Se paciente tiver carencia, incluir registro na tabela de autorização com o status do exame para cancelado por carência do convênio e 
      -- status cancelado na tabela de historico
      if dt_fim_carencia > sysdate then
        cria_autorizacao(1, v_seq_solicitacao, p_id_exame(i));
      else
        -- Se não houver carencia, aprovar solicitação do exame e incluir status de aprovado na tabela de auditoria
        cria_autorizacao(2, v_seq_solicitacao, p_id_exame(i));
      end if;
    
    end if;
  end loop;

  -- Finalização do procedimento
  dbms_output.put_line('Rotina executada com sucesso.');

exception
  when others then
    dbms_output.put_line('Erro ao executar rotina. Erro: ' || sqlerrm);
end;

-- Validar fluxo
/*
select * from tb_solicitacao_teste_naty order by 1;
select * from tb_itens_solicitacao_teste_naty  order by 1;
select * from au_historico_exame_teste_naty  order by 1;
select * from tb_autorizacao_teste_naty order by 1;
*/

--ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS'; -- alterar formato da sessão
