# Arquitetura e Modelagem

> **Projeto:** OmniStore  
> **Documento:** Arquitetura e Modelagem  
> **Objetivo:** apresentar a estrutura técnica da solução, seu fluxo de dados, seus principais componentes e o modelo de dados utilizado pelo OmniStore.

---

## 1. Visão geral da solução

O OmniStore possui uma solução de análise de dados baseada em um **Copiloto Text-to-SQL**. O usuário realiza uma pergunta em linguagem natural por meio da aplicação, e a solução utiliza o contexto de autenticação e autorização do usuário para processar a solicitação.

Em alto nível, o fluxo documentado é:

```text
Usuário
   ↓
Frontend
   ↓
Autenticação (JWT)
   ↓
Copiloto Text-to-SQL
   ↓
Banco de dados
   ↓
Auditoria
   ↓
Frontend
   ↓
Usuário
```

A arquitetura representa uma separação entre a interface utilizada pelo usuário, a autenticação, o processamento da pergunta pelo Copiloto, o acesso aos dados e o registro de auditoria.

O banco é representado na documentação como contendo **Views / RLS**, enquanto o fluxo do Copiloto também representa análise do escopo e geração da consulta SQL.

> **Nota:** a documentação define o fluxo arquitetural, mas não especifica todos os detalhes de implementação de cada componente.

---

## 2. Arquitetura

A arquitetura documentada pode ser representada pelos seguintes componentes principais:

```text
┌─────────────────────┐
│       Usuário       │
│     Web / Mobile    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│      Frontend       │
│      App Web        │
└──────────┬──────────┘
           │ POST /api/chat
           │ + Token JWT
           ▼
┌─────────────────────┐
│ Autenticação (JWT)  │
└──────────┬──────────┘
           │ Contexto do usuário
           ▼
┌─────────────────────┐
│ Copiloto Text-to-SQL│
│                     │
│ - análise da intenção│
│ - contexto de acesso │
│ - geração de SQL     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Banco omni_store    │
│ Views / RLS         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Retorno dos dados   │
└─────────────────────┘

           ┌──────────────────────┐
           │ Auditoria de consulta│
           └──────────────────────┘
```

### 2.1 Componentes representados na arquitetura

| Componente | Responsabilidade documentada |
|---|---|
| Frontend App | Receber a pergunta do usuário e apresentar a resposta final. |
| Camada de Autenticação | Validar o token JWT e disponibilizar o contexto do usuário. |
| Copiloto Text-to-SQL | Analisar a pergunta, considerar o contexto e gerar a consulta SQL. |
| Banco `omni_store` | Disponibilizar os dados consultados por meio das estruturas relacionais e Views/RLS representadas na arquitetura. |
| Tabela de Auditoria | Registrar informações relacionadas às consultas realizadas. |

---

## 3. Fluxo Text-to-SQL

O fluxo documentado para uma consulta segue estas etapas:

1. O usuário digita uma pergunta em linguagem natural.
2. O Frontend envia uma requisição para a aplicação.
3. A requisição contém um token JWT.
4. A camada de autenticação valida o token.
5. O contexto do usuário é disponibilizado para o Copiloto.
6. O Copiloto analisa a intenção da pergunta.
7. O Copiloto considera o escopo de acesso do usuário.
8. A pergunta é traduzida para uma consulta SQL.
9. A consulta é enviada ao banco.
10. O banco retorna o conjunto de dados.
11. O Copiloto estrutura a resposta.
12. A consulta é registrada na auditoria.
13. A resposta é enviada ao Frontend.
14. O Frontend apresenta o resultado ao usuário.

A documentação também representa uma etapa de sanitização do prompt e análise da intenção antes da geração da consulta.

---

## 4. Componentes

### 4.1 Frontend

É a camada de interação com o usuário.

No fluxo documentado, o Frontend:

- recebe a pergunta em linguagem natural;
- envia a requisição para a API;
- encaminha o token JWT;
- recebe a resposta estruturada;
- apresenta a resposta final ao usuário;
- pode apresentar gráficos associados ao resultado.

### 4.2 Autenticação

A arquitetura utiliza uma camada de autenticação baseada em **JWT**.

O payload representado no fluxo contém:

- `funcionarioID`;
- `cargoID`;
- `gestorID`;
- `lojaID`;
- `regiaoID`.

Essas informações fornecem ao Copiloto o contexto necessário para considerar o perfil e o escopo do usuário.

### 4.3 Copiloto Text-to-SQL

O Copiloto é responsável pelo processamento da pergunta em linguagem natural.

O fluxo documentado atribui a ele as seguintes etapas:

- sanitização do prompt;
- análise da intenção;
- consideração do contexto de acesso;
- geração da consulta SQL;
- execução da consulta no banco;
- formatação do resultado;
- registro da consulta na auditoria.

### 4.4 Banco de dados

O banco é identificado como `omni_store`.

A arquitetura representa o acesso a **Views / RLS**, além das tabelas relacionais descritas no modelo de dados.

### 4.5 Auditoria

A auditoria registra informações relacionadas às consultas realizadas pelo Copiloto.

O modelo contém campos para:

- pergunta realizada;
- SQL gerado;
- status da consulta;
- motivo da negativa;
- tempo de execução;
- data e hora;
- identificador do funcionário.

---

## 5. Modelo de dados

O modelo de dados do OmniStore representa o domínio de varejo/e-commerce utilizado pelo projeto.

As principais relações documentadas incluem:

```text
Cargo ─────────────── Funcionário
Região ────────────── Loja
Loja ──────────────── Departamento
Loja ──────────────── Estoque
Loja ──────────────── Vendas
Loja ──────────────── Metas
Departamento ─────── Funcionário
Funcionário ───────── Funcionário (gestor)
Funcionário ───────── Vendas
Funcionário ───────── Metas
Cliente ───────────── Vendas
MétodoPagamento ───── Vendas
Vendas ────────────── ItensVenda
Produto ───────────── ItensVenda
Produto ───────────── Estoque
Fornecedor ────────── Produto
Categoria ─────────── Subcategoria
Subcategoria ──────── Produto
Categoria ─────────── Metas
Funcionário ───────── AuditoriaConsulta
```

O modelo utiliza chaves primárias e estrangeiras para representar os relacionamentos entre as entidades.

---

## 6. Principais entidades

| Entidade | Finalidade no modelo |
|---|---|
| `cargo` | Representar os cargos dos funcionários. |
| `regiao` | Representar as regiões de atuação. |
| `lojaFisica` | Representar as lojas físicas e sua região. |
| `departamento` | Representar os departamentos das lojas. |
| `funcionario` | Representar os colaboradores, seus cargos, departamentos e gestores. |
| `cliente` | Representar os clientes relacionados às vendas. |
| `fornecedor` | Representar fornecedores de produtos. |
| `categoriaProduto` | Representar categorias de produtos. |
| `subcategoriaProduto` | Representar subdivisões das categorias. |
| `produto` | Representar os produtos comercializados. |
| `estoque` | Relacionar produtos às lojas e suas quantidades em estoque. |
| `metodoPagamento` | Representar os métodos utilizados nas vendas. |
| `vendas` | Representar as vendas realizadas. |
| `itensVenda` | Representar os produtos e quantidades presentes em cada venda. |
| `metas` | Representar metas associadas a funcionários, categorias e lojas. |
| `auditoriaConsulta` | Registrar informações das consultas realizadas pelo Copiloto. |

### 6.1 Entidade de auditoria

A entidade `auditoriaConsulta` possui os seguintes atributos documentados:

| Campo | Função |
|---|---|
| `consultaID` | Identificador da consulta. |
| `funcionarioID` | Funcionário responsável pela consulta. |
| `perguntaTexto` | Pergunta realizada pelo usuário. |
| `sqlGerado` | SQL gerado pelo Copiloto. |
| `statusConsulta` | Status da consulta. |
| `motivoNegativa` | Motivo associado a uma negativa. |
| `tempoExecucaoMs` | Tempo de execução da consulta em milissegundos. |
| `dataHoraConsulta` | Data e hora da consulta. |

Essa estrutura conecta o componente de auditoria da arquitetura ao modelo de dados.

### 6.2 Implementação do modelo

O arquivo `database/01-schema.sql` contém a definição relacional
das principais entidades do modelo.

O script implementa as tabelas, chaves e relacionamentos descritos
neste documento, incluindo a entidade de auditoria.

Os mecanismos de Views e RLS representados na arquitetura ainda
não estão materializados neste script, pois sua implementação não
foi definida no projeto.

---

## 7. Fluxo de uma consulta

O fluxo completo documentado pode ser resumido da seguinte forma:

```text
1. Usuário
   │
   │ pergunta em linguagem natural
   ▼
2. Frontend
   │
   │ POST /api/chat + JWT
   ▼
3. Autenticação
   │
   │ valida token e obtém contexto
   ▼
4. Copiloto
   │
   ├── sanitiza prompt
   ├── analisa intenção
   ├── considera escopo do usuário
   └── gera SQL
   │
   ▼
5. Banco
   │
   │ executa SELECT
   ▼
6. Resultado
   │
   ├──────────────► Auditoria
   │                 registra consulta
   ▼
7. Copiloto
   │
   │ estrutura resposta
   ▼
8. Frontend
   │
   ▼
9. Usuário
```

### 7.1 Consulta autorizada

Quando a consulta não viola o escopo de acesso documentado, o fluxo segue para a execução no banco e posterior retorno da resposta.

### 7.2 Consulta não autorizada

Quando a consulta viola o escopo, o fluxo documentado não executa o SQL.

Nesse cenário:

```text
Consulta
   ↓
Verificação de escopo
   ↓
Violação detectada
   ↓
Bloqueio da execução
   ↓
Contador de tentativa +1
   ↓
[menos de 3] → mensagem de acesso negado
   ↓
[3 ou mais] → bloqueio temporário
                    ↓
                 auditoria
                    ↓
             alerta ao gestor
```

As regras detalhadas desse comportamento estão centralizadas no documento `01-contexto-e-requisitos.md`.

---

## 8. Separação entre geração e execução SQL

A solução deve ser entendida conceitualmente como duas etapas distintas:

```text
Linguagem natural
       ↓
Geração / interpretação
       ↓
Consulta SQL
       ↓
Validação do escopo
       ↓
Execução
       ↓
Dados
```

Essa separação é importante porque **gerar uma consulta SQL e executar uma consulta SQL são responsabilidades diferentes**.

No fluxo atualmente documentado, o Copiloto gera a consulta e o banco executa o `SELECT`. A documentação também representa uma análise do escopo antes da execução.

O modelo arquitetural menciona **Views / RLS**, porém não detalha completamente como essas camadas garantem o enforcement da autorização em uma implementação real.

Portanto:

- a existência do fluxo de autorização está documentada;
- a existência de Views/RLS está representada na arquitetura;
- a implementação detalhada do enforcement ainda não está especificada.

Essa distinção deve ser preservada para evitar apresentar uma arquitetura conceitual como se fosse uma implementação concluída.

---

## 9. Decisões estruturais e pontos de atenção

### 9.1 Contexto do usuário acompanha a consulta

O Copiloto recebe a pergunta junto ao contexto do usuário. Isso permite relacionar a solicitação ao cargo, gestor, loja e região representados no token JWT.

### 9.2 Auditoria é parte da solução

A auditoria não é apresentada apenas como uma funcionalidade de consulta histórica. Ela está integrada ao fluxo da consulta e possui uma entidade própria no modelo de dados.

### 9.3 Controle de acesso deve ocorrer antes da execução

O fluxo de segurança documentado estabelece que uma consulta que viola o escopo deve ser bloqueada antes da execução do SQL.

### 9.4 Views / RLS

A arquitetura representa Views/RLS no banco. Entretanto, a documentação disponível não detalha a implementação dessas estruturas.

**Isso ainda não está definido na documentação disponível.**

### 9.5 Geração de SQL por LLM

A geração de SQL pelo Copiloto é um componente central da solução. Por isso, a fronteira entre interpretação da pergunta, autorização e execução precisa permanecer clara na arquitetura.

Uma implementação real exigiria especificações adicionais de segurança para evitar que a geração de SQL seja tratada como mecanismo único de autorização.

> **Nota:** essa última observação é uma recomendação técnica de implementação, não uma funcionalidade já definida no projeto.

---

## 10. Limitações da modelagem atual

A documentação atual permite compreender o domínio, os principais componentes e o fluxo da solução, mas ainda não especifica alguns aspectos de baixo nível, como:

- tecnologia específica utilizada no Frontend;
- tecnologia específica do serviço de autenticação;
- tecnologia ou framework utilizado pelo Copiloto;
- SGBD específico;
- implementação detalhada das Views;
- implementação detalhada de RLS;
- mecanismo interno de validação do SQL;
- infraestrutura de execução;
- estratégia de escalabilidade;
- mecanismos detalhados de tratamento de falhas.

---

## 11. Relação com os demais documentos

Este documento complementa os demais artefatos do projeto:

```text
01-contexto-e-requisitos.md
        │
        │ define necessidades, requisitos e regras
        ▼
02-casos-de-uso-e-regras.md
        │
        │ descreve usuários e comportamentos
        ▼
03-arquitetura-e-modelagem.md
        │
        ├── estrutura da solução
        ├── fluxo de dados
        ├── componentes
        └── modelo de dados
```

O objetivo é evitar duplicação: requisitos e regras permanecem centralizados nos documentos anteriores, enquanto este documento explica **como os elementos da solução se relacionam estruturalmente**.
