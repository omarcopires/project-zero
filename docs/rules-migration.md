# Migração de regras para o novo cliente

Data: 2026-09-17. Migração seletiva solicitada pelo responsável; não é adoção da engine antiga.

Os caminhos abaixo identificam fontes históricas, não uma marca do novo projeto. Não derivar deles nomes ou prefixos de pastas, namespaces, manifesto, alvos ou executáveis. A raiz existente não será renomeada.

Requisitos posteriores do responsável: Clean Architecture e Clean Code para todo backend; spdlog encapsulado na infraestrutura, com composição/injeção explícita; enums novos em headers próprios por tipo/módulo. Detalhes nos [padrões de código](coding-standards.md).

## Fontes examinadas

- `E:\caverot-client\.ai\agent.md`: regras de idioma, código, commits, arquitetura, build e validação. Lido integralmente.
- `E:\caverot-client\docs\architecture.md`: responsabilidade, portas, ownership e política mais restrita para testes compilados.
- `E:\caverot-client\docs\sound-system\README.md`: separação de contratos/testes e validação manual de CTest/cliente.
- `E:\caverot-client\.clang-format` e `.editorconfig`: formatação existente; a configuração já adicionada a `project-zero` é a autoridade local e não foi substituída.
- `E:\caverot-client\docs\tests.md`, `docs\benchmark-separation-plan.md` e `docs\otcv8-performance-roadmap.md`: testes isolados, fixtures e medição sem mudança de semântica.
- `E:\caverot-client\src\client\container.h`, `soundplaybackpolicy.h` e `soundevent.h`: exemplos de nomenclatura observada, não APIs a importar.
- `E:\caverot-client\docs\qml-import.md` e `docs\otui-editor\15-qml-import.md`: demonstram uma estratégia de importação QML/OTUI que não se aplica aqui.

A enumeração da raiz, `.ai/` e `.github/` da origem identificou `.ai/agent.md` como entrada principal de regras e não mostrou `AGENTS.md`, `.github/copilot-instructions.md` ou `.github/instructions/` nesses locais. Não se afirma ausência de customizações em toda subpasta profunda. Não foram lidos logs, segredos, executáveis ou dumps para esta migração.

## Decisões de migração

| Regra da origem | Tratamento no destino |
|---|---|
| Comunicação em português; código e comentários em inglês | Preservada para código novo |
| Documentação em `docs/` | Preservada |
| Regras centralizadas em `.ai/` | Adaptada para `.github/copilot-instructions.md`, entrada reconhecida pelo Copilot, mais instruções C++ específicas |
| Conventional Commits, título 50/corpo 72 | Preservada e detalhada em [política de commits](../.github/instructions/commits.instructions.md): título ≤ 72 (preferir ≤ 50), corpo detalhado, commit só após solicitação/confirmação da feature |
| Proibição de configurar/gerar/build/rebuild/limpar | Preservada e estendida explicitamente a wrappers, subagentes e instalações vcpkg que compilem |
| Permissão limitada de testes binários em `.ai/agent.md` versus proibição em `docs/architecture.md` | Conflito resolvido pelo critério mais restrito: agentes não executam testes compilados, CTest, cliente ou servidor |
| Formatar todo `src/` e executar `stylua .` | Não migrada; proibida formatação global e de conteúdo protegido |
| Modernização remove aliases e legado | Não pode remover nenhum contrato consumido pelo QML original; compatibilidade fica no adaptador novo |
| C++20 da origem | Não fixa automaticamente o padrão novo; toolchain será decidida com Qt 6 |
| `CamelCase` genérico | Especificado como tipos/enums PascalCase e funções/variáveis lowerCamelCase; `m_` para membros privados novos |
| Lua, OTUI, ImGui, `g_ui`, `g_modules`, `g_logger` | Não transplantados para o motor Qt |
| Invariante de árvore `UIWidget` do OTClient | Preservado princípio de ownership, não a implementação antiga |
| Conversão QML para OTUI | Explicitamente proibida |
| Testes e benchmarks existentes/concluídos | Não copiados como evidência do projeto novo |
| EditorConfig global, StyLua, Luacheck e atributos específicos ANGLE | Não copiados; poderiam afetar originais ou introduzir infraestrutura irrelevante |

## Nova regra mandatória: frontend original imutável

As árvores `data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/` e `message.txt` permanecem byte a byte intactas. Não renomear, mover, remover, normalizar, formatar, converter ou gerar arquivos nelas. A proteção abrange QML, JS, JSON, descritores de módulos, gráficos e outros recursos.

Não basta deixar a cópia original intacta e carregar uma cópia modificada: patches, substituições em runtime e componentes de mesmo nome que alterem o frontend também são proibidos. Os tipos nativos ausentes podem e devem ser implementados no novo motor conforme seus contratos; isso não autoriza substituir componentes QML já existentes.

Incompatibilidades devem ser resolvidas no C++/Qt novo, registro de tipos, modelos, providers e aliases externos. Se isso não for possível, documentar bloqueio e interromper o recurso afetado. Não excluir material por parecer vestígio de backend.

## Documentos produzidos

- [Instruções gerais](../.github/copilot-instructions.md)
- [Instruções C++](../.github/instructions/cpp.instructions.md)
- [Padrões de código](coding-standards.md)
- [Política de validação](validation-policy.md)
- [Plano completo](project-plan-2026-09-17.md)
- [Auditoria de recursos/backend](backend-resource-audit.md)

Não foram adicionados hooks, agentes executores, workflows, comandos de build, dependências ou cópias concorrentes de regras em `.ai/` e `AGENTS.md`. Instruções são orientações comportamentais, não ACLs nem garantia automática de integridade.
