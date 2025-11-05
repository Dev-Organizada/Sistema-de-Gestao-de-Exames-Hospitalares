-- Dados do convenio e do pacientes 
select c.id_convenio,
       c.tipo_plano,
       c.vl_mensalidade,
       c.carencia,
       p.nome paciente
  from tb_convenio_teste_naty c,
       tb_paciente_teste_naty p
 where c.id_convenio = p.id_convenio;  
 
 
-- Quantos pacientes estão cadastrados em cada convenio
select count(*) qtd_paciente,
       c.tipo_plano
  from tb_convenio_teste_naty c,
       tb_paciente_teste_naty p
 where c.id_convenio = p.id_convenio
 group by c.tipo_plano;