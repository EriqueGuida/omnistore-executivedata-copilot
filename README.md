# ExecutiveData Copilot — OmniStore
> *Um projeto de Engenharia de Sistemas e Dados focado no design e modelagem de uma solução Text-to-SQL para o setor de varejo/e-commerce.*

<div align="center">

[![Status](https://img.shields.io/badge/Status-Conclu%C3%ADdo-brightgreen?style=for-the-badge)](#)
[![SENAI](https://img.shields.io/badge/Firjan_SENAI-T%C3%A9cnico_em_Dev_Sistemas-005CA9?style=for-the-badge)](#)
[![SQL](https://img.shields.io/badge/SQL-Modelagem_Relacional-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](#)
[![Figma](https://img.shields.io/badge/Figma-Prot%C3%B3tipo_UX%2FUI-F24E1E?style=for-the-badge&logo=figma&logoColor=white)](#)
[![Prompt Engineering](https://img.shields.io/badge/IA-Prompt_Engineering-8A2BE2?style=for-the-badge)](#)

</div>

## Sobre o Projeto

O **ExecutiveData Copilot — OmniStore** é um projeto de portfólio voltado à **Engenharia de Requisitos, modelagem de sistemas e modelagem de dados** para uma solução de análise de informações corporativas.

A proposta é permitir que executivos e gestores consultem dados de negócio por meio de **linguagem natural**, utilizando um Copiloto **Text-to-SQL** para transformar perguntas em consultas SQL e retornar informações estruturadas.

O cenário simulado é uma empresa de varejo/e-commerce que enfrenta problemas como:

- demora para obter relatórios e indicadores;
- dependência de equipes técnicas para consultas ad hoc;
- necessidade de análises rápidas por **região, categoria, loja e equipe**;
- necessidade de manter **controle de acesso, rastreabilidade e auditoria** sobre as consultas realizadas.

> **Status do projeto:** o repositório contém os artefatos de especificação, modelagem, DDL e prototipação. Ele **não deve ser interpretado como uma aplicação corporativa pronta para produção**. Os documentos distinguem explicitamente decisões consolidadas, hipóteses e pontos técnicos ainda pendentes.

---

## Metodologia & Inovação (Simulação de Reunião com IA)

O diferencial metodológico do projeto foi utilizar uma **LLM como stakeholder fictício**, simulando uma reunião de levantamento de requisitos com o **Diretor de Operações e Analytics da OmniStore**.

### Linha do tempo do processo

```text
Simulação do cliente
        ↓
Levantamento de necessidades
        ↓
Requisitos + Regras de Negócio
        ↓
Casos de Uso + Fluxos
        ↓
Modelagem Relacional + Arquitetura
        ↓
Segurança + UX/UI
        ↓
Validação e revisão dos entregáveis
```

- **Simulação de Cliente:** um agente de IA foi configurado para atuar como Diretor de Operações e Analytics, apresentando dores de negócio, restrições, ambiguidades e questionamentos sem assumir conhecimento técnico do sistema.
- **Levantamento e Modelagem — autoria própria:** a **entrevista simulada, extração das regras de negócio, especificação de requisitos funcionais e não funcionais, casos de uso, modelagem da solução e modelagem do banco de dados foram executadas EXCLUSIVAMENTE pelo autor do repositório**.
- **Avaliação Técnica:** os entregáveis foram submetidos à análise do agente para receber questionamentos e validações. As sugestões da IA foram tratadas como insumos para análise, e **não como autoridade sobre os requisitos ou decisões finais**.
- **Limite metodológico:** a IA representa um stakeholder fictício; não houve cliente real envolvido na definição dos requisitos.

---

## Arquitetura e Modelagem do Sistema

### 1. Perfil de Atores e Permissões

| Perfil | Escopo / capacidades documentadas |
|---|---|
| **Diretor Executivo** | Consultas globais, visualização da auditoria do Copiloto e exportação de relatórios executivos. |
| **Gerente Regional** | Consultas relacionadas à sua região e exportação de relatórios. |
| **Gerente de Categoria** | Consultas relacionadas às categorias sob seu contexto de atuação. |
| **Supervisor de Loja** | Consultas relacionadas à loja/equipe sob seu escopo. |

O contexto de autorização é associado ao usuário por informações como `funcionarioID`, `cargoID`, `gestorID`, `lojaID` e `regiaoID`.

### 2. Requisitos Principais

#### Funcionais (RF)

A solução documenta, entre outros, os seguintes comportamentos:

- realizar perguntas em linguagem natural ao Copiloto;
- permitir consultas globais, regionais, por categoria e por loja/equipe conforme o perfil;
- verificar o escopo autorizado **antes da execução** da consulta;
- bloquear consultas que violem o escopo do usuário;
- contabilizar tentativas não autorizadas;
- bloquear temporariamente o acesso após **3 tentativas não autorizadas**;
- gerar auditoria com status `SUSPICIOUS_BLOCK` quando o bloqueio ocorrer;
- alertar o gestor direto por e-mail em caso de bloqueio;
- registrar as consultas realizadas pelo Copiloto;
- permitir a visualização da auditoria ao perfil autorizado;
- permitir a exportação de relatórios aos perfis documentados.

#### Não Funcionais (RNF)

| Aspecto | Definição atual |
|---|---|
| **Autenticação** | Camada baseada em **JWT**. |
| **Autorização** | O contexto do usuário deve ser considerado no processamento e execução das consultas. |
| **Segurança** | Consultas fora do escopo não devem ser executadas. |
| **Auditoria** | As consultas devem registrar dados como pergunta, SQL, status, tempo e data/hora. |
| **Tempo de execução** | O banco possui `tempoExecucaoMs` para rastreabilidade; **não existe, porém, um SLA ou tempo máximo de resposta definido**. |
| **Read-Only** | **Não há uma especificação técnica formal no material atual** definindo a política de acesso exclusivamente de leitura. |
| **Mascaramento de dados** | **Não especificado** na documentação atual. |
| **Limite de resultados** | **Não especificado** na documentação atual. |
| **Desempenho / escala** | Não foram definidos volume de usuários simultâneos, throughput, disponibilidade ou metas quantitativas. |

> **Importante:** itens como Read-Only, mascaramento, limite de resultados, SLA e políticas detalhadas de RLS aparecem como questões que ainda precisam ser especificadas, e não como características já implementadas.

### 3. Modelo de Dados (DER / Tabelas)

O banco relacional idealizado é o `omni_store` e organiza o domínio em blocos de **estrutura organizacional, colaboradores, catálogo, estoque, vendas, metas e auditoria**.

| Tabela | Finalidade |
|---|---|
| `cargo` | Cargos organizacionais. |
| `regiao` | Regiões de atuação. |
| `lojaFisica` | Lojas e vínculo com regiões. |
| `departamento` | Departamentos vinculados às lojas. |
| `funcionario` | Colaboradores, cargos, departamentos e gestor direto. |
| `cliente` | Clientes relacionados às vendas. |
| `fornecedor` | Fornecedores dos produtos. |
| `categoriaProduto` | Categorias de produtos. |
| `subcategoriaProduto` | Subdivisões das categorias. |
| `produto` | Catálogo de produtos e preços. |
| `estoque` | Estoque por **loja + produto**, com chave composta. |
| `metodoPagamento` | Métodos de pagamento. |
| `vendas` | Cabeçalho das vendas realizadas. |
| `itensVenda` | Produtos e quantidades de cada venda, com chave composta. |
| `metas` | Metas associadas a funcionário, categoria e loja. |
| `auditoriaConsulta` | Rastreabilidade das consultas realizadas pelo Copiloto. |

### Relações principais

```text
Região ─────────────── Loja
Loja ───────────────── Departamento
Departamento ───────── Funcionário
Funcionário ────────── Funcionário (gestor)
Loja ───────────────── Estoque ───────────── Produto
Fornecedor ─────────── Produto
Categoria ──────────── Subcategoria ─────── Produto
Loja ───────────────── Vendas ────────────── ItensVenda ───── Produto
Cliente ────────────── Vendas
Funcionário ────────── Vendas
MétodoPagamento ────── Vendas
Funcionário ────────── Metas ─────────────── Categoria / Loja
Funcionário ────────── AuditoriaConsulta
```

### Fluxo arquitetural simplificado

```text
Usuário
   ↓
Frontend
   ↓  POST /api/chat + JWT
Autenticação
   ↓  contexto do usuário
Copiloto Text-to-SQL
   ↓  análise da intenção + escopo
Geração de SQL
   ↓
Banco omni_store
   ↓
Resultado
   ↓
Auditoria
   ↓
Frontend
```

A arquitetura também representa **Views / RLS** na camada de dados. Entretanto, o material do projeto deixa explícito que o mecanismo final de *enforcement* do RLS e a divisão exata de responsabilidade entre banco, aplicação e Copiloto ainda precisam ser definidos em uma implementação real.

---

## Segurança e Governança

A segurança é tratada como parte do fluxo funcional, não apenas como uma preocupação de infraestrutura.

### Fluxo de uma tentativa não autorizada

```text
Pergunta
   ↓
Análise do escopo
   ↓
Violação?
 ┌───┴────┐
Não      Sim
 ↓        ↓
Executa  Bloqueia
          ↓
       Contabiliza
          ↓
      3 tentativas?
       ↙        ↘
     Não        Sim
      ↓          ↓
 Acesso       Bloqueio
 Negado       + Auditoria
              + Alerta ao gestor
```

Esse fluxo conecta **requisitos → regra de negócio → arquitetura → UX**, com estados específicos para processamento, resposta autorizada, acesso negado, bloqueio, erro e auditoria.

---

## Protótipos e UX/UI

O repositório inclui protótipos que representam os principais estados da experiência do usuário:

- consulta inicial;
- processamento;
- resposta autorizada;
- acesso negado;
- acesso bloqueado;
- painel de auditoria.

Arquivos disponíveis em [`prototipos/`](./prototipos/).

---

## Estrutura do Repositório

```text
OmniStore/
├── database/
│   └── 01-schema.sql
│       └── DDL MySQL do banco `omni_store`.
│
├── docs/
│   ├── 01-contexto-e-requisitos.md
│   │   └── Problema, objetivos, stakeholders, requisitos, regras e lacunas.
│   ├── 02-casos-de-uso-e-regras.md
│   │   └── Perfis, casos de uso, fluxos principais e exceções.
│   ├── 03-arquitetura-e-modelagem.md
│   │   └── Arquitetura, fluxo Text-to-SQL e modelo relacional.
│   ├── 04-seguranca-e-ux.md
│   │   └── Autenticação, autorização, bloqueios, auditoria e estados de UX.
│   ├── 05-decisoes-validacao-e-ia.md
│   │   └── Decisões, trade-offs, validação e metodologia de uso de IA.
│   └── DOCUMENTACAO_TECNICA.md
│       └── Consolidação dos diagramas e fluxos técnicos principais.
│
└── prototipos/
    ├── auditoria/
    │   └── painel-auditoria.png
    └── copilot/
        ├── acesso-bloqueado.png
        ├── acesso-negado.png
        ├── consulta-inicial.png
        ├── processamento.png
        └── resposta-autorizada.png
```

---

## Tecnologias e Conceitos Aplicados

### Tecnologias / artefatos

- **MySQL / SQL** — modelagem e DDL do banco relacional;
- **Markdown** — documentação técnica estruturada;
- **Mermaid** — diagramas de arquitetura, fluxo e casos de uso;
- **Figma / prototipação** — representação dos estados de UX/UI;
- **LLM / IA generativa** — simulação de stakeholder e apoio à avaliação dos entregáveis.

### Conceitos de Engenharia de Software

- Análise e Engenharia de Requisitos;
- Requisitos Funcionais e Não Funcionais;
- Regras de Negócio;
- Casos de Uso;
- Rastreabilidade de requisitos;
- Modelagem de Bancos de Dados Relacionais;
- DER / ERD e chaves primárias e estrangeiras;
- Arquitetura orientada a dados;
- Design de sistemas para **LLM / Text-to-SQL**;
- Autenticação e autorização por contexto;
- Auditoria e Governança de Dados;
- Segurança aplicada à UX;
- Análise de trade-offs e registro de decisões técnicas.

---

## O que este projeto demonstra

Para fins de portfólio, o principal objetivo do OmniStore não é apenas mostrar um banco de dados ou uma interface, mas evidenciar a capacidade de **transformar um problema de negócio em artefatos técnicos rastreáveis**.

O projeto demonstra, em um único fluxo:

```text
Problema de negócio
      ↓
Levantamento de requisitos
      ↓
Regras de negócio
      ↓
Casos de uso
      ↓
Arquitetura
      ↓
Modelo de dados
      ↓
Segurança e governança
      ↓
Protótipo UX/UI
      ↓
Validação e documentação
```

O uso de IA é apresentado de forma consciente: **a LLM apoia a simulação e a avaliação, enquanto as decisões finais, requisitos aceitos e modelagem permanecem sob responsabilidade do autor**.

---

## Autor

**Erique Guida**
- [LinkedIn](www.linkedin.com/in/erique-guida)

---

## Observação final

Este repositório representa um **projeto acadêmico/pessoal de Engenharia de Sistemas e Dados**. A documentação foi construída para demonstrar processo, raciocínio técnico e tomada de decisão. Onde ainda não existem definições ou implementações comprovadas, o projeto mantém essas limitações explícitas em vez de apresentá-las como funcionalidades concluídas.
