# Contexto e Requisitos

> **Projeto:** OmniStore  
> **Documento:** Contexto e Requisitos  
> **Objetivo do documento:** consolidar o contexto do problema, as necessidades identificadas, os requisitos e as regras de negócio atualmente definidos para o OmniStore e seu Copiloto Text-to-SQL.

---

## 1. Contexto

O OmniStore é um projeto pessoal de portfólio que simula o desenvolvimento de uma solução corporativa de análise de dados para um cenário de e-commerce/varejo.

A solução possui um **Copiloto Text-to-SQL**, permitindo que usuários realizem perguntas em linguagem natural e obtenham respostas baseadas nos dados disponíveis no banco de dados.

O modelo de dados contempla informações relacionadas a:

- funcionários e cargos;
- regiões e lojas;
- departamentos;
- clientes;
- fornecedores;
- produtos e categorias;
- estoque;
- vendas e itens de venda;
- métodos de pagamento;
- metas;
- auditoria das consultas realizadas pelo Copiloto.

O modelo também relaciona funcionários aos seus cargos, departamentos e gestores, permitindo representar diferentes contextos organizacionais e de acesso.

O Copiloto foi concebido considerando diferentes perfis de acesso:

- Diretor Executivo;
- Gerente Regional;
- Gerente de Categoria;
- Supervisor de Loja.

Cada perfil possui um escopo de consulta correspondente ao seu contexto de atuação.

### 1.1 Funcionamento em alto nível

O fluxo documentado considera que o usuário realiza uma pergunta em linguagem natural pela aplicação. A requisição é autenticada e o contexto do usuário é encaminhado ao Copiloto.

Esse contexto inclui informações como:

- `funcionarioID`;
- `cargoID`;
- `gestorID`;
- `lojaID`;
- `regiaoID`.

O Copiloto analisa a intenção da pergunta, gera a consulta SQL e realiza a consulta no banco utilizando Views/Tabelas relacionais. A resposta é então estruturada e apresentada ao usuário.

As consultas também são registradas em uma estrutura de auditoria, contendo informações como pergunta realizada, SQL gerado, status da consulta, motivo de negativa, tempo de execução e data/hora.

---

## 2. Problema

O problema central considerado pelo projeto é a necessidade de permitir que diferentes perfis de usuários consultem informações de negócio por meio de linguagem natural, sem perder o controle sobre o escopo de acesso aos dados.

Em um cenário com diferentes níveis de atuação — executivo, regional, categoria e loja — uma mesma capacidade de consulta não deve necessariamente fornecer acesso aos mesmos dados para todos os usuários.

O projeto, portanto, precisa conciliar:

1. facilidade de consulta por linguagem natural;
2. geração de consultas SQL;
3. controle do escopo de acesso;
4. auditoria das consultas;
5. tratamento de tentativas de acesso não autorizado.

A documentação atual representa um fluxo no qual consultas que violam o escopo autorizado são bloqueadas antes da execução.

> **Observação:** a documentação define o fluxo de controle de acesso, mas não detalha todos os mecanismos de implementação necessários para garantir esse controle em ambiente real.

---

## 3. Objetivo

O objetivo do OmniStore é desenvolver e documentar uma solução de análise de dados com um Copiloto Text-to-SQL capaz de receber perguntas em linguagem natural, considerar o contexto de acesso do usuário, consultar os dados disponíveis e retornar uma resposta estruturada.

Além da consulta de dados, o projeto considera mecanismos de:

- autenticação;
- autorização por contexto organizacional;
- auditoria;
- bloqueio de consultas não autorizadas;
- bloqueio temporário após tentativas repetidas;
- alerta ao gestor direto em situações de bloqueio.

O objetivo deste projeto de portfólio não é representar um sistema corporativo completo em produção, mas demonstrar a aplicação de conceitos de Engenharia de Requisitos, modelagem, arquitetura, segurança e documentação técnica em um cenário empresarial simulado.

---

## 4. Stakeholders

### 4.1 Stakeholder simulado

O projeto utiliza uma **LLM como stakeholder simulado**, representando o **Diretor de Operações da OmniStore**.

Esse stakeholder é utilizado para simular situações de levantamento e validação de requisitos, incluindo:

- apresentação de necessidades de negócio;
- questionamento de decisões;
- apresentação de restrições;
- situações de ambiguidade;
- validação de entregáveis;
- geração de conflitos ou cenários para análise.

O stakeholder é fictício e não representa um cliente real.

As decisões finais do projeto são de responsabilidade do autor.

### 4.2 Perfis de usuário

Os perfis representados na documentação são:

| Perfil | Escopo documentado |
|---|---|
| Diretor Executivo | Consultas globais, auditoria do Copiloto e exportação de relatórios executivos |
| Gerente Regional | Consultas regionais e exportação de relatórios |
| Gerente de Categoria | Consultas por categoria |
| Supervisor de Loja | Consultas relacionadas à loja/equipe |

Esses perfis também aparecem associados aos respectivos casos de uso do Copiloto.

---

## 5. Necessidades identificadas

A partir do contexto e dos artefatos atualmente documentados, foram identificadas as seguintes necessidades.

| ID | Necessidade | Origem / evidência |
|---|---|---|
| N-01 | Permitir que usuários realizem perguntas em linguagem natural. | Caso de uso "Fazer Pergunta em Linguagem Natural" |
| N-02 | Permitir consultas conforme o escopo de atuação do usuário. | Casos de uso por escopo e fluxo de segurança |
| N-03 | Disponibilizar consultas globais para o perfil executivo. | Caso de uso "Consultar Dados Globais" |
| N-04 | Disponibilizar consultas regionais para o gerente regional. | Caso de uso "Consultar Dados Regionais" |
| N-05 | Disponibilizar consultas por categoria para o gerente de categoria. | Caso de uso "Consultar Dados por Categoria" |
| N-06 | Disponibilizar consultas relacionadas à loja/equipe para o supervisor de loja. | Caso de uso "Consultar Dados da Loja/Equipe" |
| N-07 | Permitir visualização da auditoria do Copiloto ao perfil autorizado. | Caso de uso "Visualizar Auditoria do Copiloto" |
| N-08 | Permitir exportação de relatórios executivos ao perfil autorizado. | Caso de uso "Exportar Relatórios Executivos" |
| N-09 | Bloquear consultas que violem o escopo de acesso. | Fluxo de segurança e bloqueio |
| N-10 | Registrar consultas realizadas pelo Copiloto. | Modelo de auditoria e fluxo arquitetural |
| N-11 | Tratar repetidas tentativas de acesso não autorizado. | Fluxo de segurança e bloqueio |

> **Nota:** esta tabela organiza necessidades já representadas nos artefatos do projeto. Ela não deve ser interpretada como uma transcrição de entrevistas reais.

---

## 6. Requisitos funcionais

Os requisitos funcionais abaixo consolidam os comportamentos explicitamente representados nos casos de uso e fluxos atualmente documentados.

| ID | Requisito funcional | Critério de verificação |
|---|---|---|
| RF-01 | O sistema deve permitir que o usuário faça perguntas em linguagem natural ao Copiloto. | Uma pergunta pode ser enviada ao Copiloto para processamento. |
| RF-02 | O sistema deve permitir consultas de dados globais ao Diretor Executivo. | O perfil autorizado consegue realizar uma consulta global. |
| RF-03 | O sistema deve permitir consultas de dados regionais ao Gerente Regional. | O perfil autorizado consegue realizar uma consulta regional. |
| RF-04 | O sistema deve permitir consultas por categoria ao Gerente de Categoria. | O perfil autorizado consegue realizar uma consulta relacionada à categoria. |
| RF-05 | O sistema deve permitir consultas de dados da loja/equipe ao Supervisor de Loja. | O perfil autorizado consegue realizar uma consulta relacionada à loja/equipe. |
| RF-06 | O sistema deve verificar se a consulta está dentro do escopo autorizado do usuário antes de sua execução. | Uma consulta é analisada em relação ao contexto de autorização antes da execução. |
| RF-07 | O sistema deve bloquear a execução de uma consulta que viole o escopo autorizado. | Uma consulta fora do escopo não é executada. |
| RF-08 | O sistema deve incrementar o contador de tentativas não autorizadas quando uma consulta for bloqueada por violação de escopo. | Uma tentativa bloqueada altera o contador correspondente. |
| RF-09 | O sistema deve bloquear temporariamente o acesso do colaborador após três tentativas não autorizadas. | Ao atingir três tentativas, o acesso é temporariamente bloqueado. |
| RF-10 | O sistema deve gerar um registro de auditoria quando ocorrer o bloqueio por tentativas não autorizadas. | O evento de bloqueio gera registro com status `SUSPICIOUS_BLOCK`. |
| RF-11 | O sistema deve enviar um alerta por e-mail ao gestor direto quando ocorrer o bloqueio. | O gestor direto recebe o alerta previsto no fluxo. |
| RF-12 | O sistema deve registrar informações das consultas realizadas pelo Copiloto. | A consulta gera registro contendo os dados de auditoria definidos. |
| RF-13 | O sistema deve permitir a visualização da auditoria do Copiloto ao perfil autorizado. | O Diretor Executivo consegue acessar a funcionalidade de auditoria. |
| RF-14 | O sistema deve permitir a exportação de relatórios executivos ao perfil autorizado. | O perfil autorizado consegue utilizar a funcionalidade de exportação documentada. |

### 6.1 Observação sobre geração e execução de SQL

O fluxo arquitetural documentado representa as seguintes etapas:

1. recebimento da pergunta;
2. autenticação da requisição;
3. envio da pergunta e contexto do usuário ao Copiloto;
4. análise da intenção;
5. geração da consulta SQL;
6. execução da consulta;
7. retorno dos dados;
8. registro da consulta na auditoria.

A documentação também representa Views/RLS no banco.

Entretanto, **não está definido em detalhe na documentação disponível como o enforcement de autorização é implementado tecnicamente no banco e na camada do Copiloto**. Portanto, esta questão deve ser tratada como uma definição técnica ainda pendente, e não como uma implementação já concluída.

---

## 7. Requisitos não funcionais

Os requisitos não funcionais representam características, restrições ou atributos de qualidade do sistema.

A documentação disponível fornece evidências de alguns desses aspectos, mas não define métricas quantitativas para todos eles.

| ID | Requisito não funcional | Situação |
|---|---|---|
| RNF-01 | O acesso à aplicação deve utilizar uma camada de autenticação baseada em JWT. | Definido na arquitetura documentada |
| RNF-02 | O sistema deve considerar o contexto de autorização do usuário no processamento das consultas. | Definido na arquitetura e no fluxo de segurança |
| RNF-03 | As consultas realizadas pelo Copiloto devem possuir informações de auditoria. | Definido |
| RNF-04 | O sistema deve registrar o tempo de execução das consultas. | Definido no modelo de auditoria |
| RNF-05 | O acesso a dados deve respeitar o escopo associado ao usuário. | Definido como requisito de segurança |
| RNF-06 | O sistema deve impedir a execução de consultas não autorizadas. | Definido no fluxo de segurança |

### 7.1 Requisitos ainda não especificados

A documentação disponível não define, entre outros pontos:

- tempo máximo de resposta esperado;
- disponibilidade ou SLA;
- volume máximo de usuários simultâneos;
- volume máximo de consultas;
- política de retenção dos registros de auditoria;
- mecanismo detalhado de proteção dos dados sensíveis;
- requisitos de acessibilidade;
- estratégia detalhada de recuperação após falhas.

Esses itens **não devem ser tratados como requisitos existentes** até que sejam definidos no projeto.

---

## 8. Regras de negócio

As regras de negócio determinam condições que devem ser respeitadas pelo funcionamento da solução, independentemente de como a funcionalidade será implementada.

| ID | Regra de negócio |
|---|---|
| RB-01 | O usuário somente pode executar consultas compatíveis com seu escopo de acesso. |
| RB-02 | Uma consulta que viole o escopo autorizado deve ser bloqueada antes da execução. |
| RB-03 | Uma tentativa de consulta não autorizada deve ser contabilizada. |
| RB-04 | Ao atingir três tentativas não autorizadas, o acesso do colaborador deve ser temporariamente bloqueado. |
| RB-05 | O bloqueio decorrente de tentativas não autorizadas deve gerar um registro de auditoria com status `SUSPICIOUS_BLOCK`. |
| RB-06 | O bloqueio decorrente de três tentativas não autorizadas deve gerar um alerta por e-mail ao gestor direto. |
| RB-07 | O acesso às funcionalidades de consulta deve respeitar o perfil e o escopo associados ao usuário. |

### 8.1 Relação entre perfil e escopo

Os casos de uso documentados estabelecem a seguinte relação:

| Perfil | Capacidade documentada |
|---|---|
| Diretor Executivo | Consultar dados globais, visualizar auditoria e exportar relatórios executivos |
| Gerente Regional | Consultar dados regionais e exportar relatórios |
| Gerente de Categoria | Consultar dados por categoria |
| Supervisor de Loja | Consultar dados da loja/equipe |

Essa tabela representa o comportamento atualmente documentado. Ela não deve ser expandida para permissões adicionais sem uma decisão explícita do projeto.

---

## 9. Escopo e fora de escopo

### 9.1 Escopo

Com base nos artefatos atuais, fazem parte do escopo do OmniStore:

- Copiloto para perguntas em linguagem natural;
- geração e execução de consultas SQL;
- consultas orientadas por diferentes perfis de acesso;
- controle do escopo das consultas;
- autenticação por JWT;
- registro de auditoria das consultas;
- bloqueio de consultas não autorizadas;
- tratamento de três tentativas não autorizadas;
- bloqueio temporário do colaborador;
- registro de bloqueio como `SUSPICIOUS_BLOCK`;
- alerta ao gestor direto;
- visualização de auditoria pelo perfil autorizado;
- exportação de relatórios executivos pelo perfil autorizado;
- consulta aos dados representados pelo modelo de dados do OmniStore.

### 9.2 Fora de escopo

O projeto ainda **não possui uma definição formal e completa de fora de escopo** na documentação disponível.

Por esse motivo, não serão inventadas funcionalidades para preencher esta seção.

No estado atual, podem ser considerados como **não definidos**, e não necessariamente como fora de escopo:

- funcionalidades administrativas adicionais;
- mecanismos detalhados de gerenciamento de usuários;
- políticas completas de retenção de auditoria;
- métricas de desempenho e disponibilidade;
- mecanismos detalhados de recuperação de falhas;
- implementação produtiva de infraestrutura;
- integrações externas não descritas nos artefatos atuais.

> **Importante:** "não definido" é diferente de "fora de escopo". Um item somente deve ser classificado como fora de escopo após uma decisão explícita do projeto.

---

## 10. Lacunas e decisões pendentes

A consolidação dos requisitos também permite identificar pontos que precisam de definição futura.

### Segurança e autorização

- Como o escopo é efetivamente aplicado no banco?
- O RLS será efetivamente implementado ou permanece como elemento arquitetural conceitual?
- Qual é a relação entre o filtro gerado pelo Copiloto e o mecanismo de autorização do banco?
- Como são tratados dados potencialmente sensíveis?

### Desempenho

- Qual é o tempo de resposta esperado?
- Existe um limite aceitável para o tempo de execução das consultas?
- Quais consultas devem utilizar Views pré-computadas?

### Auditoria

- Por quanto tempo os registros devem ser mantidos?
- Quem pode consultar a auditoria além do Diretor Executivo?
- Quais eventos adicionais devem ser auditados?

### Bloqueio

- Qual é a duração do bloqueio temporário?
- Como o acesso é desbloqueado?
- O contador de tentativas é zerado em algum momento?

Essas questões devem ser tratadas como **pendências de especificação**, não como requisitos já implementados.

---

## 11. Rastreabilidade inicial

A relação entre os principais artefatos pode ser representada da seguinte forma:

```text
Necessidade de negócio
        ↓
Necessidade identificada
        ↓
Requisito funcional / não funcional
        ↓
Regra de negócio
        ↓
Caso de uso
        ↓
Fluxo de segurança / arquitetura
        ↓
Critério de verificação
```

Essa rastreabilidade permite relacionar o problema de negócio às decisões técnicas e aos comportamentos esperados do sistema.

---

## 12. Status do documento

Este documento consolida o estado atual da documentação do projeto.

Ele deve ser atualizado quando novas decisões forem tomadas, requisitos forem refinados ou lacunas forem resolvidas.

**Regra de documentação:** requisitos, regras ou funcionalidades novas não devem ser adicionados como fatos sem que tenham sido definidos ou validados no projeto.
