# Fase 2 — Contrato inicial do handshake do mundo

Data: 2026-09-23. Cliente de referência em `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; servidor em `f42413eff8d59b04087b52d1b793a4c685de5a82`.

## Desafio inicial do servidor

O perfil 15.25 usa `ServerChallengeBeforeLogin`. Antes de receber o login, o servidor envia um frame moderno cujo corpo não está criptografado e possui 12 bytes:

1. Adler-32 little-endian de quatro bytes, calculado sobre os oito bytes seguintes;
2. marcador `0x01`, consumido pelo cliente como byte inicial do pacote moderno;
3. opcode `0x1F`;
4. timestamp little-endian de 32 bits;
5. byte aleatório;
6. trailer `0x71`.

O decoder deste incremento exige comprimento exato e valida checksum, marcador, opcode e trailer antes de expor timestamp e byte aleatório. Ele opera somente sobre o corpo já separado pelo envelope externo implementado na Fase 1.

## Login subsequente confirmado

Após validar o desafio, o cliente monta o login com identificador de protocolo `0x000A`, sistema operacional, a versão única do cliente 1525 nos campos numéricos exigidos pelo fio, texto de versão derivado automaticamente, identificador de assets e preview state. O bloco RSA de 128 bytes começa com zero, contém quatro palavras XTEA, flag de game master, chave de sessão, personagem, timestamp e byte aleatório, seguido pelo campo opcional de extensão vazio e padding. O servidor descriptografa esse bloco antes de habilitar XTEA.

A escrita exata do bloco RSA, sua chave pública, o probe estendido, checksum/sequência externa e a ativação da criptografia serão implementados em incrementos separados. Nenhum pacote de login foi produzido ou enviado nesta etapa.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 82`. Os seis testes adicionais cobrem uma fixture moderna conhecida, comprimento inesperado, checksum inválido, marcador inicial inválido, opcode inválido e trailer inválido.

## Catálogo e primitivas binárias

Constantes do handshake ficam em um catálogo interno com nomes de domínio, incluindo tamanhos, offsets, marcadores, opcode, versão, identificador do login e dimensões de RSA/XTEA. Leitura e escrita little-endian e Adler-32 ficam em módulos binários reutilizáveis. Fixtures conhecidas mantêm bytes literais como evidência independente; mutações e código de produção usam os nomes do catálogo.

Validação externa de 2026-09-23: após a extração do catálogo e das primitivas binárias, o responsável informou `100% tests passed, 0 tests failed out of 86`. Os quatro testes adicionais cobrem leitura little-endian, recusa de leitura fora dos limites, escrita little-endian e um vetor Adler-32 conhecido.

## Bloco RSA em plaintext

O encoder monta exatamente 128 bytes antes da criptografia: zero inicial, quatro palavras XTEA little-endian, flag GM desabilitada, chave de sessão e personagem como strings `u16 + bytes`, timestamp, byte aleatório, extensão opcional vazia e padding zero. O cliente não anuncia identidade ou versão de outro cliente. Entradas vazias, strings não representáveis e payload maior que o bloco são rejeitados.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 93`. Os sete testes adicionais cobrem string com prefixo `u16`, layout completo do bloco, campos obrigatórios vazios, comprimento de string não representável, excesso do bloco RSA e preenchimento do limite exato de 128 bytes.

## Criptografia RSA bruta

O bloco completo é interpretado como inteiro big-endian e elevado ao expoente público `65537` módulo a chave OpenTibia de 1024 bits, sem padding, em conformidade com o cliente e o servidor fixados acima. A operação usa diretamente o componente criptográfico OpenSSL, agora declarado como dependência do projeto, e nunca recebe a chave privada. Tamanho diferente de 128 bytes, chave pública inválida e mensagem maior ou igual ao módulo são falhas explícitas.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 98`. Os cinco testes adicionais cobrem vetor OpenTibia conhecido, identidade matemática para o valor um, tamanho incorreto, chave/expoente inválidos e mensagem fora do módulo. A criptografia ainda não está acoplada à montagem do pacote nem ao transporte.

## Pacote completo de login

O encoder do pacote compõe o frame moderno inteiro sem acessar a rede. O corpo contém Adler-32, identificador `0x000A`, sistema Windows neutro `2`, a versão única do cliente `1525` escrita nos dois campos numéricos exigidos pelo protocolo, texto `"1525"` gerado dessa mesma constante, identificador de assets fornecido pela aplicação, preview state zero e o bloco RSA criptografado. Não existe uma configuração separada de versão do servidor: incompatibilidade é decisão do servidor. Um padding zero final satisfaz o contrato moderno `(bodySize - 4) % 8 == 0`; com identificador de assets de quatro bytes, o exemplo ocupa 156 bytes de corpo e 158 bytes com o cabeçalho externo.

Validação externa de 2026-09-23: após remover a identidade do cliente de referência e centralizar a versão do projeto em uma única constante compartilhada pela autenticação e pelo handshake, o responsável informou `100% tests passed, 0 tests failed out of 103`. Os cinco testes adicionais verificam layout e checksum completos, determinismo, metadados vazios, limite `u16` e propagação de bloco de login inválido. O resultado ainda é apenas um buffer pronto para envio: conexão, escrita no transporte e ativação posterior de XTEA não fazem parte deste incremento.

## Primitiva XTEA da sessão

A transformação XTEA opera em blocos independentes de 8 bytes, com quatro palavras de chave de 32 bits, palavras little-endian e 32 rodadas. Entradas desalinhadas são rejeitadas; padding, sequência, checksum e envelope permanecem responsabilidades das camadas de sessão e framing. O módulo não gera chaves e não mantém estado global.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 107`. Os quatro testes adicionais cobrem vetores conhecidos de cifragem e decifragem, múltiplos blocos com round-trip e rejeição de entrada desalinhada. A primitiva ainda não foi ativada no transporte.

## Framing criptografado da sessão

Após o login, um pacote de saída recebe sequência entre `1` e `0x7FFFFFFF`, byte frontal com o tamanho do padding, padding traseiro até múltiplo de 8 e cifragem XTEA. A sequência permanece fora da área cifrada e o conjunto é envolvido pelo frame moderno. Na entrada, o decoder exige a sequência esperada, decifra somente a região XTEA e remove o padding validado. Sequência zero, desalinhamento, padding inválido e salto de sequência são falhas explícitas.

O bit alto da palavra de sequência sinaliza compressão. Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 115`. Os oito testes adicionais cobrem round-trip com framing, limites de padding, payload vazio, sequências inválidas ou inesperadas, detecção de compressão, corpo malformado e padding inválido.

## Orquestração TCP do handshake

O serviço de sessão do mundo conecta pelo transporte TCP limitado, acumula frames fragmentados, valida o desafio, monta e envia o login e somente então aceita frames de sessão XTEA com sequência iniciada em `1`. A primeira resposta válida muda o estado para ativo e publica apenas o payload já decifrado. Falhas de transporte, frame, desafio, montagem, envio e sessão possuem categorias próprias; mensagens de falha não incluem chave, sessão ou personagem.

A chave XTEA é fornecida ao pedido de sessão, permitindo geração externa e testes determinísticos, mas nunca é emitida ou registrada pelo serviço. Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 119`. Os quatro testes de integração locais cobrem handshake e primeiro payload, fragmentação do desafio, desafio inválido e recusa de início concorrente. Esse aceite isolado não declara entrada real no mundo.

## Descompressão limitada da sessão

Quando o bit alto da sequência está presente, o payload decifrado é tratado como um stream raw DEFLATE independente, igual ao produzido pelo servidor. Cada pacote reinicia o estado do zlib, precisa terminar exatamente no fim da entrada e pode expandir no máximo 65.500 bytes. Entrada vazia, stream truncado, dados residuais e expansão acima do limite são falhas explícitas; nenhum buffer de saída é dimensionado a partir de um tamanho remoto não confiável.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 124`. Os cinco novos testes unitários cobrem uma fixture raw DEFLATE conhecida, limite exato e excedido, truncamento, dados residuais e argumentos vazios ou inválidos. O teste existente de compressão do framing passou a confirmar descompressão e entrega do payload original.

## Respostas iniciais do mundo

O decoder inicial reconhece os opcodes de login pendente (`0x0A`), entrada no mundo (`0x0F`), atualização requerida (`0x11`), erro (`0x14`), aviso (`0x15`), fila (`0x16`), sucesso de login (`0x17`), encerramento de sessão (`0x18`), configuração de bug report (`0x1A`), restrições Exiva (`0xCA`) e horário (`0xEF`). Os valores ficam centralizados no enum `GameServerOpcode`; o decoder e o serviço usam os nomes desse catálogo. Strings usam prefixo `u16`; sucesso lê player ID, server beat, três valores de velocidade no formato precisão + `u32`, flags de PvP/expert, URL e tamanho do pacote de moedas da loja e flag Exiva. A leitura devolve bytes consumidos sem engolir o opcode subsequente.

O serviço percorre sequencialmente respostas completas do payload e ignora, com limites validados, mensagens auxiliares conhecidas até encontrar entrada no mundo. `0x0F` promove a sessão a `Active`. O cabeçalho do pacote de mapa (`0x64`) é decodificado para obter centro x/y/andar, e o restante da descrição dos tiles continua disponível ao consumidor bruto. Aviso e espera são sinais explícitos; rejeição e atualização requerida encerram com categorias próprias. A resposta de fila preserva o estado `Waiting` após o servidor fechar o TCP, e uma nova chamada a `start` inicia uma tentativa subsequente. O opcode `0x18` é informação de encerramento de sessão com um byte de motivo, não um resultado de token de autenticação.

Validação externa de 2026-09-24: o responsável informou `100% tests passed, 0 tests failed out of 132` após implementar e percorrer a sequência de respostas auxiliares até `0x0F`, além das correções para `0x18` e nova tentativa após fila. Oito testes unitários cobrem layouts e limites; a integração valida a resposta de sucesso e `LoginAccepted`. A decodificação do cabeçalho `0x64` para a posição central foi adicionada depois desse resultado e aguarda validação. Os tiles continuam publicados brutos, sem interpretação semântica nem afirmação de mapa carregado.
