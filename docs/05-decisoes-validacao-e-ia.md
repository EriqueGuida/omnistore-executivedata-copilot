# Decisões, Validação e Uso de IA

> **Projeto:** OmniStore  
> **Documento:** Decisões, Validação e Uso de IA  
> **Objetivo:** registrar as principais decisões do projeto, os critérios utilizados para avaliá-las, os trade-offs identificados e a forma como a IA foi utilizada durante o desenvolvimento.

---

## 1. Decisões técnicas

Este documento diferencia decisões efetivamente registradas no projeto de questões que ainda estão em aberto. Isso evita apresentar hipóteses ou possibilidades técnicas como se fossem implementações concluídas.

### 1.1 Utilização de um Copiloto Text-to-SQL

Foi definida a utilização de um Copiloto Text-to-SQL como principal mecanismo de interação com os dados.

A proposta é permitir que o usuário faça perguntas em linguagem natural, em vez de precisar escrever SQL diretamente.

A decisão está diretamente relacionada ao objetivo do projeto de aproximar a análise de dados da linguagem utilizada pelos usuários de negócio.

### 1.2 Contextualização da consulta pelo usuário

A arquitetura considera o envio, junto à pergunta, de informações relacionadas ao usuário, incluindo:

- `funcionarioID`;
- `cargoID`;
- `gestorID`;
- `lojaID`;
- `regiaoID`.

Essas informações são utilizadas para contextualizar o processamento da consulta e o escopo de acesso.

### 1.3 Autenticação por JWT

A arquitetura documentada utiliza uma camada de autenticação baseada em JWT.

O token validado fornece o contexto necessário para que o fluxo encaminhe a pergunta ao Copiloto.

A documentação não especifica todos os detalhes de ciclo de vida do token, como emissão, renovação ou revogação. Esses pontos permanecem como decisões de implementação pendentes.

### 1.4 Auditoria das consultas

Foi definida uma estrutura específica para registrar consultas realizadas pelo Copiloto.

A entidade `auditoriaConsulta` registra informações como:

- funcionário;
- pergunta realizada;
- SQL gerado;
- status da consulta;
- motivo de negativa;
- tempo de execução;
- data e hora.

A decisão permite relacionar a interação do usuário ao comportamento do Copiloto e ao resultado da consulta.

### 1.5 Bloqueio de consultas fora do escopo

Foi definido que consultas que violem o escopo autorizado não devem ser executadas.

O fluxo documentado também estabelece um tratamento progressivo para tentativas repetidas:

1. bloquear a consulta;
2. contabilizar a tentativa;
3. após três tentativas, bloquear temporariamente o acesso;
4. registrar o evento na auditoria;
5. enviar alerta ao gestor direto.

### 1.6 Uso de Views / RLS na camada de dados

A arquitetura representa o banco `omni_store` utilizando **Views / RLS**.

Essa representação indica uma preocupação com o controle do acesso próximo à camada de dados.

Entretanto, a documentação atual não especifica a implementação detalhada do RLS. Portanto, a existência dessa decisão arquitetural no diagrama não deve ser interpretada como evidência de que uma política RLS já foi implementada e validada em banco real.

---

## 2. Alternativas consideradas

Nem todas as alternativas técnicas foram formalmente registradas durante o desenvolvimento. Por isso, esta seção diferencia alternativas documentadas de questões arquiteturais identificadas durante a análise.

### 2.1 Controle de acesso no Copiloto versus enforcement no banco

O fluxo documentado apresenta dois elementos relacionados à autorização:

- análise do escopo e injeção de filtro durante o processamento do SQL;
- indicação de Views / RLS no banco.

Esses elementos podem representar camadas complementares de segurança, mas a documentação ainda não define a responsabilidade exata de cada uma.

A questão arquitetural é relevante porque existe diferença entre:

> **Orientar a geração do SQL para respeitar o escopo**

 e

> **Garantir tecnicamente que uma consulta fora do escopo não consiga acessar os dados.**

A segunda abordagem oferece uma fronteira de segurança mais independente do comportamento da LLM.

**Status:** questão arquitetural identificada; decisão definitiva de implementação ainda não registrada.

### 2.2 Regra de segurança na aplicação versus banco de dados

Uma possibilidade é realizar verificações principalmente na camada da aplicação/Copiloto. Outra é utilizar mecanismos do banco para impor restrições de acesso.

O projeto atualmente representa elementos das duas abordagens, mas não documenta uma comparação formal ou uma decisão final sobre a divisão de responsabilidades.

Portanto, não é correto afirmar que uma das alternativas foi definitivamente escolhida como única camada de segurança.

---

## 3. Trade-offs

### 3.1 Linguagem natural versus controle sobre a consulta

**Benefício:** o usuário não precisa conhecer SQL para consultar os dados.

**Custo:** a geração automática de SQL introduz uma camada adicional de interpretação e aumenta a necessidade de validação e controle.

**Implicação:** quanto mais autonomia é dada ao Copiloto, maior deve ser a preocupação com autorização, validação e auditoria.

### 3.2 Flexibilidade da LLM versus previsibilidade

A geração de consultas por uma LLM oferece flexibilidade para interpretar perguntas diferentes.

Por outro lado, uma solução baseada em geração probabilística exige mecanismos que reduzam o risco de uma interpretação incorreta ou incompatível com o escopo do usuário.

O projeto trata esse risco por meio da combinação de contexto de acesso, análise de escopo, bloqueio e auditoria.

### 3.3 Segurança versus experiência do usuário

Bloquear uma consulta é necessário quando ela viola o escopo autorizado, mas uma mensagem de erro pouco clara poderia gerar uma experiência ruim.

Por isso, o projeto associa o controle de segurança a estados específicos da interface, como **Acesso Negado** e **Bloqueio Temporário**.

A decisão demonstra que segurança não deve ser tratada apenas como uma regra técnica: o usuário também precisa receber feedback compreensível sobre o que ocorreu.

### 3.4 Auditoria versus exposição de informações

Registrar a pergunta e o SQL gerado aumenta a capacidade de investigação e rastreabilidade.

Por outro lado, esses registros podem conter informações que exigem proteção adequada.

A documentação define os campos da auditoria, mas ainda não especifica política de retenção, proteção ou classificação desses registros.

**Conclusão:** o benefício da rastreabilidade foi definido, mas os controles complementares da auditoria ainda precisam ser especificados.

---

## 4. Validação dos requisitos

A validação do projeto é baseada na comparação entre requisitos, casos de uso, fluxos, arquitetura, modelo de dados e protótipo.

### 4.1 Validação por rastreabilidade

Os principais comportamentos possuem correspondência entre diferentes artefatos:

| Necessidade / requisito | Caso de uso | Arquitetura / fluxo | UX / validação |
|---|---|---|---|
| Perguntar em linguagem natural | UC01 | Usuário → Frontend → Copiloto | Campo de pergunta |
| Consulta global | UC02 | Copiloto → Banco | Resultado da consulta |
| Consulta regional | UC03 | Copiloto → Banco | Resultado da consulta |
| Consulta por categoria | UC04 | Copiloto → Banco | Resultado da consulta |
| Consulta loja/equipe | UC05 | Copiloto → Banco | Resultado da consulta |
| Auditoria | UC06 | Copiloto → Auditoria | Tela de auditoria |
| Exportação | UC07 | Fluxo de resposta | Ação de exportação |
| Bloqueio por escopo | Regras de autorização | Análise de escopo → bloqueio | Estado Acesso Negado |
| Tentativas repetidas | Regras de segurança | Contador → bloqueio | Estado de bloqueio |

Essa rastreabilidade é útil porque permite verificar se um comportamento definido nos requisitos aparece também no fluxo e na experiência do usuário.

### 4.2 Validação dos fluxos de segurança

O fluxo documentado de tentativa não autorizada foi usado como referência para verificar a sequência esperada:

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
   Negado    Bloqueio
             + Auditoria
             + Alerta
```

O fluxo é coerente com os comportamentos definidos nos requisitos e casos de uso.

### 4.3 Validação por protótipo

O protótipo permite avaliar a representação visual de diferentes estados do sistema, incluindo:

- estado inicial;
- processamento;
- resposta autorizada;
- acesso negado;
- bloqueio temporário;
- auditoria;
- ausência de dados;
- erro;
- exportação.

Essa validação é principalmente comportamental e de UX. Ela não comprova, por si só, que os mecanismos de segurança foram implementados ou testados tecnicamente.

---

## 5. Como a solução foi avaliada

A avaliação atual considera quatro perspectivas complementares:

### 5.1 Requisitos

Verificação da correspondência entre necessidades, requisitos funcionais, requisitos não funcionais e regras de negócio.

### 5.2 Casos de uso

Verificação de que os perfis de usuário possuem comportamentos e capacidades compatíveis com o que foi definido.

### 5.3 Arquitetura e modelagem

Verificação de que o fluxo principal representado —

```text
Usuário
  ↓
Frontend
  ↓
Autenticação
  ↓
Copiloto
  ↓
Banco
  ↓
Auditoria
  ↓
Frontend
```

é compatível com os requisitos documentados.

### 5.4 UX e segurança

Verificação de que situações relevantes de segurança possuem representação na interface, principalmente nos estados de acesso negado e bloqueio.

### 5.5 Limite da validação atual

A documentação disponível não apresenta evidências de testes automatizados, testes de segurança, testes de carga ou validação com usuários reais.

Portanto, esses mecanismos não devem ser apresentados como realizados.

---

## 6. Uso de IA no projeto

A IA foi utilizada como ferramenta de apoio à Engenharia de Requisitos e ao desenvolvimento da documentação do OmniStore.

Seu uso não substitui a responsabilidade do autor pelas decisões do projeto.

A utilização da IA ocorre principalmente em duas funções:

1. **apoio à análise e documentação**;
2. **simulação de stakeholder**.

A IA também pode ser utilizada para questionar decisões, identificar ambiguidades e propor cenários para análise.

---

## 7. IA como stakeholder simulado

Uma LLM foi utilizada para representar o **Diretor de Operações da OmniStore**, um stakeholder fictício.

O objetivo dessa simulação é criar situações semelhantes às encontradas em um processo de Engenharia de Requisitos, como:

- apresentação de necessidades de negócio;
- questionamento de decisões;
- apresentação de restrições;
- conflitos entre necessidades;
- ambiguidades de requisitos;
- solicitação de validação de entregáveis;
- feedback sobre artefatos.

### 7.1 Limite da simulação

A LLM não é um cliente real e suas respostas não constituem evidência de requisitos reais de uma organização.

As informações produzidas durante a simulação precisam ser analisadas pelo autor antes de serem incorporadas à documentação do projeto.

---

## 8. Limites do uso de IA

A utilização de IA no projeto possui limites claros.

### 8.1 A IA não é autoridade sobre os requisitos

Uma sugestão produzida pela LLM não se torna automaticamente um requisito.

O requisito precisa ser analisado e aceito pelo autor do projeto.

### 8.2 A IA não substitui validação técnica

Uma resposta gerada por IA não comprova que uma arquitetura, política de segurança ou implementação realmente funciona.

Por exemplo, uma sugestão sobre RLS não é evidência de que uma política RLS foi implementada e testada.

### 8.3 A IA pode produzir informações incorretas ou inadequadas

Por esse motivo, o projeto mantém a documentação como fonte de referência e diferencia:

- decisão tomada;
- comportamento documentado;
- proposta;
- hipótese;
- implementação futura.

### 8.4 A IA não é apresentada como cliente real

O stakeholder utilizado no projeto é explicitamente fictício e simulado.

Essa distinção é importante para manter a honestidade metodológica do portfólio.

---

## 9. Decisões tomadas pelo autor

As decisões finais do projeto são de responsabilidade do autor.

Entre as decisões atualmente consolidadas estão:

- utilizar um Copiloto Text-to-SQL como interface de consulta;
- representar diferentes perfis de acesso;
- considerar o contexto organizacional do usuário nas consultas;
- utilizar autenticação baseada em JWT na arquitetura documentada;
- registrar consultas em uma estrutura de auditoria;
- bloquear consultas fora do escopo autorizado;
- contabilizar tentativas não autorizadas;
- aplicar bloqueio temporário após três tentativas;
- registrar o bloqueio como `SUSPICIOUS_BLOCK`;
- alertar o gestor direto após o bloqueio;
- representar Views / RLS na arquitetura de dados;
- relacionar os estados de segurança a feedbacks específicos na interface.

Essas decisões devem ser entendidas no contexto da documentação atual. Quando a documentação não fornece detalhes suficientes para afirmar que uma decisão já foi implementada, o documento mantém essa limitação explícita.

---

## 10. Decisões ainda pendentes

A análise dos artefatos também evidencia decisões que ainda não foram formalizadas.

Entre elas:

- como o RLS será efetivamente implementado;
- qual camada terá a responsabilidade final pelo enforcement de autorização;
- duração do bloqueio temporário;
- mecanismo de desbloqueio;
- política de retenção da auditoria;
- requisitos quantitativos de desempenho;
- estratégia de testes de segurança;
- critérios de teste para consultas geradas pela LLM;
- política de proteção dos registros de auditoria.

Esses pontos devem entrar no projeto somente após decisão explícita, e não como se já fossem características implementadas.

---

## 11. Síntese das decisões

O OmniStore não foi estruturado apenas como uma demonstração de geração automática de SQL.

A solução foi organizada considerando a cadeia:

```text
Necessidade de negócio
        ↓
Pergunta em linguagem natural
        ↓
Contexto do usuário
        ↓
Análise de escopo
        ↓
Geração de SQL
        ↓
Execução controlada
        ↓
Resposta
        ↓
Auditoria
```

Quando ocorre uma tentativa não autorizada, o fluxo se altera:

```text
Pergunta
   ↓
Análise de escopo
   ↓
Violação
   ↓
Bloqueio
   ↓
Contabilização
   ↓
3 tentativas?
   ↓
Bloqueio temporário
   ↓
Auditoria + alerta
```

Essa estrutura evidencia uma preocupação com o problema completo: **quem pode consultar, o que pode consultar, como a consulta é processada, como uma violação é tratada e como o comportamento é registrado**.

Ao mesmo tempo, o projeto mantém explícitas suas limitações e não apresenta como implementado aquilo que ainda está apenas definido conceitualmente.
