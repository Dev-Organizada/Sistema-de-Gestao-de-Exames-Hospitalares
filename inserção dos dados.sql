-- ===========================================================
-- POPULANDO TABELAS BÁSICAS
-- ===========================================================

-- Convenios
INSERT INTO tb_convenio_teste_naty 
(id_convenio, id_paciente, dt_contratacao, vl_mensalidade, carencia, cobertura, tipo_plano, coparticipacao)
VALUES 
(1, NULL, TO_DATE('2022-01-10', 'YYYY-MM-DD'), 350.00, 30, TO_DATE('2022-02-10', 'YYYY-MM-DD'), 'Premium', 'S');

INSERT INTO tb_convenio_teste_naty 
(id_convenio, id_paciente, dt_contratacao, vl_mensalidade, carencia, cobertura, tipo_plano, coparticipacao)
VALUES 
(2, NULL, TO_DATE('2023-03-01', 'YYYY-MM-DD'), 250.00, 60, TO_DATE('2023-05-01', 'YYYY-MM-DD'), 'Standard', 'N');

-- Categorias de Exame
INSERT INTO tb_categoria_exame_teste_naty (id_categoria_exame, descricao)
VALUES (1, 'Laboratorial');
INSERT INTO tb_categoria_exame_teste_naty (id_categoria_exame, descricao)
VALUES (2, 'Imagem');
INSERT INTO tb_categoria_exame_teste_naty (id_categoria_exame, descricao)
VALUES (3, 'Cardiologia');

-- Exames
INSERT INTO tb_exame_teste_naty (id_exame, nome, preco, tempo_media_realizacao, autorizacao, id_categoria_exame)
VALUES (1, 'Hemograma Completo', 80.00, 0.5, 'N', 1);

INSERT INTO tb_exame_teste_naty (id_exame, nome, preco, tempo_media_realizacao, autorizacao, id_categoria_exame)
VALUES (2, 'Ressonância Magnética', 1200.00, 1.5, 'S', 2);

INSERT INTO tb_exame_teste_naty (id_exame, nome, preco, tempo_media_realizacao, autorizacao, id_categoria_exame)
VALUES (3, 'Eletrocardiograma', 180.00, 0.5, 'N', 3);

-- Pacientes
INSERT INTO tb_paciente_teste_naty (id_paciente, nome, cpf, dt_nascimento, sexo, telefone, id_convenio)
VALUES (1, 'Ana Beatriz Souza', '12345678901', TO_DATE('1990-06-15', 'YYYY-MM-DD'), 'F', '(11)99999-1111', 1);

INSERT INTO tb_paciente_teste_naty (id_paciente, nome, cpf, dt_nascimento, sexo, telefone, id_convenio)
VALUES (2, 'Carlos Mendes', '98765432100', TO_DATE('1985-03-22', 'YYYY-MM-DD'), 'M', '(11)98888-2222', 2);

INSERT INTO tb_paciente_teste_naty (id_paciente, nome, cpf, dt_nascimento, sexo, telefone, id_convenio)
VALUES (3, 'Juliana Lima', '12398765400', TO_DATE('1995-11-10', 'YYYY-MM-DD'), 'F', '(11)97777-3333', 1);

-- Médicos
INSERT INTO tb_medico_teste_naty (id_medico, nome, crm, status)
VALUES (1, 'Dr. Ricardo Oliveira', 'CRM12345', 'A');
INSERT INTO tb_medico_teste_naty (id_medico, nome, crm, status)
VALUES (2, 'Dra. Fernanda Costa', 'CRM54321', 'A');
INSERT INTO tb_medico_teste_naty (id_medico, nome, crm, status)
VALUES (3, 'Dr. Paulo Silva', 'CRM77777', 'I');

-- ===========================================================
-- SOLICITAÇÕES DE EXAMES
-- ===========================================================

INSERT INTO tb_solicitacao_teste_naty (id_solicitacao, id_paciente, id_medico, dt_solicitacao)
VALUES (1, 1, 1, TO_DATE('2024-01-15', 'YYYY-MM-DD'));
INSERT INTO tb_solicitacao_teste_naty (id_solicitacao, id_paciente, id_medico, dt_solicitacao)
VALUES (2, 2, 2, TO_DATE('2024-02-01', 'YYYY-MM-DD'));

-- Itens de solicitação (N:N)
INSERT INTO tb_itens_solicitacao_teste_naty (id_solicitacao, id_exame)
VALUES (1, 1);
INSERT INTO tb_itens_solicitacao_teste_naty (id_solicitacao, id_exame)
VALUES (1, 2);
INSERT INTO tb_itens_solicitacao_teste_naty (id_solicitacao, id_exame)
VALUES (2, 3);

-- ===========================================================
-- AUTORIZAÇÕES
-- ===========================================================

INSERT INTO tb_autorizacao_teste_naty (id_autorizacao, dt_autorizacao, num_protocolo, status, motivo_negado, id_solicitacao)
VALUES (1, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 2024011601, 'A', NULL, 1);

INSERT INTO tb_autorizacao_teste_naty (id_autorizacao, dt_autorizacao, num_protocolo, status, motivo_negado, id_solicitacao)
VALUES (2, TO_DATE('2024-02-03', 'YYYY-MM-DD'), 2024020302, 'N', 'Carência de plano', 2);

-- ===========================================================
-- AGENDAMENTOS
-- ===========================================================

INSERT INTO tb_agendamento_teste_naty (id_agendamento, dt_realizacao, status, id_paciente, id_exame)
VALUES (1, TO_DATE('2024-01-20', 'YYYY-MM-DD'), 'Agendado', 1, 2);

INSERT INTO tb_agendamento_teste_naty (id_agendamento, dt_realizacao, status, id_paciente, id_exame)
VALUES (2, TO_DATE('2024-02-05', 'YYYY-MM-DD'), 'Cancelado', 2, 3);

-- ===========================================================
-- RESULTADOS DE EXAME
-- ===========================================================

INSERT INTO tb_resultado_exame_teste_naty (id_resultado, laudo, dt_liberacao_resultado, senha_acesso, id_autorizacao)
VALUES (1, 'Exame normal, sem alterações significativas.', TO_DATE('2024-01-22', 'YYYY-MM-DD'), 'ABC123', 1);

-- ===========================================================
-- REGISTROS FINANCEIROS
-- ===========================================================

INSERT INTO tb_registro_financeiro_teste_naty (id_registro_fin, id_paciente, id_exame, vl_exame, vl_pago_paciente)
VALUES (1, 1, 2, 1200.00, 0.00);

INSERT INTO tb_registro_financeiro_teste_naty (id_registro_fin, id_paciente, id_exame, vl_exame, vl_pago_paciente)
VALUES (2, 2, 3, 180.00, 180.00);

-- ===========================================================
-- HISTÓRICO DE EXAMES
-- ===========================================================

INSERT INTO au_historico_exame_teste_naty (id_status_ex_pa, id_paciente, id_exame, dt_status)
VALUES (1, 1, 2, TO_DATE('2024-01-20', 'YYYY-MM-DD'));
INSERT INTO au_historico_exame_teste_naty (id_status_ex_pa, id_paciente, id_exame, dt_status)
VALUES (2, 2, 3, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
