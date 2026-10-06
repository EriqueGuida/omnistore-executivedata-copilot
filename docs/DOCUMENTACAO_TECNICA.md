# Documentação Técnica - OmniStore & Copiloto Text-to-SQL

**Autor:** Erique Guida  
**Projeto:** OmniStore  
**Data:** 2026  

---

## 1. Diagrama de Entidade e Relacionamento (DER/MER)

```mermaid
erDiagram
    cargo ||--o{ funcionario : "possuem"
    regiao ||--o{ lojaFisica : "agrupa"
    lojaFisica ||--o{ departamento : "contem"
    lojaFisica ||--o{ estoque : "mantem"
    lojaFisica ||--o{ vendas : "registra"
    lojaFisica ||--o{ metas : "aloca"
    departamento ||--o{ funcionario : "aloca"
    funcionario ||--o{ funcionario : "gerencia (gestorID)"
    funcionario ||--o{ vendas : "realiza"
    funcionario ||--o{ metas : "atribui"
    cliente ||--o{ vendas : "efetua"
    metodoPagamento ||--o{ vendas : "utilizado_em"
    vendas ||--|{ itensVenda : "contem"
    produto ||--o{ itensVenda : "compoe"
    produto ||--o{ estoque : "disponivel_em"
    fornecedor ||--o{ produto : "fornece"
    categoriaProduto ||--o{ subcategoriaProduto : "divide"
    categoriaProduto ||--o{ metas : "define_meta_para"
    subcategoriaProduto ||--o{ produto : "classifica"
    funcionario ||--o{ auditoriaConsulta : "realiza_pesquisa"

    cargo {
        int cargoID PK
        string nomeCargo
    }

    regiao {
        int regiaoID PK
        string nomeRegiao
    }

    lojaFisica {
        int lojaID PK
        int regiaoID FK
        string nomeLoja
        string endereco
        string telefoneLoja
    }

    departamento {
        int departamentoID PK
        int lojaID FK
        string nomeDepartamento
    }

    funcionario {
        int funcionarioID PK
        int cargoID FK
        int departamentoID FK
        int gestorID FK
        string nomeCompleto
        string cpf
        string idColaborador
        string emailCorporativo
    }

    cliente {
        int clienteID PK
        string nomeCliente
        string telefoneCliente
        string emailCliente
    }

    fornecedor {
        int fornecedorID PK
        string nomeFornecedor
        string telefoneFornecedor
        string emailFornecedor
    }

    categoriaProduto {
        int categoriaID PK
        string nomeCategoria
    }

    subcategoriaProduto {
        int subcategoriaID PK
        int categoriaID FK
        string nomeSubcategoria
    }

    produto {
        int produtoID PK
        int fornecedorID FK
        int subcategoriaID FK
        string nomeProduto
        string codigoProduto
        decimal precoCusto
        decimal precoVenda
        string statusProduto
    }

    estoque {
        int lojaID PK, FK
        int produtoID PK, FK
        int qtdEstoque
    }

    metodoPagamento {
        int metodoID PK
        string nomeMetodo
    }

    vendas {
        int vendaID PK
        int lojaID FK
        int funcionarioID FK
        int metodoPagamentoID FK
        int clienteID FK
        datetime dataVenda
        decimal valorTotal
    }

    itensVenda {
        int vendaID PK, FK
        int produtoID PK, FK
        int quantidade
        decimal precoVenda
    }

    metas {
        int metaID PK
        int funcionarioID FK
        int categoriaID FK
        int lojaID FK
        decimal valorMeta
        datetime dataInicio
        datetime dataFim
        string status
    }
    
    auditoriaConsulta {
        int consultaID PK
        int funcionarioID FK
        string perguntaTexto
        string sqlGerado
        string statusConsulta
        string motivoNegativa
        int tempoExecucaoMs
        datetime dataHoraConsulta
    }
```

---

## 2. Diagrama de Caso de Uso e Perfis de Acesso

### A. Casos de Uso
```mermaid
graph LR
    subgraph Atores
        DE[Diretor Executivo]
        GR[Gerente Regional]
        GC[Gerente de Categoria]
        SL[Supervisor de Loja]
    end

    subgraph "Copiloto Text-to-SQL - Casos de Uso"
        UC1((Fazer Pergunta em Linguagem Natural))
        UC2((Consultar Dados Globais))
        UC3((Consultar Dados Regionais))
        UC4((Consultar Dados por Categoria))
        UC5((Consultar Dados da Loja/Equipe))
        UC6((Visualizar Auditoria do Copiloto))
        UC7((Exportar Relatórios Executivos))
    end

    DE --> UC1
    DE --> UC2
    DE --> UC6
    DE --> UC7

    GR --> UC1
    GR --> UC3
    GR --> UC7

    GC --> UC1
    GC --> UC4

    SL --> UC1
    SL --> UC5
```

### B. Fluxo de Segurança e Bloqueio de Acesso
```mermaid
flowchart TD
    A([Usuário digita pergunta no Copiloto]) --> B[Analisa Pergunta e Extrai Escopo do SQL]
    B --> C{A consulta viola o escopo de cargoID / gestorID?}
    
    C -- Não --> D[Executa Consulta SQL no Banco]
    D --> E[Retorna Resposta ao Usuário]
    
    C -- Sim --> F[Bloqueia Execução do SQL]
    F --> G[Incrementa Contador de Tentativas NaoAutorizadas]
    G --> H{Contador de Tentativas >= 3?}
    
    H -- Não --> I[Exibe Mensagem: 'Acesso Negado ao Escopo Solicitado']
    
    H -- Sim --> J[Bloqueia Temporariamente o Acesso do Colaborador]
    J --> K[Gera Registro na Tabela de Auditoria com Status 'SUSPICIOUS_BLOCK']
    K --> L[Envia Alerta por E-mail ao gestorID Direto]
    L --> M([Acesso Bloqueado])
```

---

## 3. Diagrama de Arquitetura e Fluxo de Dados

```mermaid
sequenceDiagram
    autonumber
    actor Executivo as Usuario (Web/Mobile)
    participant Frontend as Frontend App
    participant Auth as Camada Autenticacao (JWT)
    participant Agent as Copiloto Text-to-SQL
    participant DB as Banco omni_store (Views / RLS)
    participant Audit as Tabela Auditoria

    Executivo->>Frontend: Digita pergunta: "Qual foi o faturamento da loja este mês?"
    Frontend->>Auth: Envia requisição POST /api/chat + Token JWT
    Auth-->>Frontend: Token Válido (Payload: funcionarioID, cargoID, gestorID, lojaID, regiaoID)
    Frontend->>Agent: Repassa Pergunta + Contexto do Usuário
    
    Note over Agent: Sanitização do Prompt & Análise da Intenção
    
    Agent->>Agent: Injeta Filtro de Permissão no Prompt SQL (Ex: WHERE lojaID = user.lojaID)
    Agent->>Agent: Traduz Pergunta -> Query SQL Otimizada (utilizando VIEWS pré-computadas)
    
    Agent->>DB: Executa SELECT em VIEWS / Tabelas Relacionais
    DB-->>Agent: Retorna Dataset (Linhas e Colunas)
    
    Note over Agent: Formatação dos dados em linguagem natural / JSON visual
    
    Agent->>Audit: Registra Pergunta, SQL Gerado, Tempo de Resposta e funcionarioID
    Audit-->>Agent: Confirmado (Log ID)
    
    Agent-->>Frontend: Retorna Resposta Estruturada + Gráficos
    Frontend-->>Executivo: Exibe Resposta Final na Tela
```