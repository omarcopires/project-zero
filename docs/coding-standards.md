# Padrões de código do novo motor

## Escopo

Aplicáveis ao código novo C++/Qt 6 e sua configuração. Não permitem alterar, traduzir, modernizar ou formatar o frontend original. As APIs legadas consumidas pelo QML devem ser implementadas pelos adaptadores, não removidas dos consumidores.

## Fonte de formatação

A [.clang-format](../.clang-format) adicionada pelo responsável é a autoridade e deve ser preservada. Valores inspecionados:

| Opção | Valor |
|---|---|
| `IndentWidth` / `TabWidth` | `4` / `4` |
| `UseTab` | `AlignWithSpaces` |
| `ColumnLimit` | `0` (sem limite imposto pelo formatador) |
| `NamespaceIndentation` | `All` |
| `PointerAlignment` / `ReferenceAlignment` | `Left` / `Right` |
| `QualifierAlignment` | `Left` |
| `SortIncludes` / `IncludeBlocks` | `Never` / `Preserve` |
| `InsertBraces` / `InsertNewlineAtEOF` | `true` / `true` |
| `UseCRLF` / `DeriveLineEnding` | `false` / `true` |

Chaves de funções, classes e estruturas de controle permanecem na mesma linha segundo `BraceWrapping`. Não deduzir um padrão WebKit ativo: `BasedOnStyle` é comentário. `Standard: Latest` afeta o formatador, não seleciona C++20/C++23 para compilação. A versão C++ e a versão da ferramenta serão fixadas após análise da toolchain; não migrar opções para fazê-las caber em um executável local incompatível.

Não rodar formatação global. Quando houver código novo autorizado, limitar a formatação aos arquivos C++ pertinentes, fora das árvores protegidas, resolvendo a ferramenta pelo PATH. Não foi executado formatador nesta migração.

## Nomenclatura e comentários

- Tipos e enumeradores: `PascalCase`.
- Funções, métodos, variáveis e parâmetros: `lowerCamelCase`.
- Membros privados novos: prefixo `m_`; campos públicos de estruturas de dados: `lowerCamelCase`.
- Nomes consumidos pelo frontend, APIs Qt e interfaces externas: preservar exatamente o contrato, incluindo grafias legadas como a role `liquideType` onde exigida.
- Código, comentários e mensagens internas novos em inglês. Comunicação e documentação de projeto em português.
- Comentários curtos explicam motivo, restrição ou invariância não evidente. Não narrar o fluxo, não manter histórico de bugs ou arquitetura extensa dentro das funções.
- Pastas, namespaces, manifesto, alvos CMake e executáveis devem descrever responsabilidades, sem marca, nome próprio fixo ou prefixos derivados do repositório ou de referências externas. Exemplos: `client`, `domain`, `transport`, `protocol`, `diagnostics`, `unit_tests`. A raiz do workspace e caminhos históricos não serão renomeados.
- Arquivos C++ novos: lower_snake_case, `.h`/`.cpp`; tipo principal em seu par quando houver implementação fora do header. Headers autocontidos com includes mínimos e proteção contra inclusão múltipla; não usar `using namespace` em headers públicos. Convenção específica de guards fica para o bootstrap, sem prefixo de marca.

## Enums e organização de tipos

- Todo enum novo é `enum class`, em header próprio nomeado pelo tipo: `ConnectionState` em `connection_state.h`, no módulo responsável. Um enum por arquivo; não agrupar em `enums.h`, classe consumidora ou header genérico.
- Enumeradores PascalCase, valores semânticos explícitos. Fixar tipo subjacente/valores quando exigidos por formato binário; não serializar o layout nativo do enum. Validar números externos e tratar valores desconhecidos explicitamente.
- Dependentes incluem o header do enum, sem copiar definições. Não centralizar enums de módulos distintos nem criar dependências reversas para reutilizá-los.
- Metadados Qt (`Q_ENUM`, `Q_ENUM_NS` ou wrappers) ficam em adaptadores de apresentação. Se o contrato exigir declaração aninhada, isolar e documentar a exceção e o mapeamento; o enum de domínio permanece independente e em arquivo próprio. Preservar nomes/valores exigidos pelo frontend original.

## Clean Architecture obrigatória

Clean Architecture rege dependências; Clean Code rege clareza e manutenção. Ambas se aplicam a todo backend novo, não apenas ao transporte.

| Módulo | Pode depender de | Não pode depender de |
|---|---|---|
| Domínio | Tipos de valor e biblioteca padrão | Transporte, persistência, apresentação, Qt/QML e spdlog |
| Casos de uso | Domínio e portas internas com consumidores reais | Implementações de sockets, logging, banco/arquivos ou UI |
| Adaptadores/infraestrutura | Contratos internos e bibliotecas necessárias | Detalhes de outro adaptador sem contrato explícito |
| Composição | Casos de uso e implementações concretas | Não transfere configuração concreta ao domínio |

Portas pertencem ao módulo interno consumidor. Eventos/erros internos são tipos próprios, sem `QObject`, tipos de socket ou `spdlog::logger` atravessando fronteiras. Adaptadores convertem dados externos e tratam detalhes operacionais. Enquadramento puro pode ser usado sem rede e sem logging concreto.

CMake deve expressar essa direção por alvo e distinguir dependências públicas/privadas; diretórios, sozinhos, não demonstram arquitetura. Proibir ciclos, singletons globais e service locators. Compor e injetar dependências explicitamente na entrada da aplicação, com lifecycle e cancelamento documentados. Não criar interfaces, fábricas ou camadas sem necessidade real.

## Logging padrão: spdlog

- spdlog é a implementação obrigatória, encapsulada em `infrastructure/logging` ou módulo equivalente descritivo. A escolha não está mais em aberto; versão e baseline serão fixadas na implementação autorizada. Nenhuma instalação nesta tarefa.
- Não incluir headers/tipos spdlog no domínio ou nos casos de uso. Preferir resultados/eventos para regras puras; uma porta mínima de logging só existe se houver consumidor interno real. Testes usam fake dessa porta quando necessário.
- A composição cria e injeta o logger concreto e configura sinks, níveis, formato e destino fora do Git conforme o perfil inicial abaixo. Não depender do logger global/default do spdlog; rotação/retenção exige mudança futura explícita.
- Garantir segurança entre threads e tratamento de falhas de sink no perfil síncrono inicial. Fila, overflow e política assíncrona só se aplicam após mudança futura aprovada. Garantir ordem de encerramento, flush e destruição antes dos recursos dependentes; não prometer desempenho sem medição.
- Mensagens em inglês; campos permitidos como evento, estado, categoria, duração e contagens. Não registrar credenciais, tokens, payloads, headers sensíveis ou URLs com segredos. Testar omissão/redação com dados sintéticos, inclusive em caminhos de erro.
- Não usar `printf`, `std::cout` ou `qDebug` dispersos como logging regular. Saída funcional de CLI não é log. Se mensagens Qt forem encaminhadas ao adaptador, evitar recursão e preservar a semântica fatal.

### Formato verificado na referência

Inspeção somente leitura em 2026-09-17 de `E:\caverot-client`, revisão `02e0ae82693cbb7036983329d03246157947a751`. Os três arquivos abaixo não apresentavam alterações locais no Git. Não foram abertos logs reais nem executados binários.

| Fonte relativa à referência | Evidência |
|---|---|
| `src/framework/core/logger.cpp`, `Logger::init` | Pattern literal `[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v`; console colorido `stdout_color_sink_mt`; arquivo `basic_file_sink_mt` em `debug.log`, truncado ao abrir; flush a partir de trace; debug com `--developer`, info por padrão |
| `src/framework/core/logger.h`, `normalizeLogMessage` | Percorre a mensagem até a primeira letra ASCII; converte-a para maiúscula se minúscula, ou para sem alterar se já maiúscula |
| `src/framework/luaengine/luaspdlog.cpp`, `logAt` | Obtém a função por `getCurrentFunction()` e compõe o payload com `"[{}] - {}"`, após normalização da mensagem |

O pattern global **não contém o nome da função**: esse prefixo integra `%v` no adaptador Lua. Chamadas C++ diretas examinadas também usam `{}`, mas nem todas incluem função ou normalização. O formatador Lua substitui `{}` sequencialmente e acrescenta argumentos excedentes separados por espaço; não é uma implementação completa de fmt. Não copiar essa limitação para C++.

### Contrato obrigatório do backend novo

- Preservar exatamente o pattern `[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v`: data, hora local com milissegundos, nome do logger, nível e payload. Os marcadores `%^`/`%$` delimitam a cor do nível no console; arquivo recebe texto sem códigos ANSI.
- O payload regular segue `[FunctionName] - Message`, composto pelo adaptador com `"[{}] - {}"`. Capturar a função **no ponto da chamada**, não o nome do wrapper de logging. Usar metadado padrão compatível com a toolchain ou parâmetro explícito; não criar macros globais apenas para reproduzir o logger antigo. Definir representação estável do nome, sem depender de assinaturas específicas do compilador.
- Normalizar somente o texto da mensagem como na referência: primeira letra ASCII em maiúscula, mantendo o restante; não normalizar o prefixo de função ou o nome do logger. Templates novos já devem começar com texto descritivo em inglês para evitar alterar valores interpolados.
- Argumentos de mensagens usam formatação tipada spdlog/fmt: `{}` e, quando necessário, especificadores como `{:08x}` ou `{:.2f}`. Não usar `%d`, `%s`, `printf`/`sprintf` ou concatenação para interpolar valores. Os tokens `%` do **pattern do logger** são outra linguagem e devem permanecer exatamente como acima. Chaves literais usam `{{` e `}}`; texto externo nunca vira format string.
- `%n` identifica responsabilidade (`transport`, `protocol`, `diagnostics`), não uma marca. A referência usa `GameClient`; não copiar esse identificador nem seu `set_default_logger`. Reproduzir o formato visual por instância injetada, sem violar Clean Architecture.
- Perfil inicial equivalente ao observado: logger síncrono, sinks thread-safe de console colorido e arquivo simples `debug.log`, truncamento ao iniciar, flush a partir de trace, nível info por padrão e debug em modo `--developer`. O arquivo fica no diretório de logs local fora do Git. Truncamento não preserva sessões anteriores; rotação/retenção ou logging assíncrono são mudanças futuras explícitas, não comportamentos já presentes na referência.
- Configuração, criação e encerramento continuam na composição; headers/tipos spdlog não atravessam domínio/casos de uso. Falha de inicialização deve ser explícita, sem copiar a continuação silenciosa após erro da referência. Nenhum payload sensível pode ser incluído para reproduzir a aparência dos logs.

Exemplo **sintético**, não saída de execução: `[2026-09-17 14:05:09.123] [transport] [info] [connect] - Connected to local endpoint`.

Na implementação autorizada, escrever testes determinísticos de pattern com horário controlado, origem da função, capitalização ASCII, interpolação de inteiro/string/chaves literais, ausência de ANSI no arquivo, filtragem de níveis e omissão de segredos. Validar também sinks, truncamento e flush em diretório temporário isolado. Esses testes ainda não existem nem foram executados; leitura de fonte comprova a configuração descrita, não equivalência operacional do motor novo.

## Engenharia

- Identificar responsabilidade, contratos, ownership e dependências antes de editar.
- Separar domínio, sessão, transporte, protocolo 15.25, integração Qt e renderização. Não exigir abstrações sem consumidores reais ou camadas que apenas repassem chamadas.
- Regras de domínio devem ser testáveis sem QML e sem rede. Adaptadores traduzem intenção e estado; QML original continua um contrato fixo, mesmo quando contém lógica de apresentação.
- Usar RAII e ownership explícito. Evitar proprietários concorrentes entre smart pointers e parent QObject. Definir validade de referências e comportamento de cancelamento/desconexão.
- Respeitar afinidade de threads Qt e sincronização do estado gráfico. Não acessar objetos de UI diretamente a partir da thread de transporte.
- Falhas são explícitas, contextualizadas e distinguem rede, autenticação, versão e estado inválido. Não registrar senhas, tokens ou dados de sessão sensíveis.
- Usar spdlog na infraestrutura conforme a política acima; não importar `g_logger` ou outros singletons da engine antiga. Não usar saídas de depuração dispersas como logging regular.
- Preservar testes determinísticos de regressão. Benchmarks devem manter semântica e cenários equivalentes, sem esconder o caminho lento ou reduzir qualidade visual para alegar otimização.

## CMake, vcpkg e testes

- Usar configuração por alvo e dependências explícitas; não espalhar flags globais que afetem bibliotecas externas.
- vcpkg em modo manifesto, baseline e triplet fixados. Origem única de Qt: ports vcpkg, conforme [decisão da Fase 0](phase0-contract-status.md). Versões, módulos/features, runtime e C++20 foram selecionados documentalmente; sua resolução e compatibilidade ainda exigem validação externa. Não misturar instalações/ABIs de Qt.
- Presets versionados devem ser reproduzíveis, sem caminhos pessoais ou segredos; configuração local separada.
- Tests unitários, integração Qt, integração de servidor e benchmarks têm responsabilidades distintas.
- Registrar procedimentos para responsável/CI; não executar configuração, instalação com compilação, build ou testes pelo agente.

## Commits

Somente quando solicitados pelo responsável ou após confirmação da feature aprovada: Conventional Commits em inglês, título ≤ 72 caracteres (limite do projeto, preferir ≤ 50; não é limite rígido universal do GitHub) e corpo detalhado com linhas de até 72 caracteres. A descrição explica o que mudou, por quê, impacto nos contratos do frontend (esperado "nenhum") e validações pendentes. Regras completas e exemplos: [política de commits](../.github/instructions/commits.instructions.md). Antes de encerrar, revisar diff e limitações sem alegar validação executável inexistente.

Fontes e adaptações: [migração de regras](rules-migration.md). Restrições operacionais: [política de validação](validation-policy.md).
