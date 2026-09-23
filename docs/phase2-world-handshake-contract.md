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

Após validar o desafio, o cliente monta o login com identificador de protocolo `0x000A`, sistema operacional, versão de protocolo 1525, versão de cliente de 32 bits, duas strings de versão/asset e preview state. O bloco RSA de 128 bytes começa com zero, contém quatro palavras XTEA, flag de game master, chave de sessão, personagem, timestamp e byte aleatório, seguido pelo probe OTCv8 e padding. O servidor descriptografa esse bloco antes de habilitar XTEA.

A escrita exata do bloco RSA, sua chave pública, o probe estendido, checksum/sequência externa e a ativação da criptografia serão implementados em incrementos separados. Nenhum pacote de login foi produzido ou enviado nesta etapa.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 82`. Os seis testes adicionais cobrem uma fixture moderna conhecida, comprimento inesperado, checksum inválido, marcador inicial inválido, opcode inválido e trailer inválido.

## Catálogo e primitivas binárias

Constantes do handshake ficam em um catálogo interno com nomes de domínio, incluindo tamanhos, offsets, marcadores, opcode, versão, identificador do login e dimensões de RSA/XTEA. Leitura e escrita little-endian e Adler-32 ficam em módulos binários reutilizáveis. Fixtures conhecidas mantêm bytes literais como evidência independente; mutações e código de produção usam os nomes do catálogo.

Validação externa de 2026-09-23: após a extração do catálogo e das primitivas binárias, o responsável informou `100% tests passed, 0 tests failed out of 86`. Os quatro testes adicionais cobrem leitura little-endian, recusa de leitura fora dos limites, escrita little-endian e um vetor Adler-32 conhecido.

## Bloco RSA em plaintext

O encoder monta exatamente 128 bytes antes da criptografia: zero inicial, quatro palavras XTEA little-endian, flag GM desabilitada, chave de sessão e personagem como strings `u16 + bytes`, timestamp, byte aleatório, probe `OTCv8`, versão 1525 e padding zero. O primeiro incremento inclui somente campos efetivamente consumidos pelo servidor atual; extensões do cliente de referência que o parser atual não consome não são inventadas. Entradas vazias, strings não representáveis e payload maior que o bloco são rejeitados.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 93`. Os sete testes adicionais cobrem string com prefixo `u16`, layout completo do bloco, campos obrigatórios vazios, comprimento de string não representável, excesso do bloco RSA e preenchimento do limite exato de 128 bytes.

## Criptografia RSA bruta

O bloco completo é interpretado como inteiro big-endian e elevado ao expoente público `65537` módulo a chave OpenTibia de 1024 bits, sem padding, em conformidade com o cliente e o servidor fixados acima. A operação usa diretamente o componente criptográfico OpenSSL, agora declarado como dependência do projeto, e nunca recebe a chave privada. Tamanho diferente de 128 bytes, chave pública inválida e mensagem maior ou igual ao módulo são falhas explícitas.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 98`. Os cinco testes adicionais cobrem vetor OpenTibia conhecido, identidade matemática para o valor um, tamanho incorreto, chave/expoente inválidos e mensagem fora do módulo. A criptografia ainda não está acoplada à montagem do pacote nem ao transporte.
