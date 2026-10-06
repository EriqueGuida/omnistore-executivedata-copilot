# Segurança e UX

> **Projeto:** OmniStore  
> **Documento:** Segurança e UX  
> **Objetivo:** documentar como controle de acesso, segurança, auditoria e experiência do usuário se relacionam no Copiloto Text-to-SQL.

---

## 1. Modelo de acesso

O OmniStore considera diferentes perfis de usuário, cada um associado a um escopo de consulta compatível com sua função organizacional.

Os perfis atualmente documentados são:

| Perfil | Escopo / comportamento documentado |
|---|---|
| Diretor Executivo | Consultas globais, visualização da auditoria e exportação de relatórios executivos |
| Gerente Regional | Consultas regionais e exportação de relatórios |
| Gerente de Categoria | Consultas por categoria |
| Supervisor de Loja | Consultas relacionadas à loja/equipe |

O contexto do usuário utilizado pelo fluxo arquitetural inclui `funcionarioID`, `cargoID`, `gestorID`, `lojaID` e `regiaoID`.

Esse contexto é relevante porque a pergunta em linguagem natural não determina, sozinha, quais dados podem ser consultados.

> **Regra relacionada:** o usuário somente pode executar consultas compatíveis com seu escopo de acesso. A definição completa das regras está centralizada em `01-contexto-e-requisitos.md`.

---

## 2. Autenticação

O fluxo arquitetural documentado representa uma camada de autenticação baseada em **JWT**.

O fluxo simplificado é:

```text
Usuário
   ↓
Frontend
   ↓
Requisição com Token JWT
   ↓
Camada de Autenticação
   ↓
Token validado + contexto do usuário
   ↓
Copiloto Text-to-SQL
```

O payload representado no fluxo contém informações utilizadas para contextualizar a consulta, incluindo `funcionarioID`, `cargoID`, `gestorID`, `lojaID` e `regiaoID`.

A documentação disponível não detalha o mecanismo completo de emissão, renovação, expiração ou revogação dos tokens. Esses pontos permanecem como decisões de implementação não especificadas.

---

## 3. Autorização

A autorização ocorre considerando o escopo associado ao usuário.

O fluxo documentado representa uma análise da pergunta antes da execução:

```text
Pergunta em linguagem natural
          ↓
Análise da pergunta
          ↓
Extração/análise do escopo da consulta
          ↓
Consulta está dentro do escopo?
      ↙             ↘
    Sim              Não
     ↓                ↓
 Executa          Bloqueia
```

O sistema não deve executar uma consulta que viole o escopo autorizado.

A documentação também representa a injeção de filtros de permissão no contexto da geração do SQL e indica `Views / RLS` na camada de banco.

### Ponto de atenção arquitetural

Existe uma distinção importante entre:

1. **gerar SQL com um filtro de autorização**; e
2. **garantir a autorização independentemente do SQL gerado**.

O projeto documenta ambos como elementos do fluxo/arquitetura, mas não especifica em detalhe como o enforcement definitivo será realizado no banco.

Portanto, não se deve assumir que o RLS já esteja implementado ou que o filtro gerado pelo Copiloto seja, sozinho, o mecanismo definitivo de segurança.

---

## 4. Escopo de dados

O escopo de dados está relacionado ao contexto organizacional do usuário.

A documentação representa diferentes níveis de consulta:

- **global**;
- **regional**;
- **por categoria**;
- **por loja/equipe**.

A finalidade é evitar que uma pergunta válida do ponto de vista sintático permita acesso a dados que não pertencem ao escopo do usuário.

Exemplo conceitual:

```text
Usuário com escopo regional
        ↓
Pergunta sobre dados de sua região
        ↓
Consulta autorizada
```

Em contraste:

```text
Usuário com escopo regional
        ↓
Pergunta sobre dados fora de seu escopo
        ↓
Consulta bloqueada
```

Os limites exatos de cada escopo devem continuar sendo derivados das regras e perfis definidos no projeto, sem adicionar permissões não documentadas.

---

## 5. Bloqueio de consultas

Quando a consulta viola o escopo autorizado, o fluxo documentado impede sua execução.

A interface correspondente apresenta uma mensagem explícita de **acesso negado ao escopo solicitado**, informando que a consulta está fora do escopo de acesso.

O bloqueio não é tratado apenas como um problema de interface. Ele faz parte do fluxo de segurança do sistema e está relacionado ao registro de auditoria e ao mecanismo de tratamento de tentativas repetidas.

> **Regra relacionada:** uma consulta que viole o escopo autorizado deve ser bloqueada antes da execução.

---

## 6. Auditoria

O OmniStore possui uma entidade `auditoriaConsulta` destinada ao registro das consultas realizadas pelo Copiloto.

Os campos documentados incluem:

- `consultaID`;
- `funcionarioID`;
- `perguntaTexto`;
- `sqlGerado`;
- `statusConsulta`;
- `motivoNegativa`;
- `tempoExecucaoMs`;
- `dataHoraConsulta`.

A arquitetura também representa o registro da consulta após a execução, incluindo pergunta, SQL gerado, tempo de resposta e identificador do funcionário.

A auditoria permite relacionar a interação do usuário ao comportamento do Copiloto e ao resultado da consulta.

### 6.1 Auditoria de bloqueios

O fluxo de segurança define que, ao atingir o limite de tentativas não autorizadas, é gerado um registro com status `SUSPICIOUS_BLOCK`.

A interface também possui uma tela de **Auditoria do Copiloto**, com histórico de consultas, funcionário, pergunta, status, tempo e acesso aos detalhes.

A documentação disponível não define a política de retenção dos registros nem todas as permissões administrativas sobre a auditoria.

---

## 7. Fluxo de tentativa não autorizada

O fluxo de segurança atualmente documentado é:

```text
Usuário envia pergunta
        ↓
Análise do escopo da consulta
        ↓
┌───────────────────────────────┐
│ Consulta viola o escopo?      │
└───────────────────────────────┘
       ↓ Sim
       ↓
Bloqueia execução do SQL
       ↓
Incrementa contador de tentativas
       ↓
┌───────────────────────────────┐
│ Contador >= 3?                │
└───────────────────────────────┘
       ↙                  ↘
     Não                  Sim
      ↓                    ↓
Mensagem de acesso     Bloqueio temporário
negado                 ↓
                       Registro de auditoria
                       ↓
                       Alerta por e-mail
                       ↓
                       Acesso bloqueado
```

O comportamento documentado estabelece três consequências principais:

1. a consulta não autorizada não é executada;
2. tentativas não autorizadas são contabilizadas;
3. após três tentativas, ocorre bloqueio temporário, registro de auditoria e alerta ao gestor direto.

O fluxo não define, porém, a duração do bloqueio nem o procedimento de desbloqueio. Esses pontos ainda precisam ser especificados.

---

## 8. Telas e fluxos UX/UI

O protótipo disponível representa diferentes estados do Copiloto Text-to-SQL e da auditoria.

### 8.1 Estado inicial

A tela inicial apresenta:

- identificação do Copiloto Text-to-SQL;
- indicação do escopo da consulta;
- campo para digitação da pergunta;
- botão de envio;
- exemplos de perguntas.

Esse estado reduz a ambiguidade sobre como iniciar uma interação e oferece exemplos do tipo de pergunta esperado.

### 8.2 Processamento

Durante o processamento, a interface apresenta:

- a pergunta enviada;
- indicação visual de processamento;
- mensagem orientando o usuário a aguardar;
- opção de cancelamento.

O estado de carregamento comunica que a operação ainda está em andamento, evitando que o usuário interprete a ausência imediata de resposta como uma falha.

### 8.3 Resposta autorizada

Quando a consulta é autorizada e processada, a interface apresenta:

- a pergunta realizada;
- a resposta em linguagem natural;
- visualização gráfica dos dados;
- opção de realizar nova pergunta;
- opção de exportar.

### 8.4 Acesso negado

Quando a consulta está fora do escopo, o protótipo apresenta um estado específico de **Acesso Negado ao Escopo Solicitado**.

A mensagem explica que a consulta solicitada está fora do escopo de acesso e oferece uma ação para iniciar uma nova pergunta.

Esse comportamento é importante porque transforma uma regra de segurança em um feedback compreensível para o usuário.

### 8.5 Bloqueio temporário

Após múltiplas tentativas não autorizadas, o protótipo apresenta o estado **Acesso Bloqueado**, informando que o acesso do colaborador foi bloqueado após múltiplas tentativas não autorizadas.

Esse estado comunica que o problema deixou de ser apenas uma consulta individual recusada e passou a afetar o acesso do usuário.

### 8.6 Auditoria

A tela de Auditoria do Copiloto apresenta um histórico de consultas com informações como:

- data/hora;
- funcionário;
- pergunta;
- status;
- tempo;
- acesso aos detalhes.

Essa tela conecta diretamente o requisito de auditoria à experiência de consulta dos registros.

---

## 9. Estados da interface

O protótipo representa os seguintes estados principais:

| Estado | Objetivo | Feedback ao usuário |
|---|---|---|
| Inicial | Permitir iniciar uma consulta | Campo de pergunta e exemplos |
| Processando | Informar que a consulta está sendo processada | Indicador de carregamento e opção de cancelar |
| Resposta autorizada | Apresentar o resultado | Resposta, gráfico e ações posteriores |
| Acesso negado | Informar que a consulta não pode ser executada | Mensagem de escopo e nova pergunta |
| Bloqueio temporário | Informar que o acesso foi bloqueado | Mensagem de bloqueio |
| Ausência de dados | Informar que não existem resultados para a consulta | Mensagem orientativa e nova pergunta |
| Exportação | Informar o estado da geração/exportação | Estados de exportação e confirmação |
| Erro | Informar uma falha inesperada | Mensagem de erro e orientação para tentar novamente |

Os estados de ausência de dados, exportação e erro aparecem nos componentes reutilizáveis do protótipo. A documentação funcional disponível, porém, não detalha todas as condições que levam a cada um desses estados.

---

## 10. Tratamento de erros

O tratamento de erros deve ser analisado em conjunto com os estados da interface.

O protótipo apresenta pelo menos três categorias relevantes:

### 10.1 Acesso negado

Não representa uma falha técnica. É uma resposta esperada quando a solicitação está fora do escopo autorizado.

A interface deve comunicar claramente a restrição sem sugerir que a consulta simplesmente falhou.

### 10.2 Bloqueio

Também não representa uma falha técnica. É uma consequência de uma regra de segurança após múltiplas tentativas não autorizadas.

### 10.3 Erro inesperado

O protótipo possui um componente de erro com mensagem orientando o usuário a tentar novamente.

A documentação atual não especifica quais erros técnicos devem produzir esse estado nem como erros de geração de SQL, banco ou comunicação são classificados.

Portanto, essas situações permanecem como uma área de especificação futura.

---

## 11. Acessibilidade e usabilidade

A avaliação de UX/UI do OmniStore considera, além da aparência, aspectos de comunicação e interação:

- clareza dos estados da interface;
- hierarquia visual;
- feedback durante operações demoradas;
- comunicação explícita de bloqueios;
- diferenciação entre sucesso, informação, erro e restrição de acesso;
- possibilidade de iniciar uma nova consulta após uma resposta ou bloqueio;
- consistência dos componentes reutilizáveis.

O protótipo demonstra preocupação com esses aspectos por meio de estados específicos para processamento, sucesso, acesso negado, bloqueio, ausência de dados, exportação e erro.

Entretanto, **requisitos formais de acessibilidade ainda não estão definidos na documentação disponível**. Não foram estabelecidos, por exemplo, critérios formais relacionados a navegação por teclado, contraste, leitores de tela ou conformidade com uma norma específica.

Portanto, acessibilidade deve ser tratada como uma área a ser especificada e validada posteriormente, e não como uma característica já comprovadamente atendida.

---

## 12. Relação entre segurança e UX

No OmniStore, segurança e UX não são tratados como assuntos completamente independentes.

O fluxo pode ser resumido como:

```text
Regra de segurança
       ↓
Decisão do sistema
       ↓
Estado da interface
       ↓
Feedback ao usuário
```

Exemplo:

```text
Consulta fora do escopo
        ↓
Consulta bloqueada
        ↓
Estado "Acesso Negado"
        ↓
Usuário recebe explicação + pode iniciar nova pergunta
```

E, em uma situação mais grave:

```text
3 tentativas não autorizadas
        ↓
Bloqueio temporário
        ↓
Registro de auditoria
        ↓
Alerta ao gestor
        ↓
Estado "Acesso Bloqueado"
```

Essa relação é uma característica relevante do projeto porque demonstra que a segurança não foi considerada apenas como uma camada técnica invisível. Seus efeitos também precisam ser comunicados de forma compreensível na interface.

---

## 13. Pontos ainda não definidos

A documentação atual não especifica completamente:

- mecanismo detalhado de autorização no banco;
- implementação efetiva do RLS;
- duração do bloqueio temporário;
- procedimento de desbloqueio;
- política de retenção da auditoria;
- permissões completas para acesso à auditoria;
- tratamento detalhado de falhas de geração de SQL;
- tratamento detalhado de falhas de banco ou comunicação;
- requisitos formais de acessibilidade;
- critérios quantitativos de usabilidade ou desempenho.

Esses pontos devem ser tratados como **lacunas de especificação** e não como funcionalidades já implementadas.

---

## 14. Referência às regras de negócio

As regras de negócio permanecem centralizadas em `01-contexto-e-requisitos.md`.

Este documento apenas as utiliza para explicar o comportamento de segurança e seus reflexos na interface, evitando duplicação e possíveis inconsistências entre documentos.

A principal cadeia de comportamento é:

```text
Perfil + contexto do usuário
          ↓
Escopo autorizado
          ↓
Análise da consulta
          ↓
Autorizada → execução → resposta
          ↓
Não autorizada → bloqueio → contagem
                              ↓
                         3 tentativas
                              ↓
                  bloqueio temporário
                              ↓
                   auditoria + alerta
```
