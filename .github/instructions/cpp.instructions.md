---
description: "Use ao criar ou revisar C++ do backend: Clean Architecture, Clean Code, nomes descritivos, enums separados, spdlog, ownership, Qt e testes. Não autoriza build nem alteração do frontend original."
applyTo: "**/*.cpp,**/*.h,**/*.hpp,**/*.cc,**/*.cxx"
---

# Padrão C++ do novo motor

- Use a `.clang-format` da raiz como fonte de formatação. Não substitua por estilo presumido WebKit: `BasedOnStyle` está comentado. `Standard: Latest` não fixa o padrão C++ do compilador.
- Tipos e enumeradores em `PascalCase`; funções, métodos, parâmetros e variáveis em `lowerCamelCase`. Novos membros privados de classes usam `m_`; campos públicos de estruturas de dados usam `lowerCamelCase`. Nomes de APIs Qt e contratos exigidos pelo frontend são exceções obrigatórias.
- Código e comentários novos em inglês. Comentários devem explicar uma invariância, restrição ou motivo não evidente, não narrar cada linha. Contexto arquitetural e histórico pertencem a `docs/` e testes.
- Use nomes descritivos de responsabilidade para pastas, arquivos, namespaces, alvos e executáveis; nunca adote marca, nome fixo ou prefixos de repositórios de referência. Preserve caminhos históricos e contratos externos.
- Todo backend segue Clean Architecture e Clean Code: domínio → sem dependência de infraestrutura; casos de uso → domínio e portas internas; adaptadores → portas; composição → implementações concretas. Não criar ciclos, service locators ou dependências de sockets, QML, spdlog e persistência nos módulos internos.
- Prefira responsabilidade única, funções coesas e nomes explícitos. Evite booleanos ambíguos, parâmetros sentinela, classes genéricas de utilidades, duplicação de regras e interfaces sem consumidor real. Não dividir código apenas para aumentar o número de camadas.
- Cada enum novo é `enum class` em header próprio (`connection_state.h` para `ConnectionState`), no módulo que o possui; um enum por arquivo. Não criar `enums.h` central nem misturar enums a classes. Use tipo subjacente explícito quando houver contrato binário; valide valores externos antes de convertê-los. Exceções de metadados Qt exigidas pelo contrato são isoladas no adaptador e documentadas, nunca propagadas ao domínio.
- Arquivos novos C++ usam lower_snake_case com `.h`/`.cpp`; cada tipo principal em seu par de arquivos quando houver implementação fora do header. Headers devem ser autocontidos, com includes mínimos, sem `using namespace` público. Não renomear APIs ou arquivos protegidos para adequá-los.
- Separe regras determinísticas de transporte, arquivos e renderização. Não acrescente dependências da engine OTClient, `g_logger`, `g_ui` ou `g_modules`.
- Use RAII, ownership explícito, semântica de valor e smart pointers adequados. Não combine ownership por parent QObject e smart pointer proprietário sem justificar o ciclo de vida. Referências não proprietárias devem ter validade definida.
- Respeite afinidade de thread de QObject e regras do Qt Quick. Transporte não altera diretamente objetos QML de outra thread; sincronize estado consumido pela renderização.
- Declare falhas explicitamente; não transforme erro de rede/decodificação em sucesso nem mantenha referências inválidas após desconexão.
- Use spdlog como única implementação de logging regular do backend, encapsulada na infraestrutura. Injete uma porta mínima quando um caso de uso realmente precisar de logging; regras puras retornam resultados/erros sem efeitos de log. Não expor spdlog em APIs internas nem usar logger global, `printf`, `std::cout` ou `qDebug` dispersos como substitutos.
- Inicialize sinks, níveis e flush/shutdown na composição; defina ownership e segurança entre threads. Perfil inicial síncrono com console colorido e arquivo simples truncado ao iniciar, sem rotação/fila assíncrona; mudanças futuras exigem decisão explícita. Seguir o [formato verificado](../../docs/coding-standards.md#formato-verificado-na-referência).
- Pattern obrigatório: `[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v`; payload `[FunctionName] - Message`, com função capturada no ponto da chamada e normalização ASCII conforme documentação. Nome do logger descritivo, sem marca. Argumentos usam `{}`/formatação tipada fmt, nunca `%d`/`%s`; não confundir com tokens `%` do pattern. Não usar texto externo como format string.
- Redija mensagens em inglês; nunca registrar credenciais, tokens, payloads ou dados sensíveis. Integração de mensagens Qt deve evitar recursão e preservar a semântica de mensagens fatais.
- Preserve exatamente nomes, roles, propriedades, métodos e sinais necessários aos componentes QML originais. Implemente compatibilidade no código novo, sem renomear os consumidores.
- Escreva testes de regras e regressões em escopo isolado; benchmarks não substituem testes de correção. Não execute builds, CTest ou testes compilados.
- Formatação futura, quando houver implementação autorizada, limita-se aos arquivos C++ novos/alterados no escopo. Ferramenta deve ser resolvida pelo PATH; se indisponível ou incompatível, registrar pendência, não editar `.clang-format` para contornar.

Detalhes: [padrões de código](../../docs/coding-standards.md) e [política de validação](../../docs/validation-policy.md).
